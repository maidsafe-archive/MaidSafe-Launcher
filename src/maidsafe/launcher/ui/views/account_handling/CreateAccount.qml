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

import SAFEAppLauncher.AccountHandler 1.0

import "../../custom_components"

Item {
  id: createAccountView

  readonly property LoadingView loadingView: loadingView

  property Item bottomButton: nextButton
  property Item currentTextFields: pinTextFields

  function checkPasswordStrength(textField) {
    var result = passwordStrength.check(textField.text)
    var text = ""
    var color = ""
    switch (result.score) {
    case 0:
    case 1:
      text = qsTr("Weak")
      color = customBrushes.textWeakPassword
      break
    case 2:
      text = qsTr("Medium")
      color = customBrushes.textMediumPassword
      break
    default:
      text = qsTr("Strong")
      color = customBrushes.textStrongPassword
      break
    }

    floatingStatus.show(textField, qsTr("Strength:"), text, color, false)
  }

  function checkBlankField(fieldName, textField) {
    if (textField.text !== "") return true

    floatingStatus.showError(textField, qsTr(fieldName + " cannot be left blank"))
    return false
  }

  function checkIdenticalField(fieldName, textField1, textField2) {
    if (textField1.text === textField2.text) return true

    floatingStatus.showError(textField2, qsTr("Entries don't match"))
    return false
  }

  readonly property var createAccountModel: [
    {text: qsTr("PIN")     , state: "PIN"},
    {text: qsTr("Keyword") , state: "KEYWORD"},
    {text: qsTr("Password"), state: "PASSWORD"}
  ]

  state: "PIN"

  states: [State {
    name: "PIN"
    PropertyChanges {
      target: pinTextFields
      visible: true
    }
    PropertyChanges {
      target: createAccountView
      currentTextFields: pinTextFields
    }

  }, State {
    name: "KEYWORD"
    PropertyChanges {
      target: keywordTextFields
      visible: true
    }
    PropertyChanges {
      target: createAccountView
      currentTextFields: keywordTextFields
    }

  }, State {
    name: "PASSWORD"
    PropertyChanges {
      target: passwordTextFields
      visible: true
    }
    PropertyChanges {
      target: createAccountView
      currentTextFields: passwordTextFields
    }

  }, State {
      name: "LOADING"

      PropertyChanges {
        target: createAccountView
        bottomButton: loadingView.bottomButton
      }
      PropertyChanges {
        target: primaryPasswordTextField
        y: accountHandlerView.bottomButtonY
        width: customProperties.cancelButtonWidth
        backgroundColor: customBrushes.buttonDefaultBlue
      }
      PropertyChanges {
        target: confirmationPasswordTextField
        y: accountHandlerView.bottomButtonY
        width: customProperties.cancelButtonWidth
        backgroundColor: customBrushes.buttonDefaultBlue
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
        target: nextButton
        backgroundWidth: customProperties.cancelButtonWidth
      }
      PropertyChanges {
        target: createAccountTabRow
        y: accountHandlerView.bottomButtonY
        opacity: 0
      }
      PropertyChanges {
        target: passwordTextFields
        visible: true
      }
    }]

  transitions: [Transition {

    from: "LOADING"
    ScriptAction {
      script: {
        createAccountElements.visible = true
        loadingView.visible = false
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
          duration: 1000; easing.type: Easing.Bezier
          easing.bezierCurve: customProperties.animationColapseEasingCurve
        }
        NumberAnimation {
          target: nextButton; property: "backgroundWidth"
          duration: 1000; easing.type: Easing.Bezier
          easing.bezierCurve: customProperties.animationColapseEasingCurve
        }
        SequentialAnimation {
          PauseAnimation { duration: 300 }
          NumberAnimation {
            target: createAccountTabRow; properties: "y,opacity"
            duration: 600; easing.type: Easing.Bezier
            easing.bezierCurve: customProperties.animationColapseEasingCurve
          }
        }
        SequentialAnimation {
          PauseAnimation { duration: 266 }
          NumberAnimation {
            target: primaryPasswordTextField; properties: "width"
            duration: 800; easing.type: Easing.Bezier
            easing.bezierCurve: customProperties.animationColapseEasingCurve
          }
        }
        SequentialAnimation {
          PauseAnimation { duration: 200 }
          ParallelAnimation {
            NumberAnimation {
              target: primaryPasswordTextField; properties: "y"
              duration: 700; easing.type: Easing.Bezier
              easing.bezierCurve: customProperties.animationColapseEasingCurve
            }
            ColorAnimation {target: primaryPasswordTextField; property: "backgroundColor"
              duration: 860; easing.type: Easing.Bezier
              easing.bezierCurve: customProperties.animationColapseEasingCurve
            }
          }
        }
        SequentialAnimation {
          PauseAnimation { duration: 166 }
          NumberAnimation {
            target: confirmationPasswordTextField; properties: "width"
            duration: 900; easing.type: Easing.Bezier
            easing.bezierCurve: customProperties.animationColapseEasingCurve
          }
        }
        SequentialAnimation {
          PauseAnimation { duration: 100 }
          ParallelAnimation {
            NumberAnimation {
              target: confirmationPasswordTextField; properties: "y"
              duration: 800; easing.type: Easing.Bezier
              easing.bezierCurve: customProperties.animationColapseEasingCurve
            }
            ColorAnimation {target: confirmationPasswordTextField; property: "backgroundColor"
              duration: 960; easing.type: Easing.Bezier
              easing.bezierCurve: customProperties.animationColapseEasingCurve
            }
          }
        }
      }
      ScriptAction {
        script: createAccountElements.visible = false
      }
    }
  }]

  function resetFields() {
    primaryPinTextField.text = ""
    confirmationPinTextField.text = ""
    primaryKeywordTextField.text = ""
    confirmationKeywordTextField.text = ""
    primaryPasswordTextField.text = ""
    confirmationPasswordTextField.text = ""
    floatingStatus.hide()
  }

  onStateChanged: {
    focusAfterStateChange.start()
  }
  Timer {
    id: focusAfterStateChange
    interval: 1
    onTriggered: {
      if (accountHandlerController_.currentView === AccountHandlerController.CreateAccountView &&
          createAccountView.state !== "LOADING") {
        currentTextFields.primaryTextField.focus = true
        currentTextFields.primaryTextField.cursorPosition = currentTextFields.primaryTextField.text.length
      }
    }
  }

  LoadingView {
    id: loadingView
    visible: false
    onLoadingCanceled: createAccountView.state = "PIN"
  }

  Item {
    id: createAccountElements
    anchors.fill: parent

    Row {
      id: createAccountTabRow

      anchors.horizontalCenter: parent.horizontalCenter
      y: accountHandlerView.bottomButtonY -
         customProperties.blueButtonMargin -
         customProperties.textFieldHeight*3 -
         customProperties.textFieldVerticalSpacing*3

      spacing: 15

      Repeater {
        id: tabRepeater

        model: createAccountView.createAccountModel
        delegate:
          CustomLabel {
            text: modelData.text
            color: modelData.state === createAccountView.state ||
                   (modelData.state === "PASSWORD" && createAccountView.state === "LOADING") ||
                   tabItemMouseArea.pressed ?
                     customBrushes.labelSelected
                   : tabItemMouseArea.containsMouse ?
                     customBrushes.labelHovered
                   :
                     customBrushes.labelDefault

            MouseArea {
              id: tabItemMouseArea
              anchors.fill: parent
              hoverEnabled: true
              onClicked: createAccountView.state = modelData.state
              cursorShape: containsMouse ? Qt.ClosedHandCursor : Qt.ArrowCursor
            }
          }
      }
    }

    Item {
      id: pinTextFields

      readonly property Item primaryTextField: primaryPinTextField

      visible: false
      anchors.fill: parent

      CustomTextField {
        id: primaryPinTextField

        placeholderText: qsTr("Choose a 4 digit PIN")
        submitButton: nextButton
        y: accountHandlerView.bottomButtonY -
           customProperties.blueButtonMargin -
           customProperties.textFieldHeight*2 -
           customProperties.textFieldVerticalSpacing*2
      }

      CustomTextField {
        id: confirmationPinTextField

        placeholderText: qsTr("Confirm PIN")
        submitButton: nextButton
        y: accountHandlerView.bottomButtonY -
           customProperties.blueButtonMargin -
           customProperties.textFieldHeight -
           customProperties.textFieldVerticalSpacing
      }

      function validateValues() {
        if (!primaryPinTextField.text.match(/^\d{4}$/)) {
          floatingStatus.showError(primaryPinTextField,
                                   qsTr("PIN must be only and exactly 4 digits"))
          return false
        }
        return checkIdenticalField(qsTr("PIN"),
                                   primaryPinTextField,
                                   confirmationPinTextField)
      }
    }

    Item {
      id: keywordTextFields

      readonly property Item primaryTextField: primaryKeywordTextField

      visible: false
      anchors.fill: parent

      CustomTextField {
        id: primaryKeywordTextField

        placeholderText: qsTr("Choose a Keyword")
        submitButton: nextButton
        y: accountHandlerView.bottomButtonY -
           customProperties.blueButtonMargin -
           customProperties.textFieldHeight*2 -
           customProperties.textFieldVerticalSpacing*2

        onTextChanged: checkPasswordStrength(this)
      }

      CustomTextField {
        id: confirmationKeywordTextField

        placeholderText: qsTr("Confirm Keyword")
        submitButton: nextButton
        y: accountHandlerView.bottomButtonY -
           customProperties.blueButtonMargin -
           customProperties.textFieldHeight -
           customProperties.textFieldVerticalSpacing
      }

      function validateValues() {
        return checkBlankField(qsTr("Keyword"), primaryKeywordTextField) &&
               checkIdenticalField(qsTr("Keyword"),
                                   primaryKeywordTextField,
                                   confirmationKeywordTextField)
      }
    }

    Item {
      id: passwordTextFields

      readonly property Item primaryTextField: primaryPasswordTextField

      visible: false
      anchors.fill: parent

      CustomTextField {
        id: primaryPasswordTextField

        placeholderText: qsTr("Choose a Password")
        submitButton: nextButton
        y: accountHandlerView.bottomButtonY -
           customProperties.blueButtonMargin -
           customProperties.textFieldHeight*2 -
           customProperties.textFieldVerticalSpacing*2

        onTextChanged: checkPasswordStrength(this)
      }

      CustomTextField {
        id: confirmationPasswordTextField

        placeholderText: qsTr("Confirm Password")
        submitButton: nextButton
        y: accountHandlerView.bottomButtonY -
           customProperties.blueButtonMargin -
           customProperties.textFieldHeight -
           customProperties.textFieldVerticalSpacing
      }

      function validateValues() {
        return checkBlankField(qsTr("Password"), primaryPasswordTextField) &&
               checkIdenticalField(qsTr("Password"),
                                   primaryPasswordTextField,
                                   confirmationPasswordTextField)
      }
    }

    Item {
      id: fadeOutItems
      anchors.fill: parent

      BlueButton {
        id: nextButton

        y: accountHandlerView.bottomButtonY
        width: customProperties.blueButtonWidth
        anchors.horizontalCenter: parent.horizontalCenter

        text: qsTr("NEXT")
        onClicked: {
          floatingStatus.hide()
          if (!pinTextFields.validateValues()) {
            createAccountView.state = "PIN"

          } else if (createAccountView.state === "PIN" || !keywordTextFields.validateValues()) {
            createAccountView.state = "KEYWORD"

          } else if (createAccountView.state === "KEYWORD" || !passwordTextFields.validateValues()) {
            createAccountView.state = "PASSWORD"

          } else {
            createAccountView.state = "LOADING"
            accountHandlerController_.createAccount(primaryPinTextField.text,
                                                    primaryKeywordTextField.text,
                                                    primaryPasswordTextField.text)
          }
        }
      }

      Rectangle { // white line
        width: customProperties.textFieldWidth
        height: 1
        anchors.horizontalCenter: parent.horizontalCenter
        y: accountHandlerView.height -
           loginButton.height -
           customProperties.clickableTextBottomMargin - 12
        color: customBrushes.bottomLineColor
      }

      ClickableText {
        id: loginButton
        anchors.horizontalCenter: parent.horizontalCenter
        y: accountHandlerView.height - height - customProperties.clickableTextBottomMargin
        text: qsTr("Already have an account? Log In")
        onClicked: {
          accountHandlerController_.showLoginView()
        }
      }
    }
  }

  FloatingStatusBox { id: floatingStatus }
}
