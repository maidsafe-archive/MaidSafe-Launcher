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

import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.3

import SAFEAppLauncher.MainController 1.0

import "./detail"
import "../custom_components"

Item {
  id: mainWindowItem
  objectName: "mainWindowItem"

  FontLoader       { id: globalFontFamily; name      : "OpenSans"         }
  GlobalBrushes    { id: globalBrushes;    objectName: "globalBrushes"    }
  GlobalProperties { id: globalProperties; objectName: "globalProperties" }

  DragMainWindowHelper {
    id: dragMainWindowHelper
    objectName: "dragMainWindowHelper"

    anchors {
      top: parent.top
      right: parent.right
      left: parent.left
      bottom: mainWindowTitleBar.bottom
      leftMargin: Qt.platform.os === "linux" || Qt.platform.os === "osx" ?
                    mainWindowTitleBar.buttonLoaderwidth + 10 : 0
      rightMargin: Qt.platform.os === "windows" ? mainWindowTitleBar.buttonLoaderwidth + 10 : 0
    }
    enabled: mainWindowTitleBar.visible
  }

  Loader {
    id: mainWindowLoader
    objectName: "mainWindowLoader"

    anchors.fill: parent
    source: mainController_.currentView === MainController.HandleAccount ?
              "account_handling/AccountHandlerView.qml"
            :
              ""
    focus: true
    onLoaded: item.focus = true
  }

  ResizeMainWindowHelper {
    id: globalWindowResizeHelper
    objectName: "globalWindowResizeHelper"

    anchors.fill: parent
    enabled: Qt.platform.os !== "linux"
  }

  CustomTitleBar {
    id: mainWindowTitleBar
    objectName: "mainWindowTitleBar"

    anchors {
      top: parent.top
      left: parent.left
      right: parent.right
      margins: 5
    }

    visible: Qt.platform.os !== "linux"
    enabled: visible
  }
}
