import 'package:dribbble/diary/common/test_colors.dart';
import 'package:dribbble/diary/common/test_configuration.dart';
import 'package:dribbble/diary/data/bean/record.dart';
import 'package:dribbble/diary/data/sqlite_helper.dart';
import 'package:dribbble/diary/utils/dialog_utils.dart';
import 'package:dribbble/diary/utils/docs.dart';
import 'package:dribbble/diary/utils/time_utils.dart';
import 'package:dribbble/diary/widgets/TriggerInkWell.dart';
import 'package:dribbble/diary/widgets/edit/edit_demo3.dart';
import 'package:dribbble/diary/widgets/emotion/edit_mood.dart';
import 'package:dribbble/diary/widgets/folder/book_page.dart';
import 'package:dribbble/diary/widgets/list/diary_list.dart';
import 'package:dribbble/diary/widgets/router_utils.dart';
import 'package:dribbble/diary/widgets/simple/event_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TestListView3 extends StatelessWidget {
  static const moodSize = 40.0;
  static const itemPadding = 10.0;
  static const verticalLineWidth = 2.0;
  static const cardBorderRadius = 20.0;

  const TestListView3({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseListView(contentBuilder: (context, map) {
      return Padding(
        padding: const EdgeInsets.all(TestConfiguration.pagePadding),
        child: ListView.separated(
          itemBuilder: (context, index) {
            List<DiaryRecord> records = map.values.elementAt(index);
            DateTime dateTime = map.keys.elementAt(index);
            return _TestItem3(
              dateTime: dateTime,
              records: records,
              data: BaseListView.generateTestListData(records),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(height: TestConfiguration.pagePadding);
          },
          itemCount: map.length,
        ),
      );
    });
  }
}

class _TestItem3 extends StatelessWidget {
  final DateTime dateTime;
  final List<DiaryRecord> records;
  final List<TestInfo> data;

  const _TestItem3({required this.dateTime, required this.records, required this.data});

  Widget _buildTopHeader(DateTime dateTime, List<DiaryRecord> records) {
    var dayMood = DocUtils.getDayMood(records);
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: dayMood != null ? TestColors.moodColors[dayMood].withOpacity(0.5) : Colors.transparent,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(TestListView3.cardBorderRadius),
          topRight: Radius.circular(TestListView3.cardBorderRadius),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: TestListView3.itemPadding * 2 + TestListView3.moodSize,
            height: double.infinity,
            child: Center(
                child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: dayMood != null ? TestColors.moodColors[dayMood] : TestColors.black1,
                  width: 3,
                ),
              ),
            )),
          ),
          Text(
            // sat, 2021-08-21
            '${TimeUtils.getWeekdayStr(dateTime)}, ${TimeUtils.getDateStr(dateTime)}',
            style: TextStyle(
              fontSize: 14,
              color: dayMood != null ? TestColors.moodColors[dayMood] : TestColors.black1,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: TestColors.grey1,
            offset: Offset(0, 2),
            blurRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data.length > 1) _buildTopHeader(dateTime, records),
          for (int i = 0; i < data.length; i++)
            DiaryListItem(
              data: data[i],
              isTop: i == 0,
              isBottom: i == data.length - 1,
              isOnlyOne: data.length == 1,
              showMoodText: true,
            ),
        ],
      ),
    );
  }
}

// Theme.of(context).splashColor
class DiaryListItem extends StatefulWidget {
  final TestInfo data;
  final bool isTop;
  final bool isBottom;
  final bool isOnlyOne;
  final int maxLines;
  final Function(BuildContext itemContext, BuildContext triggerContext, Offset? tapPosition)? onMoreTap;
  final bool showMoodText;

  const DiaryListItem({
    super.key,
    required this.data,
    this.isTop = false,
    this.isBottom = false,
    this.isOnlyOne = false,
    this.maxLines = 3,
    this.onMoreTap,
    this.showMoodText = false,
  });

  @override
  State<StatefulWidget> createState() => DiaryListItemState();
}

class DiaryListItemState extends State<DiaryListItem> {
  TestInfo get data => widget.data;

  bool _showSplash = false;
  Offset? _tapPosition;

  void _triggerItemTap({
    required Duration delay,
    required Duration touchDuration,
  }) async {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(const Offset(1, 1));
    Future.delayed(delay, () async {
      if (!mounted) {
        return;
      }
      _showSplash = true;
      WidgetsBinding.instance.handlePointerEvent(PointerDownEvent(
        pointer: 0,
        position: position,
      ));
      await Future.delayed(touchDuration);
      WidgetsBinding.instance.handlePointerEvent(PointerUpEvent(
        pointer: 0,
        position: position,
      ));
    });
  }

  void triggerItemTap({
    Duration delay = const Duration(milliseconds: 1000),
    Duration touchDuration = const Duration(milliseconds: 1000),
  }) {
    _triggerItemTap(delay: delay, touchDuration: touchDuration);
  }

  Widget _buildMood(int? moodIndex, RecordType type) {
    if (moodIndex == null) {
      if (type == RecordType.event) {
        return Container(
          height: TestListView3.moodSize,
          width: TestListView3.moodSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: TestColors.grey1,
              width: 1,
            ),
          ),
        );
      } else {
        return SvgPicture.asset(
          TestConfiguration.moodAddImage,
          width: TestListView3.moodSize,
          height: TestListView3.moodSize,
          colorFilter: const ColorFilter.mode(TestColors.grey1, BlendMode.srcIn),
        );
      }
    } else {
      return SvgPicture.asset(
        TestConfiguration.moodImages[moodIndex],
        width: TestListView3.moodSize,
        height: TestListView3.moodSize,
      );
    }
  }

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

    Color verticalLineColor = Theme.of(context).splashColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashFactory: InkRipple.splashFactory,
        onTapDown: (details) {
          _tapPosition = details.globalPosition;
        },
        onTap: () {
          if (!_showSplash) {
            widget.onMoreTap?.call(context, context, _tapPosition);
          }
          _tapPosition = null;
          _showSplash = false;
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: TestListView3.itemPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isTop)
                const SizedBox(height: TestListView3.itemPadding)
              else
                SizedBox(
                  width: TestListView3.moodSize,
                  height: TestListView3.itemPadding,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: TestListView3.verticalLineWidth,
                      height: TestListView3.itemPadding / 2,
                      color: verticalLineColor,
                    ),
                  ),
                ),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        _buildMood(data.moodIndex, data.type),
                        const SizedBox(height: TestListView3.itemPadding / 2),
                        if (!widget.isBottom)
                          Expanded(
                            child: Container(
                              width: TestListView3.verticalLineWidth,
                              color: verticalLineColor,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: TestListView3.itemPadding),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: TestListView3.itemPadding),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (data.moodIndex != null && widget.showMoodText) ...[
                                            Text(
                                              TestConfiguration.moodTexts[data.moodIndex!],
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: TestColors.moodColors[data.moodIndex!],
                                                height: 1.2,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                          ],
                                          Padding(
                                            padding: const EdgeInsets.only(top: 3),
                                            child: Text(
                                              TimeUtils.getTimeStr(data.time.toTimeOfDay()),
                                              style:
                                                  const TextStyle(fontSize: 12, color: TestColors.grey3, height: 1.2),
                                            ),
                                          ),
                                          if (widget.isOnlyOne)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 3, left: 8),
                                              child: Text(
                                                '${TimeUtils.getWeekdayStr(data.time)}, ${TimeUtils.getDateStr(data.time)}',
                                                style:
                                                    const TextStyle(fontSize: 12, color: TestColors.grey3, height: 1.2),
                                              ),
                                            ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 3, bottom: 5),
                                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                                          buildTypeIcon(data.type),
                                          if (data.type == RecordType.mood && data.isOneDayMood == true) ...[
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
                                          if (data.type == RecordType.diary && data.checkCount != null) ...[
                                            const SizedBox(width: 3),
                                            const Icon(
                                              Icons.check_box_rounded,
                                              size: 13,
                                              color: TestColors.grey3,
                                            ),
                                            Text(
                                              '${data.checkedCount}/${data.checkCount}',
                                              style:
                                                  const TextStyle(fontSize: 12, color: TestColors.grey3, height: 1.2),
                                            ),
                                          ],
                                        ]),
                                      ),
                                    ],
                                  ),
                                ),
                                if (widget.onMoreTap != null)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Builder(builder: (moreContext) {
                                      return SizedBox(
                                        width: 25,
                                        height: 25,
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          style: IconButton.styleFrom(
                                            side: const BorderSide(color: TestColors.grey3),
                                            shape: const CircleBorder(),
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          onPressed: () {
                                            widget.onMoreTap!(context, moreContext, null);
                                          },
                                          icon: const Icon(
                                            Icons.more_horiz_outlined,
                                            color: TestColors.grey3,
                                            size: 20,
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                              ],
                            ),
                            if (data.note != null)
                              Text(
                                data.note!,
                                maxLines: widget.maxLines,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: TestListView.itemTextSize,
                                  color: TestColors.black1,
                                  height: TestListView.itemTextHeight,
                                ),
                              ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
