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
  property var easingCurve: [ 1, 0, 0.64, 1, 1, 1 ]

  anchors.fill: parent

  states: [State {
    name: "VISIBLE"
    PropertyChanges {
      target: fadeOutItems
      opacity: 1
    }
    PropertyChanges {
      target: sharedBackgroundButton
      width: customProperties.textFieldWidth
    }
    PropertyChanges {
      target: pinTextField
      width: customProperties.textFieldWidth
      y: accountHandlerView.bottomButtonY -
         customProperties.blueButtonMargin -
         customProperties.textFieldHeight*3 -
         customProperties.textFieldVerticalSpacing*3
      backgroundColor: customBrushes.textFieldBackground
    }
    PropertyChanges {
      target: keywordTextField
      width: customProperties.textFieldWidth
      y: accountHandlerView.bottomButtonY -
         customProperties.blueButtonMargin -
         customProperties.textFieldHeight*2 -
         customProperties.textFieldVerticalSpacing*2
      backgroundColor: customBrushes.textFieldBackground
    }
    PropertyChanges {
      target: passwordTextField
      width: customProperties.textFieldWidth
      y: accountHandlerView.bottomButtonY -
         customProperties.blueButtonMargin -
         customProperties.textFieldHeight -
         customProperties.textFieldVerticalSpacing
      backgroundColor: customBrushes.textFieldBackground
    }
  }, State {
    name: "HIDDEN"
    PropertyChanges {
      target: fadeOutItems
      opacity: 0
    }
    PropertyChanges {
      target: sharedBackgroundButton
      width: customProperties.cancelButtonWidth
    }
    PropertyChanges {
      target: pinTextField
      width: customProperties.cancelButtonWidth
      y: accountHandlerView.bottomButtonY
      backgroundColor: customBrushes.buttonDefaultBlue
    }
    PropertyChanges {
      target: keywordTextField
      width: customProperties.cancelButtonWidth
      y: accountHandlerView.bottomButtonY
      backgroundColor: customBrushes.buttonDefaultBlue
    }
    PropertyChanges {
      target: passwordTextField
      width: customProperties.cancelButtonWidth
      y: accountHandlerView.bottomButtonY
      backgroundColor: customBrushes.buttonDefaultBlue
    }
  }]

  transitions: [Transition {
      from: "HIDDEN"; to: "VISIBLE"
//      SequentialAnimation {
/*        PauseAnimation {
          duration: 500
        }*/
        ScriptAction {
            script: {
              loginForm.visible = true
              accountHandlerView.currentView = loginForm
              pinTextField.focus = true
              pinTextField.cursorPosition = pinTextField.text.length
            }
         }
/*        NumberAnimation {
            duration: 1000
            easing.type: Easing.OutQuad
            properties: "width,y,opacity"
        }
        ScriptAction {
           script: {
           }
        }*/
//      }
  },Transition {
      from: "VISIBLE"; to: "HIDDEN"
      SequentialAnimation {
        ParallelAnimation {
          NumberAnimation {
              target: fadeOutItems; property: "opacity"
              duration: 1000; easing.type: Easing.Bezier; easing.bezierCurve: easingCurve
          }
          NumberAnimation {
              target: sharedBackgroundButton; property: "width"
              duration: 1000; easing.type: Easing.Bezier; easing.bezierCurve: easingCurve
          }
          SequentialAnimation {
            PauseAnimation { duration: 200 }
            ParallelAnimation {
              NumberAnimation {
                  target: pinTextField; properties: "width,y"
                  duration: 800; easing.type: Easing.Bezier; easing.bezierCurve: easingCurve
              }
              ColorAnimation {target: pinTextField; property: "backgroundColor"
                duration: 800; easing.type: Easing.Bezier; easing.bezierCurve: easingCurve
              }
            }
          }
          SequentialAnimation {
            PauseAnimation { duration: 100 }
            ParallelAnimation {
              NumberAnimation {
                  target: keywordTextField; properties: "width,y"
                  duration: 900; easing.type: Easing.Bezier; easing.bezierCurve: easingCurve
              }
              ColorAnimation {target: keywordTextField; property: "backgroundColor"
                duration: 900; easing.type: Easing.Bezier; easing.bezierCurve: easingCurve
              }
            }
          }
          ParallelAnimation {
            NumberAnimation {
                target: passwordTextField; properties: "width,y"
                duration: 1000; easing.type: Easing.Bezier; easing.bezierCurve: easingCurve
            }
            ColorAnimation {target: passwordTextField; property: "backgroundColor"
              duration: 1000; easing.type: Easing.Bezier; easing.bezierCurve: easingCurve
            }
          }
        }
        ScriptAction {
           script: {
             loginForm.visible = false
           }
        }
      }
  }]


  CustomTextField {
      id: pinTextField
      placeholderText: qsTr("PIN")
      submitButton: loginButton
      Component.onCompleted: {
        forceActiveFocus()
      }
  }

  CustomTextField {
      id: keywordTextField
      placeholderText: qsTr("Keyword")
      submitButton: loginButton
  }

  CustomTextField {
      id: passwordTextField
      placeholderText: qsTr("Password")
      submitButton: loginButton
  }

  Item {
    id: fadeOutItems
    anchors.fill: parent

    BlueButton {
      id: loginButton

      y: accountHandlerView.bottomButtonY

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
            accountHandlerView.fromState = "LOGIN"
            accountHandlerView.state = "LOADING"
            accountHandlerController_.createAccount(pinTextField.text,
                                                    keywordTextField.text,
                                                    passwordTextField.text)
            //accountHandlerController_.LoginCompleted
          }
      }
    }

    Rectangle { // white line
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

      y: accountHandlerView.height - height - customProperties.clickableTextBottomMargin

      text: qsTr("Don't have an account yet? Create one")
      onClicked: {
        accountHandlerView.fromState = "LOGIN"
        accountHandlerView.state = "REGISTER"
      }
    }
  }
}
