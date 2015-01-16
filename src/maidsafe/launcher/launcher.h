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
#include <string>

#include "maidsafe/passport/passport.h"
#include "maidsafe/nfs/client/maid_node_nfs.h"

#include "maidsafe/launcher/account_handler.h"

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

  // Throws on error, with strong exception guarantee.  After calling, the class should be
  // destructed as it is no longer connected to the network.
  void LogoutAndStop();

  // Adds an instance of 'app_name' to the map of recognised apps, or increments the reference
  // count for this app if it already exists.
  void AddApp(const std::string& app_name, const std::string& app_path_and_args);

  void RegisterAppSession();

 private:
  // For already existing accounts.
  Launcher(Keyword keyword, Pin pin, Password password, AccountGetter& account_getter);

  // For new accounts.  Throws on failure to create account.
  Launcher(Keyword keyword, Pin pin, Password password, passport::MaidAndSigner&& maid_and_signer);

  std::shared_ptr<nfs_client::MaidNodeNfs> maid_node_nfs_;
  AccountHandler account_handler_;
};

}  // namespace launcher

}  // namespace maidsafe

#endif  // MAIDSAFE_LAUNCHER_LAUNCHER_H_
