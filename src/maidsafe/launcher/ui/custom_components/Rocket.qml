import QtQuick 2.4

Canvas {
    id: rocketLoading
    width: 400
    height: 400
    antialiasing: true
    property real animationPosition

    onAnimationPositionChanged:requestPaint()

    function alphaPolygon1(value) { return value < 1 ? value : 1 - ((value - 1) / 5) }
    function alphaPolygon2(value) { value -= 1; if (value < 0) value +=6; return alphaPolygon1(value); }
    function alphaPolygon3(value) { value -= 2; if (value < 0) value +=6; return alphaPolygon1(value); }
    function alphaPolygon4(value) { value -= 3; if (value < 0) value +=6; return alphaPolygon1(value); }
    function alphaPolygon5(value) { value -= 4; if (value < 0) value +=6; return alphaPolygon1(value); }
    function alphaPolygon6(value) { value -= 5; if (value < 0) value +=6; return alphaPolygon1(value); }

    onPaint: {
        var ctx = getContext("2d");
        ctx.save();
        ctx.scale(width/500, height/500);

        ctx.clearRect(0, 0, 500, 500);

        // polygon 1
        ctx.beginPath();
/*
        ctx.moveTo(0.6168 *width, 0.2174 *height);
        ctx.lineTo(0.5532 *width, 0.0860 *height);
        ctx.lineTo(0.5020 *width, 0.0486 *height);
        ctx.lineTo(0.5020 *width, 0.2608 *height);
        ctx.lineTo(0.5710 *width, 0.3008 *height);
        ctx.lineTo(0.5710 *width, 0.3844 *height);
        ctx.lineTo(0.5020 *width, 0.4204 *height);
        ctx.lineTo(0.5020 *width, 0.5686 *height);
        ctx.lineTo(0.6652 *width, 0.4744 *height);
        ctx.lineTo(0.6652 *width, 0.4590 *height);
        */

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
        ctx.fillStyle = Qt.rgba(1,1,1, alphaPolygon1(animationPosition));
        ctx.fill();

        // polygon 2
        ctx.beginPath();
        ctx.moveTo(378.1,357.7);
        ctx.lineTo(371.1,343.9);
        ctx.lineTo(332.6,318.4);
        ctx.lineTo(332.6,237.2);
        ctx.lineTo(251,284.3);
        ctx.closePath();
        ctx.fillStyle = Qt.rgba(1,1,1, alphaPolygon2(animationPosition));
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
        ctx.fillStyle = Qt.rgba(1,1,1, alphaPolygon3(animationPosition));
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
        ctx.fillStyle = Qt.rgba(1,1,1, alphaPolygon4(animationPosition));
        ctx.fill();

        // polygon 5
        ctx.beginPath();
        ctx.moveTo(169.4,237.2);
        ctx.lineTo(169.4,318.4);
        ctx.lineTo(130.9,343.9);
        ctx.lineTo(123.9,357.7);
        ctx.lineTo(251,284.3);
        ctx.closePath();
        ctx.fillStyle = Qt.rgba(1,1,1, alphaPolygon5(animationPosition));
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
        ctx.fillStyle = Qt.rgba(1,1,1, alphaPolygon6(animationPosition));
        ctx.fill();

        ctx.restore();
    }

    NumberAnimation on animationPosition {
        from: 0
        to: 6
        duration: 1000
        loops: Animation.Infinite
    }
}
