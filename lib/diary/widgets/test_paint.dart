import 'dart:math';

import 'package:dribbble/diary/utils/pathUtils.dart';
import 'package:flutter/material.dart';

class TestPaintPage extends StatelessWidget {
  const TestPaintPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Paint'),
      ),
      body: Column(children: [
        SizedBox(
            height: 300,
            child: PageView.builder(
              itemBuilder: (context, index) => _Page(
                index: index,
              ),
              itemCount: 20,
            )),
        Container(
          width: 300,
          height: 300,
          color: Colors.yellow,
          child: CustomPaint(
            painter: _TestPainter(),
          ),
        ),
      ]),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    print('-----build index: $index');
    return Container(
      width: 300,
      height: 300,
      color: Colors.yellow,
      child: Center(
        child: Text(
          index.toString(),
          style: const TextStyle(fontSize: 50),
        ),
      ),
    );
  }
}

class _TestPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double w = size.width;
    double h = size.height;

    double x = w / 3;
    double y = h * 0.7;
    double radius = w / 7;

    Offset p1 = Offset(w - x, 0);
    Offset p2 = Offset(w - radius, 0);
    Offset p3 = Offset(w, y);
    Path path1 = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..arcTo(Rect.fromCircle(center: Offset(w - radius, radius), radius: radius), -pi / 2, pi / 2, false)
      ..lineTo(p3.dx, p3.dy)
      ..close();
    // ..moveTo(w - x, 0)
    // ..lineTo(w - radius, 0)
    // ..arcTo(Rect.fromCircle(center: Offset(w - radius, radius), radius: radius), -pi / 2, pi / 2, false)
    // ..lineTo(w, y)
    // ..close();
    canvas.drawPath(path1, paint);

    Offset symmetryStartPoint = Offset(w - x, 0);
    Offset symmetryEndPoint = Offset(w, y);

    Offset q1 = PathUtils.getSymmetryPoint(p1, symmetryStartPoint, symmetryEndPoint);
    Offset q2 = PathUtils.getSymmetryPoint(p2, symmetryStartPoint, symmetryEndPoint);
    Offset q3 = PathUtils.getSymmetryPoint(p3, symmetryStartPoint, symmetryEndPoint);
    // Offset q4 = PathUtils.getSymmetryPoint(p4, symmetryStartPoint, symmetryEndPoint);
    Offset arcEnd = PathUtils.getSymmetryPoint(Offset(w, radius), symmetryStartPoint, symmetryEndPoint);

    Path path2 = Path()
      ..moveTo(q1.dx, q1.dy)
      ..lineTo(q2.dx, q2.dy);
    path2.arcToPoint(arcEnd, radius: Radius.circular(radius), clockwise: false);
    // PathUtils.addArc(path2, q2, arcEnd, radius, pi / 2, isClockwise: false);
    path2.lineTo(q3.dx, q3.dy);
    path2.close();

    Paint paint2 = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path2, paint2);

    //   ..lineTo(w - radius, 0)
    //   ..arcTo(Rect.fromCircle(center: Offset(w - radius, radius), radius: radius), -pi / 2, pi / 2, false)
    //   ..lineTo(w, y)
    //   ..close();

    Paint pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    // Offset p1 = Offset(w, 0);
    // Offset p2 = PathUtils.getSymmetryPoint(p1, Offset(w - x, 0), Offset(w, y));
    // canvas.drawCircle(p22, 5, pointPaint);
    // canvas.drawCircle(p2, 5, pointPaint);
    // canvas.drawCircle(p3, 5, pointPaint);
    // canvas.drawCircle(p33, 5, pointPaint);
    // canvas.drawCircle(p4, 5, pointPaint);
    // canvas.drawCircle(p44, 5, pointPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
