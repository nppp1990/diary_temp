import 'dart:math';

import 'package:flutter/material.dart';

class CordLock extends StatelessWidget {
  final Color lockColor;
  final double lockRadius;
  final Color cordColor;
  final double strokeWidth;
  final double lineWidthRatio;
  final bool startLeft;

  const CordLock({
    super.key,
    this.lockColor = Colors.black,
    required this.lockRadius,
    this.cordColor = const Color(0xFF9D9D9D),
    this.strokeWidth = 1,
    this.lineWidthRatio = 0.3,
    this.startLeft = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CordLockPainter(
        lockColor: lockColor,
        lockRadius: lockRadius,
        cordColor: cordColor,
        strokeWidth: strokeWidth,
        lineWidthRatio: lineWidthRatio,
        startLeft: startLeft,
      ),
    );
  }
}

class _CordLockPainter extends CustomPainter {
  final Color lockColor;
  final double lockRadius;
  final Color cordColor;
  final double strokeWidth;
  final double lineWidthRatio;

  // 上面的圆在左边还是右边
  final bool startLeft;

  _CordLockPainter({
    required this.lockColor,
    required this.lockRadius,
    required this.cordColor,
    required this.strokeWidth,
    required this.lineWidthRatio,
    required this.startLeft,
  });

  void _addArc(Path path, double dx, double dy, double length, double angle, bool isDown) {
    final double radius = length / 2 / sin(angle / 2);
    final double startAngle;
    final Offset centerPoint;
    if (isDown) {
      // 圆心在(dx, dy)的下面
      startAngle = pi + pi / 2 - angle / 2;
      centerPoint = Offset(dx + length / 2, dy + radius * cos(angle / 2));
    } else {
      // 圆心在(dx, dy)的上面
      startAngle = pi / 2 - angle / 2;
      centerPoint = Offset(dx - length / 2, dy - radius * cos(angle / 2));
    }
    path.addArc(Rect.fromCircle(center: centerPoint, radius: radius), startAngle, angle);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double circleRadius = lockRadius;
    final double lineWidth = circleRadius * lineWidthRatio;

    final Paint circlePaint = Paint()
      ..color = lockColor
      ..style = PaintingStyle.fill;
    final Paint linePaint = Paint()
      ..color = cordColor
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.3)
      ..strokeWidth = 2;
    final Paint fillLinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Offset upCircleCenter =
    startLeft ? Offset(circleRadius, circleRadius) : Offset(size.width - circleRadius, circleRadius);
    final Offset downCircleCenter = startLeft
        ? Offset(size.width - circleRadius, size.height - circleRadius)
        : Offset(circleRadius, size.height - circleRadius);
    canvas.drawCircle(upCircleCenter, circleRadius, circlePaint);
    canvas.drawCircle(downCircleCenter, circleRadius, circlePaint);

    Offset p1 = Offset(upCircleCenter.dx - lineWidth / 2, upCircleCenter.dy);
    Offset p2 = Offset(upCircleCenter.dx + lineWidth / 2, upCircleCenter.dy);
    Offset p3 = Offset(downCircleCenter.dx + lineWidth / 2, downCircleCenter.dy);
    Offset p4 = Offset(downCircleCenter.dx - lineWidth / 2, downCircleCenter.dy);

    final Path path = Path()
      ..moveTo(p1.dx, p1.dy);
    _addArc(path, p1.dx, p1.dy, lineWidth, 180 / 180 * pi, true);
    _addArc(path, p3.dx, p3.dy, lineWidth, 180 / 180 * pi, false);
    path.addPolygon([p1, p2, p3, p4], true);
    canvas.drawPath(path, linePaint);
    canvas.drawPath(path, fillLinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
