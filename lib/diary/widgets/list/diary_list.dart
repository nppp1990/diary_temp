import 'dart:math';
import 'package:dribbble/diary/common/test_colors.dart';
import 'package:dribbble/diary/utils/docs.dart';
import 'package:dribbble/diary/widgets/card.dart';
import 'package:dribbble/diary/widgets/cord.dart';
import 'package:flutter/material.dart';

class TestListView extends StatelessWidget {
  const TestListView({super.key});

  _onHeightChanged(double height, int index) {
    print('---height: $height');
  }

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
  final String note;
  double? textHeight;

  TestInfo({required this.note});
}

class _TestItemState extends State<_TestItem> {
  final List<TestInfo> data = [
    TestInfo(note: 'Note 1\nxxx\nxxxx\nabc\nxxx'),
    TestInfo(note: 'Note 2'),
    TestInfo(note: 'Note 3\n123'),
    TestInfo(note: 'Note 4\n-1'),
    TestInfo(note: 'Note 5'),
    TestInfo(note: 'Note 6'),
    TestInfo(note: 'Note 7\nxxx\nxxxx\nabc\nxxx1111222222222222223333334455667777'),
    TestInfo(note: 'Note 7-------111222222222222223333334455667777'),
  ];

  late List<double> _topPosition;

  @override
  void initState() {
    super.initState();
    _topPosition = List.filled(data.length, 0);
    _topPosition[0] = 50;
  }

  _onHeightChanged(double height, int index) {
    print('---height: $height, index: $index');
  }

  @override
  Widget build(BuildContext context) {
    for (int i = 0; i < data.length; i++) {
      if (data[i].textHeight == null) {
        data[i].textHeight = _calItemHeight(data[i].note, widget.width);
      }
    }
    if (_topPosition.last == 0 && _topPosition.length > 1) {
      for (int i = 1; i < data.length; i++) {
        _topPosition[i] = _topPosition[i - 1] + data[i - 1].textHeight! + 20;
      }
    }
    return Stack(children: [
      SizedBox(
        width: widget.width + 10,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            for (int i = 0; i < data.length; i++) ...[
              TaskItem(
                width: widget.width,
                note: data[i].note,
                textHeight: data[i].textHeight,
                dateTime: DateTime.now(),
                angle: _getAngle(i),
              ),
              const SizedBox(height: 20),
            ]
          ],
        ),
      ),
      for (int i = 1; i < _topPosition.length; i++) ..._getCord(i),
    ]);
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

  double _calItemHeight(String note, double width) {
    var calculateTextHeight = DocUtils.calculateTextHeight(
      text: note,
      style: DefaultTextStyle.of(context).style.copyWith(fontSize: 14, height: 1.2),
      maxWidth: width - 32,
      maxLine: 3,
    );
    // border + padding + text + padding + time
    return 2 + 32 + calculateTextHeight + 8 + 12 * 1.2;
  }

  double _getAngle(int index) {
    if (index % 3 == 0) {
      return -1 / 180 * pi;
    }
    if (index % 3 == 1) {
      return 1 / 180 * pi;
    }
    return 0;
    // if (index % 2 == 0) {
    //   return 0;
    // }
    // if (index % 4 == 1) {
    //   return -1 / 180 * pi;
    // }
    // return 1 / 180 * pi;
  }
}

// class MoodItem extends StatelessWidget {
//   final int moodIndex;
//   final String? note;
//   final double? textHeight;
// }

class TaskItem extends StatelessWidget {
  final double width;
  final String note;
  final double? textHeight;
  final DateTime dateTime;
  final int maxLines;
  final double angle;
  final ValueChanged<double>? heightGetter;

  const TaskItem({
    super.key,
    required this.width,
    required this.note,
    required this.textHeight,
    required this.dateTime,
    this.maxLines = 3,
    this.angle = 0,
    this.heightGetter,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: DashOffsetCard(
        offset: const Offset(3, 3),
        strokeWidth: 2,
        dashWidth: 5,
        dashSpace: 5,
        borderRadius: 20,
        cardWidth: width,
        backgroundColor: TestColors.third.withOpacity(0.4),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            splashColor: Colors.transparent,
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
                border: Border.all(color: TestColors.black1, width: 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note ?? '',
                      maxLines: maxLines,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, height: 1.2),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dateTime.toString(),
                      style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
