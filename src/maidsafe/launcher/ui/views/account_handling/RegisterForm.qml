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

import "./detail"
import "../../custom_components"
import "../../resources/js/password_strength.js" as PasswordStrength

Item {
  property var passwordStrength: new PasswordStrength.StrengthChecker()
  property string pin: ""
  property string keyword: ""

  property Item bottomButton: nextButton

  property Item currentTextFields: null

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

  anchors.fill: parent

  states: [State {
    name: "VISIBLE"
    PropertyChanges {
      target: backButton
      visible: true
    }
    PropertyChanges {
      target: registerForm
      opacity: 1
    }
    PropertyChanges {
      target: sharedBackgroundButton
      width: customProperties.textFieldWidth
    }
  }, State {
    name: "PIN"
    extend: "VISIBLE"
    PropertyChanges {
      target: backButton
      visible: false
    }
    PropertyChanges {
      target: pinTextFields
      visible: true
    }
    PropertyChanges {
      target: registerForm
      currentTextFields: pinTextFields
    }
    PropertyChanges {
      target: registerButton
      visible: true
    }
    PropertyChanges {
      target: backButton
      visible: false
    }

  }, State {
    name: "KEYWORD"
    extend: "VISIBLE"
    PropertyChanges {
      target: keywordTextFields
      visible: true
    }
    PropertyChanges {
      target: registerForm
      currentTextFields: keywordTextFields
    }
    PropertyChanges {
      target: registerButton
      visible: false
    }
    PropertyChanges {
      target: backButton
      visible: true
    }

  }, State {
    name: "PASSWORD"
    extend: "VISIBLE"
    PropertyChanges {
      target: passwordTextFields
      visible: true
    }
    PropertyChanges {
      target: registerForm
      currentTextFields: passwordTextFields
    }
    PropertyChanges {
      target: registerButton
      visible: false
    }
    PropertyChanges {
      target: backButton
      visible: true
    }

  }, State {
    name: "HIDDEN"
    PropertyChanges {
      target: registerForm
      opacity: 0
    }
/*    PropertyChanges {
      target: sharedBackgroundButton
      width: customProperties.cancelButtonWidth
    }*/
  }]

  transitions: [Transition {
      from: "HIDDEN";// to: "VISIBLE"
      SequentialAnimation {
        PauseAnimation {
          duration: 500
        }
        ScriptAction {
            script: {
              registerForm.visible = true
              accountHandlerView.currentView = registerForm
              primaryPinTextField.forceActiveFocus()
            }
         }
        NumberAnimation {
            duration: 1000
            easing.type: Easing.OutQuad
            properties: "width,y,opacity"
        }
      }
  },Transition {
      //from: "VISIBLE";
      to: "HIDDEN"
      SequentialAnimation {
        NumberAnimation {
            duration: 1000
            easing.type: Easing.InQuad
            properties: "width,y,opacity"
        }
        ScriptAction {
           script: {
             registerForm.visible = false
           }
        }
      }
  }]

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

      model: ["PIN", "KEYWORD", "PASSWORD"]
      delegate: CustomLabel {
        text: qsTr(modelData)
        color: modelData == registerForm.state ?
                 customBrushes.labelSelected
               :
                 customBrushes.labelNotSelected
      }
    }
  }

  Item {
    id: pinTextFields

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

    function goBack() {
    }

    function validateValuesAndContinueIfOk() {
      if ( ! primaryPinTextField.text.match(/^\d{4}$/)) {
        floatingStatus.showError(primaryPinTextField,
                                 qsTr("PIN must be only and exactly 4 digits"))
      } else if ( ! checkIdenticalField(qsTr("PIN"),
                                        primaryPinTextField,
                                        confirmationPinTextField)) {
      } else {
        registerForm.state = "KEYWORD"
        primaryKeywordTextField.forceActiveFocus()
      }
    }
  }

  Item {
    id: keywordTextFields

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

    function goBack() {
      registerForm.state = "PIN"
    }

    function validateValuesAndContinueIfOk() {
      if ( ! checkBlankField(qsTr("KEYWORD"), primaryKeywordTextField)) {
      } else if ( ! checkIdenticalField(qsTr("KEYWORD"),
                                        primaryKeywordTextField,
                                        confirmationKeywordTextField)) {
      } else {
        registerForm.state = "PASSWORD"
        primaryPasswordTextField.forceActiveFocus()
      }
    }
  }

  Item {
    id: passwordTextFields

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

    function goBack() {
      registerForm.state = "KEYWORD"
    }

    function validateValuesAndContinueIfOk() {
      if ( ! checkBlankField(qsTr("PASSWORD"), primaryPasswordTextField)) {
      } else if ( ! checkIdenticalField(qsTr("PASSWORD"),
                                        primaryPasswordTextField,
                                        confirmationPasswordTextField)) {
      } else {
        accountHandlerView.fromState = "REGISTER"
        accountHandlerView.state = "LOADING"
        accountHandlerController_.createAccount(primaryPinTextField.text,
                                                primaryKeywordTextField.text,
                                                primaryPasswordTextField.text)
      }
    }
  }

  BlueButton {
    id: nextButton

    y: accountHandlerView.bottomButtonY

    text: qsTr("Next")
    onClicked: {
      floatingStatus.hide()
      registerForm.currentTextFields.validateValuesAndContinueIfOk()
    }
  }

  ClickableText {
    id: backButton

    y: accountHandlerView.height - height - customProperties.clickableTextBottomMargin

    text: qsTr("Go back")
    onClicked: {
      floatingStatus.hide()
      registerForm.currentTextFields.goBack()
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

    anchors.horizontalCenter: parent.horizontalCenter
    y: accountHandlerView.height - height - customProperties.clickableTextBottomMargin
    text: qsTr("Already have an account? Log In")
    onClicked: {
      accountHandlerView.fromState = "REGISTER"
      accountHandlerView.state = "LOGIN"
    }
  }
}
