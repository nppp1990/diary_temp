import 'package:flutter/material.dart';

abstract class TimeUtils {
  /// 获取时间字符串 12:00 am
  static String getTimeStr(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute;
    final period = time.period;
    return '${hour == 0 ? 12 : hour}:${minute.toString().padLeft(2, '0')} ${period == DayPeriod.am ? 'am' : 'pm'}';
  }
}

extension DateTimeExtension on DateTime {
  TimeOfDay toTimeOfDay() {
    return TimeOfDay(hour: hour, minute: minute);
  }
}
