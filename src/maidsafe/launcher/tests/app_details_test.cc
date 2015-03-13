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

#include "maidsafe/launcher/app_details.h"

#include "maidsafe/common/test.h"

#include "maidsafe/launcher/tests/test_utils.h"

namespace maidsafe {

namespace launcher {

namespace test {

TEST(AppDetailsTest, BEH_CopyAndMove) {
  AppDetails default_constructed_app;
  EXPECT_TRUE(default_constructed_app.name.empty());
  EXPECT_TRUE(default_constructed_app.path.empty());
  EXPECT_TRUE(default_constructed_app.args.empty());
  EXPECT_TRUE(default_constructed_app.permitted_dirs.empty());
  EXPECT_TRUE(default_constructed_app.icon.empty());
  EXPECT_FALSE(default_constructed_app.auto_start);

  // Create two AppDetails with all fields different from eachother
  AppDetails app1(CreateRandomAppDetails());
  AppDetails app2(CreateRandomAppDetails());
  ASSERT_NE(app1.name, app2.name);
  ASSERT_NE(app1.path, app2.path);
  ASSERT_NE(app1.args, app2.args);
  if (app1.permitted_dirs.size() == app2.permitted_dirs.size())
    ASSERT_NE(app1.permitted_dirs.begin()->directory_id, app2.permitted_dirs.begin()->directory_id);
  ASSERT_NE(app1.icon, app2.icon);
  app2.auto_start = !app1.auto_start;

  // Copy construct
  AppDetails copied_app(app1);
  EXPECT_TRUE(Equals(app1, copied_app));

  // Move construct
  AppDetails moved_app(std::move(copied_app));
  EXPECT_TRUE(Equals(app1, moved_app));

  // Copy assign
  copied_app = app2;
  EXPECT_TRUE(Equals(app2, copied_app));

  // Move assign
  moved_app = std::move(copied_app);
  EXPECT_TRUE(Equals(app2, moved_app));
}

TEST(AppDetailsTest, BEH_Swap) {
  AppDetails app1(CreateRandomAppDetails());
  AppDetails app2(CreateRandomAppDetails());

  AppDetails copy_of_app1(app1);
  AppDetails copy_of_app2(app2);

  swap(app1, app2);
  EXPECT_TRUE(Equals(copy_of_app1, app2));
  EXPECT_TRUE(Equals(copy_of_app2, app1));
}

TEST(AppDetailsTest, BEH_LessThan) {
  // Create two AppDetails where the first has 'name' less than second's 'name'
  AppDetails app1(CreateRandomAppDetails());
  AppDetails app2(CreateRandomAppDetails());
  app1.name = app2.name.substr(0, app2.name.size() - 1);
  ASSERT_LT(app1.name, app2.name);

  // Check that app1 < app2 is true and app2 < app1 is false
  EXPECT_TRUE(operator<(app1, app2));
  EXPECT_FALSE(operator<(app2, app1));

  // Check that none of the fields except 'name' matter to operator<
  using std::swap;
  swap(app1.path, app2.path);
  EXPECT_TRUE(operator<(app1, app2));
  EXPECT_FALSE(operator<(app2, app1));

  swap(app1.args, app2.args);
  EXPECT_TRUE(operator<(app1, app2));
  EXPECT_FALSE(operator<(app2, app1));

  swap(app1.permitted_dirs, app2.permitted_dirs);
  EXPECT_TRUE(operator<(app1, app2));
  EXPECT_FALSE(operator<(app2, app1));

  swap(app1.icon, app2.icon);
  EXPECT_TRUE(operator<(app1, app2));
  EXPECT_FALSE(operator<(app2, app1));

  swap(app1.auto_start, app2.auto_start);
  EXPECT_TRUE(operator<(app1, app2));
  EXPECT_FALSE(operator<(app2, app1));

  // Similarly check for two apps with the same 'name'
  AppDetails app3(app1);
  EXPECT_FALSE(operator<(app1, app3));
  EXPECT_FALSE(operator<(app3, app1));

  app3.path.clear();
  EXPECT_FALSE(operator<(app1, app3));
  EXPECT_FALSE(operator<(app3, app1));

  app3.args.clear();
  EXPECT_FALSE(operator<(app1, app3));
  EXPECT_FALSE(operator<(app3, app1));

  app3.permitted_dirs.clear();
  EXPECT_FALSE(operator<(app1, app3));
  EXPECT_FALSE(operator<(app3, app1));

  app3.icon.clear();
  EXPECT_FALSE(operator<(app1, app3));
  EXPECT_FALSE(operator<(app3, app1));

  app3.auto_start = !app3.auto_start;
  EXPECT_FALSE(operator<(app1, app3));
  EXPECT_FALSE(operator<(app3, app1));
}

}  // namespace test

}  // namespace launcher

}  // namespace maidsafe
