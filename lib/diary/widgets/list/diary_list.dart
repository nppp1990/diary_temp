import 'dart:math';

import 'package:dribbble/diary/common/test_colors.dart';
import 'package:dribbble/diary/common/test_configuration.dart';
import 'package:dribbble/diary/utils/docs.dart';
import 'package:dribbble/diary/utils/time_utils.dart';
import 'package:dribbble/diary/widgets/card.dart';
import 'package:dribbble/diary/widgets/cord.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

enum ItemType {
  event,
  mood,
  diary,
}

class TestListView extends StatelessWidget {
  static const borderRadius = 20.0;
  static const borderWidth = 1.0;

  static const dashStrokeWidth = 2.0;
  static const dashWidth = 5.0;
  static const dashSpace = 5.0;
  static const dashOffset = 3.0;

  static const itemPadding = 16.0;
  static const itemSpace = 20.0;
  static const itemTextSize = 14.0;
  static const itemTextHeight = 1.2;

  static const itemMoodSize = 24.0;

  static const itemBottomHeight = 14.0;

  const TestListView({super.key});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width - 100;
    return SingleChildScrollView(
      child: _TestItem(width: width),
    );
  }
}

class _TestItem extends StatefulWidget {
  final double width;

  const _TestItem({required this.width});

  @override
  State<StatefulWidget> createState() {
    return _TestItemState();
  }
}

class TestInfo {
  final ItemType type;
  final String? note;
  final int? moodIndex;
  final int? checkedCount;
  final int? checkCount;
  double? itemHeight;

  TestInfo({
    required this.type,
    this.note,
    this.moodIndex,
    this.checkedCount,
    this.checkCount,
  });
}

class _TestItemState extends State<_TestItem> {
  final List<TestInfo> data = [
    TestInfo(type: ItemType.event, note: 'Note 1\nxxx\nxxxx\nabc\nxxx'),
    TestInfo(type: ItemType.mood, moodIndex: 0, note: 'Note 1\nxxx\nxxxx\nabc\nxxx'),
    TestInfo(type: ItemType.diary, moodIndex: 0, note: 'Note 1\nxxx\nxxxx\nabc\nxxx'),
    TestInfo(type: ItemType.diary, note: 'Note 1\nxxx\nxxxx\nabc\nxxx', checkCount: 2, checkedCount: 1),
    TestInfo(type: ItemType.diary, moodIndex: 3, note: 'Note 1\nxxx\nxxxx\nabc\nxxx', checkCount: 2, checkedCount: 2),
    TestInfo(type: ItemType.event, note: 'Note 2'),
    TestInfo(type: ItemType.mood, moodIndex: 3),
    TestInfo(type: ItemType.event, note: 'Note 3\n123'),
    TestInfo(type: ItemType.event, note: 'Note 4\n-1'),
    TestInfo(
        type: ItemType.mood,
        moodIndex: 7,
        note:
            '1111222222222222223333334455667777你哈滴答滴答滴答滴答大大大方法尴尬肉嘎嘎哈哈哈7你哈滴答滴答滴答滴答大大大方法尴尬肉嘎嘎哈哈哈7你哈滴答滴答滴答滴答大大大方法尴尬肉嘎嘎哈哈哈7你哈滴答滴答滴答滴答大大大方法尴尬肉嘎嘎哈哈哈'),
    TestInfo(type: ItemType.event, note: 'Note 5'),
    TestInfo(type: ItemType.event, note: 'Note 6'),
    TestInfo(
        type: ItemType.event,
        note: 'Note 7\nxxx\nxxxx\nabc\nxxx1111222222222222223333334455667777你哈滴答滴答滴答滴答大大大方法尴尬肉嘎嘎哈哈哈'),
    TestInfo(type: ItemType.event, note: 'Note 7-------111222222222222223333334455667777'),
  ];

  late List<double> _topPosition;

  @override
  void initState() {
    super.initState();
    _topPosition = List.filled(data.length, 0);
  }

  @override
  Widget build(BuildContext context) {
    for (int i = 0; i < data.length; i++) {
      if (data[i].itemHeight == null) {
        switch (data[i].type) {
          case ItemType.event:
            data[i].itemHeight = _calTaskItemHeight(data[i].note!, widget.width);
            print('1----i: $i, height: ${data[i].itemHeight}');
            break;
          case ItemType.mood:
            data[i].itemHeight = _calMoodItemHeight(data[i].note, widget.width);
            print('2----i: $i, height: ${data[i].itemHeight}');
            break;
          case ItemType.diary:
            data[i].itemHeight = _calDiaryItemHeight(data[i].note!, widget.width, data[i].moodIndex);
            print('3----i: $i, height: ${data[i].itemHeight}');
            break;
        }
      }
    }
    if (_topPosition.last == 0 && _topPosition.length > 1) {
      for (int i = 1; i < data.length; i++) {
        _topPosition[i] = _topPosition[i - 1] + data[i - 1].itemHeight! + TestListView.itemSpace;
      }
    }
    return SizedBox(
      width: widget.width + 20,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Stack(children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const SizedBox(height: 50),
              for (int i = 0; i < data.length; i++) ...[
                _buildItem(i),
                const SizedBox(height: TestListView.itemSpace),
              ]
            ],
          ),
          for (int i = 1; i < _topPosition.length; i++) ..._getCord(i),
        ]),
      ),
    );
  }

  Widget _buildItem(int index) {
    final item = data[index];
    switch (item.type) {
      case ItemType.event:
        return EventItem(
          width: widget.width,
          height: item.itemHeight,
          note: item.note!,
          dateTime: DateTime.now(),
          angle: _getAngle(index),
        );
      case ItemType.mood:
        return MoodItem(
          width: widget.width,
          height: item.itemHeight,
          note: item.note,
          dateTime: DateTime.now(),
          moodIndex: item.moodIndex!,
          angle: _getAngle(index),
        );
      case ItemType.diary:
        return DiaryItem(
          width: widget.width,
          height: item.itemHeight,
          note: item.note!,
          dateTime: DateTime.now(),
          moodIndex: item.moodIndex,
          checkCount: item.checkCount,
          checkedCount: item.checkedCount,
          angle: _getAngle(index),
        );
    }
  }

  List<Widget> _getCord(int index) {
    final double left;
    final double right;
    final double width1;
    final double width2;
    final double height1;
    final double height2;
    final double top1;
    final double top2;

    if (index % 3 == 1) {
      left = 60;
      right = 80;
      width1 = 6;
      width2 = 10;
      height1 = 22 + 16;
      height2 = 26 + 16;
      top1 = _topPosition[index] - 30;
      top2 = _topPosition[index] - 32;
    } else if (index % 3 == 2) {
      left = 15;
      right = 30;
      width1 = 10;
      width2 = 6;
      height1 = 42;
      height2 = 38;
      top1 = _topPosition[index] - 32;
      top2 = _topPosition[index] - 30;
    } else {
      left = 80;
      right = 35;
      width1 = 30;
      width2 = 10;
      height1 = 40;
      height2 = 38;
      top1 = _topPosition[index] - 30;
      top2 = _topPosition[index] - 30;
    }

    return [
      Positioned(
        left: left,
        top: top1,
        child: SizedBox(
          height: height1,
          width: width1,
          child: const CordLock(
            lockRadius: 4,
            lineWidthRatio: 0.3,
          ),
        ),
      ),
      Positioned(
        right: right,
        top: top2,
        child: SizedBox(
          height: height2,
          width: width2,
          child: const CordLock(
            lockRadius: 4,
            lineWidthRatio: 0.3,
          ),
        ),
      ),
    ];
  }

  double _calTaskItemHeight(String note, double width) {
    var calculateTextHeight = DocUtils.calculateTextHeight(
      text: note,
      style: DefaultTextStyle.of(context)
          .style
          .copyWith(fontSize: TestListView.itemTextSize, height: TestListView.itemTextHeight),
      maxWidth: width - 2 * TestListView.itemPadding,
      maxLine: 3,
    );
    // border + padding + text + padding + time
    return 2 * TestListView.borderWidth +
        2 * TestListView.itemPadding +
        calculateTextHeight +
        8 +
        TestListView.itemBottomHeight;
  }

  double _calDiaryItemHeight(String note, double width, int? moodIndex) {
    double calculateTextHeight = DocUtils.calculateTextHeight(
      text: note,
      style: DefaultTextStyle.of(context)
          .style
          .copyWith(fontSize: TestListView.itemTextSize, height: TestListView.itemTextHeight),
      maxWidth: width - 2 * TestListView.itemPadding,
      maxLine: 3,
    );
    double moodHeight = moodIndex != null ? TestListView.itemMoodSize + 8 : 0;
    // border + padding + text + padding + time
    return 2 * TestListView.borderWidth +
        2 * TestListView.itemPadding +
        moodHeight +
        calculateTextHeight +
        8 +
        TestListView.itemBottomHeight;
  }

  double _calMoodItemHeight(String? note, double width) {
    double calculateTextHeight;
    if (note != null) {
      calculateTextHeight = DocUtils.calculateTextHeight(
        text: note,
        style: DefaultTextStyle.of(context)
            .style
            .copyWith(fontSize: TestListView.itemTextSize, height: TestListView.itemTextHeight),
        maxWidth: width - 2 * TestListView.itemPadding,
        maxLine: 3,
      );
      calculateTextHeight += 8;
    } else {
      calculateTextHeight = 0;
    }
    // border + padding + mood + padding + text + padding + time
    return 2 * TestListView.borderWidth +
        2 * TestListView.itemPadding +
        calculateTextHeight +
        TestListView.itemBottomHeight +
        TestListView.itemMoodSize +
        8;
  }

  double _getAngle(int index) {
    if (index % 3 == 0) {
      return -1 / 180 * pi;
    }
    if (index % 3 == 1) {
      return 1 / 180 * pi;
    }
    return 0;
  }
}

class DiaryItem extends StatelessWidget {
  final double width;
  final double? height;
  final double angle;
  final String note;
  final DateTime dateTime;
  final int? moodIndex;
  final int? checkCount;
  final int? checkedCount;

  const DiaryItem({
    super.key,
    required this.width,
    this.height,
    required this.angle,
    required this.note,
    required this.dateTime,
    required this.moodIndex,
    required this.checkCount,
    required this.checkedCount,
  });

  @override
  Widget build(BuildContext context) {
    return ListItem(
        width: width,
        height: height,
        angle: angle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (moodIndex != null) ...[
              SvgPicture.asset(
                TestConfiguration.moodImages[moodIndex!],
                width: TestListView.itemMoodSize,
                height: TestListView.itemMoodSize,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              note,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: TestListView.itemTextSize, height: TestListView.itemTextHeight),
            ),
            const SizedBox(height: 8),
            _BottomTimeLayout(
                itemType: ItemType.diary, dateTime: dateTime, checkCount: checkCount, checkedCount: checkedCount),
          ],
        ));
  }
}

class MoodItem extends StatelessWidget {
  final double width;
  final double? height;
  final double angle;
  final DateTime dateTime;
  final int moodIndex;
  final String? note;

  const MoodItem({
    super.key,
    required this.width,
    this.height,
    required this.angle,
    required this.dateTime,
    required this.moodIndex,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    return ListItem(
        width: width,
        height: height,
        angle: angle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              TestConfiguration.moodImages[moodIndex],
              width: 24,
              height: 24,
            ),
            if (note != null) ...[
              const SizedBox(height: 8),
              Text(
                note!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: TestListView.itemTextSize, height: TestListView.itemTextHeight),
              ),
            ],
            const SizedBox(height: 8),
            _BottomTimeLayout(itemType: ItemType.mood, dateTime: dateTime),
          ],
        ));
  }
}

class EventItem extends StatelessWidget {
  final double width;
  final double? height;
  final String note;
  final DateTime dateTime;
  final int maxLines;
  final double angle;

  const EventItem({
    super.key,
    required this.width,
    this.height,
    required this.note,
    required this.dateTime,
    this.maxLines = 3,
    this.angle = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ListItem(
      width: width,
      height: height,
      angle: angle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            note,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: TestListView.itemTextSize, height: TestListView.itemTextHeight),
          ),
          const SizedBox(height: 8),
          _BottomTimeLayout(itemType: ItemType.event, dateTime: dateTime),
        ],
      ),
    );
  }
}

class _BottomTimeLayout extends StatelessWidget {
  final ItemType itemType;
  final DateTime dateTime;
  final int? checkCount;
  final int? checkedCount;

  const _BottomTimeLayout({
    required this.itemType,
    required this.dateTime,
    this.checkCount,
    this.checkedCount,
  });

  @override
  Widget build(BuildContext context) {
    Widget buildTypeIcon(ItemType type) {
      switch (type) {
        case ItemType.mood:
          return const Icon(
            Icons.mood_outlined,
            size: 13,
            color: TestColors.grey3,
          );
        case ItemType.event:
          return const Icon(
            Icons.event_available_outlined,
            size: 13,
            color: TestColors.grey3,
          );
        case ItemType.diary:
          return const Icon(
            Icons.event_note_outlined,
            size: 13,
            color: TestColors.grey3,
          );
      }
    }

    return SizedBox(
      height: TestListView.itemBottomHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            TimeUtils.getTimeStr(dateTime.toTimeOfDay()),
            style: const TextStyle(fontSize: 12, color: TestColors.grey3, height: 1.2),
          ),
          const SizedBox(width: 8),
          buildTypeIcon(itemType),
          if (itemType == ItemType.diary && checkCount != null) ...[
            const SizedBox(width: 8),
            const Icon(
              Icons.check_box_rounded,
              size: 13,
              color: TestColors.grey3,
            ),
            Text(
              '$checkedCount/$checkCount',
              style: const TextStyle(fontSize: 12, color: TestColors.grey3, height: 1.2),
            ),
          ],
        ],
      ),
    );
  }
}

class ListItem extends StatelessWidget {
  final double width;
  final double? height;
  final double angle;
  final Widget child;

  const ListItem({
    super.key,
    required this.width,
    this.height,
    required this.angle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: DashOffsetCard(
        offset: const Offset(TestListView.dashOffset, TestListView.dashOffset),
        strokeWidth: TestListView.dashStrokeWidth,
        dashWidth: TestListView.dashWidth,
        dashSpace: TestListView.dashSpace,
        borderRadius: TestListView.borderRadius,
        cardWidth: width,
        cardHeight: height,
        backgroundColor: TestColors.third.withOpacity(0.4),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(TestListView.borderRadius),
          child: InkWell(
            borderRadius: BorderRadius.circular(TestListView.borderRadius),
            onTap: () {
              print('---onTap');
            },
            onLongPress: () {
              print('---onLongPress');
            },
            child: Container(
              width: width,
              decoration: BoxDecoration(
                // color: Colors.white,
                border: Border.all(color: TestColors.black1, width: TestListView.borderWidth),
                borderRadius: BorderRadius.circular(TestListView.borderRadius),
              ),
              child: Padding(
                padding: const EdgeInsets.all(TestListView.itemPadding),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
