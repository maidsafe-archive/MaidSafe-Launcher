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

#include "maidsafe/launcher/client_interface.h"

#include "maidsafe/common/serialisation/serialisation.h"

#include "maidsafe/launcher/directory_info.h"

namespace maidsafe {

namespace launcher {

ClientInterface::ClientInterface() : asio_service_(1), promise_() {}

std::future<std::vector<DirectoryInfo>> ClientInterface::RegisterSessionKey(
    asymm::PublicKey public_key, tcp::Port port) {
  public_key_ = std::move(public_key);
  port_ = port;
  asio_service_.service().post([this] { this->DoRegisterSessionKey(); });
  return promise_.get_future();
}

void ClientInterface::DoRegisterSessionKey() {
  try {
    tcp::ConnectionPtr tcp_connection{tcp::Connection::MakeShared(asio_service_, port_)};
    tcp_connection->Start([this](std::string message) { HandleReply(std::move(message)); },
                          [this] {});  // FIXME OnConnectionClosed
    tcp_connection->Send(ConvertToString(public_key_));
  } catch (const std::exception& e) {
    LOG(kError) << boost::diagnostic_information(e);
    promise_.set_exception(std::current_exception());
  }
}

void ClientInterface::HandleReply(std::string message) {
  try {
    auto directories(ConvertFromString<std::vector<DirectoryInfo>>(std::move(message)));
    if (directories.empty())
      BOOST_THROW_EXCEPTION(MakeError(CommonErrors::uninitialised));
    promise_.set_value(std::move(directories));
  } catch (const std::exception& e) {
    LOG(kError) << boost::diagnostic_information(e);
    promise_.set_exception(std::current_exception());
  }
}

}  // namespace launcher

}  // namespace maidsafe
