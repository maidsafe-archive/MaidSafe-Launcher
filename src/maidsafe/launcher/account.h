/*  Copyright 2014 MaidSafe.net limited

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

#ifndef MAIDSAFE_LAUNCHER_ACCOUNT_H_
#define MAIDSAFE_LAUNCHER_ACCOUNT_H_

#include <cstdint>
#include <memory>
#include <set>
#include <string>

#include "asio/ip/address.hpp"
#include "boost/date_time/posix_time/ptime.hpp"

#include "maidsafe/common/config.h"
#include "maidsafe/common/crypto.h"
#include "maidsafe/common/types.h"
#include "maidsafe/common/authentication/user_credentials.h"
#include "maidsafe/passport/passport.h"

#include "maidsafe/launcher/app_details.h"

namespace maidsafe {

namespace launcher {

struct Account;

// Used when saving account.  Updates 'timestamp', serialises the account, then encrypts this.
// Throws on error.
ImmutableData EncryptAccount(const authentication::UserCredentials& user_credentials,
                             Account& account);

struct Account {
  Account();

  // Used when creating a new user account, i.e. registering a new user on the network rather than
  // logging back in.  Creates a new default-constructed passport.  Throws on error.
  explicit Account(const passport::MaidAndSigner& maid_and_signer);

  // Used when logging in.  Parses account from previously-serialised and encrypted account.  Throws
  // on error.
  Account(const ImmutableData& encrypted_account,
          const authentication::UserCredentials& user_credentials);

  // Move-constructible and move-assignable only.
  Account(const Account&) = delete;
  Account(Account&& other) MAIDSAFE_NOEXCEPT;
  Account& operator=(const Account&) = delete;
  Account& operator=(Account&& other) MAIDSAFE_NOEXCEPT;

  std::unique_ptr<passport::Passport> passport;
  boost::posix_time::ptime timestamp;
  asio::ip::address ip;
  uint16_t port;
  Identity unique_user_id, root_parent_id;
  crypto::AES256Key config_file_aes_key;
  crypto::AES256InitialisationVector config_file_aes_iv;
  std::set<AppDetails> apps;
};

void swap(Account& lhs, Account& rhs) MAIDSAFE_NOEXCEPT;

}  // namespace launcher

}  // namespace maidsafe

#endif  // MAIDSAFE_LAUNCHER_ACCOUNT_H_
