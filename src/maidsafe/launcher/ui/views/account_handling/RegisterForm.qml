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
  id: createAccountRoot

  property var passwordStrength: new PasswordStrength.StrengthChecker()
  property string pin: ""
  property string keyword: ""

  property Item bottomButton: goBackLabel

  Row {
    id: createAccountTabRow

    anchors {
      horizontalCenter: parent.horizontalCenter
      bottom: userInputLoader.top
      bottomMargin: customProperties.textFieldHeight
    }

    spacing: 15

    Repeater {
      id: tabRepeater

      model: ["PIN", "KEYWORD", "PASSWORD"]

      delegate: CustomLabel {
        id: tabLabel

        text: qsTr(modelData)
        color: modelData == createAccountRoot.state ?
                 customBrushes.labelSelected
               :
                 customBrushes.labelNotSelected
      }
    }
  }

  Loader {
    id: userInputLoader

    anchors {
      horizontalCenter: parent.horizontalCenter
      bottom: parent.bottom
      bottomMargin: customProperties.buttonBottomMargin
    }

    focus: true
    sourceComponent: {
      if (createAccountRoot.state == "PIN") {
        acceptPINComponent
      } else if (createAccountRoot.state == "KEYWORD") {
        acceptKeywordComponent
      } else {
        acceptPasswordComponent
      }
    }

    onLoaded: {
      item.passwordStrength = createAccountRoot.passwordStrength
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
        createAccountRoot.pin = primaryTextField.text
        createAccountRoot.state = "KEYWORD"
        goBackLabel.onClicked = function(){
          createAccountRoot.state = "PIN"
        }
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
        createAccountRoot.keyword = primaryTextField.text
        createAccountRoot.state = "PASSWORD"
        goBackLabel.onClicked = function(){
          createAccountRoot.state = "KEYWORD"
        }
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
        accountHandlerController_.createAccount(createAccountRoot.pin, createAccountRoot.keyword, primaryTextField.text)
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

    sourceComponent: createAccountRoot.state != "PIN" ?
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

      text: qsTr("Already have an account? Log In")
      onClicked: accountHandlerController_.showLoginView()
    }
  }

  Component {
    id: goBackComponent

    ClickableText {
      id: goBackLabel
      objectName: "goBackLabel"

      text: qsTr("Go back")
//      onClicked: previous.state ==
    }
  }
}
