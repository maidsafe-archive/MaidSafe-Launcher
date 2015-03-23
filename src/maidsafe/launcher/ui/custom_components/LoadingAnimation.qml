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

Item {
  id: rocket
  width: 250
  height: 100

  signal finished(bool success)
  signal startFailing() // start showing error message
  function showLoading() {
    if (running)
      stopAnimations()
    rocketCanvas.visible = true
    rocketBreaking.visible = false
    rocketCanvas.startLoadingWithColor("#ffffffff");
    running = true
  }

  function showFailed() {
    breakAtTheEnd = true
    rocketCanvas.stopToColor("#aaff0000");
  }
  function showSuccess() {
    breakAtTheEnd = false
    rocketCanvas.stopToColor("#aaffffff");
  }
  function stopAnimations() {
    running = false
    angleAnimation.stop()
    finishAnimation.stop()
    frameNumberTimer.stop()
    frameNumberAnimation.stop()
  }

  property bool breakAtTheEnd: false
  property bool running: false

  Canvas {
    id: rocketCanvas

    x: 75
    width: 95 // to match the pngs
    height: 95 // to match the pngs

    function startLoadingWithColor(color) {
      currentColor = color
      angleAnimation.start()
    }
    function stopToColor(color) {
      toColor = color
      angleAnimation.stop()
    }


    property color currentColor
    property color toColor
    // this angle property go from 0 to 6 while loading, and 6 to 12 to finish the rotation
    property real  angle

    function getFillColor(polygon) {
      if (angle - 6 > polygon) { // mean animation ending
        return Qt.rgba(toColor.r,
                       toColor.g,
                       toColor.b,
                       Math.min(angle - 6 -polygon, 1) * toColor.a)
      } else {
        return Qt.rgba(currentColor.r,
                       currentColor.g,
                       currentColor.b,
                       getFillColorAlpha(polygon) * currentColor.a)
      }
    }

    function getFillColorAlpha(polygon) {
      var alpha = angle
      alpha -= polygon
      if (alpha < 0) alpha += 6
      if (alpha > 1) alpha = 1 - (alpha -1) / 5
      return alpha
    }

    antialiasing: true
    onAngleChanged: requestPaint()
    onPaint: {
      var ctx = getContext("2d");
      ctx.save();
      ctx.scale(width / 500, height / 500);

      ctx.clearRect(0, 0, 500, 500);
      ctx.lineWidth = 0

      // polygon 1
      ctx.beginPath();

      ctx.moveTo(308.4, 108.7);
      ctx.lineTo(276.6, 43);
      ctx.lineTo(251, 24.3);
      ctx.lineTo(251, 130.4);
      ctx.lineTo(285.5, 150.4);
      ctx.lineTo(285.5, 190.2);
      ctx.lineTo(251, 210.2);
      ctx.lineTo(251, 284.3);
      ctx.lineTo(332.6, 237.2);
      ctx.lineTo(332.6, 229.5);

      ctx.closePath();
      ctx.fillStyle = getFillColor(0)
      ctx.fill();

      // polygon 2
      ctx.beginPath();
      ctx.moveTo(378.1,357.7);
      ctx.lineTo(371.1,343.9);
      ctx.lineTo(332.6,318.4);
      ctx.lineTo(332.6,237.2);
      ctx.lineTo(251,284.3);
      ctx.closePath();
      ctx.fillStyle = getFillColor(1)
      ctx.fill();

      // polygon 3
      ctx.beginPath();
      ctx.moveTo(251,451.4);
      ctx.lineTo(306.9,451.4);
      ctx.lineTo(317.8,413.7);
      ctx.lineTo(333.1,415.8);
      ctx.lineTo(362.8,436.6);
      ctx.lineTo(382.2,478.5);
      ctx.lineTo(396.1,440.6);
      ctx.lineTo(399,399.2);
      ctx.lineTo(378.1,357.7);
      ctx.lineTo(251,284.3);
      ctx.closePath();
      ctx.fillStyle = getFillColor(2)
      ctx.fill();

      // polygon 4
      ctx.beginPath();
      ctx.moveTo(123.9,357.7);
      ctx.lineTo(103,399.2);
      ctx.lineTo(105.9,440.6);
      ctx.lineTo(119.8,478.5);
      ctx.lineTo(139.2,436.6);
      ctx.lineTo(168.9,415.8);
      ctx.lineTo(184.2,413.7);
      ctx.lineTo(195.1,451.4);
      ctx.lineTo(251,451.4);
      ctx.lineTo(251,284.3);
      ctx.closePath();
      ctx.fillStyle = getFillColor(3)
      ctx.fill();

      // polygon 5
      ctx.beginPath();
      ctx.moveTo(169.4,237.2);
      ctx.lineTo(169.4,318.4);
      ctx.lineTo(130.9,343.9);
      ctx.lineTo(123.9,357.7);
      ctx.lineTo(251,284.3);
      ctx.closePath();
      ctx.fillStyle = getFillColor(4)
      ctx.fill();

      // polygon 6
      ctx.beginPath();
      ctx.moveTo(251,210.2);
      ctx.lineTo(216.5,190.2);
      ctx.lineTo(216.5,150.4);
      ctx.lineTo(251,130.4);
      ctx.lineTo(251,24.3);
      ctx.lineTo(225.4,43);
      ctx.lineTo(193.7,108.7);
      ctx.lineTo(169.4,229.5);
      ctx.lineTo(169.4,237.2);
      ctx.lineTo(251,284.3);
      ctx.closePath();
      ctx.fillStyle = getFillColor(5)
      ctx.fill();

      ctx.restore();
    }

    NumberAnimation on angle {
      id: angleAnimation
      running: false
      from: 0
      to: 6
      duration: 1000
      loops: Animation.Infinite
      onStopped: if (rocket.running) finishAnimation.start()
      alwaysRunToEnd: true
    }
    NumberAnimation on angle {
      id: finishAnimation
      running: false
      to: 12
      duration: 1000
      onStopped: {
        if (rocket.running) {
          if (rocket.breakAtTheEnd) {
            rocketBreaking.visible = true
            rocketCanvas.visible = false
            rocketBreaking.frameNumber = 0
            frameNumberTimer.start()
          } else {
            rocket.finished(true)
          }
        }
      }
    }
  }

  Item {
    id: rocketBreaking

    // alignment with the loading rocket
    x: 7
    y: -7

    readonly property int fromFrame: 101
    readonly property int numberOfFrames: 72
    property int frameNumber: 0

    Repeater {
      model: rocketBreaking.numberOfFrames
      Image {
        visible: rocketBreaking.frameNumber === modelData
        source: "/resources/images/rocket_breaking/frame_" + (rocketBreaking.fromFrame + modelData) + ".png"
      }
    }

    Timer {
      id: frameNumberTimer
      interval: 633 // the rocket is full red during this time
      onTriggered: {
        if (rocket.running) {
          console.time("animation duration")
          frameNumberAnimation.restart()
          rocket.startFailing() // signal emited to start error message fade in
        }
      }
    }

    NumberAnimation on frameNumber {
      id: frameNumberAnimation
      running: false
      from: 0
      to: rocketBreaking.numberOfFrames - 1

      // TODO(Gildas) find why 30 does not work for 30 fps
      duration: rocketBreaking.numberOfFrames * 1000 / 21 // 30
      onStopped: {
        if (rocket.running) {
          rocket.finished(false)
          console.timeEnd("animation duration")
          console.log("should be " + frameNumberAnimation.duration + "ms")
        }
      }
    }
  }
}
