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
  titleBarHeight: titleBarTitle.height

  ResizeMainWindowHelper {
    id: globalWindowResizeHelper
    anchors.fill: parent
    visible: mainWindowItem.resizeable
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
      bottom: titleBarTitle.visible ? titleBarTitle.bottom : controlsRow.bottom
    }
  }

  Row {
    id: controlsRow

    anchors {
      top: parent.top
      right: parent.right
    }

    Rectangle {
      id: minimiseHighlighter

      implicitWidth: minimiseImage.implicitWidth
      implicitHeight: minimiseImage.implicitHeight

      color: minimiseMouseArea.containsMouse ? "#2e050708" : "#00000000"

      Image {
        id: minimiseImage
        source: "/resources/images/window_details/windows_minimise.png"
      }

      MouseArea {
        id: minimiseMouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: mainWindow_.showMinimized()
      }
    }

    Rectangle {
      id: maximiseHighlighter

      implicitWidth: maximiseImage.implicitWidth
      implicitHeight: maximiseImage.implicitHeight

      color: maximiseMouseArea.containsMouse ? "#2e050708" : "#00000000"

      Image {
        id: maximiseImage
        source: mainWindow_.visibility === Window.Maximized ?
                  "/resources/images/window_details/windows_restore.png"
                :
                  "/resources/images/window_details/windows_maximise.png"
      }

      MouseArea {
        id: maximiseMouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
          if (mainWindow_.visibility === Window.Maximized) {
            mainWindow_.showNormal()
          } else {
            mainWindow_.showMaximized()
          }
        }
      }
    }

    Rectangle {
      id: closeHighlighter

      implicitWidth: closeImage.implicitWidth
      implicitHeight: closeImage.implicitHeight

      color: closeMouseArea.containsMouse ? "#99e63725" : "#00000000"

      Image {
        id: closeImage
        source: "/resources/images/window_details/windows_close.png"
      }

      MouseArea {
        id: closeMouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: Qt.quit()
      }
    }
  }

  Item {
    id: titleBarComponents
    visible: customTitleBar.homePageControlsVisible
    anchors {
      top: controlsRow.bottom
      right: parent.right
    }

    ViewTypeSelector {
      id: viewTypeSelector

      height: 16
      anchors {
        top: parent.top
        topMargin: 2
        right: profileMenu.left
        rightMargin: 18
      }
    }

    ProfileMenu {
      id: profileMenu

      height: 20
      anchors {
        top: parent.top
        right: searchField.left
        rightMargin: 10
      }
    }

    SearchTextField {
      id: searchField

      height: 16
      width: 132
      font.pixelSize: 8
      anchors {
        top: parent.top
        topMargin: 1
        right: parent.right
        rightMargin: 7
      }
    }
  }

  Item {
    id: titleBarTitle
    visible: customTitleBar.homePageControlsVisible
    height: 50

    Image {
      id: appIcon
      anchors {
        top: parent.top
        left: parent.left
        leftMargin: 10
        topMargin: 9
      }

      source: "/resources/images/window_details/windows_app_icon.png"
    }

    CustomText {
      anchors {
        left: appIcon.right
        leftMargin: 10
        verticalCenter: appIcon.verticalCenter
      }
      font.pixelSize: 14
      text: "Productivity - Safe App Launcher"
      color: "#f1f1f1"
    }
  }
}
