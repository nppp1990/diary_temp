import 'package:dribbble/diary/data/sqlite_helper.dart';
import 'package:dribbble/diary/utils/color.dart';
import 'package:dribbble/diary/utils/time_utils.dart';
import 'package:flutter/material.dart';

enum RecordType {
  diary,
  mood,
  event,
}

// todo for folder、tag、weather、location
class DiaryRecord {
  final int? id;
  final RecordType type;
  final DateTime time;
  final String? content;
  String? diaryPlainText;

  // just for diary and mood
  final int? mood;

  // just for mood
  final bool? moodForAllDay;

  // just for diary
  final Color? backgroundColor;

  // just for diary
  final String? backgroundImage;

  DiaryRecord({
    this.id,
    required this.type,
    required this.time,
    this.content,
    this.mood,
    this.moodForAllDay,
    this.backgroundColor,
    this.backgroundImage,
  });

  Map<String, dynamic> toMap() {
    return {
      RecordManager.recordId: id,
      RecordManager.recordType: type.index,
      RecordManager.recordTime: TimeUtils.getDbTime(time),
      RecordManager.recordContent: content,
      RecordManager.recordMood: mood,
      RecordManager.recordMoodForAllDay: moodForAllDay == null ? null : (moodForAllDay! ? 1 : 0),
      RecordManager.recordBackgroundColor: ColorUtils.colorToHex(backgroundColor),
      RecordManager.recordBackgroundImage: backgroundImage,
    };
  }

  factory DiaryRecord.fromMap(Map<String, dynamic> map) {
    return DiaryRecord(
      id: map[RecordManager.recordId],
      type: RecordType.values[map[RecordManager.recordType]],
      time: TimeUtils.parseDbTime(map[RecordManager.recordTime])!,
      content: map[RecordManager.recordContent],
      mood: map[RecordManager.recordMood],
      moodForAllDay:
          map[RecordManager.recordMoodForAllDay] == null ? null : map[RecordManager.recordMoodForAllDay] == 1,
      backgroundColor: ColorUtils.hexToColor(map[RecordManager.recordBackgroundColor]),
      backgroundImage: map[RecordManager.recordBackgroundImage],
    );
  }
}
