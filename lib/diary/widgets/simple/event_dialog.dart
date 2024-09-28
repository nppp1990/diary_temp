import 'package:dribbble/diary/common/test_colors.dart';
import 'package:dribbble/diary/common/test_configuration.dart';
import 'package:dribbble/diary/widgets/card.dart';
import 'package:flutter/material.dart';

class SimpleEventDialog extends StatefulWidget {
  final TimeOfDay? timeOfDay;
  final String? text;

  const SimpleEventDialog({super.key, this.timeOfDay, this.text});

  static showEventDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const SimpleEventDialog(),
    );
  }

  @override
  State<StatefulWidget> createState() => _SimpleEventDialogState();
}

class _SimpleEventDialogState extends State<SimpleEventDialog> {
  late TimeOfDay _time;
  late ValueNotifier<String?> _textNotifier;

  @override
  void initState() {
    super.initState();
    _time = widget.timeOfDay ?? TimeOfDay.now();
    _textNotifier = ValueNotifier(widget.text);
  }

  void _save() {
    print('save time: $_time, text: ${_textNotifier.value}');
    Navigator.of(context).pop();
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
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: TestConfiguration.pagePadding),
                      child: Text('event',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: TestColors.black1,
                          )),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: TestConfiguration.pagePadding),
                      child: TextField(
                        maxLength: 20,
                        maxLines: null,
                        decoration: const InputDecoration(
                          hintText: 'write what happened briefly',
                          hintStyle: TextStyle(color: TestColors.grey1),
                        ),
                        onChanged: (value) {
                          _textNotifier.value = value;
                        },
                      ),
                    ),
                    Row(
                      children: [
                        const SizedBox(width: TestConfiguration.pagePadding),
                        _TimeLayout(
                          time: _time,
                          onChanged: (time) {
                            _time = time;
                          },
                        ),
                        const SizedBox(width: 8),
                        const Spacer(),
                        ValueListenableBuilder(
                          valueListenable: _textNotifier,
                          builder: (context, value, child) {
                            return TextButton(
                              style: TextButton.styleFrom(
                                minimumSize: Size.zero,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                foregroundColor: value == null ? TestColors.grey1 : TestColors.primary,
                              ),
                              onPressed: value == null ? null : _save,
                              child: child!,
                            );
                          },
                          child: const Text(
                            'Done',
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

class _TimeLayout extends StatefulWidget {
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onChanged;

  const _TimeLayout({required this.time, required this.onChanged});

  @override
  State<StatefulWidget> createState() => _TimeLayoutState();
}

class _TimeLayoutState extends State<_TimeLayout> {
  late TimeOfDay _time;

  @override
  void initState() {
    super.initState();
    _time = widget.time;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final time = await showTimePicker(context: context, initialTime: _time);
        if (time != null) {
          widget.onChanged(time);
          setState(() {
            _time = time;
          });
        }
      },
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: TestColors.grey2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.timer_outlined,
                color: TestColors.black1,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(_getTimeStr(_time), style: const TextStyle(color: TestColors.black1, fontSize: 12)),
            ],
          )),
    );
  }

  // 12:30 am
  String _getTimeStr(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute;
    final period = time.period;
    return '${hour == 0 ? 12 : hour}:${minute.toString().padLeft(2, '0')} ${period == DayPeriod.am ? 'am' : 'pm'}';
  }
}
