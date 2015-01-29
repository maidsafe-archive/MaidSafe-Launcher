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
  static maidsafe::test::TestPath test_path(
      maidsafe::test::CreateTestPath("MaidSafe_TestLauncher"));
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
    : asio_service_(1),
      maid_client_(),
      account_handler_(),
      account_mutex_(),
      app_handler_(),
      rollback_snapshot_() {
  account_handler_.Login(ConvertToCredentials(keyword, pin, password), account_getter);
  maid_client_ = nfs_client::MaidClient::MakeShared(account_handler_.account_->passport->GetMaid());
  app_handler_.Initialise(GetConfigFilePath(), account_handler_.account_.get(), &account_mutex_);
  // Auto-start any relevant apps
  std::set<AppDetails> local_apps(app_handler_.GetApps(true));
  for (const auto& app : local_apps) {
    if (app.auto_start)
      LaunchApp(app.name, app.path, app.args);
  }
}

Launcher::Launcher(Keyword keyword, Pin pin, Password password,
                   passport::MaidAndSigner&& maid_and_signer)
    : asio_service_(1),
      maid_client_(nfs_client::MaidClient::MakeShared(maid_and_signer)),
      account_handler_(Account{maid_and_signer}, ConvertToCredentials(keyword, pin, password),
                       *maid_client_),
      account_mutex_(),
      app_handler_(),
      rollback_snapshot_() {
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
  SaveSession(true);
  maid_client_->Stop();
}

void Launcher::AddApp(std::string app_name, boost::filesystem::path app_path, std::string app_args,
                      SerialisedData app_icon, bool auto_start) {
  AddOrLinkApp(std::move(app_name), std::move(app_path), std::move(app_args), &app_icon,
               auto_start);
}

void Launcher::LinkApp(std::string app_name, boost::filesystem::path app_path, std::string app_args,
                       bool auto_start) {
  AddOrLinkApp(std::move(app_name), std::move(app_path), std::move(app_args), nullptr, auto_start);
}

void Launcher::AddOrLinkApp(std::string app_name, boost::filesystem::path app_path,
                            std::string app_args, const SerialisedData* const app_icon,
                            bool auto_start) {
  auto snapshot(app_handler_.GetSnapshot());
  on_scope_exit strong_guarantee{[&] { RevertAppHandler(std::move(snapshot)); }};
  AppDetails app{app_handler_.AddOrLinkApp(std::move(app_name), std::move(app_path),
                                           std::move(app_args), app_icon, auto_start)};
  if (app_icon) {  // we're adding the app
                   // TODO(Fraser#5#): 2015-01-23 - Add the app.dir to maid_client_
  }
  if (!rollback_snapshot_)
    rollback_snapshot_ = snapshot;
  strong_guarantee.Release();
}

void Launcher::UpdateAppName(const std::string& app_name, const std::string& new_name) {
  auto snapshot(app_handler_.GetSnapshot());
  on_scope_exit strong_guarantee{[&] { RevertAppHandler(std::move(snapshot)); }};
  app_handler_.UpdateName(app_name, new_name);
  if (!rollback_snapshot_)
    rollback_snapshot_ = snapshot;
  strong_guarantee.Release();
}

void Launcher::UpdateAppPath(const std::string& app_name, const boost::filesystem::path& new_path) {
  auto snapshot(app_handler_.GetSnapshot());
  on_scope_exit strong_guarantee{[&] { RevertAppHandler(std::move(snapshot)); }};
  app_handler_.UpdatePath(app_name, new_path);
  // No need to keep snapshot since app path isn't held in the account, so no need to rollback.
  strong_guarantee.Release();
}

void Launcher::UpdateAppArgs(const std::string& app_name, const std::string& new_args) {
  auto snapshot(app_handler_.GetSnapshot());
  on_scope_exit strong_guarantee{[&] { RevertAppHandler(std::move(snapshot)); }};
  app_handler_.UpdateArgs(app_name, new_args);
  // No need to keep snapshot since app args aren't held in the account, so no need to rollback.
  strong_guarantee.Release();
}

void Launcher::UpdateAppSafeDriveAccess(const std::string& app_name,
                                        DirectoryInfo::AccessRights new_rights) {
  auto snapshot(app_handler_.GetSnapshot());
  on_scope_exit strong_guarantee{[&] { RevertAppHandler(std::move(snapshot)); }};
  // TODO(Fraser#5#): 2015-01-20 - Replace "SafeDrive" string with constant defined... where?
  DirectoryInfo safe_dir("SafeDrive", drive::ParentId(), drive::DirectoryId(), new_rights);
  {
    std::lock_guard<std::mutex> lock{account_mutex_};
    // TODO(Fraser#5#): 2015-01-20 - Confirm with Lee if these IDs should be used.
    safe_dir.parent_id = drive::ParentId{account_handler_.account_->unique_user_id};
    safe_dir.directory_id = account_handler_.account_->root_parent_id;
  }
  app_handler_.UpdatePermittedDirs(app_name, safe_dir);
  if (!rollback_snapshot_)
    rollback_snapshot_ = snapshot;
  strong_guarantee.Release();
}

void Launcher::UpdateAppIcon(const std::string& app_name, const SerialisedData& new_icon) {
  auto snapshot(app_handler_.GetSnapshot());
  on_scope_exit strong_guarantee{[&] { RevertAppHandler(std::move(snapshot)); }};
  app_handler_.UpdateIcon(app_name, new_icon);
  if (!rollback_snapshot_)
    rollback_snapshot_ = snapshot;
  strong_guarantee.Release();
}

void Launcher::UpdateAppAutoStart(const std::string& app_name, bool new_auto_start_value) {
  auto snapshot(app_handler_.GetSnapshot());
  on_scope_exit strong_guarantee{[&] { RevertAppHandler(std::move(snapshot)); }};
  app_handler_.UpdateAutoStart(app_name, new_auto_start_value);
  // No need to keep snapshot since auto_start isn't held in the account, so no need to rollback.
  strong_guarantee.Release();
}

void Launcher::RemoveAppLocally(const std::string& app_name) {
  auto snapshot(app_handler_.GetSnapshot());
  on_scope_exit strong_guarantee{[&] { RevertAppHandler(std::move(snapshot)); }};
  app_handler_.RemoveLocally(app_name);
  // No need to keep snapshot since this only applies to apps in the local config file, so no need
  // to rollback.
  strong_guarantee.Release();
}

void Launcher::RemoveAppFromNetwork(const std::string& app_name) {
  auto snapshot(app_handler_.GetSnapshot());
  on_scope_exit strong_guarantee{[&] { RevertAppHandler(std::move(snapshot)); }};
  app_handler_.RemoveFromNetwork(app_name);
  if (!rollback_snapshot_)
    rollback_snapshot_ = snapshot;
  strong_guarantee.Release();
}

void Launcher::LaunchApp(const std::string& app_name) {
  auto path_and_args(app_handler_.GetPathAndArgs(app_name));
  LaunchApp(app_name, path_and_args.first, path_and_args.second);
}

void Launcher::LaunchApp(const std::string& /*app_name*/, const boost::filesystem::path& /*path*/,
                         const std::string& /*args*/) {
  //  tcp::Port listening_port{StartListening()};
}

void Launcher::SaveSession(bool force) {
  std::lock_guard<std::mutex> lock{account_mutex_};
  if (!force && !rollback_snapshot_)
    return;
  account_handler_.Save(*maid_client_);
  rollback_snapshot_ = boost::none;
}

void Launcher::RevertToLastSavedSession() {
  std::lock_guard<std::mutex> lock{account_mutex_};
  if (!rollback_snapshot_)
    return;
  RevertAppHandler(*rollback_snapshot_);
  rollback_snapshot_ = boost::none;
}

void Launcher::RevertAppHandler(AppHandler::Snapshot snapshot) {
  try {
    app_handler_.ApplySnapshot(std::move(snapshot));
  } catch (const common_error&) {
    LOG(kError) << "Failed to revert operation.";
    BOOST_THROW_EXCEPTION(MakeError(CommonErrors::filesystem_io_error));
  }
}

tcp::Port Launcher::StartListening() { return 0; }

}  // namespace launcher

}  // namespace maidsafe
