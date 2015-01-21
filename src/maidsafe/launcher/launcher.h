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

#ifndef MAIDSAFE_LAUNCHER_LAUNCHER_H_
#define MAIDSAFE_LAUNCHER_LAUNCHER_H_

#include <cstdint>
#include <memory>
#include <mutex>
#include <set>
#include <string>

#include "boost/filesystem/path.hpp"

#include "maidsafe/directory_info.h"
#include "maidsafe/common/on_scope_exit.h"
#include "maidsafe/passport/passport.h"
#include "maidsafe/nfs/client/maid_node_nfs.h"

#include "maidsafe/launcher/account_handler.h"
#include "maidsafe/launcher/app_handler.h"
#include "maidsafe/launcher/app_details.h"

namespace maidsafe {

namespace launcher {

class AccountGetter;

class Launcher {
 public:
  using Keyword = std::string;
  using Pin = uint32_t;
  using Password = std::string;

  Launcher(const Launcher&) = delete;
  Launcher(Launcher&&) = delete;
  Launcher& operator=(const Launcher&) = delete;
  Launcher& operator=(Launcher&&) = delete;

  // Retrieves and decrypts account info and logs in to an existing account.  Throws on error.
  static std::unique_ptr<Launcher> Login(Keyword keyword, Pin pin, Password password);

  // This function should be used when creating a new account, i.e. where a account has never
  // been put to the network.  Internally saves the first encrypted account after creating the new
  // account.  Throws on error.
  static std::unique_ptr<Launcher> CreateAccount(Keyword keyword, Pin pin, Password password);

  // Saves session, and logs out of the network.  After calling, the class should be destructed as
  // it is no longer connected to the network.  Throws on error, with strong exception guarantee.
  void LogoutAndStop();

  // Returns the set of apps which have been added.  If 'locally_available' is false, only apps
  // which have been added on other machines are returned (i.e. there is no local config file entry
  // for these apps).  If 'locally_available' is true, only apps which have been added on this
  // machine are returned.  These sets are mutually exclusive.  Doesn't throw.
  std::set<AppDetails> GetApps(bool locally_available) const;

  // Adds an instance of 'app_name' to the set of recognised apps.
  void AddApp(std::string app_name, boost::filesystem::path app_path, std::string app_args);

  // Update functions all throw on error (e.g. if the indicated app doesn't exist in the set) with
  // strong exception guarantee.
  void UpdateAppName(const std::string& app_name, const std::string& new_name);
  void UpdateAppPath(const std::string& app_name, const boost::filesystem::path& new_path);
  void UpdateAppArgs(const std::string& app_name, const std::string& new_args);
  void UpdateAppSafeDriveAccess(const std::string& app_name,
                                DirectoryInfo::AccessRights new_rights);
  void UpdateAppIcon(const std::string& app_name, const SerialisedData& new_icon);

  // Removes an instance of 'app_name' from the set of locally available apps (i.e. apps which have
  // been added on this machine and which have an entry in the local config file).  Throws with
  // strong exception guarantee if 'app_name' isn't in the set.
  void RemoveAppLocally(const std::string& app_name);

  // Removes an instance of 'app_name' from the set of non-locally available apps (i.e. apps which
  // have only been added on a different machine and which don't have an entry in the local config
  // file).  Throws with strong exception guarantee if 'app_name' isn't in the set.
  void RemoveAppFromNetwork(const std::string& app_name);

  // Save the account to the network.                        If this throws, the application should not continue running.  timeout / conn dropped?
  void SaveSession();

  // Launches a new instance of the app indicated by 'app_name' as a detached child.  Throws on
  // error, with strong exception guarantee.
  void LaunchApp(const std::string& app_name);

 private:
  // For already existing accounts.
  Launcher(Keyword keyword, Pin pin, Password password, AccountGetter& account_getter);

  // For new accounts.  Throws on failure to create account.
  Launcher(Keyword keyword, Pin pin, Password password, passport::MaidAndSigner&& maid_and_signer);

  void RevertOperation(AppHandler::Snapshot snapshot);

  tcp::Port StartListening();

  std::shared_ptr<nfs_client::MaidNodeNfs> maid_node_nfs_;
  AccountHandler account_handler_;
  mutable std::mutex account_mutex_;
  AppHandler app_handler_;
};

}  // namespace launcher

}  // namespace maidsafe

#endif  // MAIDSAFE_LAUNCHER_LAUNCHER_H_
