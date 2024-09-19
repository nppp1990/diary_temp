import 'dart:math';

import 'package:flutter/material.dart';

class LeftArrow extends StatelessWidget {
  final double? size;
  final Color color;
  final double strokeWidth;
  final double angle;

  const LeftArrow({
    super.key,
    this.size,
    this.color = Colors.black,
    this.strokeWidth = 2,
    this.angle = 50 / 180 * pi,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: LeftArrowPainter(color: color, strokeWidth: strokeWidth, angle: angle),
      size: Size.square(size ?? 0.0),
    );
  }
}

class LeftArrowPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double angle;

  LeftArrowPainter({super.repaint, required this.color, required this.strokeWidth, required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Offset start = Offset(0, size.height / 2);

    // line1
    final length = size.width * 0.5;
    final p1 = start + Offset(length * cos(angle), -length * sin(angle));
    final p2 = start + Offset(length * cos(angle), length * sin(angle));
    final p3 = start + Offset(size.width, 0);
    canvas.drawLine(start, p1, paint);
    canvas.drawLine(start, p2, paint);
    canvas.drawLine(start, p3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
