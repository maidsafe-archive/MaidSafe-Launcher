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

#ifndef MAIDSAFE_LAUNCHER_TYPES_H_
#define MAIDSAFE_LAUNCHER_TYPES_H_

#include <cstdint>
#include <string>
#include <vector>

#ifdef ROUTING_AND_NFS_UPDATED

#ifdef USE_FAKE_STORE
#include "maidsafe/nfs/client/fake_store.h"
#else
#include "maidsafe/nfs/client/data_getter.h"
#include "maidsafe/nfs/client/maid_client.h"
#endif

#else

#include "maidsafe/common/data_buffer.h"

#endif

namespace maidsafe {

namespace launcher {

using AppName = std::string;
using AppArgs = std::string;
using Keyword = std::vector<unsigned char>;
using Pin = std::uint32_t;
using Password = std::vector<unsigned char>;

// Once Routing and NFS are updated, this block should be reduced to just the #ifdef USE_FAKE_STORE
// ... #else ... #endif block.  Other blocks inside ROUTING_AND_NFS_UPDATED guards should be handled
// similarly.
#ifdef ROUTING_AND_NFS_UPDATED

#ifdef USE_FAKE_STORE
#ifndef TESTING
#error USE_FAKE_STORE must only be defined if TESTING is also defined
#endif
using NetworkClient = nfs::FakeStore;
using DataGetter = nfs::FakeStore;
#else
using NetworkClient = nfs_client::MaidClient;
using DataGetter = nfs_client::DataGetter;
#endif

#else

using NetworkClient = DataBuffer;
using DataGetter = DataBuffer;

#endif

}  // namespace launcher

}  // namespace maidsafe

#endif  // MAIDSAFE_LAUNCHER_TYPES_H_
