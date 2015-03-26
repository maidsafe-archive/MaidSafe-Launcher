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

  ResizeMainWindowHelper {
    id: globalWindowResizeHelper
    anchors.fill: parent
  }

  Item {
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

      spacing: 9

      anchors {
        verticalCenter: parent.verticalCenter
        left: parent.left
        leftMargin: 9
      }

      Rectangle {
        id: closeButton

        height: 13
        width: 13
        radius: 6.5
        color: "#f05f55"
        border {
          width: 1
          color: "#e13e32"
        }

        Image {
          id: closeImage
          x: 2
          y: 2
          visible: hoverMouseArea.containsMouse
          source: "/resources/images/window_details/osx_close.png"
        }

        MouseArea {
          id: closeMouseArea
          anchors.fill: parent
          onClicked: Qt.quit()
        }
      }

      Rectangle {
        id: hideButton

        height: 13
        width: 13
        radius: 6.5
        color: "#fdbd10"
        border {
          width: 1
          color: "#e1a126"
        }

        Image {
          id: hideImage
          x: 1
          y: 1
          visible: hoverMouseArea.containsMouse
          source: "/resources/images/window_details/osx_hide.png"
        }

        MouseArea {
          id: hideMouseArea
          anchors.fill: parent
          onClicked: mainWindow_.showMinimized()
        }
      }

      Rectangle {
        id: fullscreenButton

        height: 13
        width: 13
        radius: 6.5
        color: "#47b549"
        border {
          width: 1
          color: "#1db14b"
        }

        Image {
          id: fullscreenImage
          x: 2
          y: 2
          visible: hoverMouseArea.containsMouse
          source: "/resources/images/window_details/osx_fullscreen.png"
        }

        MouseArea {
          id: fullscreenMouseArea
          anchors.fill: parent
          onClicked: {
            if (mainWindow_.visibility === Window.Maximized) {
              mainWindow_.showNormal()
            } else {
              mainWindow_.showMaximized()
            }
          }
        }
      }
    }

    Item {
      id: titleBarComponents
      visible: opacity !== 0
      opacity: customTitleBar.homePageControlsOpacity
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
          verticalCenter: parent.verticalCenter
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
