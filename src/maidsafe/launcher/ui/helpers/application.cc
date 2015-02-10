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

#include "maidsafe/launcher/ui/helpers/application.h"

#include "maidsafe/common/log.h"
#include "maidsafe/launcher/ui/controllers/main_controller.h"

namespace maidsafe {

namespace launcher {

namespace ui {

ExceptionEvent::ExceptionEvent(const QString& exception_message, Type type)
    : QEvent(type), exception_message_(exception_message) {}

ExceptionEvent::~ExceptionEvent() = default;

QString ExceptionEvent::ExceptionMessage() { return exception_message_; }

Application::Application(int& argc, char** argv)
    : QApplication(argc, argv),
      handler_object_(),
      translators_(),
      current_translator_(),
      shared_memory_() {
  maidsafe::log::Logging::Instance().Initialise(argc, argv);
  CreateTranslators();
  SwitchLanguage("en");
}

QStringList Application::AvailableTranslations() { return QStringList(translators_.keys()); }

void Application::SwitchLanguage(QString language) {
  if (current_translator_)
    removeTranslator(current_translator_);

  current_translator_ = translators_.value(language, nullptr);
  if (current_translator_)
    installTranslator(current_translator_);
}

bool Application::notify(QObject* receiver, QEvent* event) {
  try {
    return QApplication::notify(receiver, event);
  }
  catch (...) {
    if (handler_object_) {
      QApplication::instance()->postEvent(&(*handler_object_),
                                          new ExceptionEvent(tr("Unknown Exception")));
    } else {
      QApplication::quit();
    }
  }
  return false;
}

void Application::SetErrorHandler(boost::optional<MainController&> handler_object) {
  if (handler_object)
    handler_object_ = handler_object;
}

bool Application::IsUniqueInstance() {
  shared_memory_.setKey("SAFE_APP_LAUNCHER");
  return shared_memory_.create(1);
}

void Application::CreateTranslators() {
  if (!translators_.isEmpty())
    return;
  QStringList languages;
  languages << "en"
            << "fr"
            << "es";
  foreach(QString language, languages) {
    QTranslator* translator = new QTranslator(instance());
    translator->load(language);
    translators_.insert(language, translator);
  }
}

}  // namespace ui

}  // namespace launcher

}  // namespace maidsafe
