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
#include "maidsafe/launcher/ui/helpers/qt_push_headers.h"
#include "maidsafe/launcher/ui/helpers/qt_pop_headers.h"
#include "maidsafe/launcher/ui/models/api_model.h"

namespace maidsafe {

namespace launcher {

namespace ui {

namespace controllers {

MainController::MainController(QObject* parent)
    : QObject{parent},
      api_model_{new models::APIModel{this}},
      account_handler_controller_{new AccountHandlerController{this}} {
  RegisterQtMetaTypes();
  RegisterQmlTypes();
  QTimer::singleShot(0, this, SLOT(EventLoopStarted()));
}

void MainController::EventLoopStarted() {
  main_window_.reset(new MainWindow);

  SetContexProperties();

  main_window_->setSource(QUrl{"qrc:/views/MainWindow.qml"});
  main_window_->setWidth(300);
  main_window_->setHeight(400);
  main_window_->CenterToScreen();
  main_window_->show();
}

MainController::MainViews MainController::currentView() const { return current_view_; }

void MainController::setCurrentView(const MainViews new_current_view) {
  if (new_current_view != current_view_) {
    current_view_ = new_current_view;
    emit currentViewChanged(current_view_);
  }
}

bool MainController::eventFilter(QObject* object, QEvent* event) {
  if (object == this && event->type() >= QEvent::User && event->type() <= QEvent::MaxUser) {
    UnhandledException();
    return true;
  }
  return QObject::eventFilter(object, event);
}

void MainController::UnhandledException() {
  // TODO (spandan) inform the user
  qApp->quit();
}

void MainController::RegisterQmlTypes() const {
  qmlRegisterUncreatableType<MainController>(
        "MainController",
        1, 0,
        "MainController",
        "Error!! Attempting to access uncreatable type - MainController");
  qmlRegisterUncreatableType<AccountHandlerController>(
        "AccountHandler",
        1, 0,
        "AccountHandlerController",
        "Error!! Attempting to access uncreatable type - AccountHandlerController");

}

void MainController::RegisterQtMetaTypes() const {
  qRegisterMetaType<MainController::MainViews>("MainViews");
}

void MainController::SetContexProperties() const {
  auto root_context(main_window_->rootContext());
  root_context->setContextProperty("mainController", this);
}


}  // namespace controllers

}  // namespace ui 

}  // namespace launcher

}  // namespace maidsafe

