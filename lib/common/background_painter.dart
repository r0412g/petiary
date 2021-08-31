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
      ..color =Color.fromRGBO(255, 255, 255, 80.0);
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
