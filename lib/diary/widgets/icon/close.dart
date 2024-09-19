import 'package:flutter/material.dart';

class IconClose extends StatelessWidget {
  final Color color;
  final double? size;
  final double strokeWidth;
  final double ratio;
  final bool showLeftLine;
  final bool showRightLine;

  const IconClose({
    super.key,
    this.color = Colors.black,
    this.size,
    this.strokeWidth = 2.0,
    this.ratio = 1.0,
    this.showLeftLine = true,
    this.showRightLine = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size ?? 0.0),
      painter: _ClosePainter(
          color: color,
          strokeWidth: strokeWidth,
          ratio: ratio,
          showLeftLine: showLeftLine,
          showRightLine: showRightLine),
    );
  }
}

class _ClosePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double ratio;
  final bool showLeftLine;
  final bool showRightLine;

  _ClosePainter({
    required this.showLeftLine,
    required this.showRightLine,
    required this.color,
    required this.strokeWidth,
    required this.ratio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final padding = size.width * (1 - ratio) / 2;

    if (showLeftLine) {
      canvas.drawLine(
        Offset(padding, padding),
        Offset(size.width - padding, size.height - padding),
        paint,
      );
    }
    if (showRightLine) {
      canvas.drawLine(
        Offset(size.width - padding, padding),
        Offset(padding, size.height - padding),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
