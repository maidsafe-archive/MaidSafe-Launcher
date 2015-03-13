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

#include <mutex>

#include "asio/ip/address_v6.hpp"
#include "boost/filesystem/operations.hpp"
#include "boost/filesystem/path.hpp"

#include "maidsafe/common/crypto.h"
#include "maidsafe/common/make_unique.h"
#include "maidsafe/common/test.h"
#include "maidsafe/common/utils.h"
#include "maidsafe/passport/passport.h"

#include "maidsafe/launcher/account.h"
#include "maidsafe/launcher/tests/test_utils.h"

namespace fs = boost::filesystem;

namespace maidsafe {

namespace launcher {

namespace test {

class AppHandlerTest : public testing::Test {
 protected:
  AppHandlerTest()
      : test_root_(maidsafe::test::CreateTestPath("MaidSafe_TestAppHandler")),
        account_(passport::CreateMaidAndSigner()),
        account_mutex_() {
    account_.ip = asio::ip::make_address_v6(maidsafe::test::GetRandomIPv6AddressAsString());
    account_.port = static_cast<std::uint16_t>(RandomUint32());
    account_.unique_user_id = Identity{MakeIdentity()};
    account_.root_parent_id = Identity{MakeIdentity()};
    for (int i{0}; i < 5; ++i)
      account_.apps.insert(CreateRandomAppDetails());
  }

  fs::path SnapshotConfigFile(const AppHandler::Snapshot& snapshot) {
    return *snapshot.config_file;
  }

  const maidsafe::test::TestPath test_root_;
  Account account_;
  std::mutex account_mutex_;
};

TEST_F(AppHandlerTest, BEH_Snapshot) {
  // Check snaphot with new AppHandler (i.e. no existing config file)
  AppHandler app_handler;
  fs::path config_file{*test_root_ / "config.txt"};
  app_handler.Initialise(config_file, &account_, &account_mutex_);
  ASSERT_TRUE(fs::is_empty(*test_root_));
  {
    AppHandler::Snapshot snapshot(app_handler.GetSnapshot());
    EXPECT_TRUE(fs::is_empty(*test_root_));
  }
  // Keep a copy of the "empty" snapshot to try applying later
  auto empty_snapshot(maidsafe::make_unique<AppHandler::Snapshot>(app_handler.GetSnapshot()));

  // Cause config file to be created by adding apps.
  const std::uint32_t app_count{(RandomUint32() % 100) + 1};
  std::set<AppDetails> apps;
  for (std::uint32_t i{0}; i < app_count; ++i) {
    AppDetails app{CreateRandomAppDetails()};
    AppDetails added_app(
        app_handler.AddOrLinkApp(app.name, app.path, app.args, &app.icon, app.auto_start));
    app.permitted_dirs.insert(*added_app.permitted_dirs.begin());
    for (const auto& dir : app.permitted_dirs)
      app_handler.UpdatePermittedDirs(app.name, dir);
    ASSERT_TRUE(apps.insert(std::move(app)).second);
  }
  ASSERT_TRUE(fs::exists(config_file));
  ASSERT_TRUE(Equals(apps, app_handler.GetApps(true)));

  // Check that creating a snapshot copies the config file and that copying and moving a snapshot
  // doesn't affect the file copy being destroyed when the final snapshot copy is destroyed.
  fs::path snapshot_config_file;
  {
    AppHandler::Snapshot snapshot0;
    {
      AppHandler::Snapshot snapshot1;
      {
        AppHandler::Snapshot snapshot2(app_handler.GetSnapshot());
        snapshot_config_file = SnapshotConfigFile(snapshot2);
        EXPECT_TRUE(fs::exists(snapshot_config_file));
        EXPECT_EQ(ReadFile(config_file).value(), ReadFile(snapshot_config_file).value());
        snapshot1 = snapshot2;
      }
      EXPECT_TRUE(fs::exists(snapshot_config_file));
      EXPECT_EQ(ReadFile(config_file).value(), ReadFile(snapshot_config_file).value());
      snapshot0 = std::move(snapshot1);
    }
    EXPECT_TRUE(fs::exists(snapshot_config_file));
    EXPECT_EQ(ReadFile(config_file).value(), ReadFile(snapshot_config_file).value());
  }
  EXPECT_FALSE(fs::exists(snapshot_config_file));

  // Keep a copy of the current snapshot to try applying later
  auto snapshot(maidsafe::make_unique<AppHandler::Snapshot>(app_handler.GetSnapshot()));
  snapshot_config_file = SnapshotConfigFile(*snapshot);
  auto config_file_contents(ReadFile(config_file).value());

  // Check that applying the "empty" snapshot clears the data and removes the config file
  ASSERT_EQ(app_count, app_handler.GetApps(true).size());
  ASSERT_TRUE(fs::exists(config_file));
  app_handler.ApplySnapshot(std::move(*empty_snapshot));
  EXPECT_TRUE(app_handler.GetApps(true).empty());
  EXPECT_FALSE(fs::exists(config_file));
  empty_snapshot.reset();

  // Check that applying the other snapshot renews the data and config file.
  app_handler.ApplySnapshot(std::move(*snapshot));
  EXPECT_TRUE(Equals(apps, app_handler.GetApps(true)));
  EXPECT_TRUE(fs::exists(config_file));
  EXPECT_EQ(config_file_contents, ReadFile(config_file).value());
  EXPECT_FALSE(fs::exists(snapshot_config_file));
}

}  // namespace test

}  // namespace launcher

}  // namespace maidsafe
