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

FocusScope {
  id: focusScope
  objectName: "focusScope"

  signal clicked()
  property alias label: customLabel
  property alias mouseArea: mouseArea
  property alias text: customLabel.text

  width: childrenRect.width
  height: childrenRect.height

  activeFocusOnTab: true

  MouseArea {
    id: mouseArea
    objectName: "mouseArea"

    height: customLabel.implicitHeight
    width: customLabel.implicitWidth

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton
    cursorShape: containsMouse ? Qt.ClosedHandCursor : Qt.ArrowCursor

    onClicked: focusScope.clicked()

    CustomLabel {
      id: customLabel
      objectName: "customLabel"

      font {
        pixelSize: customProperties.customTextPixelSize
        family: globalFontFamily.name
      }

      focus: true
      anchors.centerIn: parent
      font.underline: activeFocus

      Keys.onEnterPressed: focusScope.clicked()
      Keys.onSpacePressed: focusScope.clicked()
      Keys.onReturnPressed: focusScope.clicked()
    }
  }
}
