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

import "../../../custom_components"

FocusScope {
  id: focusScopeRoot
  objectName: "focusScopeRoot"

  signal proceed()
  signal primaryFieldTabPressed()
  signal confirmationFieldTabPressed()

  property var passwordStrength: undefined
  property Item nextFocusItem: null
  property alias primaryTextField: primaryTextField
  property alias confirmationTextField: confirmationTextField
  property alias nextButton: nextButton
  property alias floatingStatus: statusDisplayRect
  property string fieldName: qsTr("This field")

  function clearAllStatusImages() {
    primaryTextField.clearAllImages()
    confirmationTextField.clearAllImages()
  }

  function validatePIN() {
    if (!primaryTextField.text.match(/^\d{4}$/)) {
      primaryTextField.showErrorImage = true
      floatingStatus.infoText.text = qsTr("PIN must be only and exactly 4 digits")
      floatingStatus.infoText.color = customBrushes.textWeakPassword
      floatingStatus.pointToItem = primaryTextField
      floatingStatus.visible = true
      return false
    }

    return true
  }

  function validateStrength() {
    floatingStatus.pointToItem = primaryTextField
    floatingStatus.metaText.text = qsTr("Strength:")

    var result = passwordStrength.check(primaryTextField.text)
    switch (result.score) {
    case 0:
    case 1:
      floatingStatus.infoText.text = qsTr("Weak")
      floatingStatus.infoText.color = customBrushes.textWeakPassword
      break
    case 2:
      floatingStatus.infoText.text = qsTr("Medium")
      floatingStatus.infoText.color = customBrushes.textMediumPassword
      break
    default:
      floatingStatus.infoText.text = qsTr("Strong")
      floatingStatus.infoText.color = customBrushes.textStrongPassword
      break
    }

    floatingStatus.visible = true
  }

  function showBlankFieldError() {
    primaryTextField.showErrorImage = true
    floatingStatus.infoText.text = qsTr(fieldName + " cannot be left blank")
    floatingStatus.infoText.color = customBrushes.textWeakPassword
    floatingStatus.pointToItem = primaryTextField
    floatingStatus.visible = true
  }

  function validateConfirmationMatch() {
    if (primaryTextField.text !== confirmationTextField.text) {
      confirmationTextField.showErrorImage = true
      floatingStatus.infoText.text = qsTr("Entries don't match")
      floatingStatus.infoText.color = customBrushes.textWeakPassword
      floatingStatus.pointToItem = confirmationTextField
      floatingStatus.visible = true
      return false
    }

    return true
  }

  width: textFieldsAndButtonColumn.implicitWidth
  height: textFieldsAndButtonColumn.implicitHeight

  FloatingStatusBox {
    id: statusDisplayRect
    objectName: "statusDisplayRect"

    anchors {
      left: textFieldsAndButtonColumn.right
      leftMargin: 15
    }
    pointToItem: primaryTextField
  }

  Column {
    id: textFieldsAndButtonColumn
    objectName: "textFieldsAndButtonColumn"

    spacing: customProperties.textFieldVerticalSpacing

    CustomTextField {
      id: primaryTextField
      objectName: "primaryTextField"

      anchors.horizontalCenter: parent.horizontalCenter
      echoMode: TextInput.Password
      focus: true
      Keys.onEnterPressed: nextButton.clicked()
      Keys.onReturnPressed: nextButton.clicked()

      Keys.onTabPressed: {
        focusScopeRoot.primaryFieldTabPressed()
        event.accepted = false
      }

      Keys.onBacktabPressed: {
        focusScopeRoot.primaryFieldTabPressed()
        event.accepted = false
      }

      onTextChanged: {
        floatingStatus.visible = false
        confirmationTextField.clearAllImages()

        if (fieldName !== qsTr("PIN") && text !== "") {
          validateStrength()
        }
      }
    }

    CustomTextField {
      id: confirmationTextField
      objectName: "confirmationTextField"

      anchors.horizontalCenter: parent.horizontalCenter
      echoMode: TextInput.Password
      Keys.onEnterPressed: nextButton.clicked()
      Keys.onReturnPressed: nextButton.clicked()

      Keys.onTabPressed: {
        focusScopeRoot.confirmationFieldTabPressed()
        event.accepted = false
      }

      Keys.onBacktabPressed: {
        focusScopeRoot.confirmationFieldTabPressed()
        event.accepted = false
      }

      onTextChanged: {
        if (floatingStatus.pointToItem === confirmationTextField ||
            !primaryTextField.showErrorImage) {
          floatingStatus.visible = false
        }
      }
    }

    BlueButton {
      id: nextButton
      objectName: "nextButton"

      text: qsTr("Next")
      KeyNavigation.tab: nextFocusItem

      onClicked: {
        floatingStatus.visible = false
        clearAllStatusImages()

        var ok = false

        if (primaryTextField.text === "") { showBlankFieldError() }
        else {
          ok = fieldName === qsTr("PIN") ?
                validatePIN() && validateConfirmationMatch()
              :
                validateConfirmationMatch()
        }

        if (ok) {
          focusScopeRoot.proceed()
        }
      }
    }
  }
}
