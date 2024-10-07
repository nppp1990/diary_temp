import 'package:flutter/material.dart';

abstract class TimeUtils {

  static const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static getWeekdayStr(DateTime date) {
    return days[date.weekday - 1];
  }

  static getDateStr(DateTime date) {
    // 2021-09-01
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

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

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isSameMonth(DateTime other) {
    return year == other.year && month == other.month;
  }
}
