import 'dart:collection';
import 'dart:convert';

import 'package:dribbble/diary/data/bean/record.dart';
import 'package:dribbble/diary/utils/time_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';

abstract class DocUtils {
  static double calculateTextHeight({
    required String text,
    required TextStyle style,
    required double maxWidth,
    int? maxLine,
  }) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLine,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    var computeLineMetrics = textPainter.computeLineMetrics();
    if (computeLineMetrics.isEmpty) {
      return 0;
    }
    // print('-----computeLineMetrics: $computeLineMetrics');
    // print('-----length: ${computeLineMetrics.length}');
    // for (var line in computeLineMetrics) {
    // print('-----line: $line');
    // }
    // get height
    return computeLineMetrics.fold(0, (previousValue, element) => previousValue + element.height);
  }

  static List<LineMetrics> test({
    required String text,
    required TextStyle style,
    required double maxWidth,
  }) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: null,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    return textPainter.computeLineMetrics();
  }

  static parseDocInfoByDelta(Delta delta) {
    String allText = '';
    int checkCount = 0;
    int checkedCount = 0;
    // int textLength = 0;
    // int imageCount = 0;
    for (final op in delta.operations) {
      if (op.isInsert) {
        allText += op.value;
        var attrs = op.attributes;
        if (attrs != null) {
          if (attrs.containsKey(Attribute.unchecked.key)) {
            if (attrs[Attribute.checked.key] == Attribute.checked.value) {
              checkedCount++;
            }
            checkCount++;
          }
        }
      }
    }
    return {
      'allText': allText,
      'checkCount': checkCount,
      'checkedCount': checkedCount,
    };
  }

  static parseDocInfo(String deltaJson) {
    final delta = Delta.fromJson(jsonDecode(deltaJson));
    return parseDocInfoByDelta(delta);
  }

  static String getPlainTextFromJson(String deltaJson) {
    final delta = Delta.fromJson(jsonDecode(deltaJson));
    String allText = '';
    for (final op in delta.operations) {
      if (op.isInsert) {
        allText += op.value;
      }
    }
    return allText;
  }

  static String getPlainTextFromDelta(Delta delta) {
    String allText = '';
    for (final op in delta.operations) {
      if (op.isInsert) {
        allText += op.value;
      }
    }
    return allText;
  }

  static Map<DateTime, List<DiaryRecord>>? groupRecordsByDate(List<DiaryRecord>? records) {
    if (records == null) {
      return {};
    }
    Map<DateTime, List<DiaryRecord>> map = {};
    for (var record in records) {
      DateTime date = DateTime(record.time.year, record.time.month, record.time.day);
      if (record.type == RecordType.diary && record.diaryPlainText == null) {
        var info = parseDocInfo(record.content!);
        record.diaryPlainText = info['allText'];
        record.checkCount = info['checkCount'];
        record.checkedCount = info['checkedCount'];
      }
      if (map.containsKey(date)) {
        map[date]!.add(record);
      } else {
        map[date] = [record];
      }
    }
    // List<DiaryRecord> 按照time从大到小排序
    map.forEach((key, value) {
      value.sort((a, b) => b.time.compareTo(a.time));
    });
    // map 按照time从大到小排序
    return SplayTreeMap<DateTime, List<DiaryRecord>>.from(map, (a, b) => b.compareTo(a));
  }

  static Map<DateKey, List<DiaryRecord>>? groupRecordsByDate2(List<DiaryRecord>? records) {
    if (records == null) {
      return {};
    }
    Map<DateKey, List<DiaryRecord>> map = {};
    for (var record in records) {
      DateKey dateKey = DateKey.fromDateTime(record.time);
      if (record.type == RecordType.diary && record.diaryPlainText == null) {
        var info = parseDocInfo(record.content!);
        record.diaryPlainText = info['allText'];
        record.checkCount = info['checkCount'];
        record.checkedCount = info['checkedCount'];
      }
      if (map.containsKey(dateKey)) {
        map[dateKey]!.add(record);
      } else {
        map[dateKey] = [record];
      }
    }
    // List<DiaryRecord> 按照time从小到大排序
    map.forEach((key, value) {
      value.sort((a, b) => a.time.compareTo(b.time));
    });
    // map 按照time从小到大排序
    return SplayTreeMap<DateKey, List<DiaryRecord>>.from(map, (a, b) => a.compareTo(b));
  }

  static int? getDayMood(List<DiaryRecord> records) {
    int totalMood = 0;
    int count = 0;
    for (var record in records) {
      if (record.moodForAllDay == true) {
        return record.mood!;
      }
      if (record.mood != null) {
        totalMood += record.mood!;
        count++;
      }
    }
    if (count == 0) {
      return null;
    }
    return totalMood ~/ count;
  }
}
