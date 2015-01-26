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

#include <utility>

namespace maidsafe {

namespace launcher {

AppDetails::AppDetails() : name(), path(), args(), permitted_dirs(), icon() {}

AppDetails::AppDetails(AppDetails&& other) MAIDSAFE_NOEXCEPT
    : name(std::move(other.name)),
      path(std::move(other.path)),
      args(std::move(other.args)),
      permitted_dirs(std::move(other.permitted_dirs)),
      icon(std::move(other.icon)) {}

AppDetails& AppDetails::operator=(AppDetails&& other) MAIDSAFE_NOEXCEPT {
  name = std::move(other.name);
  path = std::move(other.path);
  args = std::move(other.args);
  permitted_dirs = std::move(other.permitted_dirs);
  icon = std::move(other.icon);
  return *this;
}

void swap(AppDetails& lhs, AppDetails& rhs) MAIDSAFE_NOEXCEPT {
  using std::swap;
  swap(lhs.name, rhs.name);
  swap(lhs.path, rhs.path);
  swap(lhs.args, rhs.args);
  swap(lhs.permitted_dirs, rhs.permitted_dirs);
  swap(lhs.icon, rhs.icon);
}

bool operator<(const AppDetails& lhs, const AppDetails& rhs) { return lhs.name < rhs.name; }

}  // namespace launcher

}  // namespace maidsafe
