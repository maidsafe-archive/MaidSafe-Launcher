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

#include "maidsafe/launcher/ui/controllers/main_window.h"

#include <QDesktopWidget>

namespace maidsafe {

namespace launcher {

namespace ui {

namespace controllers {

MainWindow::MainWindow(const QUrl& source_qml_file, QWindow* parent /*= nullptr*/)
  : QQuickView{source_qml_file, parent}
{
  setWidth(300);
  setHeight(400);

  setResizeMode(QQuickView::SizeRootObjectToView);

  auto screen_width(QDesktopWidget{}.screen()->width());
  auto screen_height(QDesktopWidget{}.screen()->height());
  setGeometry(screen_width / 2 - width() / 2, screen_height / 2 - height() / 2, width(), height());
}

MainWindow::~MainWindow() = default;

}  // namespace controllers

}  // namespace ui

}  // namespace launcher

}  // namespace maidsafe
