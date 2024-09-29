import 'package:flutter/material.dart';

enum RecordType {
  diary,
  mood,
  task,
}

// todo for folder、tag、weather、location
class Record {
  final int? id;
  final RecordType type;
  final DateTime time;
  final String? content;

  // just for diary and mood
  final int? mood;

  // just for mood
  final bool? moodForAllDay;

  // just for diary
  final Color? backgroundColor;

  // just for diary
  final String? backgroundImage;

  Record({
    this.id,
    required this.type,
    required this.time,
    this.content,
    this.mood,
    this.moodForAllDay,
    this.backgroundColor,
    this.backgroundImage,
  });
}
