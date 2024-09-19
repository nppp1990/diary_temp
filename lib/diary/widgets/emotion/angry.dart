import 'dart:math';

import 'package:dribbble/diary/utils/pathUtils.dart';
import 'package:flutter/material.dart';

class AngryEmotion extends StatelessWidget {
  final double size;

  const AngryEmotion({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AngryPainter(),
      size: Size.square(size),
    );
  }
}

class _AngryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawEyes(canvas, size.width);
    _drawMouth(canvas, size);
  }

  _drawBackground(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width / 2, size.width / 2), size.width / 2, paint);
  }

  _drawEyes(Canvas canvas, double size) {
    final eyeRadius = size / 12;

    // draw eyebrows
    final eyebrowPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    Offset endPoint = Offset(size / 2 + size / 30, size / 3 - eyeRadius / 2);
    Offset leftPoint = PathUtils.getEndPoint(endPoint, 3 * eyeRadius, pi + pi / 16);
    Offset rightPoint = PathUtils.getEndPoint(endPoint, 3 * eyeRadius, 2 * pi - pi / 15);
    canvas.drawLine(leftPoint, endPoint, eyebrowPaint);
    canvas.drawLine(rightPoint, endPoint, eyebrowPaint);

    // draw eye balls
    final eyePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      endPoint + Offset(-size / 24, size / 24),
      size / 24,
      eyePaint,
    );
    canvas.drawCircle(
      endPoint + Offset(size / 24, size / 24),
      size / 24,
      eyePaint,
    );
  }

  static const List<double> _cubicBezier = [549, 426, 438, 303, 312, 387];

  _drawMouth(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path();
    final startPoint = Offset(size.width * 2 / 3, size.width * 2 / 3 + size.width / 12);
    final endPoint = Offset(size.width / 3, size.width * 2 / 3);
    final controlPoint = PathUtils.quadraticBezierPoint(startPoint, endPoint, _cubicBezier);
    path.moveTo(startPoint.dx, startPoint.dy);
    path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
