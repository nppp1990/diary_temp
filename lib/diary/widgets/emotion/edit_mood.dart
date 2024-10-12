import 'package:dribbble/diary/common/test_colors.dart';
import 'package:dribbble/diary/common/test_configuration.dart';
import 'package:dribbble/diary/data/bean/record.dart';
import 'package:dribbble/diary/data/sqlite_helper.dart';
import 'package:dribbble/diary/utils/time_utils.dart';
import 'package:dribbble/diary/widgets/bubble.dart';
import 'package:dribbble/diary/widgets/card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pageviewj/pageviewj.dart';

import '../simple/event_dialog.dart';

class MoodDialog extends StatefulWidget {
  final DiaryRecord? record;

  // 此种情况只有测试时会用到
  final DateTime? dateTime;

  // record 和 time 不能同时有
  const MoodDialog({
    super.key,
    this.record,
    this.dateTime,
  }) : assert(record == null || dateTime == null, 'record 和 dateTime 不能同时有');

  @override
  State<StatefulWidget> createState() => _MoodDialogState();

  static showMoodDialog(BuildContext context, {DiaryRecord? record, DateTime? dateTime}) {
    return showDialog(
      context: context,
      builder: (context) => MoodDialog(
        record: record,
        dateTime: dateTime,
      ),
    );
  }
}

class _MoodDialogState extends State<MoodDialog> {
  late int _moodIndex;
  late TimeOfDay _time;
  late TimeOfDay _oldTime;
  late ValueNotifier<bool> _isOneDayMood;
  late String? _note;
  late DateTime _initDateTime;

  @override
  void initState() {
    super.initState();
    _moodIndex = widget.record?.mood ?? 4;
    if (widget.dateTime != null) {
      _initDateTime = widget.dateTime!;
    } else {
      _initDateTime = widget.record?.time ?? DateTime.now();
    }
    _time = _initDateTime.toTimeOfDay();
    _oldTime = _time;
    _isOneDayMood = ValueNotifier(widget.record?.moodForAllDay ?? false);
    _note = widget.record?.content;
  }

  @override
  void dispose() {
    _isOneDayMood.dispose();
    super.dispose();
  }

  bool _hasChanged() {
    bool oldIsOneDayMood = widget.record?.moodForAllDay ?? false;

    return _moodIndex != widget.record?.mood ||
        _note != widget.record?.content ||
        _isOneDayMood.value != oldIsOneDayMood ||
        _time != _oldTime;
  }

  _save() async {
    print('save: $_moodIndex, ${_isOneDayMood.value}, ${_time.toString()}, note: $_note');
    DiaryRecord record = DiaryRecord(
      id: widget.record?.id,
      type: RecordType.mood,
      mood: _moodIndex,
      moodForAllDay: _isOneDayMood.value,
      content: _note,
      time: _initDateTime.copyWith(hour: _time.hour, minute: _time.minute),
    );
    if (_hasChanged()) {
      if (record.id == null) {
        var res = await RecordManager().insertRecord(record);
        if (res > 0 && mounted) {
          record = record.copyWith(id: res);
          Navigator.pop(context, record);
        }
      } else {
        RecordManager().updateRecord(record);
        Navigator.pop(context, record);
      }
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width - TestConfiguration.pagePadding * 2;
    return AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        insetPadding: EdgeInsets.zero,
        content: OffsetCard(
          offset: const Offset(6, 6),
          decoration: BoxDecoration(
            color: TestColors.third,
            border: Border.all(color: TestColors.black1, width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: width,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: TestColors.black1, width: 2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: TestConfiguration.dialogPadding),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: TestConfiguration.pagePadding),
                      child: Text(
                        widget.record == null ? 'Add Mood' : 'Edit Mood',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: TestColors.black1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder(
                      valueListenable: _isOneDayMood,
                      builder: (context, value, child) {
                        return Align(
                          alignment: Alignment.center,
                          child: Text(
                            'How are you feeling ${value ? 'today' : 'now'}?',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              height: 1,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    MoodPageView(
                      width: width,
                      moodIndex: _moodIndex,
                      onChanged: (index) {
                        _moodIndex = index;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: TestConfiguration.pagePadding),
                      child: TextFormField(
                        initialValue: widget.record?.content,
                        maxLength: 20,
                        maxLines: null,
                        decoration: const InputDecoration(
                          hintText: 'Add a note',
                          hintStyle: TextStyle(color: TestColors.grey1),
                        ),
                        onChanged: (value) {
                          _note = value;
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('Is this one day mood?', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 8),
                        ValueListenableBuilder(
                          valueListenable: _isOneDayMood,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: 0.8,
                              child: Switch(
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                inactiveThumbColor: TestColors.primary,
                                trackOutlineColor: WidgetStateProperty.all(TestColors.primary),
                                activeTrackColor: TestColors.primary,
                                value: value,
                                onChanged: (value) {
                                  _isOneDayMood.value = value;
                                },
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(width: TestConfiguration.pagePadding),
                        DateLayout(date: widget.dateTime ?? widget.record?.time ?? DateTime.now()),
                        const SizedBox(width: 8),
                        TimeLayout(
                          time: _time,
                          onChanged: (time) {
                            _time = time;
                          },
                        ),
                        const SizedBox(width: 8),
                        const Spacer(),
                        TextButton(
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            foregroundColor: TestColors.primary,
                          ),
                          onPressed: _save,
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: TestConfiguration.pagePadding - 16),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}

class EditMoodPageContent extends StatefulWidget {
  final int? moodIndex;
  final String? note;
  final bool isOneDayMood;
  final Function(bool, int?, String?) onChanged;

  const EditMoodPageContent({
    super.key,
    this.moodIndex,
    this.note,
    required this.isOneDayMood,
    required this.onChanged,
  });

  @override
  State<StatefulWidget> createState() => _EditMoodPageContentState();
}

class _EditMoodPageContentState extends State<EditMoodPageContent> {
  late ValueNotifier<bool> _isOneDayMood;
  late int? _moodIndex;
  late String? _note;

  @override
  void initState() {
    super.initState();
    _isOneDayMood = ValueNotifier<bool>(widget.isOneDayMood);
    _moodIndex = widget.moodIndex;
    _note = widget.note;
  }

  @override
  void dispose() {
    _isOneDayMood.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 36),
          ValueListenableBuilder(
            valueListenable: _isOneDayMood,
            builder: (context, value, child) {
              return Text(
                'How are you feeling ${value ? 'today' : 'now'}?',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              );
            },
          ),
          const SizedBox(height: 20),
          MoodPageView(
            width: MediaQuery.sizeOf(context).width,
            moodIndex: _moodIndex,
            onChanged: (index) {
              _moodIndex = index;
              widget.onChanged(_isOneDayMood.value, index, _note);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: TestConfiguration.pagePadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Is this one day mood?', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                ValueListenableBuilder(
                  valueListenable: _isOneDayMood,
                  builder: (context, value, child) {
                    return Switch(
                      inactiveThumbColor: TestColors.primary,
                      trackOutlineColor: WidgetStateProperty.all(TestColors.primary),
                      activeTrackColor: TestColors.primary,
                      value: value,
                      onChanged: (value) {
                        _isOneDayMood.value = value;
                        widget.onChanged(value, _moodIndex, _note);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: TestConfiguration.pagePadding),
              child: TextField(
                onChanged: (value) {
                  widget.onChanged(_isOneDayMood.value, _moodIndex, value);
                },
                decoration: InputDecoration(
                  hintText: 'Add a note',
                  hintStyle: const TextStyle(color: TestColors.grey1),
                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: TestColors.black1, width: 2),
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: TestColors.primary, width: 2),
                  ),
                ),
                maxLines: null,
                maxLength: 80,
              )),
        ],
      ),
    );
  }
}

class MoodPageView extends StatefulWidget {
  final double width;
  final int? moodIndex;
  final ValueChanged<int>? onChanged;

  const MoodPageView({super.key, this.moodIndex, this.onChanged, required this.width});

  @override
  State<StatefulWidget> createState() => _MoodPageViewState();
}

class _MoodPageViewState extends State<MoodPageView> {
  List<String> get moods => TestConfiguration.moodImages;

  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      initialPage: 0,
      viewportFraction: 0.5,
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      int moodIndex = widget.moodIndex ?? 4;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _controller.animateToPage(moodIndex,
              duration: const Duration(milliseconds: 300 * 2), curve: Curves.easeInOut);
        }
      });
    });
  }

  Widget _buildIMoodItem(BuildContext context, int index, double page, double aniValue, double width) {
    Widget buildBubbleTip(BuildContext context, String text) {
      return AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.zero,
        child: BubbleBorder(
          borderRadius: 6,
          direction: TriangleDirection.topCenter,
          triangleWidth: 8,
          triangleHeight: 6,
          triangleOffset: 0,
          strokeWidth: 1,
          strokeColor: Colors.transparent,
          fillColor: TestColors.primary,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Opacity(
          opacity: 0.5 + 0.5 * aniValue,
          child: GestureDetector(
            onTap: () {
              _controller.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
            },
            child: SvgPicture.asset(
              moods[index],
              width: width * 0.7 + width * 0.3 * aniValue,
              height: width * 0.7 + width * 0.3 * aniValue,
            ),
          ),
        ),
        const SizedBox(height: 6),
        if (page == index.toDouble()) buildBubbleTip(context, TestConfiguration.moodTexts[index]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.width * _controller.viewportFraction + 50,
      child: PageViewJ.aniBuilder(
        onPageChanged: (index) {
          widget.onChanged?.call(index);
        },
        controller: _controller,
        itemCount: moods.length,
        aniItemBuilder: (context, index, page, aniValue) {
          return _buildIMoodItem(context, index, page, aniValue, widget.width * _controller.viewportFraction);
        },
      ),
    );
  }
}
