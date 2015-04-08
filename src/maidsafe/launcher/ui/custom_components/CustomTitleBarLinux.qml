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
import QtQuick.Window 2.2

import SAFEAppLauncher.MainController 1.0

import "../views/detail"

CustomTitleBar {
  id: customTitleBar

  viewTypeSelector: viewTypeSelector
  searchField: searchField
  titleBarHeight: titleBarComponents.height

  Item {
    id: titleBarComponents
    visible: customTitleBar.homePageControlsVisible
    anchors {
      left: parent.left
      top: parent.top
      right: parent.right
    }
    height: 40

    ViewTypeSelector {
      id: viewTypeSelector

      height: 21
      anchors {
        verticalCenter: parent.verticalCenter
        left: parent.left
        leftMargin: 10
      }
    }

    ProfileMenu {
      id: profileMenu

      height: 22
      anchors {
        verticalCenter: parent.verticalCenter
        right: parent.right
        rightMargin: 12
      }
    }

    SearchTextField {
      id: searchField

      height: 19
      width: 154
      font.pixelSize: 10
      anchors {
        top: parent.top
        topMargin: 11
        right: profileMenu.left
        rightMargin: 12
      }
    }
  }
}
