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

#include "maidsafe/launcher/app_handler.h"

#include <algorithm>
#include <cassert>
#include <iterator>
#include <string>

#include "boost/filesystem/operations.hpp"
#include "cereal/types/string.hpp"
#include "cereal/types/set.hpp"

#include "maidsafe/common/convert.h"
#include "maidsafe/common/log.h"
#include "maidsafe/common/make_unique.h"
#include "maidsafe/common/utils.h"
#include "maidsafe/common/serialisation/types/boost_filesystem.h"

#include "maidsafe/launcher/account.h"
#include "maidsafe/launcher/app_details.h"

namespace fs = boost::filesystem;

namespace maidsafe {

namespace launcher {

namespace {

void UpdateAppDetails(AppDetails& app, const AppName* const new_name,
                      const boost::filesystem::path* const new_path, const AppArgs* const new_args,
                      const DirectoryInfo* const new_dir, const SerialisedData* const new_icon,
                      const bool* const new_auto_start_value) {
  // Check exactly one of the six pointers is non-null.
  assert(int(!!new_name) + int(!!new_path) + int(!!new_args) + int(!!new_dir) + int(!!new_icon) +
             int(!!new_auto_start_value) ==
         1);

  if (new_name) {
    app.name = *new_name;
  } else if (new_path) {
    app.path = *new_path;
  } else if (new_args) {
    app.args = *new_args;
  } else if (new_dir) {
    app.permitted_dirs.erase(*new_dir);
    if (new_dir->access_rights != DirectoryInfo::AccessRights::kNone)
      app.permitted_dirs.insert(*new_dir);
  } else if (new_icon) {
    app.icon = *new_icon;
  } else {
    app.auto_start = *new_auto_start_value;
  }
}

}  // unnamed namespace

AppHandler::AppHandler()
    : account_(nullptr),
      account_mutex_(nullptr),
      config_file_path_(),
      local_apps_(),
      non_local_apps_(),
      mutex_() {}

void AppHandler::Initialise(fs::path config_file_path, Account* account,
                            std::mutex* account_mutex) {
  // Check 'Initialise' hasn't already been called.
  assert(!account_ && !account_mutex_);

  assert(account && account_mutex);

  std::lock(*account_mutex, mutex_);
  std::lock_guard<std::mutex> account_lock(*account_mutex, std::adopt_lock);
  std::lock_guard<std::mutex> lock(mutex_, std::adopt_lock);
  account_ = account;
  account_mutex_ = account_mutex;
  config_file_path_ = std::move(config_file_path);

  // Initialise the non-local apps from the account and the local ones from the config file
  non_local_apps_ = account_->apps;
  if (!fs::exists(config_file_path_.parent_path()))
    fs::create_directories(config_file_path_.parent_path());
  else
    ReadConfigFile();

  // Iterate through each set of apps.  For any app which appears as local *and* non-local, its info
  // is merged to the copy in the local set and it is removed from the non-local set.  Any app which
  // appears as local only is removed.
  auto local_itr(local_apps_.begin());
  auto non_local_itr(non_local_apps_.begin());
  while (local_itr != local_apps_.end() && non_local_itr != non_local_apps_.end()) {
    if (*local_itr < *non_local_itr) {  // local only
      local_itr = local_apps_.erase(local_itr);
    } else if (*non_local_itr < *local_itr) {  // non-local only
      ++non_local_itr;
    } else {  // both local and non-local
      AppDetails local(*local_itr);
      local.permitted_dirs = non_local_itr->permitted_dirs;
      local_itr = local_apps_.erase(local_itr);
      local_apps_.insert(std::move(local));
      non_local_itr = non_local_apps_.erase(non_local_itr);
    }
  }
}

AppHandler::Snapshot AppHandler::GetSnapshot() const {
  Snapshot snapshot;
  std::lock_guard<std::mutex> lock{mutex_};
  snapshot.local_apps = local_apps_;
  snapshot.non_local_apps = non_local_apps_;
  try {
    // Set up copy of config file.  Path is held in a shared_ptr with a custom deleter which also
    // tries to remove the copied file as well as deleting the path pointer.
    snapshot.config_file.reset(
        new fs::path(config_file_path_.parent_path() / RandomAlphaNumericString(10)),
        [](fs::path* delete_path) {
          if (!delete_path->empty() && fs::exists(*delete_path)) {
            boost::system::error_code ec;
            if (!fs::remove(*delete_path, ec))
              LOG(kWarning) << "Failed to remove " << *delete_path;
            if (ec)
              LOG(kWarning) << "Error removing " << *delete_path << "  " << ec.message();
          }
          delete delete_path;
        });
    if (fs::exists(config_file_path_))
      fs::copy_file(config_file_path_, *snapshot.config_file);
  } catch (const std::exception& e) {
    LOG(kError) << "Failed to copy config file from " << config_file_path_ << " to "
                << *snapshot.config_file << ": " << e.what();
    BOOST_THROW_EXCEPTION(MakeError(CommonErrors::filesystem_io_error));
  }
  return snapshot;
}

void AppHandler::ApplySnapshot(Snapshot snapshot) {
  auto locks(AcquireLocks());

  // Reset account
  account_->apps.clear();
  std::set_union(snapshot.local_apps.begin(), snapshot.local_apps.end(),
                 snapshot.non_local_apps.begin(), snapshot.non_local_apps.end(),
                 std::inserter(account_->apps, account_->apps.end()));

  // Reset app sets
  local_apps_ = std::move(snapshot.local_apps);
  non_local_apps_ = std::move(snapshot.non_local_apps);

  // Replace config file
  try {
    if (fs::exists(*snapshot.config_file))
      fs::rename(*snapshot.config_file, config_file_path_);
    else
      fs::remove(config_file_path_);
  } catch (const std::exception& e) {
    LOG(kError) << "Failed to move config file from " << *snapshot.config_file << " to "
                << config_file_path_ << ": " << e.what();
    BOOST_THROW_EXCEPTION(MakeError(CommonErrors::filesystem_io_error));
  }
}

std::set<AppDetails> AppHandler::GetApps(bool locally_available) const {
  std::lock_guard<std::mutex> lock{mutex_};
  return locally_available ? local_apps_ : non_local_apps_;
}

AppDetails AppHandler::AddOrLinkApp(AppName app_name, fs::path app_path, AppArgs app_args,
                                    const SerialisedData* const app_icon, bool auto_start) {
  AppDetails app;
  app.name = app_name;
  app.path = app_path;
  app.args = app_args;
  app.auto_start = auto_start;

  auto locks(AcquireLocks());
  auto account_itr(account_->apps.find(app));

  // We're linking the app if 'app_icon' is null, otherwise we're adding the app.
  if (app_icon) {
    app.icon = *app_icon;
    Add(app, account_itr);
  } else {
    Link(app, account_itr);
  }

  WriteConfigFile();
  return app;
}

void AppHandler::Add(AppDetails& app, std::set<AppDetails>::iterator account_itr) {
  // Adding requires app to not exist in the account
  if (account_itr != account_->apps.end()) {
    LOG(kError) << "App \"" << app.name << "\" already exists in Account - can't add.";
    BOOST_THROW_EXCEPTION(MakeError(CommonErrors::unable_to_handle_request));
  }
  assert(local_apps_.count(app) == 0 && non_local_apps_.count(app) == 0);

  app.permitted_dirs.emplace(std::string("/") + app.name, account_->root_parent_id, MakeIdentity(),
                             DirectoryInfo::AccessRights::kReadWrite);

  // Add to account and local set
  account_->apps.insert(app);
  local_apps_.insert(app);
}

void AppHandler::Link(AppDetails& app, std::set<AppDetails>::iterator account_itr) {
  // Linking requires app to exist in non-local set and not exist in local set
  auto non_local_itr(non_local_apps_.find(app));
  if (local_apps_.count(app) != 0 || non_local_itr != non_local_apps_.end()) {
    LOG(kError)
        << "App \"" << app.name
        << "\" already exists in local set, or doesn't exist in non-local set - can't link.";
    BOOST_THROW_EXCEPTION(MakeError(CommonErrors::unable_to_handle_request));
  }

  // If app is in non-local set, it must also be in Account.
  assert(account_itr != account_->apps.end());

  app.permitted_dirs = account_itr->permitted_dirs;
  app.icon = account_itr->icon;

  // Add to local and remove from non-local
  local_apps_.insert(app);
  non_local_apps_.erase(non_local_itr);
}

void AppHandler::UpdateName(const AppName& app_name, const AppName& new_name) {
  Update(app_name, &new_name, nullptr, nullptr, nullptr, nullptr, nullptr);
}

void AppHandler::UpdatePath(const AppName& app_name, const fs::path& new_path) {
  Update(app_name, nullptr, &new_path, nullptr, nullptr, nullptr, nullptr);
}

void AppHandler::UpdateArgs(const AppName& app_name, const AppArgs& new_args) {
  Update(app_name, nullptr, nullptr, &new_args, nullptr, nullptr, nullptr);
}

void AppHandler::UpdatePermittedDirs(const AppName& app_name, const DirectoryInfo& new_dir) {
  Update(app_name, nullptr, nullptr, nullptr, &new_dir, nullptr, nullptr);
}

void AppHandler::UpdateIcon(const AppName& app_name, const SerialisedData& new_icon) {
  Update(app_name, nullptr, nullptr, nullptr, nullptr, &new_icon, nullptr);
}

void AppHandler::UpdateAutoStart(const AppName& app_name, bool new_auto_start_value) {
  Update(app_name, nullptr, nullptr, nullptr, nullptr, nullptr, &new_auto_start_value);
}

void AppHandler::RemoveLocally(const AppName& app_name) {
  AppDetails app;
  app.name = app_name;
  std::lock_guard<std::mutex> lock{mutex_};
  if (local_apps_.erase(app) != 1U) {
    LOG(kError) << "App \"" << app_name << "\" doesn't exist in AppHandler's local apps set.";
    BOOST_THROW_EXCEPTION(MakeError(CommonErrors::no_such_element));
  }
  WriteConfigFile();
}

void AppHandler::RemoveFromNetwork(const AppName& app_name) {
  AppDetails app;
  app.name = app_name;
  auto locks(AcquireLocks());

  // Handle non-local set
  if (non_local_apps_.erase(app) != 1U) {
    LOG(kError) << "App \"" << app_name << "\" doesn't exist in AppHandler's non-local apps set.";
    BOOST_THROW_EXCEPTION(MakeError(CommonErrors::no_such_element));
  }

  // Handle Account
  if (account_->apps.erase(app) != 1U) {
    LOG(kError) << "App \"" << app_name << "\" doesn't exist in Account.";
    BOOST_THROW_EXCEPTION(MakeError(CommonErrors::no_such_element));
  }

  WriteConfigFile();
}

std::pair<fs::path, AppArgs> AppHandler::GetPathAndArgs(AppName app_name) const {
  AppDetails app;
  app.name = app_name;
  std::lock_guard<std::mutex> lock{mutex_};
  auto itr = local_apps_.find(app);
  if (itr == local_apps_.end()) {
    LOG(kError) << "App \"" << app_name << "\" doesn't exist in AppHandler's local apps set.";
    BOOST_THROW_EXCEPTION(MakeError(CommonErrors::no_such_element));
  }
  return std::make_pair(itr->path, itr->args);
}

std::pair<AppHandler::LockGuardPtr, AppHandler::LockGuardPtr> AppHandler::AcquireLocks() const {
  std::lock(*account_mutex_, mutex_);
  return std::make_pair(
      maidsafe::make_unique<std::lock_guard<std::mutex>>(*account_mutex_, std::adopt_lock),
      maidsafe::make_unique<std::lock_guard<std::mutex>>(mutex_, std::adopt_lock));
}

void AppHandler::ReadConfigFile() {
  if (!fs::exists(config_file_path_))
    return;
  assert(fs::is_regular_file(config_file_path_));

  // Read from file.
  crypto::CipherText encrypted_contents{NonEmptyString{ReadFile(config_file_path_).value()}};

  // Decrypt and uncompress the contents.
  auto serialised_contents(crypto::Uncompress(crypto::CompressedText(
      crypto::SymmDecrypt(encrypted_contents, account_->config_file_aes_key_and_iv))));

  // Parse the set of local apps.
  std::stringstream str_stream{convert::ToString(serialised_contents.string())};
  std::size_t app_count(ConvertFromStream<std::size_t>(str_stream));
  for (std::size_t i{0}; i < app_count; ++i) {
    AppDetails app_details;
    ConvertFromStream(str_stream, app_details.name, app_details.path, app_details.args,
                      app_details.auto_start);
    local_apps_.insert(std::move(app_details));
  }
}

void AppHandler::WriteConfigFile() const {
  // Serialise the set of local apps.  Omit their 'permitted_dirs' and 'icon' fields since they're
  // held in the serialised Account.
  std::string serialised_contents(ConvertToString(local_apps_.size()));
  for (const auto& app : local_apps_)
    serialised_contents += ConvertToString(app.name, app.path, app.args, app.auto_start);

  // Compress and encrypt the serialised contents.
  auto encrypted_contents(crypto::SymmEncrypt(
      crypto::Compress(crypto::UncompressedText(convert::ToByteVector(serialised_contents)), 9)
          .data,
      account_->config_file_aes_key_and_iv));

  // Write to file.
  if (!WriteFile(config_file_path_, encrypted_contents->string())) {
    LOG(kError) << "Failed to save config file at " << config_file_path_;
    BOOST_THROW_EXCEPTION(MakeError(CommonErrors::filesystem_io_error));
  }
}

void AppHandler::Update(const AppName& app_name, const AppName* const new_name,
                        const boost::filesystem::path* const new_path,
                        const AppArgs* const new_args, const DirectoryInfo* const new_dir,
                        const SerialisedData* const new_icon,
                        const bool* const new_auto_start_value) {
  AppDetails current_app;
  current_app.name = app_name;
  auto locks(AcquireLocks());

  // Handle local or non-local set
  std::set<AppDetails>* app_set{nullptr};
  auto itr(local_apps_.find(current_app));
  if (itr == local_apps_.end()) {
    itr = non_local_apps_.find(current_app);
    if (itr == non_local_apps_.end()) {
      LOG(kError) << "App \"" << app_name << "\" doesn't exist in AppHandler sets.";
      BOOST_THROW_EXCEPTION(MakeError(CommonErrors::no_such_element));
    }
    app_set = &non_local_apps_;
  } else {
    app_set = &local_apps_;
  }
  AppDetails updated_app{*itr};
  UpdateAppDetails(updated_app, new_name, new_path, new_args, new_dir, new_icon,
                   new_auto_start_value);
  app_set->erase(itr);
  app_set->insert(updated_app);

  // Handle Account
  itr = account_->apps.find(current_app);
  if (itr == account_->apps.end()) {
    LOG(kError) << "App \"" << app_name << "\" doesn't exist in Account.";
    BOOST_THROW_EXCEPTION(MakeError(CommonErrors::no_such_element));
  }
  account_->apps.erase(itr);
  account_->apps.insert(std::move(updated_app));

  WriteConfigFile();
}

}  // namespace launcher

}  // namespace maidsafe
