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

#include "maidsafe/launcher/account.h"

#include <string>
#include <utility>

#include "cereal/types/set.hpp"
#include "cereal/types/string.hpp"

#include "maidsafe/common/error.h"
#include "maidsafe/common/make_unique.h"
#include "maidsafe/common/utils.h"
#include "maidsafe/common/authentication/user_credential_utils.h"
#include "maidsafe/common/serialisation/serialisation.h"
#include "maidsafe/common/serialisation/types/asio_and_boost_asio.h"

#include "maidsafe/launcher/app_details.h"

namespace maidsafe {

namespace launcher {

ImmutableData EncryptAccount(const authentication::UserCredentials& user_credentials,
                             Account& account) {
  uint64_t serialised_timestamp{GetTimeStamp()};
  boost::optional<Identity> unique_user_id, root_parent_id;
  if (account.unique_user_id.IsInitialised())
    unique_user_id = account.unique_user_id;
  if (account.root_parent_id.IsInitialised())
    root_parent_id = account.root_parent_id;

  OutputVectorStream binary_output_stream;
  BinaryOutputArchive output_archive{binary_output_stream};
  output_archive(account.passport->Encrypt(user_credentials), serialised_timestamp, account.ip,
                 account.port, unique_user_id, root_parent_id, account.config_file_aes_key,
                 account.config_file_aes_iv, account.apps.size());
  for (const auto& app : account.apps)
    output_archive(app.name, app.permitted_dirs, app.icon);

  NonEmptyString serialised_account{
      std::string(binary_output_stream.vector().begin(), binary_output_stream.vector().end())};

  account.timestamp = TimeStampToPtime(serialised_timestamp);

  crypto::SecurePassword secure_password{authentication::CreateSecurePassword(user_credentials)};
  return ImmutableData{
      crypto::SymmEncrypt(authentication::Obfuscate(user_credentials, serialised_account),
                          authentication::DeriveSymmEncryptKey(secure_password),
                          authentication::DeriveSymmEncryptIv(secure_password)).data};
}

Account::Account(const passport::MaidAndSigner& maid_and_signer)
    : passport(maidsafe::make_unique<passport::Passport>(maid_and_signer)),
      timestamp(),
      ip(),
      port(0),
      unique_user_id(),
      root_parent_id(),
      config_file_aes_key(RandomString(crypto::AES256_KeySize)),
      config_file_aes_iv(RandomString(crypto::AES256_IVSize)),
      apps() {}

Account::Account(const ImmutableData& encrypted_account,
                 const authentication::UserCredentials& user_credentials)
    : passport(),
      timestamp(),
      ip(),
      port(0),
      unique_user_id(),
      root_parent_id(),
      config_file_aes_key(),
      config_file_aes_iv(),
      apps() {
  crypto::SecurePassword secure_password{authentication::CreateSecurePassword(user_credentials)};
  NonEmptyString serialised_account{authentication::Obfuscate(
      user_credentials, crypto::SymmDecrypt(crypto::CipherText{encrypted_account.data()},
                                            authentication::DeriveSymmEncryptKey(secure_password),
                                            authentication::DeriveSymmEncryptIv(secure_password)))};

  crypto::CipherText encrypted_passport;
  uint64_t serialised_timestamp{0};
  boost::optional<Identity> optional_unique_user_id, optional_root_parent_id;
  std::size_t app_count{0};

  InputVectorStream binary_input_stream{
      SerialisedData(serialised_account.string().begin(), serialised_account.string().end())};
  BinaryInputArchive input_archive{binary_input_stream};
  input_archive(encrypted_passport, serialised_timestamp, ip, port, optional_unique_user_id,
                optional_root_parent_id, config_file_aes_key, config_file_aes_iv, app_count);
  for (std::size_t i{0}; i < app_count; ++i) {
    AppDetails app_details;
    input_archive(app_details.name, app_details.permitted_dirs, app_details.icon);
    apps.insert(apps.end(), std::move(app_details));
  }

  passport = maidsafe::make_unique<passport::Passport>(encrypted_passport, user_credentials);
  timestamp = TimeStampToPtime(serialised_timestamp);
  if (optional_unique_user_id)
    unique_user_id = *optional_unique_user_id;
  if (optional_root_parent_id)
    root_parent_id = *optional_root_parent_id;
}

Account::Account(Account&& other) MAIDSAFE_NOEXCEPT
    : passport(std::move(other.passport)),
      timestamp(std::move(other.timestamp)),
      ip(std::move(other.ip)),
      port(std::move(other.port)),
      unique_user_id(std::move(other.unique_user_id)),
      root_parent_id(std::move(other.root_parent_id)),
      config_file_aes_key(std::move(other.config_file_aes_key)),
      config_file_aes_iv(std::move(other.config_file_aes_iv)),
      apps(std::move(other.apps)) {}

Account& Account::operator=(Account&& other) MAIDSAFE_NOEXCEPT {
  passport = std::move(other.passport);
  timestamp = std::move(other.timestamp);
  ip = std::move(other.ip);
  port = std::move(other.port);
  unique_user_id = std::move(other.unique_user_id);
  root_parent_id = std::move(other.root_parent_id);
  config_file_aes_key = std::move(other.config_file_aes_key);
  config_file_aes_iv = std::move(other.config_file_aes_iv);
  apps = std::move(other.apps);
  return *this;
}

void swap(Account& lhs, Account& rhs) MAIDSAFE_NOEXCEPT {
  using std::swap;
  swap(lhs.passport, rhs.passport);
  swap(lhs.timestamp, rhs.timestamp);
  swap(lhs.ip, rhs.ip);
  swap(lhs.port, rhs.port);
  swap(lhs.unique_user_id, rhs.unique_user_id);
  swap(lhs.root_parent_id, rhs.root_parent_id);
  swap(lhs.config_file_aes_key, rhs.config_file_aes_key);
  swap(lhs.config_file_aes_iv, rhs.config_file_aes_iv);
  swap(lhs.apps, rhs.apps);
}

}  // namespace launcher

}  // namespace maidsafe
