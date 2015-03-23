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
import SAFEAppLauncher.AccountHandler 1.0

import "./detail"
import "../../custom_components"

FocusScope {
  id: accountHandlerView

  readonly property LoadingView loadingView: currentView.loadingView

  AccountHandlerBrushes {
    id: customBrushes
    objectName: "customBrushes"
  }

  AccountHandlerProperties {
    id: customProperties
    objectName: "customProperties"
  }

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


  state: "state" + accountHandlerController_.currentView
  readonly property int bottomButtonY: accountHandlerView.height -
                                       customProperties.cancelButtonBottom -
                                       customProperties.blueButtonMargin
  property Item currentView: loginView

  states: [State {
    name: "state" + AccountHandlerController.CreateAccountView
    PropertyChanges { target: createAccountView; x: 0 }
    PropertyChanges { target: loginView; x: -mainWindow_.width }
    PropertyChanges { target: accountHandlerView; currentView: createAccountView }
  }]

  transitions: [Transition {
    from: "state" + AccountHandlerController.LoginView
    to: "state" + AccountHandlerController.CreateAccountView
    SequentialAnimation {
      ScriptAction { script: {
        createAccountView.resetFields()
        createAccountView.visible = true
        createAccountView.currentTextFields.primaryTextField.focus = true
      }}
      NumberAnimation {
        properties: "x"
        duration: 300
        easing.type: Easing.InOutQuad
      }
      ScriptAction { script: {
        loginView.visible = false
      }}
    }
  }, Transition {
    from: "state" + AccountHandlerController.CreateAccountView
    to: "state" + AccountHandlerController.LoginView
    SequentialAnimation {
      ScriptAction { script: {
        loginView.resetFields()
        loginView.visible = true
        loginView.focusTextField.focus = true
      }}
      NumberAnimation {
        properties: "x"
        duration: 300
        easing.type: Easing.InOutQuad
      }
      ScriptAction { script: {
        createAccountView.visible = false
      }}
    }
  }]

  Image {
     id: logo
     source: "/resources/images/launcher_logo.png"
     y: 50
     anchors.horizontalCenter: parent.horizontalCenter
   }

  Login {
    id: loginView
    width: parent.width
    height: parent.height
  }

  CreateAccount {
    id: createAccountView
    width: parent.width
    height: parent.height
    visible: false
    x: mainWindow_.width
  }
}
