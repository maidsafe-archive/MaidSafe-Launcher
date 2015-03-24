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

#include "maidsafe/launcher/ui/controllers/account_handler_controller.h"

#include "maidsafe/launcher/ui/helpers/main_window.h"
#include "maidsafe/launcher/ui/models/account_handler_model.h"

namespace maidsafe {

namespace launcher {

namespace ui {

AccountHandlerController::AccountHandlerController(MainWindow& main_window,
                                                   QObject* parent)
    : QObject{parent},
      main_window_{main_window},
      account_handler_model_{new AccountHandlerModel{this}} {
  Q_ASSERT_X(connect(account_handler_model_, SIGNAL(LoginResultAvailable()), this,
                     SLOT(LoginResultAvailable()), Qt::QueuedConnection),
             "Connection Failure",
             "Account Handler Model must implement signal void LoginResultAvailable()");

  Q_ASSERT_X(connect(account_handler_model_, SIGNAL(CreateAccountResultAvailable()), this,
                     SLOT(CreateAccountResultAvailable()), Qt::QueuedConnection),
             "Connection Failure",
             "Account Handler Model must implement signal void CreateAccountResultAvailable()");
}

AccountHandlerController::~AccountHandlerController() {
  if (future_.valid()) {
    future_.wait();
  }
}

AccountHandlerController::AccountHandlingViews AccountHandlerController::currentView() const {
  return current_view_;
}

void AccountHandlerController::SetCurrentView(const AccountHandlingViews new_current_view) {
  if (new_current_view != current_view_) {
    current_view_ = new_current_view;
    emit currentViewChanged(current_view_);
  }
}

void AccountHandlerController::login(const QString& pin, const QString& keyword,
                                     const QString& password) {
  if (!future_.valid()) {
    future_ = std::async(std::launch::async,
                         [=] { return account_handler_model_->Login(pin, keyword, password); });
  }
}

void AccountHandlerController::showLoginView() {
  SetCurrentView(LoginView);
}

void AccountHandlerController::createAccount(const QString& pin, const QString& keyword,
                                             const QString& password) {
  if (!future_.valid()) {
    future_ =
        std::async(std::launch::async,
                   [=] { return account_handler_model_->CreateAccount(pin, keyword, password); });
  }
}

void AccountHandlerController::showCreateAccountView() {
  SetCurrentView(CreateAccountView);
}

void AccountHandlerController::Invoke() {
  main_window_.centerToScreen();
  main_window_.show();
}

void AccountHandlerController::LoginResultAvailable() {
  try {
    auto launcher(future_.get());
    emit LoginCompleted(launcher.release());
  }
  catch (...) {
  }
}

void AccountHandlerController::CreateAccountResultAvailable() {
  try {
    auto launcher(future_.get());
    emit loginError();
  }
  catch (...) {
  }
}

}  // namespace ui

}  // namespace launcher

}  // namespace maidsafe
