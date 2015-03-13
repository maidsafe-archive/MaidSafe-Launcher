import QtQuick 2.4

Canvas {
    id: rocketLoading

// PUBLIC

    signal finished()
    function startLoading() {
      return startLoadingWithColor("#ffffff");
    }

    function goToError() {
      return stopToColor("#ff0000");
    }
    function goToSuccess() {
      return stopToColor("#ffffff");
    }

// PRIVATE

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
    property real  angle // angle between 0 and 6

    function getFillColor(polygon) {
      if (angle - 6 > polygon) { // mean animation ending
        return Qt.rgba(toColor.r,
                       toColor.g,
                       toColor.b,
                       Math.min(angle - 6 -polygon, 1))
      } else {
        return Qt.rgba(currentColor.r,
                       currentColor.g,
                       currentColor.b,
                       getFillColorAlpha(polygon))
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
      duration: 5000
      loops: Animation.Infinite
      onStopped: finishAnimation.start()
      alwaysRunToEnd: true
    }
    NumberAnimation on angle {
      id: finishAnimation
      running: false
      to: 12
      duration: 5000
      onStopped: rocketLoading.finished()
      alwaysRunToEnd: true
    }
}
