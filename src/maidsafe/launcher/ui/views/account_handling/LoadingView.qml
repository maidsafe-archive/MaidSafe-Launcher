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

import "../../custom_components"

Item {
  id: loadingView

  anchors.horizontalCenter: parent.horizontalCenter

  signal loadingCanceled()
  readonly property Item bottomButton: cancelButton

  opacity: 0

  states: [State {
    name: "VISIBLE"
    PropertyChanges {
      target: loadingView
      opacity: 1
    }
    PropertyChanges {
      target: loadingAnimation
      y: 0
    }
  }]

  transitions: [Transition {
    to: "VISIBLE"
    SequentialAnimation {
      PauseAnimation { duration: 750 }
      ScriptAction { script: {
        errorMessageAnimation.stop()
        errorMessage.text = 0
        errorMessage.opacity = 0
        cancelButton.text = qsTr("CANCEL")
        cancelButton.focus = true
        loadingAnimation.showLoading()
        stopRocketTimer.start()
      }}
      ParallelAnimation {
        NumberAnimation {
          duration: 1000
          easing.type: Easing.OutExpo
          properties: "y"
        }
        NumberAnimation {
          duration: 1000
          properties: "opacity"
        }
      }
    }
  }]

  Timer {
    id: stopRocketTimer
    interval: 1200
    running: false
    repeat: false
    onTriggered: loadingAnimation.showFailed()
  }

  CustomText {
    id: errorMessage
    opacity: 0
    y: accountHandlerView.bottomButtonY - loadingAnimation.parent.height - height + 10
    anchors.horizontalCenter: parent.horizontalCenter

    NumberAnimation {
      id: errorMessageAnimation
      target: errorMessage
      property: "opacity"
      to: 1
      duration: 700
    }
  }

  Item {
    y: accountHandlerView.bottomButtonY - height
    anchors.horizontalCenter: parent.horizontalCenter
    height: 125
     // +7px on the right to center the loadingAnimation
     // +7px to center the loadingAnimation with the button
    width: 250 + 7 + 7

    LoadingAnimation {
      id: loadingAnimation
      x: 7 // center the loadingAnimation with the button
      y: parent.height
      //onFinished: {} // TODO Gildas: if (success)
      onStartBreaking: {
        cancelButton.text = qsTr("GO BACK")
        errorMessage.text = qsTr("There was an error creating your account.\nPlease try again.")
        errorMessageAnimation.start()
      }
    }
  }

  BlueButton {
    id: cancelButton
    y: accountHandlerView.bottomButtonY
    width: customProperties.cancelButtonWidth
    anchors.horizontalCenter: parent.horizontalCenter
    onClicked: loadingCanceled()
  }
}
