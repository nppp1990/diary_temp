import 'package:dribbble/diary/common/test_colors.dart';
import 'package:flutter/material.dart';

abstract final class TestConfiguration {
  static const double pagePadding = 20;

  static const double editorPadding = 16.0;
  static const double toolBarHeight = 48.0;
  static const double toolBarIconSize = 24.0;
  static const double boxItemSize1 = 36;
  static const double boxItemBorderRadius = 8;
  static const double boxItemPadding = 12;
  static const double dialogPadding = 12.0;
  static const double editHeaderHeight = 48.0;
  static const double editHeaderPadding = 20.0;
  static const double editHeaderItemSize = 36.0;

  static const double templateItemHeight = 110;

  static const double t1 = 24;
  static const double t2 = 20;
  static const double t3 = 16;
  static const double t4 = 14;
  static const double t5 = 12;
  static const double t6 = 10;

  static const toolbarIconStyle = IconThemeData(color: TestColors.black1, size: 28);

  // static const List<int> editToolBarMoodList = [
  //   4, // relaxed
  //   5, // happy
  //   6, // excited
  //   7, // laugh
  //   0, // angry
  //   1, // frustrated
  //   2, // worried
  //   3, // sad
  // ];

  static const List<String> moodImagesForToolbar = [
    'assets/images/emotion_relaxed.svg', // 4
    'assets/images/emotion_happy.svg', // 5
    'assets/images/emotion_excited.svg', // 6
    'assets/images/emotion_laugh.svg', // 7
    'assets/images/emotion_sad.svg', // 3
    'assets/images/emotion_worried.svg', // 2
    'assets/images/emotion_frustrated.svg', // 1
    'assets/images/emotion_angry.svg', // 0
  ];

  static const List<String> moodTextsForToolbar = [
    'Relaxed',
    'Happy',
    'Excited',
    'Laugh',
    'Sad',
    'Worried',
    'Frustrated',
    'Angry',
  ];

  //
  static const List<String> moodImages = [
    'assets/images/emotion_angry.svg',
    'assets/images/emotion_frustrated.svg',
    'assets/images/emotion_worried.svg',
    'assets/images/emotion_sad.svg',
    'assets/images/emotion_relaxed.svg',
    'assets/images/emotion_happy.svg',
    'assets/images/emotion_excited.svg',
    'assets/images/emotion_laugh.svg',
  ];

  static const String moodAddImage = 'assets/icons/ic_mood_add.svg';

  static const List<String> moodTexts = [
    'Angry',
    'Frustrated',
    'Worried',
    'Sad',
    'Relaxed',
    'Happy',
    'Excited',
    'Laugh',
  ];

}
