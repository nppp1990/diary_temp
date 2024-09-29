import 'dart:math';
import 'dart:ui';

abstract class PathUtils {

  /// 计算椭圆上的点
  /// center: 椭圆中心
  /// a: 椭圆长轴半径
  /// b: 椭圆短轴半径
  /// angle: 角度（弧度）
  static Offset getPointOnEllipse(Offset center, double a, double b, double angle) {
    double x = center.dx + a * cos(angle);
    double y = center.dy + b * sin(angle);
    return Offset(x, y);
  }

  /// bezier: [startX, startY, controlX, controlY, endX, endY]
  static Offset quadraticBezierPoint(Offset start, Offset end, List<double> bezier) {
    double xUnit = (end.dx - start.dx)/ (bezier[4] - bezier[0]);
    double yUnit = (end.dy - start.dy) / (bezier[5] - bezier[1]);
    return Offset(
      start.dx + (bezier[2] - bezier[0]) * xUnit,
      start.dy + (bezier[3] - bezier[1]) * yUnit,
    );
  }

  /// 计算三阶贝塞尔曲线的两个控制点
  /// bezier: [startX, startY, controlX1, controlY1, controlX2, controlY2, endX, endY]
  /// 返回两个控制点
  static List<Offset> cubicBezierPoint(Offset start, Offset end, List<double> bezier) {
    double xUnit = (end.dx - start.dx) / (bezier[6] - bezier[0]);
    double yUnit = (end.dy - start.dy) / (bezier[7] - bezier[1]);
    return [
      Offset(
        start.dx + (bezier[2] - bezier[0]) * xUnit,
        start.dy + (bezier[3] - bezier[1]) * yUnit,
      ),
      Offset(
        start.dx + (bezier[4] - bezier[0]) * xUnit,
        start.dy + (bezier[5] - bezier[1]) * yUnit,
      ),
    ];
  }


  static Offset getSymmetryPoint(Offset point, Offset start, Offset end) {
    // Calculate the slope (m) and intercept (c) of the line
    double m = (end.dy - start.dy) / (end.dx - start.dx);
    double c = start.dy - m * start.dx;

    // Calculate the symmetrical point
    double d = (point.dx + (point.dy - c) * m) / (1 + m * m);
    double x = 2 * d - point.dx;
    double y = 2 * d * m - point.dy + 2 * c;
    return Offset(x, y);
  }

  static bool _inRange(double value, double start, double end) {
    if (start < end) {
      return value >= start && value <= end;
    } else {
      return value >= end && value <= start;
    }
  }

  static bool _inArc(Offset arcStartPoint, Offset arcEndPoint, Offset center, Offset point) {
    double angle1 = atan2(arcStartPoint.dy - center.dy, arcStartPoint.dx - center.dx);
    double angle2 = atan2(arcEndPoint.dy - center.dy, arcEndPoint.dx - center.dx);
    double angle = atan2(point.dy - center.dy, point.dx - center.dx);
    return _inRange(angle, angle1, angle2);
  }

  /// 计算直线和圆弧的第一个交点
  /// circleCenter: 圆心坐标
  /// radius: 圆半径
  /// arcStartPoint: 圆弧起始点
  /// arcEndPoint: 圆弧结束点 顺时针
  /// lineStart: 直线起始点
  /// lineEnd: 直线结束点
  static Offset? getIntersection(
    Offset circleCenter,
    double radius, {
    required Offset arcStartPoint,
    required Offset arcEndPoint,
    required Offset lineStart,
    required Offset lineEnd,
  }) {
    double dx = lineEnd.dx - lineStart.dx;
    double dy = lineEnd.dy - lineStart.dy;
    double A = dx * dx + dy * dy;
    double B = 2 * dx * (lineStart.dx - circleCenter.dx) + 2 * dy * (lineStart.dy - circleCenter.dy);
    num C = pow(lineStart.dx - circleCenter.dx, 2).toDouble() + pow(lineStart.dy - circleCenter.dy, 2) - pow(radius, 2);
    double delta = B * B - 4 * A * C;
    if (delta < 0) {
      return null;
    }

    // lineStart.dx + t1 * dx  lineStart.dx + dx = lineEnd.dx
    // t必须在0-1之间
    double t1 = (-B + sqrt(delta)) / (2 * A);
    double t2 = (-B - sqrt(delta)) / (2 * A);

    // t1在圆上的度数

    // double angle1 = atan2(lineStart.dy - circleCenter.dy, lineStart.dx - circleCenter.dx);
    // double angle2 = atan2(lineEnd.dy - circleCenter.dy, lineEnd.dx - circleCenter.dx);

    if (!_inRange(t1, 0, 1) && !_inRange(t2, 0, 1)) {
      return null;
    }
    Offset? p1;
    if (_inRange(t1, 0, 1)) {
      p1 = Offset(lineStart.dx + t1 * dx, lineStart.dy + t1 * dy);
    }
    if (!_inArc(arcStartPoint, arcEndPoint, circleCenter, p1!)) {
      p1 = null;
    }
    Offset? p2;
    if (_inRange(t2, 0, 1)) {
      p2 = Offset(lineStart.dx + t2 * dx, lineStart.dy + t2 * dy);
    }
    if (!_inArc(arcStartPoint, arcEndPoint, circleCenter, p2!)) {
      p2 = null;
    }

    if (p1 == null && p2 == null) {
      return null;
    }

    if (p1 == null) {
      return p2;
    }
    if (p2 == null) {
      return p1;
    }
    return t1 < t2 ? p1 : p2;
  }

  // 计算点在圆中的角度
  static getAngle(Offset circleCenter, double radius, Offset point) {
    double dx = point.dx - circleCenter.dx;
    double dy = point.dy - circleCenter.dy;
    double angle = atan2(dy, dx);
    return angle;
  }
}
