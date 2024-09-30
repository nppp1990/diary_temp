import 'package:dribbble/diary/common/test_colors.dart';
import 'package:dribbble/diary/common/test_configuration.dart';
import 'package:dribbble/diary/data/bean/record.dart';
import 'package:dribbble/diary/data/sqlite_helper.dart';
import 'package:dribbble/diary/utils/dialog_utils.dart';
import 'package:dribbble/diary/widgets/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pageviewj/pageviewj.dart';

class EditMoodPage extends StatefulWidget {
  // final int? moodIndex;
  // final String? note;
  // final bool? isOneDayMood;
  final DiaryRecord? record;

  const EditMoodPage({super.key, this.record});

  @override
  State<StatefulWidget> createState() => _EditMoodPageState();
}

class _EditMoodPageState extends State<EditMoodPage> {
  late int? _moodIndex;
  late String? _note;
  late bool _isOneDayMood;

  @override
  void initState() {
    super.initState();
    _moodIndex = widget.record?.mood;
    _note = widget.record?.content;
    _isOneDayMood = widget.record?.moodForAllDay ?? false;
  }

  bool _hasChanged() {
    bool oldIsOneDayMood = widget.record?.moodForAllDay ?? false;
    return _moodIndex != widget.record?.mood || _note != widget.record?.content || _isOneDayMood != oldIsOneDayMood;
  }

  void _saveMood() async {
    if (_moodIndex == null || !_hasChanged()) {
      return;
    }
    var record = DiaryRecord(
      id: widget.record?.id,
      type: RecordType.mood,
      mood: _moodIndex!,
      content: _note,
      moodForAllDay: _isOneDayMood,
      time: widget.record?.time ?? DateTime.now(),
    );
    if (record.id == null) {
      RecordManager().insertRecord(record);
    } else {
      RecordManager().updateRecord(record);
    }
  }

  void _handlePop(BuildContext context) async {
    if (_moodIndex == null || !_hasChanged()) {
      Navigator.pop(context);
      return;
    }
    var res = await DialogUtils.showConfirmDialog(
      context,
      title: 'Save Mood?',
      content: 'You have unsaved changes. Do you want to save them?',
      cancelText: 'Discard',
      confirmText: 'Save',
    );
    if (context.mounted) {
      if (res is int && res > 0) {
        _saveMood();
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        _handlePop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Mood'),
          iconTheme: TestConfiguration.toolbarIconStyle,
          forceMaterialTransparency: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                _saveMood();
                Navigator.pop(context);
              },
            ),
          ],
        ),
        body: EditMoodPageContent(
          onChanged: (isOneDayMood, moodIndex, note) {
            print('onChanged: $isOneDayMood, $moodIndex, $note');
            _isOneDayMood = isOneDayMood;
            _moodIndex = moodIndex;
            _note = note;
          },
          isOneDayMood: _isOneDayMood,
          note: _note,
          moodIndex: _moodIndex,
        ),
      ),
    );
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
  final int? moodIndex;
  final ValueChanged<int>? onChanged;

  const MoodPageView({super.key, this.moodIndex, this.onChanged});

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
          child: SvgPicture.asset(
            moods[index],
            width: width * 0.7 + width * 0.3 * aniValue,
            height: width * 0.7 + width * 0.3 * aniValue,
          ),
        ),
        const SizedBox(height: 6),
        if (page == index.toDouble()) buildBubbleTip(context, TestConfiguration.moodTexts[index]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    return SizedBox(
      height: screenWidth * _controller.viewportFraction + 80,
      child: PageViewJ.aniBuilder(
        onPageChanged: (index) {
          widget.onChanged?.call(index);
        },
        controller: _controller,
        itemCount: moods.length,
        aniItemBuilder: (context, index, page, aniValue) {
          return _buildIMoodItem(context, index, page, aniValue, screenWidth * _controller.viewportFraction);
        },
      ),
    );
  }
}
