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

FocusScope {
  id: createAccountRoot
  objectName: "createAccountRoot"

  FloatingStatusBox {
    id: floatingStatus
    objectName: "floatingStatus"

    anchors {
      left: textFieldsAndButtonColumn.right
      leftMargin: 15
    }
    pointToItem: textFieldRepeater.itemAt(0)
    infoText.color: globalBrushes.textError
    yOffset: textFieldsAndButtonColumn.y
  }

  Column {
    id: textFieldsAndButtonColumn
    objectName: "textFieldsAndButtonColumn"

    anchors {
      horizontalCenter: parent.horizontalCenter
      bottom: parent.bottom
      bottomMargin: customProperties.loginButtonBottomMargin
    }

    spacing: customProperties.textFieldVerticalSpacing

    Repeater {
      id: textFieldRepeater
      objectName: "textFieldRepeater"

      model: [qsTr("PIN"), qsTr("Keyword"), qsTr("Password")]

      delegate: CustomTextField {
        id: textField
        objectName: "textField"

        anchors.horizontalCenter: parent.horizontalCenter
        placeholderText: modelData
        echoMode: TextInput.Password
        focus: !model.index
        Keys.onEnterPressed: loginButton.clicked()
        Keys.onReturnPressed: loginButton.clicked()
        onTextChanged: {
          if (floatingStatus.pointToItem === textField && floatingStatus.visible) {
            floatingStatus.visible = false
          }
        }
      }
    }

    BlueButton {
      id: loginButton
      objectName: "loginButton"

      text: qsTr("Log In")
      KeyNavigation.tab: showCreateAccountPageLabel
      onClicked: {
        floatingStatus.visible = false
        textFieldRepeater.itemAt(0).clearAllImages()
        textFieldRepeater.itemAt(1).clearAllImages()
        textFieldRepeater.itemAt(2).clearAllImages()

        if (textFieldRepeater.itemAt(0).text === "") {
          textFieldRepeater.itemAt(0).showErrorImage = true
          floatingStatus.pointToItem = textFieldRepeater.itemAt(0)
          floatingStatus.infoText.text = qsTr("PIN cannot be left blank")
          floatingStatus.visible = true
        } else if (textFieldRepeater.itemAt(1).text === "") {
          textFieldRepeater.itemAt(1).showErrorImage = true
          floatingStatus.pointToItem = textFieldRepeater.itemAt(1)
          floatingStatus.infoText.text = qsTr("Keyword cannot be left blank")
          floatingStatus.visible = true
        } else if (textFieldRepeater.itemAt(2).text === "") {
          textFieldRepeater.itemAt(2).showErrorImage = true
          floatingStatus.pointToItem = textFieldRepeater.itemAt(2)
          floatingStatus.infoText.text = qsTr("Password cannot be left blank")
          floatingStatus.visible = true
        } else {
          accountHandlerController_.login(textFieldRepeater.itemAt(0).text,
                                          textFieldRepeater.itemAt(1).text,
                                          textFieldRepeater.itemAt(2).text)
        }
      }
    }
  }

  ClickableText {
    id: showCreateAccountPageLabel
    objectName: "showCreateAccountPageLabel"

    anchors {
      horizontalCenter: parent.horizontalCenter
      bottom: parent.bottom
      bottomMargin: customProperties.clickableTextBottomMargin
    }

    label.text: qsTr("Create Account")
    onClicked: accountHandlerController_.showCreateAccountView()
  }
}
