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

#ifdef _MSC_VER
#include <windows.h>
#else
#include <signal.h>
#endif

#include <future>
#include <iostream>

#include "maidsafe/common/error.h"
#include "maidsafe/common/log.h"

#include "maidsafe/launcher/launcher.h"

namespace {

std::promise<void> g_shutdown_promise;

void ShutDownLauncher(int /*signal*/) {
  std::cout << "Stopping launcher." << std::endl;
  g_shutdown_promise.set_value();
}

#ifdef _MSC_VER

BOOL CtrlHandler(DWORD control_type) {
  switch (control_type) {
    case CTRL_C_EVENT:
    case CTRL_CLOSE_EVENT:
    case CTRL_SHUTDOWN_EVENT:
      ShutDownLauncher(0);
      return TRUE;
    default:
      return FALSE;
  }
}

#endif


}  // unnamed namespace

int main(int argc, char** argv) {
  using Launcher = maidsafe::launcher::Launcher;
  maidsafe::log::Logging::Instance().Initialise(argc, argv);
  try {
#ifdef _MSC_VER
    if (SetConsoleCtrlHandler(reinterpret_cast<PHANDLER_ROUTINE>(CtrlHandler), TRUE)) {
      std::unique_ptr<Launcher> launcher(Launcher::CreateAccount("aaaaa", 1111, "bbbbb"));
      g_shutdown_promise.get_future().get();
      launcher->LogoutAndStop();
    } else {
      LOG(kError) << "Failed to set control handler.";
      return maidsafe::ErrorToInt(MakeError(maidsafe::CommonErrors::unable_to_handle_request));
    }
#else
    std::unique_ptr<Launcher> launcher(Launcher::CreateAccount("aaaaa", 1111, "bbbbb"));
    signal(SIGINT, ShutDownLauncher);
    signal(SIGTERM, ShutDownLauncher);
    g_shutdown_promise.get_future().get();
    launcher->LogoutAndStop();
#endif
  } catch (const maidsafe::maidsafe_error& error) {
    LOG(kError) << "Error: " << boost::diagnostic_information(error);
    return maidsafe::ErrorToInt(error);
  } catch (const std::exception& e) {
    LOG(kError) << "Error: " << e.what();
    return maidsafe::ErrorToInt(MakeError(maidsafe::CommonErrors::unknown));
  }

  return 0;
}
