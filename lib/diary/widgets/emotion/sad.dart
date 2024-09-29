import 'dart:math';

import 'package:dribbble/diary/utils/path_utils.dart';
import 'package:flutter/material.dart';

class SadEmotion extends StatelessWidget {
  final double size;

  const SadEmotion({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SadPainter(),
      size: Size.square(size),
    );
  }
}

class _SadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawEyes(canvas, size);
    _drawMouth(canvas, size.width);
  }

  _drawBackground(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2859AA)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width / 2, size.width / 2), size.width / 2, paint);
  }

  _drawEyes(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final eyeRadius = size.width / 24;

    canvas.drawCircle(
      Offset(size.width / 3, size.width / 3),
      eyeRadius,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width * 2 / 3, size.width / 3),
      eyeRadius,
      paint,
    );
  }

  static const List<double> _cubicBezier = [537, 315, 433, 249, 279, 292];

  _drawMouth(Canvas canvas, double size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path();
    final startPoint = Offset(size * 3 / 4, size * 2 / 3 + size / 16);
    final endPoint = Offset(size / 2 - size / 12, size * 2 / 3);
    final controlPoint = PathUtils.quadraticBezierPoint(startPoint, endPoint, _cubicBezier);
    path.moveTo(startPoint.dx, startPoint.dy);
    path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
