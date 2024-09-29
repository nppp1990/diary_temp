import 'package:dribbble/diary/widgets/turn/turn_page_view.dart';
import 'package:flutter/material.dart';

class ColiContainer extends StatelessWidget {
  final double coliPaddingLeft;
  final double height;

  const ColiContainer({super.key, required this.coliPaddingLeft, required this.height});

  @override
  Widget build(BuildContext context) {
    double coliWidth = coliPaddingLeft * 386 / 148;
    double coliHeight = coliWidth * 179 / 386;
    int coliCount = (height - coliHeight * 0.5) ~/ (coliHeight * 1.5);
    final controller = TurnPageController(duration: const Duration(seconds: 1), cornerRadius: 10);

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(left: coliPaddingLeft),
            child: TurnPageView.builder(
              controller: controller,
              itemCount: 10,
              itemBuilder: (context, index) => _Page(index: index, height: height, borderRadius: 10),
              overleafColorBuilder: (index) => Colors.grey,
              animationTransitionPoint: 0.35,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(coliCount, (index) {
                return Padding(
                  padding:
                      EdgeInsets.only(top: coliHeight * 0.5, bottom: index == coliCount - 1 ? coliHeight * 0.5 : 0),
                  child: Coil(
                    coilColor: Colors.black,
                    width: coliWidth,
                  ),
                );
              }),
            ),
          )
        ],
      ),
    );
  }
}

class _Page extends StatelessWidget {
  final int index;
  final double height;
  final double borderRadius;

  static const List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.yellow,
    Colors.pink,
    Colors.teal,
    Colors.cyan,
    Colors.lime,
  ];

  const _Page({required this.index, required this.height, required this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Page $index',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                width: double.infinity,
                height: 350,
                color: Colors.yellow,
              ),
              const SizedBox(height: 10),
              const Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla nec purus feugiat, vestibulum ligula sit amet, ultrices nunc. Nullam nec nunc nec nunc ultricies ultricies. Nullam nec nunc nec nunc ultricies ultricies.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Coil extends StatelessWidget {
  final Color coilColor;
  final double width;

  const Coil({
    super.key,
    this.coilColor = Colors.black,
    this.width = 50,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CoilPainter(coilColor: coilColor),
      size: Size(width, width * 179 / 386),
    );
  }
}

// 笔记本线圈 http://wx.karlew.com/canvas/bezier/
class _CoilPainter extends CustomPainter {
  final Color coilColor;

  _CoilPainter({this.coilColor = Colors.black});

  _getPoints(Offset p1, Offset p4, double dx1, double dy1, double dx2, double dy2, double dx3, double dy3, double dx4,
      double dy4) {
    double widthUnit = (p4.dx - p1.dx) / (dx4 - dx1);
    double heightUnit = (p4.dy - p1.dy) / (dy4 - dy1);
    Offset p2 = p1 + Offset((dx2 - dx1) * widthUnit, (dy2 - dy1) * heightUnit);
    Offset p3 = p1 + Offset((dx3 - dx1) * widthUnit, (dy3 - dy1) * heightUnit);
    return [p2, p3];
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 三阶贝塞尔曲线画线圈
    final Paint paint = Paint()
      ..color = coilColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // ctx.moveTo(311, 285);
    // ctx.bezierCurveTo(148, 261, 287, 182, 429, 237);

    // 148 [238, 95] 42 totalY= 95 + 42 + 42= 179
    Offset p1 = Offset(size.width * 148 / 386, size.height * 138 / 179); //
    Offset p4 = Offset(size.width, size.height * 42 / 179); //
    var points = _getPoints(p1, p4, 311, 285, 148, 261, 287, 182, 429, 237);
    Offset p2 = points[0];
    Offset p3 = points[1];
    final Path path = Path();
    path.moveTo(p1.dx, p1.dy);
    path.cubicTo(p2.dx, p2.dy, p3.dx, p3.dy, p4.dx, p4.dy);
    double translateY = size.height * 42 / 179;
    p1 = p1 + Offset(0, translateY);
    p2 = p2 + Offset(0, translateY);
    p3 = p3 + Offset(0, translateY);
    p4 = p4 + Offset(0, translateY);
    path.moveTo(p1.dx, p1.dy);
    path.cubicTo(p2.dx, p2.dy, p3.dx, p3.dy, p4.dx, p4.dy);
    canvas.drawPath(path, paint);

    Paint linePaint = Paint()
      ..color = coilColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    // canvas.drawLine(Offset(p1.dx, 0), Offset(p1.dx, size.height), linePaint);
    // size画矩形
    // canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), linePaint);

    Paint holoPaint = Paint()
      ..color = coilColor
      ..style = PaintingStyle.fill;
    Offset centerPaint = p4 - Offset(0, translateY / 2);
    double radius = translateY / 2 * 1.6;
    canvas.drawCircle(centerPaint, radius, holoPaint);

    // 贝塞尔曲线的点画出来
    // final Paint pointPaint = Paint()
    //   ..color = Colors.red
    //   ..style = PaintingStyle.fill;
    // canvas.drawCircle(p1, 3, pointPaint);
    // canvas.drawCircle(p2, 3, pointPaint);
    // canvas.drawCircle(p3, 3, pointPaint);
    // canvas.drawCircle(p4, 3, pointPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
