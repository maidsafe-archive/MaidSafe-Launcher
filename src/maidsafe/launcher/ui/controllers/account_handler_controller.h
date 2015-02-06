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

#ifndef MAIDSAFE_LAUNCHER_UI_CONTROLLERS_ACCOUNT_HANDLER_CONTROLLER_H_
#define MAIDSAFE_LAUNCHER_UI_CONTROLLERS_ACCOUNT_HANDLER_CONTROLLER_H_

#include <memory>
#include <future>

#include "maidsafe/launcher/ui/helpers/qt_push_headers.h"
#include "maidsafe/launcher/ui/helpers/qt_pop_headers.h"

#include "maidsafe/common/config.h"

namespace maidsafe {

namespace launcher {

struct Launcher;

namespace ui {

class AccountHandlerModel;
class MainWindow;

class AccountHandlerController : public QObject {
  Q_OBJECT

  Q_ENUMS(AccountHandlingViews)
  Q_PROPERTY(AccountHandlingViews currentView READ currentView NOTIFY currentViewChanged FINAL)

 public:
  enum AccountHandlingViews {
    LoginView,
    CreateAccountView,
  };

  AccountHandlerController(MainWindow& main_window, QObject* parent);
  ~AccountHandlerController() override;
  AccountHandlerController(AccountHandlerController&&) = delete;
  AccountHandlerController(const AccountHandlerController&) = delete;
  AccountHandlerController& operator=(AccountHandlerController&&) = delete;
  AccountHandlerController& operator=(const AccountHandlerController&) = delete;

  AccountHandlingViews currentView() const;
  void SetCurrentView(const AccountHandlingViews new_current_view);

  Q_INVOKABLE void login(const QString& pin, const QString& keyword, const QString& password);
  Q_INVOKABLE void showLoginView();
  Q_INVOKABLE void createAccount(const QString& pin, const QString& keyword,
                                 const QString& password);
  Q_INVOKABLE void showCreateAccountView();

 signals: // NOLINT - Spandan
  void LoginCompleted(Launcher* launcher);
  void currentViewChanged(AccountHandlingViews arg);

 private slots:  // NOLINT - Spandan
  void Invoke();
  void LoginResultAvailable();
  void CreateAccountResultAvailable();

 private:
  MainWindow& main_window_;
  AccountHandlerModel* account_handler_model_{nullptr};
  std::future<std::unique_ptr<Launcher>> future_;

  AccountHandlingViews current_view_{LoginView};
};

}  // namespace ui

}  // namespace launcher

}  // namespace maidsafe

#endif  // MAIDSAFE_LAUNCHER_UI_CONTROLLERS_ACCOUNT_HANDLER_CONTROLLER_H_
