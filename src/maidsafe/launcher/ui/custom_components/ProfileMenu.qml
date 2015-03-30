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
import QtGraphicalEffects 1.0

MouseArea {
  id: profileMenu
  implicitHeight: 22
  implicitWidth: height + dropIcon.implicitWidth + dropIcon.anchors.leftMargin

  Rectangle {
    id: mask
    width: profileMenu.height
    height: profileMenu.height
    radius: profileMenu.height / 2
    color: "#000000"
    visible: false
  }
  Image {
    id: image
    anchors.fill: mask
    source: "/resources/images/david-irvine.jpg"
    fillMode: Image.PreserveAspectCrop
    visible: false
  }
  OpacityMask {
    anchors.fill: mask
    source: image
    maskSource: mask
  }
  Rectangle {
    anchors.fill: mask
    radius: mask.radius
    color: "#00000000"
    border {
      color: "#ffffff"
      width: 1
    }
  }

  Image {
    id: dropIcon
    anchors {
      verticalCenter: parent.verticalCenter
      left: mask.right
      leftMargin: 3
    }
    source: Qt.platform.os === "windows" ?
              "/resources/images/window_details/windows_profile_drop_icon.png"
            :
              "/resources/images/window_details/profile_drop_icon.png"
  }
}
