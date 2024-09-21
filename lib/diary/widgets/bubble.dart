import 'package:flutter/material.dart';

class BubbleBorder extends StatelessWidget {
  final Widget child;
  final TriangleDirection direction;
  final double triangleWidth;
  final double triangleHeight;
  final double triangleOffset;
  final double borderRadius;
  final double strokeWidth;
  final Color strokeColor;
  final Color? fillColor;

  const BubbleBorder({
    super.key,
    required this.child,
    this.direction = TriangleDirection.topEnd,
    required this.triangleWidth,
    required this.triangleHeight,
    required this.triangleOffset,
    required this.borderRadius,
    required this.strokeWidth,
    required this.strokeColor,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    EdgeInsetsGeometry padding;
    switch (direction) {
      case TriangleDirection.leftStart:
      case TriangleDirection.leftEnd:
        padding = EdgeInsets.only(left: triangleHeight);
        break;
      case TriangleDirection.rightStart:
      case TriangleDirection.rightEnd:
        padding = EdgeInsets.only(right: triangleHeight);
        break;
      case TriangleDirection.bottomStart:
      case TriangleDirection.bottomEnd:
        padding = EdgeInsets.only(bottom: triangleHeight);
        break;
      case TriangleDirection.topStart:
      case TriangleDirection.topEnd:
        padding = EdgeInsets.only(top: triangleHeight);
        break;
    }

    return CustomPaint(
      painter: BubbleBorderPainter(
        direction: direction,
        triangleWidth: triangleWidth,
        triangleHeight: triangleHeight,
        triangleOffset: triangleOffset,
        borderRadius: borderRadius,
        strokeWidth: strokeWidth,
        strokeColor: strokeColor,
        fillColor: fillColor,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

enum TriangleDirection {
  leftStart,
  leftEnd,
  rightStart,
  rightEnd,
  bottomStart,
  bottomEnd,
  topStart,
  topEnd,
}

class BubbleBorderPainter extends CustomPainter {
  final TriangleDirection direction;
  final double triangleWidth;
  final double triangleHeight;
  final double triangleOffset;
  final double borderRadius;
  final double strokeWidth;
  final Color strokeColor;
  final Color? fillColor;

  BubbleBorderPainter({
    super.repaint,
    required this.direction,
    required this.triangleWidth,
    required this.triangleHeight,
    required this.triangleOffset,
    required this.borderRadius,
    required this.strokeWidth,
    required this.strokeColor,
    this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint strokePaint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path arrowPath = Path();
    final Path rectPath = Path();
    switch (direction) {
      case TriangleDirection.leftStart:
        arrowPath.moveTo(triangleHeight, triangleOffset);
        arrowPath.lineTo(0, triangleOffset + triangleWidth / 2);
        arrowPath.lineTo(triangleHeight, triangleOffset + triangleWidth);
        arrowPath.close();
        rectPath.addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(triangleHeight, 0, size.width - triangleHeight, size.height),
          Radius.circular(borderRadius),
        ));
        break;
      case TriangleDirection.leftEnd:
        arrowPath.moveTo(triangleHeight, size.height - triangleOffset);
        arrowPath.lineTo(0, size.height - triangleOffset - triangleWidth / 2);
        arrowPath.lineTo(triangleHeight, size.height - triangleOffset - triangleWidth);
        arrowPath.close();
        rectPath.addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(triangleHeight, 0, size.width - triangleHeight, size.height),
          Radius.circular(borderRadius),
        ));
        break;
      case TriangleDirection.rightStart:
        arrowPath.moveTo(size.width - triangleHeight, triangleOffset);
        arrowPath.lineTo(size.width, triangleOffset + triangleWidth / 2);
        arrowPath.lineTo(size.width - triangleHeight, triangleOffset + triangleWidth);
        arrowPath.close();
        rectPath.addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width - triangleHeight, size.height),
          Radius.circular(borderRadius),
        ));
        break;
      case TriangleDirection.rightEnd:
        arrowPath.moveTo(size.width - triangleHeight, size.height - triangleOffset);
        arrowPath.lineTo(size.width, size.height - triangleOffset - triangleWidth / 2);
        arrowPath.lineTo(size.width - triangleHeight, size.height - triangleOffset - triangleWidth);
        arrowPath.close();
        rectPath.addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width - triangleHeight, size.height),
          Radius.circular(borderRadius),
        ));
        break;
      case TriangleDirection.bottomStart:
        arrowPath.moveTo(triangleOffset, size.height - triangleHeight);
        arrowPath.lineTo(triangleOffset + triangleWidth / 2, size.height);
        arrowPath.lineTo(triangleOffset + triangleWidth, size.height - triangleHeight);
        arrowPath.close();
        rectPath.addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height - triangleHeight),
          Radius.circular(borderRadius),
        ));
        break;
      case TriangleDirection.bottomEnd:
        arrowPath.moveTo(size.width - triangleOffset, size.height - triangleHeight);
        arrowPath.lineTo(size.width - triangleOffset - triangleWidth / 2, size.height);
        arrowPath.lineTo(size.width - triangleOffset - triangleWidth, size.height - triangleHeight);
        arrowPath.close();
        rectPath.addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height - triangleHeight),
          Radius.circular(borderRadius),
        ));
        break;
      case TriangleDirection.topStart:
        arrowPath.moveTo(triangleOffset, triangleHeight);
        arrowPath.lineTo(triangleOffset + triangleWidth / 2, 0);
        arrowPath.lineTo(triangleOffset + triangleWidth, triangleHeight);
        arrowPath.close();
        rectPath.addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, triangleHeight, size.width, size.height - triangleHeight),
          Radius.circular(borderRadius),
        ));
        break;
      case TriangleDirection.topEnd:
        arrowPath.moveTo(size.width - triangleOffset, triangleHeight);
        arrowPath.lineTo(size.width - triangleOffset - triangleWidth / 2, 0);
        arrowPath.lineTo(size.width - triangleOffset - triangleWidth, triangleHeight);
        arrowPath.close();
        rectPath.addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, triangleHeight, size.width, size.height - triangleHeight),
          Radius.circular(borderRadius),
        ));
        break;
    }

    Path path = Path.combine(PathOperation.union, arrowPath, rectPath);
    if (fillColor != null) {
      final Paint fillPaint = Paint()
        ..color = fillColor!
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, fillPaint);
    }
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
