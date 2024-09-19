import 'dart:math';

import 'package:dribbble/diary/utils/pathUtils.dart';
import 'package:flutter/material.dart';

class HappyEmotion extends StatelessWidget {
  final double size;

  const HappyEmotion({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HappyPainter(),
      size: Size.square(size),
    );
  }
}

class _HappyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawEyes(canvas, size);
    _drawMouth(canvas, size);
  }

  _drawBackground(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width / 2, size.width / 2), size.width / 2, paint);
  }

  _drawEyes(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final eyeRadius = size.width / 12;

    canvas.drawArc(
      Rect.fromLTWH(size.width / 3 - eyeRadius, size.width / 3 - eyeRadius / 2, eyeRadius * 2, eyeRadius * 3),
      pi,
      pi,
      false,
      paint,
    );

    canvas.drawArc(
      Rect.fromLTWH(size.width * 2 / 3 - eyeRadius, size.width / 3 - eyeRadius / 2, eyeRadius * 2, eyeRadius * 3),
      pi,
      pi,
      false,
      paint,
    );
  }

  static const List<double> _cubicBezier = [442, 237,292, 335, 186, 263];

  _drawMouth(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path();
    final startPoint = Offset(size.width * 3 / 4, size.width * 2 / 3 - size.width / 12);
    final endPoint = Offset(size.width / 4, size.width * 2 / 3);
    final controlPoint = PathUtils.quadraticBezierPoint(startPoint, endPoint, _cubicBezier);
    path.moveTo(startPoint.dx, startPoint.dy);
    path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
