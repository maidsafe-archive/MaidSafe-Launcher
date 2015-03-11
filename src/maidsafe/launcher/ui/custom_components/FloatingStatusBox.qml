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

Rectangle {
  id: statusDisplayRect
  objectName: "statusDisplayRect"

  property Item pointToItem: null
  property alias metaText: metaInformationText
  property alias infoText: informationText
  property real yOffset: 0
  property bool wipeTextsOnNoVisibility: true

  y: pointToItem.y //? pointToItem.y + pointToItem.height / 2 - height / 2 + yOffset : 0

  width: Math.min(180,
                  metaInformationText.implicitWidth   +
                  informationText.implicitWidth       +
                  metaInformationText.anchors.leftMargin +
                  informationText.anchors.leftMargin +  informationText.anchors.rightMargin)

  height: Math.max(informationText.implicitHeight + informationText.implicitHeight *
                   informationText.implicitWidth / (informationText.width ?
                                                      informationText.width : 1),
                   metaInformationText.implicitHeight + metaInformationText.implicitHeight *
                   metaInformationText.implicitWidth / (metaInformationText.width ?
                                                          metaInformationText.width : 1),
                   customProperties.textFieldHeight)

  radius: customProperties.textFieldRadius
  visible: false

  onVisibleChanged: {
    if (!visible && wipeTextsOnNoVisibility) {
      metaInformationText.text = informationText.text = ""
    }
  }

  Rectangle {
    id: pointerRect
    objectName: "pointerRect"

    anchors {
      verticalCenter: parent.verticalCenter
      left: parent.left
      leftMargin: -width / 2
    }
    width: 8
    height: width
    rotation: 45
  }

  CustomText {
    id: metaInformationText
    objectName: "metaInformationText"

    anchors {
      left: parent.left
      verticalCenter: parent.verticalCenter
      leftMargin: 10
    }
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    color: globalBrushes.textGrey
    font.pixelSize: 12
  }

  CustomText {
    id: informationText
    objectName: "informationText"

    anchors {
      left: metaInformationText.right
      right: parent.right
      rightMargin: 10
      verticalCenter: parent.verticalCenter
      leftMargin: 3
    }

    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
    color: globalBrushes.textGrey
    font.pixelSize: 12
  }
}
