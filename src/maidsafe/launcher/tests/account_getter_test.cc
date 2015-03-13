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

#include "maidsafe/launcher/account_getter.h"

#include "maidsafe/common/test.h"

#include "maidsafe/launcher/tests/test_utils.h"

namespace maidsafe {

namespace launcher {

namespace test {

class AccountGetterTest : public TestUsingFakeStore {
 protected:
  AccountGetterTest() : TestUsingFakeStore("AccountGetter") {}
};

TEST_F(AccountGetterTest, FUNC_Constructor) {
  auto account_getter_future = AccountGetter::CreateAccountGetter();
  LOG(kVerbose) << "Started CreateAccountGetter thread";
  std::unique_ptr<AccountGetter> account_getter;
  ASSERT_NO_THROW(account_getter = account_getter_future.get());
}

}  // namespace test

}  // namespace launcher

}  // namespace maidsafe
