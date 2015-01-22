/*  Copyright 2015 MaidSafe.net limited

    This MaidSafe Software is licensed to you under (1) the MaidSafe.net Commercial License,
    version 1.0 or later, or (2) The General Public License (GPL), version 3, depending on which
    licence you accepted on initial access to the Software (the "Licences").

    By contributing code to the MaidSafe Software, or to this project generally, you agree to be
    bound by the terms of the MaidSafe Contributor Agreement, version 1.0, found in the root
    directory of this project at LICENSE, COPYING and CONTRIBUTOR respectively and also
    available at: http://www.maidsafe.net/licenses

    Unless required by applicable law or agreed to in writing, the MaidSafe Software distributed
    under the GPL Licence is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS
    OF ANY KIND, either express or implied.

    See the Licences for the specific language governing permissions and limitations relating to
    use of the MaidSafe Software.                                                                 */

#include "maidsafe/launcher/launcher.h"

#include <utility>

#include "maidsafe/common/application_support_directories.h"
#include "maidsafe/common/error.h"
#include "maidsafe/common/log.h"
#ifdef TESTING
#include "maidsafe/common/test.h"
#endif

#include "maidsafe/launcher/account.h"
#include "maidsafe/launcher/account_getter.h"

namespace maidsafe {

namespace launcher {

namespace {

boost::filesystem::path GetConfigFilePath() {
#ifdef TESTING
  static test::TestPath test_path(test::CreateTestPath("MaidSafe_TestLauncher"));
  return *test_path / "config.txt";
#else
  return GetUserAppDir() / "config";
#endif
}

authentication::UserCredentials ConvertToCredentials(Launcher::Keyword keyword, Launcher::Pin pin,
                                                     Launcher::Password password) {
  authentication::UserCredentials user_credentials;
  user_credentials.keyword =
      maidsafe::make_unique<authentication::UserCredentials::Keyword>(keyword);
  user_credentials.pin =
      maidsafe::make_unique<authentication::UserCredentials::Pin>(std::to_string(pin));
  user_credentials.password =
      maidsafe::make_unique<authentication::UserCredentials::Password>(password);
  return user_credentials;
}

}  // unamed namespace

Launcher::Launcher(Keyword keyword, Pin pin, Password password, AccountGetter& account_getter)
    : maid_node_nfs_(), account_handler_(), account_mutex_(), app_handler_() {
  account_handler_.Login(ConvertToCredentials(keyword, pin, password), account_getter);
  maid_node_nfs_ =
      nfs_client::MaidNodeNfs::MakeShared(account_handler_.account_->passport->GetMaid());
  app_handler_.Initialise(GetConfigFilePath(), account_handler_.account_.get(), &account_mutex_);
}

Launcher::Launcher(Keyword keyword, Pin pin, Password password,
                   passport::MaidAndSigner&& maid_and_signer)
    : maid_node_nfs_(nfs_client::MaidNodeNfs::MakeShared(maid_and_signer)),
      account_handler_(Account{maid_and_signer}, ConvertToCredentials(keyword, pin, password),
                       *maid_node_nfs_),
      account_mutex_(),
      app_handler_() {
  app_handler_.Initialise(GetConfigFilePath(), account_handler_.account_.get(), &account_mutex_);
}

std::unique_ptr<Launcher> Launcher::Login(Keyword keyword, Pin pin, Password password) {
  std::unique_ptr<AccountGetter> account_getter{AccountGetter::CreateAccountGetter().get()};
  // Can't use make_unique since Launcher's c'tor is private.
  return std::move(
      std::unique_ptr<Launcher>(new Launcher{keyword, pin, password, *account_getter}));
}

std::unique_ptr<Launcher> Launcher::CreateAccount(Keyword keyword, Pin pin, Password password) {
  // Can't use make_unique since Launcher's c'tor is private.
  return std::move(std::unique_ptr<Launcher>(
      new Launcher{keyword, pin, password, passport::CreateMaidAndSigner()}));
  // TODO(Fraser#5#): 2015-01-16 - create safe drive folder
}

void Launcher::LogoutAndStop() {
  SaveSession();
  maid_node_nfs_->Stop();
}

void Launcher::AddApp(std::string app_name, boost::filesystem::path app_path,
                      std::string app_args) {
  auto snapshot(app_handler_.GetSnapshot());
  on_scope_exit strong_guarantee{[&] { RevertOperation(std::move(snapshot)); }};
  app_handler_.Add(std::move(app_name), std::move(app_path), std::move(app_args));
  SaveSession();
  strong_guarantee.Release();
}

void Launcher::UpdateAppName(const std::string& app_name, const std::string& new_name) {
  auto snapshot(app_handler_.GetSnapshot());
  on_scope_exit strong_guarantee{ [&] { RevertOperation(std::move(snapshot)); } };
  app_handler_.UpdateName(app_name, new_name);
  SaveSession();
  strong_guarantee.Release();
}

void Launcher::UpdateAppPath(const std::string& app_name, const boost::filesystem::path& new_path) {
  auto snapshot(app_handler_.GetSnapshot());
  on_scope_exit strong_guarantee{ [&] { RevertOperation(std::move(snapshot)); } };
  app_handler_.UpdatePath(app_name, new_path);
  // No need to save account since app path isn't held in the account.
  strong_guarantee.Release();
}

void Launcher::UpdateAppArgs(const std::string& app_name, const std::string& new_args) {
  auto snapshot(app_handler_.GetSnapshot());
  on_scope_exit strong_guarantee{ [&] { RevertOperation(std::move(snapshot)); } };
  app_handler_.UpdateArgs(app_name, new_args);
  // No need to save account since app args aren't held in the account.
  strong_guarantee.Release();
}

void Launcher::UpdateAppSafeDriveAccess(const std::string& app_name,
                                        DirectoryInfo::AccessRights new_rights) {
  auto snapshot(app_handler_.GetSnapshot());
  on_scope_exit strong_guarantee{ [&] { RevertOperation(std::move(snapshot)); } };
  // TODO(Fraser#5#): 2015-01-20 - Replace "SafeDrive" string with constant defined... where?
  DirectoryInfo safe_dir("SafeDrive", drive::ParentId(), drive::DirectoryId(), new_rights);
  {
    std::lock_guard<std::mutex> lock{ account_mutex_ };
    // TODO(Fraser#5#): 2015-01-20 - Confirm with Lee if these IDs should be used.
    safe_dir.parent_id = drive::ParentId{account_handler_.account_->unique_user_id};
    safe_dir.directory_id = account_handler_.account_->root_parent_id;
  }
  app_handler_.UpdatePermittedDirs(app_name, safe_dir);
  SaveSession();
  strong_guarantee.Release();
}

void Launcher::UpdateAppIcon(const std::string& app_name, const SerialisedData& new_icon) {
  auto snapshot(app_handler_.GetSnapshot());
  on_scope_exit strong_guarantee{ [&] { RevertOperation(std::move(snapshot)); } };
  app_handler_.UpdateIcon(app_name, new_icon);
  SaveSession();
  strong_guarantee.Release();
}

void Launcher::RemoveAppLocally(const std::string& app_name) {
  app_handler_.RemoveLocally(app_name);
  // No need to save account since this only applies to apps in the local config file.
}

void Launcher::RemoveAppFromNetwork(const std::string& app_name) {
  auto snapshot(app_handler_.GetSnapshot());
  on_scope_exit strong_guarantee{ [&] { RevertOperation(std::move(snapshot)); } };
  app_handler_.RemoveFromNetwork(app_name);
  SaveSession();
  strong_guarantee.Release();
}

void Launcher::LaunchApp(const std::string& app_name) {
  app_handler_.Launch(app_name, StartListening());
}

void Launcher::SaveSession() {
  std::lock_guard<std::mutex> lock{ account_mutex_ };
  account_handler_.Save(*maid_node_nfs_);
}

void Launcher::RevertOperation(AppHandler::Snapshot snapshot) {
  try {
    app_handler_.ApplySnapshot(std::move(snapshot));
  }
  catch (const common_error&) {
    LOG(kError) << "Failed to revert operation.";
    BOOST_THROW_EXCEPTION(MakeError(CommonErrors::filesystem_io_error));
  }
}

tcp::Port Launcher::StartListening() { return 0; }

}  // namespace launcher

}  // namespace maidsafe
