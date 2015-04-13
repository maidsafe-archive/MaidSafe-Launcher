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

Item {
  id: resizeItem

  visible: mainWindowItem.resizeable && mainWindow_.visibility !== Window.Maximized

  function setWidth(width) {
    if (width >= mainWindow_.minimumWidth && width <= mainWindow_.maximumWidth) {
      mainWindow_.width = width;
      return true
    }
    return false
  }

  function setHeight(height) {
    if (height >= mainWindow_.minimumHeight && height <= mainWindow_.maximumHeight) {
      mainWindow_.height = height;
      return true
    }
    return false
  }

  MouseArea {
    id: resizeRightMouseArea
    objectName: "resizeRightMouseArea"

    property real prevMouseX

    anchors {
      right: parent.right
      top: resizeAllRightTopMouseArea.bottom
      bottom: resizeAllRightBottomMouseArea.top
    }
    width: globalProperties.windowResizerThickness

    cursorShape: containsMouse ? Qt.SizeHorCursor : Qt.ArrowCursor

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton
    onPressed: { prevMouseX = mouseX }
    onPositionChanged: {
      if(pressed) {
        resizeItem.setWidth(mainWindow_.width + (mouseX - prevMouseX))
      }
    }
  }

  MouseArea {
    id: resizeAllRightBottomMouseArea
    objectName: "resizeAllRightBottomMouseArea"

    property real prevMouseX
    property real prevMouseY

    anchors {
      right: parent.right
      bottom: parent.bottom
    }
    width: globalProperties.windowResizerThickness
    height: globalProperties.windowResizerThickness

    cursorShape: containsMouse ? Qt.SizeFDiagCursor : Qt.ArrowCursor

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton
    onPressed: {
      prevMouseX = mouseX
      prevMouseY = mouseY
    }
    onPositionChanged: {
      if(pressed) {
        resizeItem.setWidth(mainWindow_.width + (mouseX - prevMouseX))
        resizeItem.setHeight(mainWindow_.height + (mouseY - prevMouseY))
      }
    }
  }

  MouseArea {
    id: resizeDownMouseArea
    objectName: "resizeDownMouseArea"

    property real prevMouseY

    anchors {
      right: resizeAllRightBottomMouseArea.left
      left: resizeAllLeftBottomMouseArea.right
      bottom: parent.bottom
    }
    height: globalProperties.windowResizerThickness

    cursorShape: containsMouse ? Qt.SizeVerCursor : Qt.ArrowCursor

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton
    onPressed: { prevMouseY = mouseY }
    onPositionChanged: {
      if(pressed) {
        resizeItem.setHeight(mainWindow_.height + (mouseY - prevMouseY))
      }
    }
  }

  MouseArea {
    id: resizeAllLeftBottomMouseArea
    objectName: "resizeAllLeftBottomMouseArea"

    property real prevMouseX
    property real prevMouseY

    anchors {
      left: parent.left
      bottom: parent.bottom
    }
    width: globalProperties.windowResizerThickness
    height: globalProperties.windowResizerThickness

    cursorShape: containsMouse ? Qt.SizeBDiagCursor : Qt.ArrowCursor

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton
    onPressed: {
      prevMouseX = mouseX
      prevMouseY = mouseY
    }
    onPositionChanged: {
      if(pressed) {
        var deltaX = mouseX - prevMouseX
        var deltaY = mouseY - prevMouseY

        if (resizeItem.setWidth(mainWindow_.width - deltaX))
          mainWindow_.x += deltaX
        resizeItem.setHeight(mainWindow_.height + deltaY)
      }
    }
  }

  MouseArea {
    id: resizeLeftMouseArea
    objectName: "resizeLeftMouseArea"

    property real prevMouseX

    anchors {
      left: parent.left
      top: resizeAllLeftTopMouseArea.bottom
      bottom: resizeAllLeftBottomMouseArea.top
    }
    width: globalProperties.windowResizerThickness

    cursorShape: containsMouse ? Qt.SizeHorCursor : Qt.ArrowCursor

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton
    onPressed: { prevMouseX = mouseX ; }
    onPositionChanged: {
      if(pressed) {
        var deltaX = mouseX - prevMouseX

        if (resizeItem.setWidth(mainWindow_.width - deltaX))
          mainWindow_.x += deltaX
      }
    }
  }

  MouseArea {
    id: resizeAllLeftTopMouseArea
    objectName: "resizeAllLeftTopMouseArea"

    property real prevMouseX
    property real prevMouseY

    anchors {
      left: parent.left
      top: parent.top
    }
    width: globalProperties.windowResizerThickness
    height: globalProperties.windowResizerThickness

    cursorShape: containsMouse ? Qt.SizeFDiagCursor : Qt.ArrowCursor

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton
    onPressed: {
      prevMouseX = mouseX
      prevMouseY = mouseY
    }
    onPositionChanged: {
      if(pressed) {
        var deltaX = mouseX - prevMouseX
        var deltaY = mouseY - prevMouseY

        if (resizeItem.setWidth(mainWindow_.width - deltaX))
          mainWindow_.x += deltaX
        if (resizeItem.setHeight(mainWindow_.height - deltaY))
          mainWindow_.y += deltaY
      }
    }
  }

  MouseArea {
    id: resizeUpMouseArea
    objectName: "resizeUpMouseArea"

    property real prevMouseY

    anchors {
      right: resizeAllRightTopMouseArea.left
      left: resizeAllLeftTopMouseArea.right
      top: parent.top
    }
    height: globalProperties.windowResizerThickness

    cursorShape: containsMouse ? Qt.SizeVerCursor : Qt.ArrowCursor

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton
    onPressed: { prevMouseY = mouseY }
    onPositionChanged: {
      if(pressed) {
        var deltaY = mouseY - prevMouseY

        if (resizeItem.setHeight(mainWindow_.height - deltaY))
          mainWindow_.y += deltaY
      }
    }
  }

  MouseArea {
    id: resizeAllRightTopMouseArea
    objectName: "resizeAllRightTopMouseArea"

    property real prevMouseX
    property real prevMouseY

    anchors {
      right: parent.right
      top: parent.top
    }
    width: globalProperties.windowResizerThickness
    height: globalProperties.windowResizerThickness

    cursorShape: containsMouse ? Qt.SizeBDiagCursor : Qt.ArrowCursor

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton
    onPressed: {
      prevMouseX = mouseX
      prevMouseY = mouseY
    }
    onPositionChanged: {
      if(pressed) {
        var deltaX = mouseX - prevMouseX
        var deltaY = mouseY - prevMouseY

        resizeItem.setWidth(mainWindow_.width + deltaX)
        if (resizeItem.setHeight(mainWindow_.height - deltaY))
          mainWindow_.y += deltaY
      }
    }
  }

}
