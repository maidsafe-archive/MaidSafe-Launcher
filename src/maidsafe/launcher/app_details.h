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

#ifndef MAIDSAFE_LAUNCHER_APP_DETAILS_H_
#define MAIDSAFE_LAUNCHER_APP_DETAILS_H_

#include <cstdint>
#include <string>
#include <set>

#include "boost/filesystem/path.hpp"

#include "maidsafe/common/config.h"
#include "maidsafe/common/serialisation/serialisation.h"
#include "maidsafe/directory_info.h"

namespace maidsafe {

namespace launcher {

struct AppDetails {
  AppDetails();

  AppDetails(const AppDetails&) = default;
  AppDetails(AppDetails&& other) MAIDSAFE_NOEXCEPT;
  AppDetails& operator=(const AppDetails&) = default;
  AppDetails& operator=(AppDetails&& other) MAIDSAFE_NOEXCEPT;

  std::string name;
  boost::filesystem::path path;
  std::string args;
  std::set<DirectoryInfo> permitted_dirs;
  SerialisedData icon;
  bool auto_start;
};

void swap(AppDetails& lhs, AppDetails& rhs) MAIDSAFE_NOEXCEPT;

bool operator<(const AppDetails& lhs, const AppDetails& rhs);

}  // namespace launcher

}  // namespace maidsafe

#endif  // MAIDSAFE_LAUNCHER_APP_DETAILS_H_
