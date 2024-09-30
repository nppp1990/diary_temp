import 'package:dribbble/diary/common/test_colors.dart';
import 'package:dribbble/diary/common/test_configuration.dart';
import 'package:dribbble/diary/widgets/bubble.dart';
import 'package:dribbble/diary/widgets/emphasize.dart';
import 'package:dribbble/diary/widgets/icon/arrow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EditHeader1 extends StatelessWidget {
  const EditHeader1({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TestConfiguration.editHeaderPadding),
      child: SizedBox(
        height: TestConfiguration.editHeaderHeight,
        child: Row(
          children: [
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                  width: TestConfiguration.editHeaderItemSize,
                  height: TestConfiguration.editHeaderItemSize,
                  decoration: BoxDecoration(
                    color: TestColors.second,
                    borderRadius: BorderRadius.circular(8),
                    border: const Border.fromBorderSide(BorderSide(color: TestColors.black1, width: 2)),
                  ),
                  child: const Center(
                    child: LeftArrow(
                      color: TestColors.black1,
                      strokeWidth: 2,
                      size: 16,
                    ),
                  )),
            ),
            const Spacer(),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Navigator.of(context).pop();
              },
              child: SvgPicture.asset(
                'assets/icons/ic_right.svg',
                colorFilter: const ColorFilter.mode(TestColors.black1, BlendMode.srcIn),
                width: 16,
                height: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditHeader2 extends StatefulWidget {
  final DateTime date;
  final int? moodIndex;
  final ValueChanged<DateTime>? onDateChanged;
  final ValueChanged<int>? onEmotionChanged;

  const EditHeader2({
    super.key,
    required this.date,
    this.moodIndex,
    this.onDateChanged,
    this.onEmotionChanged,
  });

  @override
  State<StatefulWidget> createState() => _EditHeader2State();
}

class _EditHeader2State extends State<EditHeader2> {
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _date = widget.date;
  }

  @override
  void didUpdateWidget(covariant EditHeader2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.date != oldWidget.date) {
      _date = widget.date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TestConfiguration.editHeaderPadding),
      child: SizedBox(
        height: TestConfiguration.editHeaderHeight,
        child: Row(
          children: [
            _DateSelector(
              date: _date,
              onChanged: (date) {
                // _date和_time得到的_data
                _date = DateTime(date.year, date.month, date.day, _date.hour, _date.minute);
                widget.onDateChanged?.call(_date);
              },
            ),
            const SizedBox(width: 10),
            _TimeSelector(
              time: _date,
              onChanged: (time) {
                // _date和_time得到的_data
                _date = DateTime(_date.year, _date.month, _date.day, time.hour, time.minute);
                widget.onDateChanged?.call(_date);
              },
            ),
            const SizedBox(width: 16),
            const Spacer(),
            _EmotionSelector(
              moodIndex: widget.moodIndex,
              onChanged: widget.onEmotionChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _DateSelector extends StatefulWidget {
  final DateTime date;
  final ValueChanged<DateTime>? onChanged;

  const _DateSelector({required this.date, this.onChanged});

  @override
  State<StatefulWidget> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<_DateSelector> {
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _date = widget.date;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        _showDatePicker(context);
      },
      child: Text(
        _formatData(_date),
        style: const TextStyle(
          fontSize: 18,
        ),
      ),
    );
  }

  static List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  _formatData(DateTime date) {
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  _showDatePicker(BuildContext context) async {
    final res = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (res != null) {
      setState(() {
        _date = res;
        widget.onChanged?.call(res);
      });
    }
  }
}

class _TimeSelector extends StatefulWidget {
  final DateTime time;
  final ValueChanged<TimeOfDay>? onChanged;

  const _TimeSelector({required this.time, this.onChanged});

  @override
  State<StatefulWidget> createState() => _TimeSelectorState();
}

class _TimeSelectorState extends State<_TimeSelector> {
  late TimeOfDay _time;

  @override
  void initState() {
    super.initState();
    _time = TimeOfDay.fromDateTime(widget.time);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        _showTimePicker(context);
      },
      child: Text(
        _formatTime(_time),
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }

  _formatTime(TimeOfDay time) {
    return '${time.hour}:${time.minute}';
  }

  _showTimePicker(BuildContext context) async {
    final res = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (res != null) {
      setState(() {
        _time = res;
        widget.onChanged?.call(res);
      });
    }
  }
}

class _EmotionSelector extends StatefulWidget {
  final int? moodIndex;
  final ValueChanged<int>? onChanged;

  const _EmotionSelector({this.moodIndex, this.onChanged});

  @override
  State<StatefulWidget> createState() => _EmotionSelectorState();
}

class _EmotionSelectorState extends State<_EmotionSelector> with SingleTickerProviderStateMixin {
  late int? _index;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _index = _convertToToolbarIndex(widget.moodIndex);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (_index == null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (context.mounted) {
          _showBubbleGuideDialog(context);
        }
      });
    }
  }

  int? _convertToToolbarIndex(int? index) {
    if (index == null) {
      return null;
    }
    if (index < 4) {
      return 7 - index;
    } else {
      return index - 4;
    }
  }

  @override
  void didUpdateWidget(covariant _EmotionSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.moodIndex != oldWidget.moodIndex) {
      _index = _convertToToolbarIndex(widget.moodIndex);
    }
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<String> get emotions => TestConfiguration.moodImagesForToolbar;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        _showBubbleGuideDialog(context);
      },
      child: EmphasizeContainer(
        controller: _controller,
        haloColor: TestColors.primary.withOpacity(0.2),
        haloSize: 10,
        child: SvgPicture.asset(
          _index == null ? 'assets/icons/ic_mood_add.svg' : emotions[_index!],
          width: TestConfiguration.editHeaderItemSize,
          height: TestConfiguration.editHeaderItemSize,
          colorFilter: _index == null ? const ColorFilter.mode(TestColors.black1, BlendMode.srcIn) : null,
        ),
      ),
    );
  }

  _showBubbleGuideDialog(BuildContext context) async {
    final renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    var screenWidth = MediaQuery.sizeOf(context).width;
    final triangleOffset = screenWidth - offset.dx - TestConfiguration.editHeaderPadding - 10;
    _controller.repeat(reverse: true);
    var res = await showDialog(
      context: context,
      useSafeArea: false,
      builder: (BuildContext context) {
        return EmotionBubbleDialog(
          top: offset.dy + renderBox.size.height,
          right: TestConfiguration.editHeaderPadding,
          triangleOffset: triangleOffset,
        );
      },
    );
    _controller.stop();
    _controller.reset();
    if (res != null && res is int) {
      setState(() {
        _index = res;
        widget.onChanged?.call(
          res < 4 ? res + 4 : 7 - res,
        );
      });
    }
  }
}

class EmotionBubbleDialog extends StatelessWidget {
  final double top;
  final double right;
  final double triangleOffset;

  const EmotionBubbleDialog({super.key, required this.top, required this.right, required this.triangleOffset});

  List<String> get emotions => TestConfiguration.moodImagesForToolbar;

  List<String> get emotionTexts => TestConfiguration.moodTextsForToolbar;

  @override
  Widget build(BuildContext context) {
    const padding = TestConfiguration.editHeaderPadding;
    return AnimatedPadding(
      padding: EdgeInsets.zero,
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
      child: Stack(
        children: [
          Positioned(
            top: top,
            right: right,
            child: BubbleBorder(
                triangleWidth: 20,
                triangleHeight: 10,
                triangleOffset: triangleOffset,
                borderRadius: 12,
                strokeWidth: 1,
                strokeColor: const Color(0xFF919191),
                fillColor: const Color(0xFFECEAED),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: padding),
                    const Padding(
                      padding: EdgeInsets.only(left: padding),
                      child: Text('how are you feeling?',
                          style: TextStyle(
                            fontSize: 14,
                          )),
                    ),
                    const SizedBox(height: 2),
                    _buildEmotionList(context, 0),
                    _buildEmotionList(context, 4),
                    const SizedBox(height: padding / 2),
                  ],
                )),
          )
        ],
      ),
    );
  }

  Widget _buildEmotionList(BuildContext context, int startIndex) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: TestConfiguration.editHeaderPadding / 2,
        ),
        for (int i = startIndex; i < startIndex + 4; i++)
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop(i);
            },
            child: Tooltip(
              message: emotionTexts[i],
              child: Padding(
                padding: const EdgeInsets.all(TestConfiguration.editHeaderPadding / 2),
                child: SvgPicture.asset(
                  emotions[i],
                  width: TestConfiguration.editHeaderItemSize,
                  height: TestConfiguration.editHeaderItemSize,
                ),
              ),
            ),
          ),
        const SizedBox(width: TestConfiguration.editHeaderPadding / 2)
      ],
    );
  }
}
