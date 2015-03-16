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
  anchors.horizontalCenter: parent.horizontalCenter
  property Item bottomButton: cancelButton

  states: [State {
    name: "VISIBLE"
    PropertyChanges {
      target: loadingView
      opacity: 1
    }
    PropertyChanges {
      target: rocket
      y: 0
    }
  }, State {
    name: "HIDDEN"
    PropertyChanges {
      target: loadingView
      opacity: 0
    }
    PropertyChanges {
      target: rocket
      y: rocketContainer.height
    }
  }]

  transitions: [Transition {
      from: "HIDDEN"; to: "VISIBLE"
      SequentialAnimation {
        PauseAnimation {
          duration: 750
        }
        ScriptAction {
            script: {
              errorMessageAnimation.stop()
              errorMessage.text = 0
              errorMessage.opacity = 0
              cancelButton.text = qsTr("CANCEL")
              loadingView.visible = true
              accountHandlerView.currentView = loadingView
              cancelButton.forceActiveFocus()
              rocket.showLoading()
              stopRocketTimer.start()
            }
         }
        NumberAnimation {
            duration: 1000
            easing.type: Easing.OutExpo
            properties: "width,y,opacity"
        }
      }
  },Transition {
      from: "VISIBLE"; to: "HIDDEN"
//      SequentialAnimation {
/*        NumberAnimation {
            duration: 1000
            easing.type: Easing.InQuad
            properties: "width,y,opacity"
        }*/
        ScriptAction {
           script: {
             loadingView.visible = false
           }
        }
//      }
  }]


  Timer {
    id: stopRocketTimer
    interval: 1200
    running: false
    repeat: false
    onTriggered: rocket.showFailed()
  }

  CustomText {
    id: errorMessage
    opacity: 0
    y: accountHandlerView.bottomButtonY - rocketContainer.height - height + 10
    anchors.horizontalCenter: parent.horizontalCenter

    NumberAnimation {
      id: errorMessageAnimation
      target: errorMessage
      property: "opacity"
      to: 1
      duration: 700
      running: true
    }
  }

  Item {
    id: rocketContainer
    y: accountHandlerView.bottomButtonY - height
    x: 4 // center the rocket
    anchors.horizontalCenter: parent.horizontalCenter
    height: 125
    width: 257 // +7 because png are uncentered 7px on the right to center the rocket
    clip: true

    Rocket {
      id: rocket
      onFinished: {
        // TODO Gildas: if (success)
      }
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
    onClicked: {
      accountHandlerView.state = accountHandlerView.fromState
    }
  }
}
