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

#include "maidsafe/launcher/tests/test_utils.h"

#include <string>

#include "maidsafe/directory_info.h"
#include "maidsafe/common/crypto.h"
#include "maidsafe/common/encode.h"
#include "maidsafe/common/make_unique.h"
#include "maidsafe/common/utils.h"
#include "maidsafe/common/authentication/user_credentials.h"

#include "maidsafe/launcher/account.h"
#include "maidsafe/launcher/launcher.h"

namespace maidsafe {

namespace launcher {

namespace test {

TestUsingFakeStore::TestUsingFakeStore(std::string name)
    : test_root_(maidsafe::test::CreateTestPath(std::string("MaidSafe_Test") + std::move(name))) {
  DiskUsage usage(1024 * 1024);
  Launcher::FakeStorePath(test_root_.get());
  Launcher::FakeStoreDiskUsage(&usage);
}

std::shared_ptr<NetworkClient> TestUsingFakeStore::GetNetworkClient(const passport::Maid& maid) {
#ifdef ROUTING_AND_NFS_UPDATED
#ifdef USE_FAKE_STORE
  static_cast<void>(maid);
  return std::make_shared<NetworkClient>(Launcher::FakeStorePath(), Launcher::FakeStoreDiskUsage());
#else
  return nfs_client::MaidClient::MakeShared(maid);
#endif
#else
  static_cast<void>(maid);
  return std::make_shared<NetworkClient>(MemoryUsage(1 << 7), Launcher::FakeStoreDiskUsage(),
                                         nullptr, Launcher::FakeStorePath());
#endif
}

std::tuple<Keyword, Pin, Password> GetRandomUserCredentialsTuple() {
  std::string keyword{RandomAlphaNumericString(1, 100)};
  std::string password{RandomAlphaNumericString(1, 100)};
  return std::make_tuple<Keyword, Pin, Password>(Keyword(keyword.begin(), keyword.end()),
                                                 RandomUint32(),
                                                 Password(password.begin(), password.end()));
}

authentication::UserCredentials GetRandomUserCredentials() {
  return MakeUserCredentials(GetRandomUserCredentialsTuple());
}

authentication::UserCredentials MakeUserCredentials(
    const std::tuple<Keyword, Pin, Password>& user_credentials_tuple) {
  authentication::UserCredentials user_credentials;
  user_credentials.keyword = maidsafe::make_unique<authentication::UserCredentials::Keyword>(
      std::get<0>(user_credentials_tuple));
  user_credentials.pin = maidsafe::make_unique<authentication::UserCredentials::Pin>(
      std::to_string(std::get<1>(user_credentials_tuple)));
  user_credentials.password = maidsafe::make_unique<authentication::UserCredentials::Password>(
      std::get<2>(user_credentials_tuple));
  return user_credentials;
}

DirectoryInfo CreateRandomDirectoryInfo() {
  return DirectoryInfo(RandomAlphaNumericString(10, 20), MakeIdentity(), MakeIdentity(),
                       static_cast<DirectoryInfo::AccessRights>((RandomUint32() % 2) + 1));
}

AppDetails CreateRandomAppDetails() {
  AppDetails app;
  app.name = RandomAlphaNumericString(1, 40);
  app.path = RandomAlphaNumericString(10, 255);
  app.args = RandomAlphaNumericString(0, 100);
  int count = (RandomUint32() % 10) + 1;
  for (int i = 0; i < count; ++i)
    app.permitted_dirs.insert(CreateRandomDirectoryInfo());
  std::string icon(RandomString(10, 1000));
  app.icon.assign(icon.begin(), icon.end());
  app.auto_start = (count % 2 == 1);
  return app;
}

testing::AssertionResult Equals(const AppDetails& expected, const AppDetails& actual,
                                int ignore_field) {
  if (expected.name != actual.name) {
    return testing::AssertionFailure() << "\n    Expected name (" << expected.name
                                       << ") does not match actual name (" << actual.name << ")\n";
  }
  if (!(ignore_field & kIgnorePath) && expected.path != actual.path) {
    return testing::AssertionFailure() << "\n    Expected path (" << expected.path
                                       << ") does not match actual path (" << actual.path << ")\n";
  }
  if (!(ignore_field & kIgnoreArgs) && expected.args != actual.args) {
    return testing::AssertionFailure() << "\n    Expected args (" << expected.args
                                       << ") do not match actual args (" << actual.args << ")\n";
  }
  if (!(ignore_field & kIgnorePermittedDirs)) {
    bool failed_permitted_dirs{expected.permitted_dirs.size() != actual.permitted_dirs.size()};
    auto expected_itr(expected.permitted_dirs.begin());
    auto actual_itr(actual.permitted_dirs.begin());
    while (!failed_permitted_dirs && expected_itr != expected.permitted_dirs.end()) {
      if (expected_itr->path != actual_itr->path)
        failed_permitted_dirs = true;
      if (expected_itr->parent_id != actual_itr->parent_id)
        failed_permitted_dirs = true;
      if (expected_itr->directory_id != actual_itr->directory_id)
        failed_permitted_dirs = true;
      if ((expected_itr++)->access_rights != (actual_itr++)->access_rights)
        failed_permitted_dirs = true;
    }
    if (failed_permitted_dirs) {
      std::string output("\n    Expected permitted dirs do not match actual permitted dirs.");

      auto print_dir([&output](const DirectoryInfo& dir) {
        output += "        path:          " + dir.path.string();
        output += "        parent_id:     " + hex::Substr(dir.parent_id);
        output += "        directory_id:  " + hex::Substr(dir.directory_id);
        switch (dir.access_rights) {
          case DirectoryInfo::AccessRights::kNone:
            output += "        access_rights: kNone\n";
            break;
          case DirectoryInfo::AccessRights::kReadOnly:
            output += "        access_rights: kReadOnly\n";
            break;
          case DirectoryInfo::AccessRights::kReadWrite:
            output += "        access_rights: kReadWrite\n";
            break;
          default:
            BOOST_THROW_EXCEPTION(MakeError(CommonErrors::invalid_argument));
        }
      });

      output += "\n\n      Expected dirs:\n";
      expected_itr = expected.permitted_dirs.begin();
      while (expected_itr != expected.permitted_dirs.end())
        print_dir(*expected_itr++);

      output += "\n\n      Actual dirs:\n";
      actual_itr = actual.permitted_dirs.begin();
      while (actual_itr != actual.permitted_dirs.end())
        print_dir(*actual_itr++);
      return testing::AssertionFailure() << output << '\n';
    }
  }

  if (!(ignore_field & kIgnoreIcon) && expected.icon != actual.icon) {
    return testing::AssertionFailure()
           << "\n    Expected icon ("
           << hex::Encode(std::string(expected.icon.begin(), expected.icon.end()))
           << ") does not match actual icon ("
           << hex::Encode(std::string(actual.icon.begin(), actual.icon.end())) << ")\n";
  }
  if (!(ignore_field & kIgnoreAutoStart) && expected.auto_start != actual.auto_start) {
    return testing::AssertionFailure() << "\n    Expected auto start value (" << expected.auto_start
                                       << ") does not match actual auto start value ("
                                       << actual.auto_start << ")\n";
  }
  return testing::AssertionSuccess();
}

testing::AssertionResult Equals(const std::set<AppDetails>& expected,
                                const std::set<AppDetails>& actual, int ignore_field) {
  if (expected.size() != actual.size()) {
    return testing::AssertionFailure() << "\n  Expected size (" << expected.size()
                                       << ") does not match actual size (" << actual.size() << ")";
  }
  auto expected_itr(expected.begin());
  auto actual_itr(actual.begin());
  int count{0};
  while (expected_itr != expected.end()) {
    if (!Equals(*expected_itr, *actual_itr, ignore_field)) {
      EXPECT_TRUE(Equals(*expected_itr, *actual_itr, ignore_field));  // to get console output.
      return testing::AssertionFailure() << "Failed to match apps at index " << count;
    }
    ++expected_itr;
    ++actual_itr;
    ++count;
  }
  return testing::AssertionSuccess();
}

}  // namespace test

}  // namespace launcher

}  // namespace maidsafe
