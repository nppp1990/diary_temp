import 'dart:math';

import 'package:dribbble/diary/widgets/dash.dart';
import 'package:flutter/material.dart';

class OffsetCard extends StatelessWidget {
  final Widget child;
  final double? cardHeight;
  final BoxDecoration decoration;
  final Offset offset;

  const OffsetCard({
    super.key,
    required this.decoration,
    required this.offset,
    this.cardHeight,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (cardHeight == null) {
      return IntrinsicHeight(
        child: Stack(
          children: [
            Transform.translate(
              offset: offset,
              child: Container(decoration: decoration),
            ),
            child,
          ],
        ),
      );
    } else {
      return Stack(
        children: [
          Transform.translate(
            offset: offset,
            child: Container(height: cardHeight, decoration: decoration),
          ),
          child,
        ],
      );
    }
  }
}

class DashOffsetCard extends StatelessWidget {
  final Widget child;
  final Offset offset;
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;
  final double? cardWidth;
  final Color? backgroundColor;

  const DashOffsetCard({
    super.key,
    this.cardWidth,
    required this.offset,
    this.color = Colors.black,
    this.strokeWidth = 2.0,
    this.dashWidth = 5.0,
    this.dashSpace = 3.0,
    this.borderRadius = 12.0,
    this.backgroundColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Stack(
        children: [
          Transform.translate(
            offset: offset,
            child: DashedBorder(
              borderRadius: borderRadius,
              color: color,
              strokeWidth: strokeWidth,
              dashWidth: dashWidth,
              dashSpace: dashSpace,
              backgroundColor: backgroundColor,
              child: cardWidth == null
                  ? Container(
                      decoration: BoxDecoration(
                      // color: backgroundColor,
                      borderRadius: BorderRadius.circular(borderRadius),
                    ))
                  : Container(
                      width: cardWidth,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        // color: backgroundColor,
                        borderRadius: BorderRadius.circular(borderRadius),
                      )),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class RotateCard extends StatelessWidget {
  final double? cardHeight;
  final BoxDecoration decoration;
  final double angle;
  final Widget child;

  const RotateCard({
    super.key,
    this.cardHeight,
    required this.decoration,
    this.angle = -2 / 180 * pi,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (cardHeight == null) {
      return IntrinsicHeight(
        child: Stack(
          children: [
            Transform.rotate(
              angle: angle,
              child: Container(decoration: decoration),
            ),
            child,
          ],
        ),
      );
    } else {
      return Stack(
        children: [
          Transform.rotate(
            angle: angle,
            child: Container(decoration: decoration, height: cardHeight),
          ),
          child,
        ],
      );
    }
  }
}
