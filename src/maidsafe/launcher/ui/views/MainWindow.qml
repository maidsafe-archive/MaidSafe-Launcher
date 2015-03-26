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

import SAFEAppLauncher.MainController 1.0

import "./detail"

Item {
  id: mainWindowItem
  objectName: "mainWindowItem"

  FontLoader       { id: globalFontFamily; name      : "OpenSans"         }
  GlobalBrushes    { id: globalBrushes;    objectName: "globalBrushes"    }
  GlobalProperties { id: globalProperties; objectName: "globalProperties" }

  Image {
    // TODO(Spandan) Check this for other flavours of linux and for stability
    readonly property int correctionFactor: Qt.platform.os === "linux" ? -1 : 0

    Component.onCompleted: {
      mainWindow_.width = implicitWidth
      mainWindow_.minimumWidth = implicitWidth
      mainWindow_.maximumWidth = implicitWidth

      mainWindow_.height = implicitHeight
      mainWindow_.minimumHeight = implicitHeight
      mainWindow_.maximumHeight = implicitHeight + correctionFactor

      if (Qt.platform.os !== "linux") {
        mainWindowTitleBar.maximiseRestoreEnabled = false
        globalWindowResizeHelper.enabled = false
      }
    }

    Component.onDestruction: {
      if (Qt.platform.os !== "linux") {
        mainWindowTitleBar.maximiseRestoreEnabled = true
        globalWindowResizeHelper.enabled = true
      }
    }

    source: "/resources/images/login_bg.png"
    anchors.fill: parent
  }

  // when the controller say login success and go to HomePage
  Connections {
    target: mainController_
    onCurrentViewChanged: {
      if (mainController_.currentView === MainController.HomePage) {
        // hide buttons/logo and launch the rocket
        accountHandlerLoader.item.showSuccess();
      }
    }
  }

  // when the rocket finished going up
  Connections {
    target: accountHandlerLoader.item
    onShowSuccessFinished: {
      // unload accountHandler view and show
      accountHandlerLoader.source = ""
      customTitleBarLoader.item.showHomePageControls()
    }
  }

  Loader {
    id: accountHandlerLoader

    width: parent.width
    height: parent.height
    source: "account_handling/AccountHandlerView.qml"
    focus: true
  }

  Loader {
    id: customTitleBarLoader
    anchors.fill: parent
    source: {
//      if (Qt.platform.os === "windows") {
        "../custom_components/CustomTitleBarWindows.qml"
//      } else if (Qt.platform.os === "osx") {
//        "../custom_components/CustomTitleBarMacOs.qml"
//      } else {
//        "../custom_components/CustomTitleBarLinux.qml"
//      }
    }
  }
}
