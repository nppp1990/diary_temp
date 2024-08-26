import 'dart:math';

import 'package:dribbble/clock/clock1/wheel/circle_wheel_scroll_view.dart';
import 'package:flutter/material.dart';

class ClockPage1 extends StatelessWidget {
  const ClockPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        backgroundColor: Color(0XFF232323),
        body: Column(
          children: [
            SizedBox(
              height: 100,
            ),
            // SizedBox(
            //   height: 200,
            //   width: 40,
            //   child: _Sector(),
            // ),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: Clock()),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(child: SizedBox.shrink()),
                ],
              ),
            ),
            // Expanded(child: _Sector()),
            SizedBox(
              height: 200,
            ),
          ],
        ));
  }
}

class Clock extends StatefulWidget {
  final double angle;

  const Clock({super.key, this.angle = pi * 0.75});

  @override
  createState() => ClockState();
}

class ClockState extends State<Clock> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = CircleFixedExtentScrollController()
      ..addListener(() {
        print('offset: ${_scrollController.offset}');
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final angle = widget.angle;
    return LayoutBuilder(builder: (_, constraints) {
      final sizeInfo = _testSize(constraints.maxWidth, constraints.maxHeight, angle);
      double radius = sizeInfo[0];
      double width = sizeInfo[1];
      double height = sizeInfo[2];
      int showNum = 6 * angle ~/ pi;
      final itemExtent = height / showNum / 3;
      print('---showNum: $showNum, itemExtent: $itemExtent, width: $width, height: $height');
      return Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            children: [
              ClockSector(
                radius: radius,
                angle: angle,
              ),
              CircleListScrollView(
                controller: _scrollController,
                physics: const CircleFixedExtentScrollPhysics(),
                axis: Axis.vertical,
                itemExtent: itemExtent,
                // scaleOffset: Offset(width - 40, height / 2 - 20),
                radius: radius,
                onSelectedItemChanged: (int index) => print('Current index: $index'),
                children: List.generate(12, (i) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 30),
                      child: Text(
                        i.toString(),
                        style: TextStyle(color: Colors.blue[100 * ((i % 8) + 1)], fontSize: 40),
                      ),
                    ),
                  );
                }),
              )
            ],
          ),
        ),
      );
    });
  }

  _testSize(double width, double height, double angle) {
    final radiusByWidth = calculateRadiusByWidth(angle, width);
    final radiusByHeight = calculateRadiusByHeight(angle, height);
    double radius = min(radiusByWidth, radiusByHeight);
    double actualWidth = radius * (1 - cos(angle / 2));
    double actualHeight = 2 * radius * sin(angle / 2);
    return [radius, actualWidth, actualHeight];
  }

  calculateRadiusByWidth(double angle, double width) {
    return width / (1 - cos(angle / 2));
  }

  calculateRadiusByHeight(double angle, double height) {
    return height / (2 * sin(angle / 2));
  }
}

class ClockSector extends StatefulWidget {
  final double radius;
  final double angle;

  const ClockSector({super.key, required this.radius, required this.angle});

  @override
  State<StatefulWidget> createState() => _ClockState();
}

class _ClockState extends State<ClockSector> with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 60).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => _Sector(start: _animation.value, radius: widget.radius, angle: widget.angle),
      // builder: (_, __) => const _Sector(start: 10),
    );
  }
}

class _Sector extends StatelessWidget {
  final double radius;
  final double angle;
  final double start;

  const _Sector({required this.angle, required this.start, required this.radius});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, double.infinity),
      painter: _SectorPainter(
        start,
        radius,
        angle,
        backgroundColor: const Color(0XFF333333),
        // scaleColor: const Color(0XFF4A4A4A),
        scaleColor: Colors.yellow,
      ),
    );
  }
}

class _SectorPainter extends CustomPainter {
  final Color backgroundColor;
  final Color scaleColor;
  final double angle;

  // 0~60
  final double start;
  final double radius;
  double _centerX = 0;
  double _centerY = 0;

  _SectorPainter(this.start, this.radius, this.angle, {required this.backgroundColor, required this.scaleColor});

  @override
  void paint(Canvas canvas, Size size) {
    _centerX = size.width - radius;
    _centerY = size.height / 2;
    _drawArc(canvas, size, angle);
    _drawScale(canvas, 20);
  }

  _drawArc(Canvas canvas, Size size, double angle) {
    // final rect = Rect.fromCircle(center: Offset(_centerX, _centerY), radius: _radius);
    final paint = Paint()..colorFilter = ColorFilter.mode(backgroundColor, BlendMode.srcIn);
    // ..color = Colors.white
    // ..style = PaintingStyle.stroke
    // ..strokeWidth = 1;
    // canvas.drawArc(rect, -angle / 2, angle, true, paint);
    canvas.drawCircle(Offset(_centerX, _centerY), radius, paint);
  }

  _drawScale(Canvas canvas, int length, {int scaleCount = 90}) {
    // int size = scaleCount * angle ~/ pi;
    Paint paint = Paint()
      ..color = scaleColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (int i = 0; i < scaleCount; i++) {
      double angle = start * 2 * pi / 60 + i * 2 * pi / scaleCount;
      // double offset = pi / 2 - angle / 2 + i * pi / scaleCount;
      _drawScaleLine(canvas, paint, angle, length);
    }
  }

  _drawScaleLine(Canvas canvas, Paint paint, double angle, int length) {
    double startX = _centerX + radius * sin(angle);
    double startY = _centerY - radius * cos(angle);
    double endX = _centerX + (radius - length) * sin(angle);
    double endY = _centerY - (radius - length) * cos(angle);
    canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
  }

  @override
  bool shouldRepaint(covariant _SectorPainter oldDelegate) => start != oldDelegate.start;
}
