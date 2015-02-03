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

#ifndef MAIDSAFE_LAUNCHER_APP_HANDSHAKE_H_
#define MAIDSAFE_LAUNCHER_APP_HANDSHAKE_H_

#include <condition_variable>
#include <functional>
#include <mutex>
#include <set>

#include "asio/io_service.hpp"
#include "asio/io_service_strand.hpp"

#include "maidsafe/directory_info.h"
#include "maidsafe/common/rsa.h"
#include "maidsafe/common/tcp/connection.h"
#include "maidsafe/common/tcp/listener.h"

namespace maidsafe {

namespace launcher {

class AppHandshake {
 public:
  AppHandshake(asio::io_service& io_service, std::set<DirectoryInfo> permitted_dirs);
  ~AppHandshake();
  tcp::Port ListeningPort() const;
  asymm::PublicKey AppSessionPublicKey();

 private:
  void OnConnection(tcp::ConnectionPtr connection);
  void OnConnectionClosed();
  void OnMessage(tcp::Message message);

  asio::io_service::strand strand_;
  tcp::ListenerPtr listener_;
  tcp::ConnectionPtr connection_;
  std::mutex mutex_;
  std::condition_variable cond_var_;
  std::set<DirectoryInfo> permitted_dirs_;
  bool reply_received_;
};

}  // namespace launcher

}  // namespace maidsafe

#endif  // MAIDSAFE_LAUNCHER_APP_HANDSHAKE_H_
