import 'dart:math';

import 'package:dribbble/diary/common/test_colors.dart';
import 'package:dribbble/diary/common/test_configuration.dart';
import 'package:dribbble/diary/data/bean/record.dart';
import 'package:dribbble/diary/data/sqlite_helper.dart';
import 'package:dribbble/diary/utils/docs.dart';
import 'package:dribbble/diary/utils/time_utils.dart';
import 'package:dribbble/diary/widgets/card.dart';
import 'package:dribbble/diary/widgets/cord.dart';
import 'package:dribbble/diary/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BaseListView extends StatelessWidget {
  static List<TestInfo> generateTestListData(List<DiaryRecord> records) {
    List<TestInfo> data = [];
    for (var record in records) {
      switch (record.type) {
        case RecordType.event:
          data.add(TestInfo(type: RecordType.event, note: record.content, time: record.time));
          break;
        case RecordType.mood:
          data.add(TestInfo(
            type: RecordType.mood,
            moodIndex: record.mood,
            note: record.content,
            isOneDayMood: record.moodForAllDay,
            time: record.time,
          ));
          break;
        case RecordType.diary:
          data.add(TestInfo(
            type: RecordType.diary,
            moodIndex: record.mood,
            note: record.diaryPlainText,
            time: record.time,
            // todo: checkCount and checkedCount
            checkCount: 1,
            checkedCount: 2,
          ));
          break;
      }
    }
    return data;
  }

  final Widget Function(BuildContext, Map<DateTime, List<DiaryRecord>>) contentBuilder;

  const BaseListView({super.key, required this.contentBuilder});

  @override
  Widget build(BuildContext context) {
    print('----build FutureLoading');
    return FutureLoading<List<DiaryRecord>, Map<DateTime, List<DiaryRecord>>>(
      futureBuilder: ()=> RecordManager().getAllRecord(),
      convert: DocUtils.groupRecordsByDate,
      contentBuilder: (context, recordMap) {
        return contentBuilder(context, recordMap);
      },
    );
  }
}

class TestListView extends StatefulWidget {
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

  static const leftSize = 70.0;
  static const leftPadding = 10.0;

  const TestListView({super.key});

  @override
  State<StatefulWidget> createState() => _TestListViewState();
}

class _TestListViewState extends State<TestListView> {
  @override
  Widget build(BuildContext context) {
    print('----build TestListView');
    var width = MediaQuery.sizeOf(context).width - TestListView.leftSize - TestConfiguration.pagePadding;
    return BaseListView(contentBuilder: (context, recordMap) {
      print('-----build contentBuilder: ${recordMap.length}----');
      return ListView.builder(
        itemCount: recordMap.length,
        itemBuilder: (context, index) {
          List<DiaryRecord> records = recordMap.values.elementAt(index);
          DateTime dateTime = recordMap.keys.elementAt(index);
          print('-----2222----records: ${records.length}');
          return _TestItem(
            width: width,
            dateTime: dateTime,
            records: records,
            data: BaseListView.generateTestListData(records),
            refresh: () {
              setState(() {});
            },
          );
        },
      );
    });
  }
}

class LeftDateItem extends StatelessWidget {
  final DateTime dateTime;
  final int? moodIndex;

  static const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  const LeftDateItem({super.key, required this.dateTime, this.moodIndex});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: TestListView.leftSize,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Text(
            days[dateTime.weekday - 1],
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 2),
          Text(
            '${dateTime.day}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),
          if (moodIndex != null)
            SvgPicture.asset(
              TestConfiguration.moodImages[moodIndex!],
              width: 40,
              height: 40,
            ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _TestItem extends StatefulWidget {
  final Function()? refresh;
  final double width;
  final DateTime dateTime;
  final List<DiaryRecord> records;
  final List<TestInfo> data;

  const _TestItem({
    this.refresh,
    required this.width,
    required this.dateTime,
    required this.records,
    required this.data,
  });

  @override
  State<StatefulWidget> createState() => _TestItemState();
}

class TestInfo {
  final RecordType type;
  final String? note;
  final int? moodIndex;
  final int? checkedCount;
  final int? checkCount;
  final bool? isOneDayMood;
  final DateTime time;
  double? itemHeight;

  TestInfo({
    required this.type,
    this.note,
    this.moodIndex,
    this.checkedCount,
    this.checkCount,
    this.isOneDayMood,
    required this.time,
  });
}

class _TestItemState extends State<_TestItem> {
  late List<double> _topPosition;
  late List<TestInfo> _data;
  late List<DiaryRecord> _records;


  void _initData() {
    _data = widget.data;
    _records = widget.records;
    _topPosition = List.filled(_data.length, 0);
    print('----initData: ${_data.length}');
  }

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void didUpdateWidget(covariant _TestItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('----didUpdateWidget');
    if (oldWidget.data != widget.data || oldWidget.records != widget.records) {
      print('----didUpdateWidget refresh: ${widget.records.length}');
      _initData();
    }
  }

  @override
  Widget build(BuildContext context) {
    for (int i = 0; i < _data.length; i++) {
      if (_data[i].itemHeight == null) {
        switch (_data[i].type) {
          case RecordType.event:
            _data[i].itemHeight = _calTaskItemHeight(_data[i].note!, widget.width);
            // print('1----i: $i, height: ${data[i].itemHeight}');
            break;
          case RecordType.mood:
            _data[i].itemHeight = _calMoodItemHeight(_data[i].note, widget.width);
            // print('2----i: $i, height: ${data[i].itemHeight}');
            break;
          case RecordType.diary:
            _data[i].itemHeight = _calDiaryItemHeight(_data[i].note!, widget.width, _data[i].moodIndex);
            // print('3----i: $i, height: ${data[i].itemHeight}');
            break;
        }
      }
    }
    if (_topPosition.last == 0 && _topPosition.length > 1) {
      for (int i = 1; i < _data.length; i++) {
        _topPosition[i] = _topPosition[i - 1] + _data[i - 1].itemHeight! + TestListView.itemSpace;
      }
    }
    print('----build _TestItem---size: ${_data.length}');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LeftDateItem(dateTime: widget.dateTime, moodIndex: DocUtils.getDayMood(_records)),
        SizedBox(
          width: widget.width,
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Stack(children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < _data.length; i++) ...[
                    _buildItem(i),
                    const SizedBox(height: TestListView.itemSpace),
                  ]
                ],
              ),
              for (int i = 1; i < _topPosition.length; i++) ..._getCord(i),
            ]),
          ),
        )
      ],
    );
  }

  void _onLongPress(int index) async {
    print('long press index: $index');
    var res = await RecordManager().deleteRecord(_records[index].id);
    // todo test
    await Future.delayed(const Duration(milliseconds: 1500));
    if (res > 0) {
      print('delete success');
      // todo
      widget.refresh?.call();
    } else {
      print('delete failed');
    }
  }

  Widget _buildItem(int index) {
    final item = _data[index];
    switch (item.type) {
      case RecordType.event:
        return EventItem(
          width: widget.width,
          height: item.itemHeight,
          note: item.note!,
          dateTime: item.time,
          angle: _getAngle(index),
          onLongPress: () => _onLongPress(index),
        );
      case RecordType.mood:
        return MoodItem(
          width: widget.width,
          height: item.itemHeight,
          note: item.note,
          dateTime: item.time,
          moodIndex: item.moodIndex!,
          angle: _getAngle(index),
          isOneDayMood: item.isOneDayMood,
          onLongPress: () => _onLongPress(index),
        );
      case RecordType.diary:
        return DiaryItem(
          width: widget.width,
          height: item.itemHeight,
          note: item.note!,
          dateTime: item.time,
          moodIndex: item.moodIndex,
          checkCount: item.checkCount,
          checkedCount: item.checkedCount,
          angle: _getAngle(index),
          onLongPress: () => _onLongPress(index),
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
      return 0;
    }
    if (index % 3 == 1) {
      return -1 / 180 * pi;
    }
    return 1 / 180 * pi;
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
  final GestureTapCallback? onTap;
  final GestureLongPressCallback? onLongPress;

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
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return ListItem(
      width: width,
      height: height,
      angle: angle,
      onTap: onTap,
      onLongPress: onLongPress,
      child: DiaryContentItem(
        note: note,
        dateTime: dateTime,
        moodIndex: moodIndex,
        checkCount: 1,
        checkedCount: 2,
      ),
    );
  }
}

class MoodItem extends StatelessWidget {
  final double width;
  final double? height;
  final double angle;
  final DateTime dateTime;
  final int moodIndex;
  final String? note;
  final bool? isOneDayMood;
  final GestureTapCallback? onTap;
  final GestureLongPressCallback? onLongPress;

  const MoodItem({
    super.key,
    required this.width,
    this.height,
    required this.angle,
    required this.dateTime,
    required this.moodIndex,
    this.note,
    this.isOneDayMood,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return ListItem(
        width: width,
        height: height,
        angle: angle,
        onTap: onTap,
        onLongPress: onLongPress,
        child: MoodContentItem(
          moodIndex: moodIndex,
          note: note,
          dateTime: dateTime,
          isOneDayMood: isOneDayMood,
        ));
  }
}

class DiaryContentItem extends StatelessWidget {
  final String note;
  final DateTime dateTime;
  final int? moodIndex;
  final int checkCount;
  final int checkedCount;

  const DiaryContentItem({
    super.key,
    required this.note,
    required this.dateTime,
    required this.moodIndex,
    required this.checkCount,
    required this.checkedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (moodIndex != null) ...[
          MoodTextLayout(moodIndex: moodIndex!),
          const SizedBox(height: 8),
        ],
        Text(
          note,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: TestListView.itemTextSize, height: TestListView.itemTextHeight),
        ),
        const SizedBox(height: 8),
        BottomTimeLayout(
            itemType: RecordType.diary, dateTime: dateTime, checkCount: checkCount, checkedCount: checkedCount),
      ],
    );
  }
}

class EventContentItem extends StatelessWidget {
  final String note;
  final DateTime dateTime;

  const EventContentItem({
    super.key,
    required this.note,
    required this.dateTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          note,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: TestListView.itemTextSize, height: TestListView.itemTextHeight),
        ),
        const SizedBox(height: 8),
        BottomTimeLayout(itemType: RecordType.event, dateTime: dateTime),
      ],
    );
  }
}

class MoodContentItem extends StatelessWidget {
  final int moodIndex;
  final String? note;
  final DateTime dateTime;
  final bool? isOneDayMood;

  const MoodContentItem({
    super.key,
    required this.moodIndex,
    this.note,
    required this.dateTime,
    this.isOneDayMood,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MoodTextLayout(moodIndex: moodIndex),
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
        BottomTimeLayout(
          itemType: RecordType.mood,
          dateTime: dateTime,
          isOneDayMood: isOneDayMood,
        ),
      ],
    );
  }
}

class EventItem extends StatelessWidget {
  final double width;
  final double? height;
  final String note;
  final DateTime dateTime;
  final int maxLines;
  final double angle;
  final GestureTapCallback? onTap;
  final GestureLongPressCallback? onLongPress;

  const EventItem({
    super.key,
    required this.width,
    this.height,
    required this.note,
    required this.dateTime,
    this.maxLines = 3,
    this.angle = 0,
    this.onLongPress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListItem(
      width: width,
      height: height,
      angle: angle,
      onLongPress: onLongPress,
      onTap: onTap,
      child: EventContentItem(note: note, dateTime: dateTime),
    );
  }
}

class MoodTextLayout extends StatelessWidget {
  final int moodIndex;

  const MoodTextLayout({super.key, required this.moodIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SvgPicture.asset(
          TestConfiguration.moodImages[moodIndex],
          width: TestListView.itemMoodSize,
          height: TestListView.itemMoodSize,
        ),
        const SizedBox(width: 6),
        Text(
          TestConfiguration.moodTexts[moodIndex],
          style: TextStyle(
            fontSize: 14,
            color: TestColors.moodColors[moodIndex],
          ),
        ),
      ],
    );
  }
}

class BottomTimeLayout extends StatelessWidget {
  final RecordType itemType;
  final DateTime dateTime;
  final int? checkCount;
  final int? checkedCount;
  final bool? isOneDayMood;

  const BottomTimeLayout({
    super.key,
    required this.itemType,
    required this.dateTime,
    this.checkCount,
    this.checkedCount,
    this.isOneDayMood,
  });

  @override
  Widget build(BuildContext context) {
    Widget buildTypeIcon(RecordType type) {
      switch (type) {
        case RecordType.mood:
          return const Icon(
            Icons.mood_outlined,
            size: 13,
            color: TestColors.grey3,
          );
        case RecordType.event:
          return const Icon(
            Icons.event_available_outlined,
            size: 13,
            color: TestColors.grey3,
          );
        case RecordType.diary:
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
          if (itemType == RecordType.mood && isOneDayMood == true) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: TestColors.grey3, width: 0.5),
              ),
              child: const Text(
                'All Day',
                style: TextStyle(fontSize: 10, color: TestColors.grey3, height: 1),
              ),
            )
          ],
          if (itemType == RecordType.diary && checkCount != null) ...[
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
  final GestureTapCallback? onTap;
  final GestureLongPressCallback? onLongPress;

  const ListItem({
    super.key,
    required this.width,
    this.height,
    required this.angle,
    this.onTap,
    this.onLongPress,
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
            onTap: onTap,
            onLongPress: onLongPress,
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
