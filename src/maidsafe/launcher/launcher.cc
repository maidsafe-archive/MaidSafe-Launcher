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

#include "maidsafe/common/error.h"
#include "maidsafe/common/log.h"

#include "maidsafe/launcher/account_getter.h"

namespace maidsafe {

namespace launcher {

namespace {

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
    : maid_node_nfs_(), account_handler_() {
  account_handler_.Login(ConvertToCredentials(keyword, pin, password), account_getter);
  maid_node_nfs_ =
      nfs_client::MaidNodeNfs::MakeShared(account_handler_.account().passport->GetMaid());
}

Launcher::Launcher(Keyword keyword, Pin pin, Password password,
                   passport::MaidAndSigner&& maid_and_signer)
    : maid_node_nfs_(nfs_client::MaidNodeNfs::MakeShared(maid_and_signer)),
      account_handler_(Account{maid_and_signer}, ConvertToCredentials(keyword, pin, password),
                       *maid_node_nfs_) {}

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
  account_handler_.Save(*maid_node_nfs_);
  maid_node_nfs_->Stop();
}

}  // namespace launcher

}  // namespace maidsafe
