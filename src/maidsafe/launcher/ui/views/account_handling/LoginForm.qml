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
  id: loginForm

  property Item bottomButton: loginButton
  readonly property Item focusTextField: pinTextField

  width: parent.width
  height: parent.height

  states: [State {
      name: "LOADING"

      PropertyChanges {
        target: loginForm
        bottomButton: loadingView.bottomButton
      }
      PropertyChanges {
        target: loadingView
        state: "VISIBLE"
      }
      PropertyChanges {
        target: fadeOutItems
        opacity: 0
      }
      PropertyChanges {
        target: loginButton
        backgroundWidth: customProperties.cancelButtonWidth
        textOpacity: 0
      }
      PropertyChanges {
        target: pinTextField
        width: customProperties.cancelButtonWidth
        y: accountHandlerView.bottomButtonY
        backgroundColor: customBrushes.buttonDefaultBlue
        textColor: customBrushes.buttonDefaultBlue
      }
      PropertyChanges {
        target: keywordTextField
        width: customProperties.cancelButtonWidth
        y: accountHandlerView.bottomButtonY
        backgroundColor: customBrushes.buttonDefaultBlue
        textColor: customBrushes.buttonDefaultBlue
      }
      PropertyChanges {
        target: passwordTextField
        width: customProperties.cancelButtonWidth
        y: accountHandlerView.bottomButtonY
        backgroundColor: customBrushes.buttonDefaultBlue
        textColor: customBrushes.buttonDefaultBlue
      }
    }]

  transitions: [Transition {

    from: "LOADING"
    ScriptAction { script: {
      loginElements.visible = true
      loadingView.visible = false
      pinTextField.forceActiveFocus()
      pinTextField.cursorPosition = pinTextField.text.length
    }}

  },Transition {

    to: "LOADING"
    SequentialAnimation {
      ScriptAction { script: {
        loadingView.visible = true
      }}
      ParallelAnimation {
        NumberAnimation {
          target: fadeOutItems; property: "opacity"
          duration: 1000; easing.type: Easing.Bezier
          easing.bezierCurve: customProperties.animationColapseEasingCurve
        }
        NumberAnimation {
          target: loginButton; properties: "backgroundWidth,textOpacity"
          duration: 1000; easing.type: Easing.Bezier
          easing.bezierCurve: customProperties.animationColapseEasingCurve
        }
        SequentialAnimation {
          PauseAnimation { duration: 366 }
          NumberAnimation {
            target: pinTextField; property: "width"
            duration: 700; easing.type: Easing.Bezier
            easing.bezierCurve: customProperties.animationColapseEasingCurve
          }
        }
        SequentialAnimation {
          PauseAnimation { duration: 300 }
          ParallelAnimation {
            NumberAnimation {
              target: pinTextField; property: "y"
              duration: 600; easing.type: Easing.Bezier
              easing.bezierCurve: customProperties.animationColapseEasingCurve
            }
            ColorAnimation {target: pinTextField; properties: "backgroundColor,textColor"
              duration: 760; easing.type: Easing.Bezier
              easing.bezierCurve: customProperties.animationColapseEasingCurve
            }
          }
        }
        SequentialAnimation {
          PauseAnimation { duration: 266 }
          NumberAnimation {
            target: keywordTextField; property: "width"
            duration: 800; easing.type: Easing.Bezier
            easing.bezierCurve: customProperties.animationColapseEasingCurve
          }
        }
        SequentialAnimation {
          PauseAnimation { duration: 200 }
          ParallelAnimation {
            NumberAnimation {
              target: keywordTextField; property: "y"
              duration: 700; easing.type: Easing.Bezier
              easing.bezierCurve: customProperties.animationColapseEasingCurve
            }
            ColorAnimation {target: keywordTextField; properties: "backgroundColor,textColor"
              duration: 860; easing.type: Easing.Bezier
              easing.bezierCurve: customProperties.animationColapseEasingCurve
            }
          }
        }
        SequentialAnimation {
          PauseAnimation { duration: 166 }
          NumberAnimation {
            target: passwordTextField; property: "width"
            duration: 900; easing.type: Easing.Bezier
            easing.bezierCurve: customProperties.animationColapseEasingCurve
          }
        }
        SequentialAnimation {
          PauseAnimation { duration: 100 }
          ParallelAnimation {
            NumberAnimation {
              target: passwordTextField; property: "y"
              duration: 800; easing.type: Easing.Bezier
              easing.bezierCurve: customProperties.animationColapseEasingCurve
            }
            ColorAnimation {target: passwordTextField; properties: "backgroundColor,textColor"
              duration: 960; easing.type: Easing.Bezier
              easing.bezierCurve: customProperties.animationColapseEasingCurve
            }
          }
        }
      }
      ScriptAction { script: {
        loginElements.visible = false
      }}
    }
  }]

  LoadingView {
    id: loadingView
    visible: false
    onLoadingCanceled: loginForm.state = ""
  }

  Item {
    id: loginElements
    anchors.fill: parent

    CustomTextField {
      id: pinTextField
      placeholderText: qsTr("PIN")
      submitButton: loginButton
      width: customProperties.textFieldWidth
      y: accountHandlerView.bottomButtonY -
         customProperties.blueButtonMargin -
         customProperties.textFieldHeight*3 -
         customProperties.textFieldVerticalSpacing*3
      backgroundColor: customBrushes.textFieldBackground
      Component.onCompleted: {
        forceActiveFocus()
      }
    }

    CustomTextField {
      id: keywordTextField
      placeholderText: qsTr("Keyword")
      submitButton: loginButton
      width: customProperties.textFieldWidth
      y: accountHandlerView.bottomButtonY -
         customProperties.blueButtonMargin -
         customProperties.textFieldHeight*2 -
         customProperties.textFieldVerticalSpacing*2
      backgroundColor: customBrushes.textFieldBackground
    }

    CustomTextField {
      id: passwordTextField
      placeholderText: qsTr("Password")
      submitButton: loginButton
      width: customProperties.textFieldWidth
      y: accountHandlerView.bottomButtonY -
         customProperties.blueButtonMargin -
         customProperties.textFieldHeight -
         customProperties.textFieldVerticalSpacing
      backgroundColor: customBrushes.textFieldBackground
    }

    BlueButton {
      id: loginButton

      y: accountHandlerView.bottomButtonY
      width: customProperties.blueButtonWidth
      anchors.horizontalCenter: parent.horizontalCenter

      text: qsTr("LOG IN")

      onClicked: {
        if (pinTextField.text === "") {
          floatingStatus.showError(pinTextField, qsTr("PIN cannot be left blank"))
        } else if (keywordTextField.text === "") {
          floatingStatus.showError(keywordTextField, qsTr("Keyword cannot be left blank"))
        } else if (passwordTextField.text === "") {
          floatingStatus.showError(passwordTextField, qsTr("Password cannot be left blank"))
        } else {
          floatingStatus.hide()
          loginForm.state = "LOADING"
          accountHandlerController_.createAccount(pinTextField.text,
                                                  keywordTextField.text,
                                                  passwordTextField.text)
         // accountHandlerController_.LoginCompleted = { console.log("LoginCompleted") }
        }
      }
    }

    Item {
      id: fadeOutItems
      anchors.fill: parent

      Rectangle { // 1px white line
        width: customProperties.textFieldWidth
        height: 1
        anchors.horizontalCenter: parent.horizontalCenter
        y: accountHandlerView.height -
           registerButton.height -
           customProperties.clickableTextBottomMargin - 4
        color: "#ffffff"
      }

      ClickableText {
        id: registerButton

        anchors.horizontalCenter: parent.horizontalCenter
        y: accountHandlerView.height - height - customProperties.clickableTextBottomMargin

        text: qsTr("Don't have an account yet? Create one")
        onClicked: {
          accountHandlerView.state = "REGISTER"
        }
      }
    }
  }
}
