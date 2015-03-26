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

#include "maidsafe/launcher/ui/controllers/main_controller.h"

#include "maidsafe/launcher/ui/controllers/account_handler_controller.h"
#include "maidsafe/launcher/ui/helpers/main_window.h"
#include "maidsafe/launcher/ui/models/api_model.h"

// TODO(Spandan) remove when fake Launcher is removed
#include "maidsafe/launcher/ui/models/account_handler_model.h"

namespace maidsafe {

namespace launcher {

namespace ui {

MainController::MainController(QObject* parent) : QObject{parent} {
  QTimer::singleShot(0, this, SLOT(EventLoopStarted()));
}

MainController::~MainController() = default;

void MainController::EventLoopStarted() {
  main_window_.reset(new MainWindow);
  api_model_ = new APIModel{this};
  account_handler_controller_ = new AccountHandlerController{*main_window_, this};

  RegisterQtMetaTypes();
  RegisterQmlTypes();
  SetContexProperties();
  SetupConnections();

  installEventFilter(this);

  main_window_->setSource(QUrl{"qrc:/views/MainWindow.qml"});
  emit InvokeAccountHandlerController();
}

MainController::MainViews MainController::currentView() const {
  return current_view_;
}

void MainController::SetCurrentView(const MainViews new_current_view) {
  if (new_current_view != current_view_) {
    current_view_ = new_current_view;
    emit currentViewChanged(current_view_);
  }
}

void MainController::LoginCompleted(Launcher* launcherPtr) {
  std::unique_ptr<Launcher> launcher{launcherPtr};
  static_cast<void>(launcher);
  SetCurrentView(HomePage);
}

bool MainController::eventFilter(QObject* object, QEvent* event) {
  if (object == this && event->type() >= QEvent::User && event->type() <= QEvent::MaxUser) {
    UnhandledException();
    return true;
  }
  return QObject::eventFilter(object, event);
}

void MainController::UnhandledException() {
  // TODO(Spandan) inform the user
  qApp->quit();
}

void MainController::RegisterQmlTypes() const {
  qmlRegisterUncreatableType<MainController>(
      "SAFEAppLauncher.MainController", 1, 0, "MainController",
      "Error!! Attempting to access uncreatable type - MainController");
  qmlRegisterUncreatableType<AccountHandlerController>(
      "SAFEAppLauncher.AccountHandler", 1, 0, "AccountHandlerController",
      "Error!! Attempting to access uncreatable type - AccountHandlerController");
}

void MainController::RegisterQtMetaTypes() const {}

void MainController::SetupConnections() const {
  Q_ASSERT_X(connect(this, SIGNAL(InvokeAccountHandlerController()), account_handler_controller_,
                     SLOT(Invoke()), Qt::UniqueConnection),
             "Connection Failure", "Account Handler Controller must implement slot void Invoke()");
  Q_ASSERT_X(connect(account_handler_controller_, SIGNAL(LoginCompleted(Launcher*)), this, // NOLINT - Spandan
                     SLOT(LoginCompleted(Launcher*)), Qt::UniqueConnection), // NOLINT - Spandan
             "Connection Failure",
             "Account Handler Controller must implement signal void LoginCompleted(Launcher*)");
  Q_ASSERT_X(
      connect(main_window_->engine(), SIGNAL(quit()), qApp, SLOT(quit()), Qt::UniqueConnection),
      "Connection Failure", "QQmlEngine::quit() -> qApp::quit()");
}

void MainController::SetContexProperties() {
  auto root_context(main_window_->rootContext());
  root_context->setContextProperty("mainController_", this);
  root_context->setContextProperty("mainWindow_", main_window_.get());
  root_context->setContextProperty("accountHandlerController_", account_handler_controller_);
}

}  // namespace ui

}  // namespace launcher

}  // namespace maidsafe
