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

#include "maidsafe/launcher/ui/helpers/main_window.h"

#include "maidsafe/common/log.h"

namespace maidsafe {

namespace launcher {

namespace ui {

MainWindow::MainWindow(QWindow* parent) : QQuickView{parent} {
  connect(this, SIGNAL(statusChanged(QQuickView::Status)), this,
          SLOT(StatusChanged(const QQuickView::Status)), Qt::UniqueConnection);

  setResizeMode(QQuickView::SizeRootObjectToView);

#if !defined(__linux__)
  setFlags(flags() | Qt::FramelessWindowHint);
#endif
}

MainWindow::~MainWindow() = default;

void MainWindow::centerToScreen() {
  auto screen_width(QDesktopWidget{}.screen()->width());
  auto screen_height(QDesktopWidget{}.screen()->height());
  setGeometry(screen_width / 2 - width() / 2, screen_height / 2 - height() / 2, width(), height());
}

void MainWindow::StatusChanged(const QQuickView::Status status) {
  qDebug() << "QML Loading Status:";
  LOG(kAlways) << "QML Loading Status:";
  switch (status) {
    case QQuickView::Null:
      qDebug() << "Status: Null.";
      LOG(kAlways) << "Status: Null.";
      break;
    case QQuickView::Ready:
      qDebug() << "Status: Ready.";
      LOG(kAlways) << "Status: Ready.";
      break;
    case QQuickView::Loading:
      qDebug() << "Status: Loading.";
      LOG(kAlways) << "Status: Loading.";
      break;
    case QQuickView::Error:
      qDebug() << "Status: ERROR.";
      LOG(kAlways) << "Status: ERROR.";
      break;
    default:
      qDebug() << "Status: Unknown.";
      LOG(kAlways) << "Status: Unknown.";
      break;
  }
}

}  // namespace ui

}  // namespace launcher

}  // namespace maidsafe
