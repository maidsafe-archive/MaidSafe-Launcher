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

  ResizeMainWindowHelper {
    id: globalWindowResizeHelper
    anchors.fill: parent
    visible: mainWindowItem.resizeable
  }

  Item {
    id: titleBarControls

    height: 40
    anchors {
      left: parent.left
      top: parent.top
      right: parent.right
    }

    DragMainWindowHelper {
      id: dragMainWindowHelper
      anchors {
        left: parent.left
        leftMargin: globalProperties.windowResizerThickness
        top: parent.top
        topMargin: globalProperties.windowResizerThickness
        right: parent.right
        rightMargin: globalProperties.windowResizerThickness
        bottom: parent.bottom
      }
    }

    MouseArea {
      id: hoverMouseArea
      anchors.fill: controlsRow
      hoverEnabled: true
    }

    Row {
      id: controlsRow

      spacing: 5

      anchors {
        verticalCenter: parent.verticalCenter
        left: parent.left
        leftMargin: 5
      }

      Image {
        source: hoverMouseArea.containsMouse ?
                  "/resources/images/window_details/osx_close_hover.png"
                :
                  "/resources/images/window_details/osx_close.png"
        MouseArea {
          anchors.fill: parent
          onClicked: Qt.quit()
        }
      }

      Image {
        source: hoverMouseArea.containsMouse ?
                  "/resources/images/window_details/osx_hide_hover.png"
                :
                  "/resources/images/window_details/osx_hide.png"

        MouseArea {
          anchors.fill: parent
          onClicked: mainWindow_.showMinimized()
        }
      }

      Image {
        source: !mainWindowItem.resizeable ?
                  "/resources/images/window_details/osx_disabled.png"
                : hoverMouseArea.containsMouse ?
                  "/resources/images/window_details/osx_fullscreen_hover.png"
                :
                  "/resources/images/window_details/osx_fullscreen.png"

        MouseArea {
          anchors.fill: parent
          onClicked: mainWindow_.showMaximized()
        }
      }
    }

    Item {
      id: titleBarComponents
      visible: customTitleBar.homePageControlsVisible
      anchors {
        left: controlsRow.right
        top: parent.top
        right: parent.right
        bottom: parent.bottom
      }

      ViewTypeSelector {
        id: viewTypeSelector

        height: 21
        anchors {
          verticalCenter: parent.verticalCenter
          left: parent.left
          leftMargin: 16
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

      ProfileMenu {
        id: profileMenu

        height: 22
        anchors {
          verticalCenter: parent.verticalCenter
          right: parent.right
          rightMargin: 12
        }
      }
    }
  }
}
