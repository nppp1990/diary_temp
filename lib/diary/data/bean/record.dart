import 'package:dribbble/diary/data/bean/folder.dart';
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
  final int? folderId;
  final List<int> tagIds;
  final RecordType type;
  final DateTime time;
  final String? content;
  String? diaryPlainText;
  int? checkedCount;
  int? checkCount;

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
    this.folderId,
    this.tagIds = const [],
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
      RecordManager.recordFolderId: folderId,
      RecordManager.recordTagIds: tagIds.join(','),
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
      folderId: map[RecordManager.recordFolderId],
      // todo
      // tagIds: (map[RecordManager.recordTagIds] as String).split(',').map(int.parse).toList(),
      tagIds: [],
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
