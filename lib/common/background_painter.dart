import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/common/theme.dart';

class DrawBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double startPaintWidth = (size.width - size.width / 5) + 4;
    double baseOfTriangle = 42;
    double triangleHeight = 22;
    double rectHeight = 83;
    double rectWidth = startPaintWidth + baseOfTriangle;

    // Draw background
    var paint = Paint()
      ..isAntiAlias = true
      ..color = ColorSet.colorsWhite;
    canvas.drawRect(Offset.zero & size, paint);

    // Draw tag
    paint
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = ColorSet.colorsDarkBlueGreenOfOpacity80;
    canvas.drawPath(
      Path()
        // start position
        ..moveTo(startPaintWidth, 0)
        // draw line down
        ..lineTo(startPaintWidth, rectHeight)
        // draw hypotenuse down
        ..lineTo(
          startPaintWidth + baseOfTriangle / 2,
          rectHeight + triangleHeight,
        )
        // draw hypotenuse up
        ..lineTo(rectWidth, rectHeight)
        // draw line up
        ..lineTo(rectWidth, 0),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class DrawContactDevPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double startPaintWidth = size.width + 30;
    double startPaintHeight = size.height + 165;
    double firstCircleStartHeight = startPaintHeight + 45;
    double secondCircleStartHeight = startPaintHeight + 175;
    double thirdCircleStartHeight = startPaintHeight + 305;

    // Draw background
    var paint = Paint()
      ..isAntiAlias = true
      ..color = ColorSet.colorsWhite;
    canvas.drawRect(Offset.zero & size, paint);

    // Draw first line
    paint
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = ColorSet.colorsDarkGreen;
    canvas.drawPath(
      Path()
        // start position
        ..moveTo(startPaintWidth, startPaintHeight)
        // draw line down
        ..lineTo(startPaintWidth, firstCircleStartHeight-6),
      paint,
    );

    // Draw first circle
    paint
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = ColorSet.colorsDarkGreen;
    canvas.drawCircle(
        Offset(startPaintWidth, firstCircleStartHeight), 6.0, paint);

    // Draw second line
    paint
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = ColorSet.colorsDarkGreen;
    canvas.drawPath(
      Path()
        // start position
        ..moveTo(startPaintWidth, firstCircleStartHeight+6)
        // draw line down
        ..lineTo(startPaintWidth, secondCircleStartHeight-6),
      paint,
    );

    // Draw second circle
    paint
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = ColorSet.colorsDarkGreen;
    canvas.drawCircle(
        Offset(startPaintWidth, secondCircleStartHeight), 6.0, paint);

    // Draw third line
    paint
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = ColorSet.colorsDarkGreen;
    canvas.drawPath(
      Path()
        // start position
        ..moveTo(startPaintWidth, secondCircleStartHeight+6)
        // draw line down
        ..lineTo(startPaintWidth, thirdCircleStartHeight-6),
      paint,
    );

    // Draw third circle
    paint
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = ColorSet.colorsDarkGreen;
    canvas.drawCircle(
        Offset(startPaintWidth, thirdCircleStartHeight), 6.0, paint);

    // Draw fourth line
    paint
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = ColorSet.colorsDarkGreen;
    canvas.drawPath(
      Path()
        // start position
        ..moveTo(startPaintWidth, thirdCircleStartHeight+6)
        // draw line down
        ..lineTo(startPaintWidth, startPaintHeight + 350),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
