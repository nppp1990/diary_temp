import 'package:flutter/material.dart';

abstract class TimeUtils {
  /// 获取时间字符串 12:00 am
  static String getTimeStr(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute;
    final period = time.period;
    return '${hour == 0 ? 12 : hour}:${minute.toString().padLeft(2, '0')} ${period == DayPeriod.am ? 'am' : 'pm'}';
  }

  static int? getDbTime(DateTime? dateTime) {
    if (dateTime == null) {
      return null;
    }
    return dateTime.millisecondsSinceEpoch ~/ 1000;
  }

  static DateTime? parseDbTime(int? time) {
    if (time == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(time * 1000);
  }
}

extension DateTimeExtension on DateTime {
  TimeOfDay toTimeOfDay() {
    return TimeOfDay(hour: hour, minute: minute);
  }
}
