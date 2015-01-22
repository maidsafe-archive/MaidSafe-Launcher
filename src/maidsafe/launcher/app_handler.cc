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

#include "boost/filesystem/operations.hpp"
#include "cereal/types/string.hpp"
#include "cereal/types/set.hpp"

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

void UpdateAppDetails(AppDetails& app, const std::string* const new_name,
                      const boost::filesystem::path* const new_path,
                      const std::string* const new_args, const DirectoryInfo* const new_dir,
                      const SerialisedData* const new_icon) {
  // Check exactly one of the four pointers is non-null.
  assert(int(!!new_name) + int(!!new_path) + int(!!new_args) + int(!!new_dir) + int(!!new_icon) ==
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
  } else {
    app.icon = *new_icon;
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
  assert(!account_ && !account_mutex_ && fs::is_regular_file(config_file_path));

  assert(account && account_mutex);
  fs::create_directories(config_file_path.parent_path());

  std::lock(*account_mutex, mutex_);
  std::lock_guard<std::mutex> account_lock(*account_mutex, std::adopt_lock);
  std::lock_guard<std::mutex> lock(mutex_, std::adopt_lock);
  account_ = account;
  account_mutex_ = account_mutex;

  // Initialise the non-local apps from the account and the local ones from the config file
  non_local_apps_ = account_->apps;
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
    snapshot.config_file = config_file_path_.parent_path() / RandomAlphaNumericString(10);
    fs::copy_file(config_file_path_, snapshot.config_file);
  }
  catch (const std::exception& e) {
    LOG(kError) << "Failed to copy config file from " << config_file_path_ << " to "
                << snapshot.config_file << ": " << e.what();
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
    fs::rename(snapshot.config_file, config_file_path_);
  }
  catch (const std::exception& e) {
    LOG(kError) << "Failed to move config file from " << snapshot.config_file << " to "
                << config_file_path_ << ": " << e.what();
    BOOST_THROW_EXCEPTION(MakeError(CommonErrors::filesystem_io_error));
  }
}

std::set<AppDetails> AppHandler::GetApps(bool locally_available) const {
  std::lock_guard<std::mutex> lock{mutex_};
  return locally_available ? local_apps_ : non_local_apps_;
}

void AppHandler::Add(std::string app_name, fs::path app_path, std::string app_args) {
  //  need to add to account to be serialised too
}

void AppHandler::UpdateName(const std::string& app_name, const std::string& new_name) {
  Update(app_name, &new_name, nullptr, nullptr, nullptr, nullptr);
}

void AppHandler::UpdatePath(const std::string& app_name, const fs::path& new_path) {
  Update(app_name, nullptr, &new_path, nullptr, nullptr, nullptr);
}

void AppHandler::UpdateArgs(const std::string& app_name, const std::string& new_args) {
  Update(app_name, nullptr, nullptr, &new_args, nullptr, nullptr);
}

void AppHandler::UpdatePermittedDirs(const std::string& app_name, const DirectoryInfo& new_dir) {
  Update(app_name, nullptr, nullptr, nullptr, &new_dir, nullptr);
}

void AppHandler::UpdateIcon(const std::string& app_name, const SerialisedData& new_icon) {
  Update(app_name, nullptr, nullptr, nullptr, nullptr, &new_icon);
}

void AppHandler::RemoveLocally(const std::string& app_name) {
  AppDetails app;
  app.name = app_name;
  std::lock_guard<std::mutex> lock{mutex_};
  if (local_apps_.erase(app) != 1U) {
    LOG(kError) << "App \"" << app_name << "\" doesn't exist in AppHandler's local apps set.";
    BOOST_THROW_EXCEPTION(MakeError(CommonErrors::no_such_element));
  }
  WriteConfigFile();
}

void AppHandler::RemoveFromNetwork(const std::string& app_name) {
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

void AppHandler::Launch(const std::string& /*app_name*/, tcp::Port /*our_port*/) {}

std::pair<AppHandler::LockGuardPtr, AppHandler::LockGuardPtr> AppHandler::AcquireLocks() const {
  std::lock(*account_mutex_, mutex_);
  return std::make_pair(
      maidsafe::make_unique<std::lock_guard<std::mutex>>(*account_mutex_, std::adopt_lock),
      maidsafe::make_unique<std::lock_guard<std::mutex>>(mutex_, std::adopt_lock));
}

void AppHandler::ReadConfigFile() {
  // Read from file.
  crypto::CipherText encrypted_contents{ReadFile(config_file_path_)};

  // Decrypt and uncompress the contents.
  auto serialised_contents(crypto::Uncompress(crypto::CompressedText(crypto::SymmDecrypt(
      encrypted_contents, account_->config_file_aes_key, account_->config_file_aes_iv))));

  // Parse the set of local apps.
  std::stringstream str_stream{serialised_contents.string()};
  while (str_stream) {
    AppDetails app_details;
    ConvertFromStream(str_stream, app_details.name, app_details.permitted_dirs);
    local_apps_.insert(std::move(app_details));
  }
}

void AppHandler::WriteConfigFile() const {
  // Serialise the set of local apps.  Omit their 'permitted_dirs' field since they're held in the
  // serialised Account.
  std::string serialised_contents;
  for (const auto& app : local_apps_)
    serialised_contents += ConvertToString(app.name, app.path, app.args);

  // Compress and encrypt the serialised contents.
  auto encrypted_contents(
      crypto::SymmEncrypt(crypto::Compress(crypto::UncompressedText(serialised_contents), 9).data,
                          account_->config_file_aes_key, account_->config_file_aes_iv));

  // Write to file.
  if (!WriteFile(config_file_path_, encrypted_contents->string())) {
    LOG(kError) << "Failed to save config file at " << config_file_path_;
    BOOST_THROW_EXCEPTION(MakeError(CommonErrors::filesystem_io_error));
  }
}

void AppHandler::Update(const std::string& app_name, const std::string* const new_name,
                        const boost::filesystem::path* const new_path,
                        const std::string* const new_args, const DirectoryInfo* const new_dir,
                        const SerialisedData* const new_icon) {
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
  UpdateAppDetails(updated_app, new_name, new_path, new_args, new_dir, new_icon);
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
