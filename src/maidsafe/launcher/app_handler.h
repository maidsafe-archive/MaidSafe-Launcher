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

#ifndef MAIDSAFE_LAUNCHER_APP_HANDLER_H_
#define MAIDSAFE_LAUNCHER_APP_HANDLER_H_

#include <cstdint>
#include <memory>
#include <mutex>
#include <set>
#include <utility>

#include "boost/filesystem/path.hpp"

#include "maidsafe/common/types.h"
#include "maidsafe/common/serialisation/serialisation.h"
#include "maidsafe/directory_info.h"

#include "maidsafe/launcher/types.h"

namespace maidsafe {

namespace launcher {

struct Account;
struct AppDetails;

namespace test {
class AppHandlerTest;
}  // namespace test

// This class only offers the basic exception safety guarantee, but it allows a snapshot to be taken
// so that the owning Launcher class can revert this to the snapshot state if required.  The
// Snapshot struct provides a RAII copy of the config file.  When an instance of a Snaphot is
// created, a copy of the config file is created and the path to this copy held in a shared_ptr
// member of the Snapshot instance.  When the final copy of this Snapshot instance is destroyed, the
// copied file is also removed from disk.
class AppHandler {
 public:
  struct Snapshot {
    friend class AppHandler;
    friend class test::AppHandlerTest;

   private:
    std::set<AppDetails> local_apps, non_local_apps;
    std::shared_ptr<boost::filesystem::path> config_file;
  };

  AppHandler();

  AppHandler(const AppHandler&) = delete;
  AppHandler(AppHandler&&) = delete;
  AppHandler& operator=(const AppHandler&) = delete;
  AppHandler& operator=(AppHandler&&) = delete;

  void Initialise(boost::filesystem::path config_file_path, Account* account,
                  std::mutex* account_mutex);

  Snapshot GetSnapshot() const;
  void ApplySnapshot(Snapshot snapshot);

  std::set<AppDetails> GetApps(bool locally_available) const;
  // Link if 'app_icon' is null, else Add.
  AppDetails AddOrLinkApp(AppName app_name, boost::filesystem::path app_path, AppArgs app_args,
                          const SerialisedData* const app_icon, bool auto_start);
  void UpdateName(const AppName& app_name, const AppName& new_name);
  void UpdatePath(const AppName& app_name, const boost::filesystem::path& new_path);
  void UpdateArgs(const AppName& app_name, const AppArgs& new_args);
  void UpdatePermittedDirs(const AppName& app_name, const DirectoryInfo& new_dir);
  void UpdateIcon(const AppName& app_name, const SerialisedData& new_icon);
  void UpdateAutoStart(const AppName& app_name, bool new_auto_start_value);
  void RemoveLocally(const AppName& app_name);
  void RemoveFromNetwork(const AppName& app_name);
  std::pair<boost::filesystem::path, AppArgs> GetPathAndArgs(AppName app_name) const;

 private:
  using LockGuardPtr = std::unique_ptr<std::lock_guard<std::mutex>>;
  std::pair<LockGuardPtr, LockGuardPtr> AcquireLocks() const;
  void ReadConfigFile();
  void WriteConfigFile() const;
  void Add(AppDetails& app, std::set<AppDetails>::iterator account_itr);
  void Link(AppDetails& app, std::set<AppDetails>::iterator account_itr);
  void Update(const AppName& app_name, const AppName* const new_name,
              const boost::filesystem::path* const new_path, const AppArgs* const new_args,
              const DirectoryInfo* const new_dir, const SerialisedData* const new_icon,
              const bool* const new_auto_start_value);

  Account* account_;
  mutable std::mutex* account_mutex_;
  boost::filesystem::path config_file_path_;
  std::set<AppDetails> local_apps_, non_local_apps_;
  mutable std::mutex mutex_;
};

}  // namespace launcher

}  // namespace maidsafe

#endif  // MAIDSAFE_LAUNCHER_APP_HANDLER_H_
