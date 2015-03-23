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

  property Item pointToItem

  radius: customProperties.textFieldRadius
  visible: false

  function hide() {
    visible = false
    if (pointToItem && pointToItem.clearAllImages) {
      pointToItem.clearAllImages()
    }
    pointToItem = null
  }

  function showError(item, info) {
    show(item, "", info, customBrushes.textWeakPassword, true)
  }
  function show(item, meta, info, color, showError) {
    hide()
    if (!item) return

    pointToItem = item
    if (pointToItem && pointToItem.showErrorImage)
      pointToItem.showErrorImage = showError
    metaText.text = meta
    infoText.text = info
    infoText.color = color
    state = "VISIBLE"
    pointToItem.focus = true
    resetSizeAndPosition()
    visible = true
  }

  // reset size and then position because y is dependant of height
  // and compute these values only once the pointToItem and text has changed is more optimized
  function resetSizeAndPosition() {
    width = Math.min(180,
                     metaText.implicitWidth +
                     infoText.implicitWidth +
                     metaText.anchors.leftMargin +
                     infoText.anchors.leftMargin + infoText.anchors.rightMargin)

    height = Math.max(infoText.implicitHeight + infoText.implicitHeight *
                      infoText.implicitWidth / (infoText.width ? infoText.width : 1),
                      metaText.implicitHeight + metaText.implicitHeight *
                      metaText.implicitWidth / (metaText.width ? metaText.width : 1),
                      customProperties.textFieldHeight)

    x = pointToItem.x + pointToItem.width + 15

    y = pointToItem.y + pointToItem.height / 2 - height / 2
  }

  Rectangle {
    id: pointerRect

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
    id: metaText

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
    id: infoText

    anchors {
      left: metaText.right
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
