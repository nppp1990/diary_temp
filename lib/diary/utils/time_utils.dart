import 'package:flutter/material.dart';

class DateKey implements Comparable<DateKey> {
  final int year;
  final int month;
  final int day;

  DateKey({
    required this.year,
    required this.month,
    required this.day,
  });

  factory DateKey.fromDateTime(DateTime dateTime) {
    return DateKey(year: dateTime.year, month: dateTime.month, day: dateTime.day);
  }

  DateTime toDateTime() {
    return DateTime(year, month, day);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is DateKey) {
      return year == other.year && month == other.month && day == other.day;
    }
    return false;
  }

  @override
  int get hashCode => year.hashCode ^ month.hashCode ^ day.hashCode;

  @override
  int compareTo(DateKey other) {
    if (year != other.year) {
      return year - other.year;
    }
    if (month != other.month) {
      return month - other.month;
    }
    return day - other.day;
  }
}

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

  String toDateString() {
    return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }
}
