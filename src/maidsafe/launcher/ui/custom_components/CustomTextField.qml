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

TextField {
  id: textField
  objectName: "textField"

  anchors.horizontalCenter: parent.horizontalCenter

  property bool showTickImage: false
  property bool showErrorImage: false
  property bool clearAllImagesOnTextChange: true

  function clearAllImages() { showTickImage = showErrorImage = false }

  onShowTickImageChanged: {
    if (showTickImage && showErrorImage) {
      showErrorImage = false
    }
  }
  onShowErrorImageChanged: {
    if (showErrorImage && showTickImage) {
      showTickImage = false
    }
  }
  onActiveFocusChanged: {
    if (activeFocus) {
      selectAll()
    }
  }
  onTextChanged: {
    if (clearAllImagesOnTextChange) { clearAllImages() }
  }

  font {
    pixelSize: customProperties.defaultFontPixelSize
    family: globalFontFamily.name
  }
  horizontalAlignment: TextInput.AlignHCenter
  verticalAlignment: TextInput.AlignVCenter

  style: TextFieldStyle {
    id: textFieldStyle
    objectName: "textFieldStyle"

    textColor: globalBrushes.textGrey

    placeholderTextColor: control.activeFocus ?
                            globalBrushes.placeHolderFocusGrey
                          :
                            globalBrushes.placeHolderDefaultGrey

    background: Rectangle {
      id: backgroundRect
      objectName: "backgroundRect"

      implicitHeight: customProperties.textFieldHeight
      implicitWidth: customProperties.textFieldWidth
      radius: customProperties.textFieldRadius

      Image {
        id: tickImage
        objectName: "tickImage"

        anchors {
          right: parent.right
          rightMargin: 3
          verticalCenter: parent.verticalCenter
        }
        source: "/resources/images/create_tick.png"
        visible: textField.showTickImage
      }

      Image {
        id: errorImage
        objectName: "errorImage"

        anchors {
          right: parent.right
          rightMargin: 3
          verticalCenter: parent.verticalCenter
        }
        source: "/resources/images/create_error.png"
        visible: textField.showErrorImage
      }
    }
  }
}
