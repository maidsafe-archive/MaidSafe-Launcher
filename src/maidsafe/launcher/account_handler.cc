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

#include "maidsafe/launcher/account_handler.h"

#include <string>
#include <utility>

#include "maidsafe/common/crypto.h"
#include "maidsafe/common/error.h"
#include "maidsafe/common/log.h"
#include "maidsafe/common/make_unique.h"
#include "maidsafe/common/on_scope_exit.h"
#include "maidsafe/common/authentication/user_credential_utils.h"
#include "maidsafe/common/data_types/immutable_data.h"
#include "maidsafe/common/data_types/mutable_data.h"

#include "maidsafe/launcher/account_getter.h"

namespace maidsafe {

namespace launcher {

Identity GetAccountLocation(const authentication::UserCredentials::Keyword& keyword,
                            const authentication::UserCredentials::Pin& pin) {
  return Identity{crypto::Hash<crypto::SHA512>(keyword.Hash<crypto::SHA512>().string() +
                                               pin.Hash<crypto::SHA512>().string())};
}

AccountHandler::AccountHandler() : account_(), account_versions_(20, 1), user_credentials_() {}

AccountHandler::AccountHandler(Account&& account,
                               authentication::UserCredentials&& user_credentials,
                               NetworkClient& network_client)
    : account_(maidsafe::make_unique<Account>(std::move(account))),
      account_versions_(20, 1),
      user_credentials_(std::move(user_credentials)) {
  // throw if private_client & account are not coherent
  // TODO(Prakash) Validate credentials
  Identity account_location{GetAccountLocation(*user_credentials_.keyword, *user_credentials_.pin)};
  ImmutableData encrypted_account{EncryptAccount(user_credentials_, *account_)};
  MutableData account_versions_wrapper;
  try {
    network_client.Store(encrypted_account.NameAndType(),
                         NonEmptyString(Serialise(encrypted_account)));
    StructuredDataVersions::VersionName first_version(0, encrypted_account.Name());
    account_versions_.Put(StructuredDataVersions::VersionName(), first_version);
    account_versions_wrapper = MutableData(account_location, account_versions_.Serialise());
    network_client.Store(account_versions_wrapper.NameAndType(),
                         NonEmptyString(Serialise(account_versions_wrapper)));
  } catch (const std::exception& e) {
    LOG(kError) << "Failed to store account: " << boost::diagnostic_information(e);
    network_client.Delete(encrypted_account.NameAndType());
    if (account_versions_wrapper.IsInitialised())
      network_client.Delete(account_versions_wrapper.NameAndType());
    throw;
  }
}

void AccountHandler::Login(authentication::UserCredentials&& user_credentials,
                           AccountGetter& account_getter) {
  if (account_ && account_->passport)  // already logged in
    BOOST_THROW_EXCEPTION(MakeError(CommonErrors::invalid_argument));

  Identity account_location{GetAccountLocation(*user_credentials.keyword, *user_credentials.pin)};
  try {
    MutableData account_versions_wrapper(
        Parse<MutableData>(account_getter.data_getter()
                               .Get(Data::NameAndTypeId(account_location, DataTypeId(1)))
                               .string()));
    account_versions_.ApplySerialised(
        StructuredDataVersions::serialised_type(account_versions_wrapper.Value()));
    auto versions(account_versions_.Get());
    assert(versions.size() == 1U);
    // TODO(Fraser#5#): 2014-04-17 - Get more than just the latest version - possibly just for the
    // case where the latest one fails.  Or just throw, but add 'int version_number' to this
    // function's signature where 0 == most recent, 1 == second newest, etc.
    ImmutableData encrypted_account(
        Parse<ImmutableData>(account_getter.data_getter()
                                 .Get(Data::NameAndTypeId(versions.at(0).id, DataTypeId(0)))
                                 .string()));
    account_ = maidsafe::make_unique<Account>(encrypted_account, user_credentials);
    user_credentials_ = std::move(user_credentials);
  } catch (const std::exception& e) {
    LOG(kError) << "Failed to login: " << boost::diagnostic_information(e);
    throw;
  }
}

void AccountHandler::Save(NetworkClient& network_client) {
  // The only member which is modified in this process is the account timestamp.
  on_scope_exit strong_guarantee{on_scope_exit::RevertValue(account_->timestamp)};

  ImmutableData encrypted_account(EncryptAccount(user_credentials_, *account_));
  try {
    network_client.Store(encrypted_account.NameAndType(),
                         NonEmptyString(Serialise(encrypted_account)));
    // Get current tip-of-tree and create new version
    auto versions(account_versions_.Get());
    assert(versions.size() == 1U);
    StructuredDataVersions::VersionName new_account_version{versions.at(0).index + 1,
                                                            encrypted_account.Name()};
    account_versions_.Put(versions.at(0), new_account_version);

    Identity account_location{
        GetAccountLocation(*user_credentials_.keyword, *user_credentials_.pin)};
    MutableData account_versions_wrapper(account_location, account_versions_.Serialise());
    network_client.Store(account_versions_wrapper.NameAndType(),
                         NonEmptyString(Serialise(account_versions_wrapper)));

    strong_guarantee.Release();
  } catch (const std::exception& e) {
    LOG(kError) << boost::diagnostic_information(e);
    network_client.Delete(encrypted_account.NameAndType());
    throw;
  }
}

}  // namespace launcher

}  // namespace maidsafe
