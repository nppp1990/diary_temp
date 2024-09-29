import 'dart:math';

import 'package:dribbble/diary/common/test_colors.dart';
import 'package:dribbble/diary/utils/path_utils.dart';
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
      ..color = TestColors.moodColors[0]
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width / 2, size.width / 2), size.width / 2, paint);
  }

  _drawEyes(Canvas canvas, double size) {
    // 倾斜一点点的椭圆 作为左眼
    final eyePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 0.03 * size
      ..style = PaintingStyle.stroke;

    var rect = Rect.fromCenter(center: Offset(size / 3, size / 3), width: size * 0.25, height: size * 0.3);
    // 椭圆上的点p1 角度为pi/12
    // var p1 = PathUtils.getEndPoint(Offset(size / 3, size / 3), size * 0.25 / 2, pi / 12);
    var p1 = PathUtils.getPointOnEllipse(Offset(size / 3, size / 3), size * 0.25 / 2, size * 0.3 / 2, pi / 12);
    // canvas.drawCircle(p1, 2, Paint()..color = Colors.yellow..style = PaintingStyle.fill);

    var p2 = PathUtils.getPointOnEllipse(Offset(size / 3, size / 3), size * 0.25 / 2, size * 0.3 / 2, pi + pi / 12);
    // canvas.drawCircle(p2, 2, Paint()..color = Colors.yellow..style = PaintingStyle.fill);

    // Path lowHalfPath = Path.combine(
    //     PathOperation.difference,
    //     Path()..addOval(rect),
    //     Path()..addRect(Rect.fromLTRB(0, 0, size, p1.dy))
    // );
    //
    // canvas.drawPath(lowHalfPath, Paint()..color = Colors.white..style = PaintingStyle.fill);
    // canvas.drawLine(p1, p2, eyePaint);

    Path ovalPath = Path()
      ..addOval(rect);
    // 旋转path
    final matrix = Matrix4.identity()
      // ..translate(size / 3, size / 3)
    ..rotateX(pi / 12);
      // ..translate(-size / 3, -size / 3);
    ovalPath.transform(matrix.storage);
    canvas.drawPath(ovalPath, eyePaint);




    // canvas.save();
    // canvas.translate(size / 3, size / 3);
    // canvas.rotate(pi / 12);
    // canvas.translate(-size / 3, -size / 3);
    // canvas.drawOval(rect, eyePaint);
    // canvas.restore();

    // final eyeRadius = size / 12;
    //
    // // draw eyebrows
    // final eyebrowPaint = Paint()
    //   ..color = Colors.black
    //   ..style = PaintingStyle.stroke
    //   ..strokeWidth = 4;
    // Offset endPoint = Offset(size / 2 + size / 30, size / 3 - eyeRadius / 2);
    // Offset leftPoint = PathUtils.getEndPoint(endPoint, 3 * eyeRadius, pi + pi / 16);
    // Offset rightPoint = PathUtils.getEndPoint(endPoint, 3 * eyeRadius, 2 * pi - pi / 15);
    // canvas.drawLine(leftPoint, endPoint, eyebrowPaint);
    // canvas.drawLine(rightPoint, endPoint, eyebrowPaint);

    // draw eye balls
    // final eyePaint = Paint()
    //   ..color = Colors.black
    //   ..strokeCap = StrokeCap.round
    //   ..style = PaintingStyle.fill;
    //
    // canvas.drawCircle(
    //   endPoint + Offset(-size / 24, size / 24),
    //   size / 24,
    //   eyePaint,
    // );
    // canvas.drawCircle(
    //   endPoint + Offset(size / 24, size / 24),
    //   size / 24,
    //   eyePaint,
    // );
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
