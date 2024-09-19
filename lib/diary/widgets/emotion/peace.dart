import 'package:flutter/material.dart';

class PeaceEmotion extends StatelessWidget {
  final double size;

  const PeaceEmotion({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PeacePainter(),
      size: Size.square(size),
    );
  }
}


class _PeacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawEyes(canvas, size);
    _drawMouth(canvas, size.width);
  }

  _drawBackground(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFAED581)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width / 2, size.width / 2), size.width / 2, paint);
  }

  _drawEyes(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final eyeRadius = size.width / 12;

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

  _drawMouth(Canvas canvas, double size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final mouthWidth = size / 3;
    final mouthHeight = size / 12;

    final path = Path()
      ..moveTo(size / 3, size / 2)
      ..cubicTo(
        size / 3 + mouthWidth / 3,
        size / 2 + mouthHeight / 2,
        size * 2 / 3 - mouthWidth / 3,
        size / 2 + mouthHeight / 2,
        size * 2 / 3,
        size / 2,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
