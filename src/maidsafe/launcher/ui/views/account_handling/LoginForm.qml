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

import "../../custom_components"

Item {
  property Item bottomButton: loginButton

  anchors.fill: parent

  states: [State {
    name: "VISIBLE"
    PropertyChanges {
      target: loginForm
      opacity: 1
    }
    PropertyChanges {
      target: pinTextField
      width: customProperties.textFieldWidth
      y: accountHandlerView.bottomButtonY - customProperties.blueButtonMargin - customProperties.textFieldHeight*3 - customProperties.textFieldVerticalSpacing*3
    }
    PropertyChanges {
      target: keywordTextField
      width: customProperties.textFieldWidth
      y: accountHandlerView.bottomButtonY - customProperties.blueButtonMargin - customProperties.textFieldHeight*2 - customProperties.textFieldVerticalSpacing*2
    }
    PropertyChanges {
      target: passwordTextField
      width: customProperties.textFieldWidth
      y: accountHandlerView.bottomButtonY - customProperties.blueButtonMargin - customProperties.textFieldHeight - customProperties.textFieldVerticalSpacing
    }
    PropertyChanges {
      target: sharedBackgroundButton
      width: customProperties.textFieldWidth
    }
  }, State {
    name: "HIDDEN"
    PropertyChanges {
      target: loginForm
      opacity: 0
    }
    PropertyChanges {
      target: pinTextField
      width: customProperties.cancelButtonWidth +60
      y: accountHandlerView.bottomButtonY
    }
    PropertyChanges {
      target: keywordTextField
      width: customProperties.cancelButtonWidth +40
      y: accountHandlerView.bottomButtonY
    }
    PropertyChanges {
      target: passwordTextField
      width: customProperties.cancelButtonWidth +20
      y: accountHandlerView.bottomButtonY
    }
  }]

  transitions: [Transition {
      from: "HIDDEN"; to: "VISIBLE"
      SequentialAnimation {
        PauseAnimation {
          duration: 500
        }
        ScriptAction {
            script: {
              loginForm.visible = true
              accountHandlerView.currentView = loginForm
              pinTextField.forceActiveFocus()
            }
         }
        NumberAnimation {
            duration: 1000
            easing.type: Easing.OutQuad
            properties: "width,y,opacity"
        }
        ScriptAction {
           script: {
           }
        }
      }
  },Transition {
      from: "VISIBLE"; to: "HIDDEN"
      SequentialAnimation {
        NumberAnimation {
            duration: 1000
            easing.type: Easing.InQuad
            properties: "width,y,opacity"
        }
        ScriptAction {
           script: {
             loginForm.visible = false
           }
        }
      }
  }]



  FloatingStatusBox {
      id: floatingStatus

      anchors {
        left: pointToItem.right
        leftMargin: 15
      }
      pointToItem: pinTextField
      infoText.color: globalBrushes.textError
      yOffset: pointToItem.y
  }

  CustomTextField {
      id: pinTextField

      placeholderText: qsTr("PIN")
      echoMode: TextInput.Password
      Keys.onEnterPressed: loginButton.clicked()
      Keys.onReturnPressed: loginButton.clicked()
      onTextChanged: {
        if (floatingStatus.pointToItem === pinTextField && floatingStatus.visible) {
          floatingStatus.visible = false
        }
      }
  }

  CustomTextField {
      id: keywordTextField

      placeholderText: qsTr("Keyword")
      echoMode: TextInput.Password
      Keys.onEnterPressed: loginButton.clicked()
      Keys.onReturnPressed: loginButton.clicked()
      onTextChanged: {
        if (floatingStatus.pointToItem === keywordTextField && floatingStatus.visible) {
          floatingStatus.visible = false
        }
      }
  }

  CustomTextField {
      id: passwordTextField

      placeholderText: qsTr("Password")
      echoMode: TextInput.Password
      Keys.onEnterPressed: loginButton.clicked()
      Keys.onReturnPressed: loginButton.clicked()
      onTextChanged: {
        if (floatingStatus.pointToItem === passwordTextField && floatingStatus.visible) {
          floatingStatus.visible = false
        }
      }
  }

  BlueButton {
    id: loginButton

    y: accountHandlerView.bottomButtonY

    text: qsTr("LOG IN")

    onClicked: {
        floatingStatus.visible = false
        pinTextField.clearAllImages()
        keywordTextField.clearAllImages()
        passwordTextField.clearAllImages()

        if (pinTextField.text === "") {
            pinTextField.showErrorImage = true
            floatingStatus.pointToItem = pinTextField
            floatingStatus.infoText.text = qsTr("PIN cannot be left blank")
            floatingStatus.visible = true
        } else if (keywordTextField.text === "") {
          keywordTextField.showErrorImage = true
          floatingStatus.pointToItem = keywordTextField
          floatingStatus.infoText.text = qsTr("Keyword cannot be left blank")
          floatingStatus.visible = true
        } else if (passwordTextField.text === "") {
          passwordTextField.showErrorImage = true
          floatingStatus.pointToItem = passwordTextField
          floatingStatus.infoText.text = qsTr("Password cannot be left blank")
          floatingStatus.visible = true
        } else {
            accountHandlerView.fromState = "LOGIN"
            accountHandlerView.state = "LOADING"
        }
    }
  }

  Rectangle { // white line
      width: customProperties.textFieldWidth
      height: 1
      anchors.horizontalCenter: parent.horizontalCenter
      y: accountHandlerView.height - registerButton.height - customProperties.clickableTextBottomMargin -4
      color: "#ffffff"
  }

  ClickableText {
    id: registerButton

    anchors.horizontalCenter: parent.horizontalCenter
    y: accountHandlerView.height - height - customProperties.clickableTextBottomMargin

    text: qsTr("Don't have an account yet? Create one")
    onClicked: {
      accountHandlerView.fromState = "LOGIN"
      accountHandlerView.state = "REGISTER"
    }
  }
}
