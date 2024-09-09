import 'dart:math';

import 'package:dribbble/diary/utils/pathUtils.dart';
import 'package:dribbble/diary/widgets/turn/const.dart';
import 'package:dribbble/diary/widgets/turn/turn_direction.dart';
import 'package:flutter/material.dart';

/// A widget that provides a page-turning animation.
class TurnPageAnimation extends StatelessWidget {
  TurnPageAnimation({
    super.key,
    required this.index,
    required this.animation,
    required this.overleafColor,
    this.animationTransitionPoint,
    this.direction = TurnDirection.rightToLeft,
    required this.cornerRadius,
    required this.child,
  }) {
    final transitionPoint = animationTransitionPoint;
    assert(
      transitionPoint == null || 0 <= transitionPoint && transitionPoint < 1,
      'animationTransitionPoint must be 0 <= animationTransitionPoint < 1',
    );
  }

  final int index;

  /// The animation that controls the page-turning effect.
  final Animation<double> animation;

  /// The color of the backside of the pages.
  /// Default color is [Colors.grey].
  final Color overleafColor;

  /// The point that behavior of the turn-page-animation changes.
  /// This value must be 0 <= animationTransitionPoint < 1.
  final double? animationTransitionPoint;

  /// The direction in which the pages are turned.
  final TurnDirection direction;

  final double cornerRadius;

  /// The widget that is displayed with the page-turning animation.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final transitionPoint = animationTransitionPoint ?? defaultAnimationTransitionPoint;

    // final alignment = direction == TurnDirection.rightToLeft ? Alignment.centerLeft : Alignment.centerRight;

    // print('-----build:animation.value: ${animation.value}---index: $index');
    return CustomPaint(
      foregroundPainter: _OverleafPainter(
        animation: animation,
        color: overleafColor,
        animationTransitionPoint: transitionPoint,
        direction: direction,
        cornerRadius: cornerRadius,
      ),
      child: ClipPath(
        clipper: _PageTurnClipper(
          animation: animation,
          animationTransitionPoint: transitionPoint,
          direction: direction,
        ),
        child: child,
        // child: Align(
        //   // alignment: alignment,
        //   child: child,
        // ),
      ),
    );
  }
}

/// CustomClipper that creates the page-turning clipping path.
class _PageTurnClipper extends CustomClipper<Path> {
  const _PageTurnClipper({
    required this.animation,
    required this.animationTransitionPoint,
    this.direction = TurnDirection.leftToRight,
  });

  /// The animation that controls the page-turning effect.
  final Animation<double> animation;

  /// The point at which the page-turning animation behavior changes.
  /// This value must be between 0 and 1 (0 <= animationTransitionPoint < 1).
  final double animationTransitionPoint;

  /// The direction in which the pages are turned.
  final TurnDirection direction;

  /// Creates the clipping path based on the animation progress and direction.
  @override
  Path getClip(Size size) {
    final width = size.width;
    final height = size.height;
    final animationProgress = animation.value;

    final verticalVelocity = 1 / animationTransitionPoint;

    late final double innerTopCornerX;
    late final double innerBottomCornerX;
    late final double outerBottomCornerX;
    late final double foldUpperCornerX;
    late final double foldLowerCornerX;
    switch (direction) {
      case TurnDirection.rightToLeft:
        innerTopCornerX = 0.0;
        innerBottomCornerX = 0.0;
        foldUpperCornerX = width * (1.0 - animationProgress);
        break;
      case TurnDirection.leftToRight:
        innerTopCornerX = width;
        innerBottomCornerX = width;
        foldUpperCornerX = width * animationProgress;
        break;
    }

    // 内部的上部角
    final innerTopCorner = Offset(innerTopCornerX, 0.0);
    // 折叠的上部角
    final foldUpperCorner = Offset(foldUpperCornerX, 0.0);
    // 内部的底部角
    final innerBottomCorner = Offset(innerBottomCornerX, height);

    final path = Path()
      ..moveTo(innerTopCorner.dx, innerTopCorner.dy) // (0, 0)
      ..lineTo(foldUpperCorner.dx, foldUpperCorner.dy); // (a, 0)

    if (animationProgress <= animationTransitionPoint) {
      // 折叠的底部角
      final foldLowerCornerY = height * verticalVelocity * animationProgress;
      switch (direction) {
        case TurnDirection.rightToLeft:
          outerBottomCornerX = width;
          foldLowerCornerX = width;
          break;
        case TurnDirection.leftToRight:
          outerBottomCornerX = 0.0;
          foldLowerCornerX = 0.0;
          break;
      }
      final outerBottomCorner = Offset(outerBottomCornerX, height);
      final foldLowerCorner = Offset(foldLowerCornerX, foldLowerCornerY);
      path
        ..lineTo(foldLowerCorner.dx, foldLowerCorner.dy) // (w, b)
        ..lineTo(outerBottomCorner.dx, outerBottomCorner.dy) // (w, h)
        ..lineTo(innerBottomCorner.dx, innerBottomCorner.dy) // (0, h)
        ..close();
    } else {
      final progressSubtractedDefault = animationProgress - animationTransitionPoint;
      final horizontalVelocity = 1 / (1 - animationTransitionPoint);
      final turnedBottomWidth = width * progressSubtractedDefault * horizontalVelocity;
      // (x - 0.1) / (1-0.1) x从0.1到1 [0, 1]

      switch (direction) {
        case TurnDirection.rightToLeft:
          foldLowerCornerX = width - turnedBottomWidth;
          break;
        case TurnDirection.leftToRight:
          foldLowerCornerX = turnedBottomWidth;
          break;
      }

      final foldLowerCorner = Offset(foldLowerCornerX, height);

      path
        ..lineTo(foldLowerCorner.dx, foldLowerCorner.dy) // BottomLeft (c, h) c从width到0
        ..lineTo(innerBottomCorner.dx, innerBottomCorner.dy) // BottomRight (0, h)
        ..close();
    }

    return path;
  }

  @override
  bool shouldReclip(_PageTurnClipper oldClipper) {
    return true;
  }
}

/// CustomPainter that paints the backside of the pages during the animation.
class _OverleafPainter extends CustomPainter {
  const _OverleafPainter({
    required this.animation,
    required this.color,
    required this.animationTransitionPoint,
    required this.direction,
    required this.cornerRadius,
  });

  /// The animation that controls the page-turning effect.
  final Animation<double> animation;

  /// The color of the backside of the pages.
  final Color color;

  /// The point at which the page-turning animation behavior changes.
  /// This value must be between 0 and 1 (0 <= animationTransitionPoint < 1).
  final double animationTransitionPoint;

  /// The direction in which the pages are turned.
  final TurnDirection direction;

  final double cornerRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final animationProgress = animation.value;

    // late final double topCornerX;
    // late final double bottomCornerX;
    // late final double topFoldX;
    // late final double bottomFoldX;

    final turnedXDistance = width * animationProgress;

    // switch (direction) {
    //   case TurnDirection.rightToLeft:
    //     topFoldX = width - turnedXDistance;
    //     break;
    //   case TurnDirection.leftToRight:
    //     topFoldX = turnedXDistance;
    //     break;
    // }

    final path = Path();

    // final topCornerPath = Path()
    //   ..moveTo(width - cornerRadius, 0)
    //   ..arcToPoint(
    //     Offset(width, cornerRadius),
    //     radius: Radius.circular(cornerRadius),
    //     clockwise: false,
    //   );
    final verticalVelocity = 1 / animationTransitionPoint;
    final turnedYDistance = height * animationProgress * verticalVelocity;

    if (animationProgress < animationTransitionPoint) {
      _handlePath1(path, turnedXDistance, turnedYDistance, width, height);
    } else if (animationProgress < 1) {
      final horizontalVelocity = 1 / (1 - animationTransitionPoint);
      final progressSubtractedDefault = animationProgress - animationTransitionPoint;
      final turnedBottomWidth = width * progressSubtractedDefault * horizontalVelocity;
      _handlePath2(path, turnedXDistance, turnedBottomWidth, width, height);
    } else {
      path.reset();
    }

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

      canvas
        ..drawPath(path, fillPaint)
        ..drawPath(path, linePaint);


    // print('-----paint:animation.value: ${animation.value}----${animationProgress == 0}');
    // if (animationProgress == 0) {
    //   canvas
    //     ..drawPath(path, fillPaint)
    //     ..drawPath(path, linePaint);
    // } else {
    //   final shadowPaint = Paint()
    //     ..color = Colors.transparent
    //     ..style = PaintingStyle.fill;
    //
    //   Path shadowPath = Path()
    //     ..moveTo(0, 0)
    //     ..lineTo(width - cornerRadius, 0)
    //     ..arcToPoint(
    //       Offset(width, cornerRadius),
    //       radius: Radius.circular(cornerRadius),
    //       clockwise: true,
    //     )
    //     ..lineTo(width, height - cornerRadius)
    //     ..arcToPoint(
    //       Offset(width - cornerRadius, height),
    //       radius: Radius.circular(cornerRadius),
    //       clockwise: true,
    //     )
    //     ..lineTo(0, height)
    //     ..close();
    //   canvas
    //     ..drawPath(shadowPath, shadowPaint)
    //     ..drawPath(path, fillPaint)
    //     ..drawPath(path, linePaint);
    // }


  }

  // width,height: size的宽高
  // w,h: 移动的距离
  void _handlePath1(Path path, double w, double h, double width, double height) {
    if (h < cornerRadius) {
      return;
    }
    if (w < cornerRadius) {
      Offset symmetryStartPoint = Offset(width - w, 0);
      Offset symmetryEndPoint = Offset(width, h);

      Offset p1 = PathUtils.getIntersection(
        Offset(width - cornerRadius, cornerRadius),
        cornerRadius,
        arcStartPoint: Offset(width - cornerRadius, 0),
        arcEndPoint: Offset(width, cornerRadius),
        lineStart: symmetryStartPoint,
        lineEnd: symmetryEndPoint,
        // symmetryStartPoint,
        // symmetryEndPoint,
      )!;

      Offset p2 = PathUtils.getSymmetryPoint(Offset(width, cornerRadius), symmetryStartPoint, symmetryEndPoint);
      path.moveTo(p1.dx, p1.dy);
      path.arcToPoint(p2, radius: Radius.circular(cornerRadius), clockwise: false);
      path.lineTo(width, h);
      path.close();
      return;
    }
    // 这里要反过来
    Offset symmetryStartPoint = Offset(width, h);
    Offset symmetryEndPoint = Offset(width - w, 0);

    // Offset p1 = PathUtils.getSymmetryPoint(Offset(topFoldX, 0), symmetryStartPoint, symmetryEndPoint);
    Offset p1 = PathUtils.getSymmetryPoint(Offset(width - w, 0), symmetryStartPoint, symmetryEndPoint);
    Offset p2 = PathUtils.getSymmetryPoint(Offset(width - cornerRadius, 0), symmetryStartPoint, symmetryEndPoint);
    Offset p3 = PathUtils.getSymmetryPoint(Offset(width, cornerRadius), symmetryStartPoint, symmetryEndPoint);
    path.moveTo(p1.dx, p1.dy);
    path.lineTo(p2.dx, p2.dy);
    path.arcToPoint(p3, radius: Radius.circular(cornerRadius), clockwise: false);
    if (h < height - cornerRadius) {
      // 直线，下方无圆弧
      Offset p4 = PathUtils.getSymmetryPoint(Offset(width, h), symmetryStartPoint, symmetryEndPoint);
      path.lineTo(p4.dx, p4.dy);
      path.close();
    } else {
      Offset p4 =
          PathUtils.getSymmetryPoint(Offset(width, height - cornerRadius), symmetryStartPoint, symmetryEndPoint);
      path.lineTo(p4.dx, p4.dy);
      Offset p5 = PathUtils.getIntersection(
        Offset(width - cornerRadius, height - cornerRadius),
        cornerRadius,
        arcStartPoint: Offset(width - cornerRadius, height),
        arcEndPoint: Offset(width, height - cornerRadius),
        lineStart: symmetryStartPoint,
        lineEnd: symmetryEndPoint,
      )!;
      path.arcToPoint(p5, radius: Radius.circular(cornerRadius), clockwise: false);
      path.close();
    }
  }

  // width,height: size的宽高
  // w,h: 移动的距离
  // bottomW: 底部移动的距离
  // w, bottomW: 会变化；h固定为height
  void _handlePath2(Path path, double w, double bottomW, double width, double height) {
    path.moveTo(width - w, 0);
    Offset symmetryStartPoint = Offset(width - bottomW, height);
    Offset symmetryEndPoint = Offset(width - w, 0);
    Offset p1 = PathUtils.getSymmetryPoint(Offset(width - cornerRadius, 0), symmetryStartPoint, symmetryEndPoint);
    Offset p2 = PathUtils.getSymmetryPoint(Offset(width, cornerRadius), symmetryStartPoint, symmetryEndPoint);
    path.lineTo(p1.dx, p1.dy);
    path.arcToPoint(p2, radius: Radius.circular(cornerRadius), clockwise: false);
    Offset p3 = PathUtils.getSymmetryPoint(Offset(width, height - cornerRadius), symmetryStartPoint, symmetryEndPoint);
    path.lineTo(p3.dx, p3.dy);
    if (bottomW < cornerRadius) {
      Offset p4 = PathUtils.getIntersection(
        Offset(width - cornerRadius, height - cornerRadius),
        cornerRadius,
        arcStartPoint: Offset(width - cornerRadius, height),
        arcEndPoint: Offset(width, height - cornerRadius),
        lineStart: symmetryStartPoint,
        lineEnd: symmetryEndPoint,
      )!;
      path.arcToPoint(p4, radius: Radius.circular(cornerRadius), clockwise: false);
      path.close();
    } else {
      Offset p4 =
          PathUtils.getSymmetryPoint(Offset(width - cornerRadius, height), symmetryStartPoint, symmetryEndPoint);
      path.arcToPoint(p4, radius: Radius.circular(cornerRadius), clockwise: false);
      Offset p5 = Offset(width - bottomW, height);
      path.lineTo(p5.dx, p5.dy);
      path.close();
    }
  }

  @override
  bool shouldRepaint(_OverleafPainter oldPainter) {
    return false;
  }
}
