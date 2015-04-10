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
  id: loginView

  readonly property LoadingView loadingView: loadingView
  property Item bottomButton: loginButton
  readonly property Item focusTextField: pinTextField

  states: [State {
      name: "LOADING"

      PropertyChanges {
        target: loginView
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
    ScriptAction {
      script: {
        loginElements.visible = true
        loadingView.visible = false
        pinTextField.focus = true
        pinTextField.cursorPosition = pinTextField.text.length
      }
    }

  },Transition {

    to: "LOADING"
    SequentialAnimation {
      ScriptAction {
        script: loadingView.visible = true
      }
      ParallelAnimation {
        NumberAnimation {
          target: fadeOutItems; property: "opacity"
          duration: 800; easing.type: Easing.Bezier
          easing.bezierCurve: globalProperties.animationColapseEasingCurve
        }
        NumberAnimation {
          target: loginButton; properties: "backgroundWidth,textOpacity"
          duration: 800; easing.type: Easing.Bezier
          easing.bezierCurve: globalProperties.animationColapseEasingCurve
        }
        SequentialAnimation {
          PauseAnimation { duration: 366 }
          NumberAnimation {
            target: pinTextField; property: "width"
            duration: 500; easing.type: Easing.Bezier
            easing.bezierCurve: globalProperties.animationColapseEasingCurve
          }
        }
        SequentialAnimation {
          PauseAnimation { duration: 300 }
          ParallelAnimation {
            NumberAnimation {
              target: pinTextField; property: "y"
              duration: 500; easing.type: Easing.Bezier
              easing.bezierCurve: globalProperties.animationColapseEasingCurve
            }
            ColorAnimation {target: pinTextField; properties: "backgroundColor,textColor"
              duration: 560; easing.type: Easing.Bezier
              easing.bezierCurve: globalProperties.animationColapseEasingCurve
            }
          }
        }
        SequentialAnimation {
          PauseAnimation { duration: 266 }
          NumberAnimation {
            target: keywordTextField; property: "width"
            duration: 600; easing.type: Easing.Bezier
            easing.bezierCurve: globalProperties.animationColapseEasingCurve
          }
        }
        SequentialAnimation {
          PauseAnimation { duration: 200 }
          ParallelAnimation {
            NumberAnimation {
              target: keywordTextField; property: "y"
              duration: 600; easing.type: Easing.Bezier
              easing.bezierCurve: globalProperties.animationColapseEasingCurve
            }
            ColorAnimation {target: keywordTextField; properties: "backgroundColor,textColor"
              duration: 660; easing.type: Easing.Bezier
              easing.bezierCurve: globalProperties.animationColapseEasingCurve
            }
          }
        }
        SequentialAnimation {
          PauseAnimation { duration: 166 }
          NumberAnimation {
            target: passwordTextField; property: "width"
            duration: 700; easing.type: Easing.Bezier
            easing.bezierCurve: globalProperties.animationColapseEasingCurve
          }
        }
        SequentialAnimation {
          PauseAnimation { duration: 100 }
          ParallelAnimation {
            NumberAnimation {
              target: passwordTextField; property: "y"
              duration: 700; easing.type: Easing.Bezier
              easing.bezierCurve: globalProperties.animationColapseEasingCurve
            }
            ColorAnimation {target: passwordTextField; properties: "backgroundColor,textColor"
              duration: 760; easing.type: Easing.Bezier
              easing.bezierCurve: globalProperties.animationColapseEasingCurve
            }
          }
        }
      }
      ScriptAction {
        script: loginElements.visible = false
      }
    }
  }]

  function resetFields() {
    pinTextField.text = ""
    keywordTextField.text = ""
    passwordTextField.text = ""
    floatingStatus.hide()
  }

  LoadingView {
    id: loadingView
    visible: false
    onLoadingCanceled: loginView.state = ""
    errorMessage: qsTr("There was an error logging you in.\nPlease try again.")
  }

  Item {
    id: loginElements
    anchors.fill: parent

    CustomTextField {
      id: pinTextField
      placeholderText: qsTr("PIN")
      submitButton: loginButton
      anchors.horizontalCenter: parent.horizontalCenter
      y: accountHandlerView.bottomButtonY -
         customProperties.blueButtonMargin -
         customProperties.textFieldHeight*3 -
         customProperties.textFieldVerticalSpacing*3
      focus: true
    }

    CustomTextField {
      id: keywordTextField
      placeholderText: qsTr("Keyword")
      submitButton: loginButton
      anchors.horizontalCenter: parent.horizontalCenter
      y: accountHandlerView.bottomButtonY -
         customProperties.blueButtonMargin -
         customProperties.textFieldHeight*2 -
         customProperties.textFieldVerticalSpacing*2
    }

    CustomTextField {
      id: passwordTextField
      placeholderText: qsTr("Password")
      submitButton: loginButton
      anchors.horizontalCenter: parent.horizontalCenter
      y: accountHandlerView.bottomButtonY -
         customProperties.blueButtonMargin -
         customProperties.textFieldHeight -
         customProperties.textFieldVerticalSpacing
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
          loginView.state = "LOADING"
          accountHandlerController_.login(pinTextField.text,
                                          keywordTextField.text,
                                          passwordTextField.text)
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
           createAccountButton.height -
           customProperties.clickableTextBottomMargin - 12
        color: customBrushes.bottomLineColor
      }

      ClickableText {
        id: createAccountButton

        anchors.horizontalCenter: parent.horizontalCenter
        y: accountHandlerView.height - height - customProperties.clickableTextBottomMargin

        text: qsTr("Don't have an account yet? Create one")
        onClicked: {
          accountHandlerController_.showCreateAccountView()
        }
      }
    }
  }

  FloatingStatusBox { id: floatingStatus }
}
