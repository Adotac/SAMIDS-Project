import 'dart:math';

import 'package:flutter/material.dart';

class Circle extends CustomPainter {
  final Color color;
  final Color sliderColor;
  final Color unSelectedColor;
  final double angle;
  Circle(
      {required this.angle,
      required this.color,
      required this.sliderColor,
      required this.unSelectedColor});
  @override
  void paint(Canvas canvas, Size size) {
    var center = const Offset(0, 0);
    canvas.translate(size.width / 2, size.height / 2);
    var radius = max(0, size.width / 2); // Ensure the radius is non-negative
    var circleBrush = Paint()..color = color;
    var unSelectedAreaBrush = Paint()..color = unSelectedColor;
    var sliderBrush = Paint()
      ..color = sliderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius.toDouble(), circleBrush);
    canvas.drawCircle(center, max(0, radius - 15), unSelectedAreaBrush);
    canvas.drawArc(
      Rect.fromCircle(
        center: const Offset(0, 0),
        radius: max(0, radius - 7),
      ),
      0,
      (angle * pi / 180)
          .clamp(-2 * pi, 2 * pi), // Clamp the angle value to a valid range
      false,
      sliderBrush,
    );

    canvas.drawCircle(center, max(0, radius - 45), circleBrush);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
