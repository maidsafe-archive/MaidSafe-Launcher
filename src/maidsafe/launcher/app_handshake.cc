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

#include "maidsafe/launcher/app_handshake.h"

#include "maidsafe/common/error.h"
#include "maidsafe/common/log.h"
#include "maidsafe/common/utils.h"

namespace maidsafe {

namespace launcher {

AppHandshake::AppHandshake(asio::io_service& io_service, std::set<DirectoryInfo> permitted_dirs)
    : strand_(io_service),
      listener_(tcp::Listener::MakeShared(
          strand_, [this](tcp::ConnectionPtr connection) { OnConnection(connection); },
          static_cast<tcp::Port>(RandomUint32()))),
      connection_(),
      permitted_dirs_(std::move(permitted_dirs)) {}

AppHandshake::~AppHandshake() {

}

tcp::Port AppHandshake::ListeningPort() const { return listener_->ListeningPort(); }

//asymm::PublicKey AppHandshake::AppSessionPublicKey() {

//}

void AppHandshake::OnConnection(tcp::ConnectionPtr connection) {
  connection_ = connection;
  //try {
  //  connection_->Start([&](std::string message) { OnMessage(std::move(message)); },
  //                     [&] { OnConnectionClosed(); });
  //  tcp_connection->Send(Serialise(std::move(public_key)));
  //  {
  //    std::unique_lock<std::mutex> lock{ reply_handler.mutex };
  //    reply_handler.cond_var.wait(lock, [&] {return reply_handler.reply_received; });
  //  }
  //  if (reply_handler.directories.empty())
  //    BOOST_THROW_EXCEPTION(MakeError(CommonErrors::uninitialised));
  //}
  //catch (const std::exception& e) {
  //  LOG(kError) << boost::diagnostic_information(e);
  //  throw;
  //}
  //return reply_handler.directories;
}

void AppHandshake::OnConnectionClosed() {}

void AppHandshake::OnMessage(tcp::Message /*message*/) {

}

}  //  namespace launcher

}  //  namespace maidsafe
