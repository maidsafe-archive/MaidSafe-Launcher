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

FocusScope {
  id: createAccountRoot
  objectName: "createAccountRoot"

  QtObject {
    id: dPtr
    objectName: "dPtr"

    property var passwordStrength: new PasswordStrength.StrengthChecker()
    property int currentTabIndex: 0
    property string pin: ""
    property string keyword: ""
  }

  Row {
    id: createAccountTabRow
    objectName: "createAccountTabRow"

    anchors {
      horizontalCenter: parent.horizontalCenter
      bottom: userInputLoader.top
      bottomMargin: customProperties.textFieldHeight
    }

    spacing: 15

    Repeater {
      id: tabRepeater
      objectName: "tabRepeater"

      model: [qsTr("PIN"), qsTr("Keyword"), qsTr("Password")]

      delegate: CustomLabel {
        id: tabLabel
        objectName: "tabLabel"

        text: modelData
        color: model.index === dPtr.currentTabIndex ?
                 customBrushes.labelSelected
               :
                 customBrushes.labelNotSelected
      }
    }
  }

  Loader {
    id: userInputLoader
    objectName: "userInputLoader"

    anchors {
      horizontalCenter: parent.horizontalCenter
      bottom: parent.bottom
      bottomMargin: customProperties.nextButtonBottomMargin
    }

    focus: true
    sourceComponent: {
      if (!dPtr.currentTabIndex) {
        acceptPINComponent
      } else if (dPtr.currentTabIndex === 1) {
        acceptKeywordComponent
      } else {
        acceptPasswordComponent
      }
    }

    onLoaded: {
      item.passwordStrength = dPtr.passwordStrength
      item.nextFocusItem = clickableTextLoader
      item.focus = true
    }
  }

  Component {
    id: acceptPINComponent

    CreateAccountUserInputColumn {
      id: textFieldsAndButtonColumn
      objectName: "textFieldsAndButtonColumn"

      fieldName: qsTr("PIN")
      primaryTextField.placeholderText: qsTr("Choose a 4 digit PIN")
      confirmationTextField.placeholderText: qsTr("Confirm PIN")

      onProceed: {
        dPtr.pin = primaryTextField.text
        ++dPtr.currentTabIndex
      }
    }
  }

  Component {
    id: acceptKeywordComponent

    CreateAccountUserInputColumn {
      id: textFieldsAndButtonColumn
      objectName: "textFieldsAndButtonColumn"

      fieldName: qsTr("Keyword")
      primaryTextField.placeholderText: qsTr("Choose a Keyword")
      confirmationTextField.placeholderText: qsTr("Confirm Keyword")

      onProceed: {
        dPtr.keyword = primaryTextField.text
        ++dPtr.currentTabIndex
      }
    }
  }

  Component {
    id: acceptPasswordComponent

    CreateAccountUserInputColumn {
      id: textFieldsAndButtonColumn
      objectName: "textFieldsAndButtonColumn"

      fieldName: qsTr("Password")
      primaryTextField.placeholderText: qsTr("Choose a Password")
      confirmationTextField.placeholderText: qsTr("Confirm Password")

      onProceed: {
        accountHandlerController_.createAccount(dPtr.pin, dPtr.keyword, primaryTextField.text)
      }
    }
  }

  Loader {
    id: clickableTextLoader
    objectName: "clickableTextLoader"

    anchors {
      horizontalCenter: parent.horizontalCenter
      bottom: parent.bottom
      bottomMargin: customProperties.clickableTextBottomMargin
    }

    sourceComponent: dPtr.currentTabIndex ?
                       goBackComponent
                     :
                       showLoginPageLabelComponent

    onLoaded: item.focus = true
  }

  Component {
    id: showLoginPageLabelComponent

    ClickableText {
      id: showLoginPageLabel
      objectName: "showLoginPageLabel"

      label.text: qsTr("Already have an account? Log In")
      onClicked: accountHandlerController_.showLoginView()
    }
  }

  Component {
    id: goBackComponent

    ClickableText {
      id: goBackLabel
      objectName: "goBackLabel"

      label.text: qsTr("Go back")
      onClicked: --dPtr.currentTabIndex
    }
  }
}
