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

#ifndef MAIDSAFE_LAUNCHER_CLIENT_INTERFACE_H_
#define MAIDSAFE_LAUNCHER_CLIENT_INTERFACE_H_

#include <future>
#include <string>
#include <thread>
#include <vector>

#include "maidsafe/common/asio_service.h"
#include "maidsafe/common/rsa.h"
#include "maidsafe/common/types.h"
#include "maidsafe/common/tcp/connection.h"

#include "maidsafe/launcher/directory_info.h"

namespace maidsafe {

namespace launcher {

// TODO(Fraser#5#): 2015-01-13 - Either pass in asio and make this inherit from
// enable_shared_from_this, or document
class ClientInterface {
 public:
  ClientInterface(const ClientInterface&) = delete;
  ClientInterface(ClientInterface&&) = delete;
  ClientInterface();

  ClientInterface& operator=(const ClientInterface&) = delete;
  ClientInterface& operator=(ClientInterface&&) = delete;

  // TODO(Fraser#5#): 2015-01-13 - Block until promise set, or exit early, set exception in promise
  // and stop asio.
  ~ClientInterface();

  // Once the future.get() returns, the session key is usable.  If future.get() throws, the session
  // key is unusable.  The value returned from the future.get() will be the list of directories
  // which this particular app is entitled to access.
  std::future<std::vector<DirectoryInfo>> RegisterSessionKey(asymm::PublicKey public_key,
                                                             tcp::Port port);

 private:
  void DoRegisterSessionKey();
  void HandleReply(std::string reply);

  AsioService asio_service_;
  std::promise<std::vector<DirectoryInfo>> promise_;
  asymm::PublicKey public_key_;
  tcp::Port port_;
};

}  // namespace launcher

}  // namespace maidsafe

#endif  // MAIDSAFE_LAUNCHER_CLIENT_INTERFACE_H_
