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

#ifndef MAIDSAFE_LAUNCHER_LAUNCH_H_
#define MAIDSAFE_LAUNCHER_LAUNCH_H_

#include <chrono>

#include "asio/io_service_strand.hpp"
#include "asio/steady_timer.hpp"

#include "maidsafe/common/asio_service.h"
#include "maidsafe/common/config.h"
#include "maidsafe/common/tcp/connection.h"
#include "maidsafe/common/tcp/listener.h"

#include "maidsafe/launcher/types.h"

namespace maidsafe {

namespace launcher {

struct Launch {
  Launch(AppName name_in, AsioService& asio_service,
         const std::chrono::steady_clock::duration& expiry_time)
      : name(std::move(name_in)),
        strand(asio_service.service()),
        timer(asio_service.service(), expiry_time),
        connection() {}
  Launch() = delete;
  ~Launch() = default;
  Launch(const Launch&) = delete;
  Launch(Launch&&) = delete;
  Launch& operator=(const Launch&) = delete;
  Launch& operator=(Launch&&) = delete;

  AppName name;
  asio::io_service::strand strand;
  asio::steady_timer timer;
  tcp::ConnectionPtr connection;
  tcp::ListenerPtr listener;
};

}  // namespace launcher

}  // namespace maidsafe

#endif  // MAIDSAFE_LAUNCHER_LAUNCH_H_
