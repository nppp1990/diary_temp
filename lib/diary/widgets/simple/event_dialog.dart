import 'package:dribbble/diary/common/test_colors.dart';
import 'package:dribbble/diary/common/test_configuration.dart';
import 'package:dribbble/diary/data/bean/record.dart';
import 'package:dribbble/diary/data/sqlite_helper.dart';
import 'package:dribbble/diary/utils/dialog_utils.dart';
import 'package:dribbble/diary/utils/time_utils.dart';
import 'package:dribbble/diary/widgets/card.dart';
import 'package:flutter/material.dart';

class SimpleEventDialog extends StatefulWidget {
  final DiaryRecord? record;
  final DateTime? dateTime;

  const SimpleEventDialog({
    super.key,
    this.record,
    this.dateTime,
  });

  static showEventDialog(BuildContext context, {DiaryRecord? record, DateTime? dateTime}) {
    return showDialog(
      context: context,
      builder: (context) => SimpleEventDialog(
        record: record,
        dateTime: dateTime,
      ),
    );
  }

  @override
  State<StatefulWidget> createState() => _SimpleEventDialogState();
}

class _SimpleEventDialogState extends State<SimpleEventDialog> {
  late TimeOfDay _time;
  late TimeOfDay _oldTime;
  late DateTime _initialDateTime;

  late ValueNotifier<String?> _textNotifier;

  @override
  void initState() {
    super.initState();
    if (widget.dateTime != null) {
      _initialDateTime = widget.dateTime!;
    } else {
      _initialDateTime = widget.record?.time ?? DateTime.now();
    }
    _time = _initialDateTime.toTimeOfDay();
    _oldTime = _time;
    _textNotifier = ValueNotifier(widget.record?.content);
  }

  bool _hasChanged() {
    return _textNotifier.value != widget.record?.content || _time != _oldTime;
  }

  void _save() async {
    var record = DiaryRecord(
      id: widget.record?.id,
      type: RecordType.event,
      content: _textNotifier.value,
      time: _initialDateTime.copyWith(hour: _time.hour, minute: _time.minute),
    );
    if (_hasChanged()) {
      if (record.id == null) {
        var id = await RecordManager().insertRecord(record);
        if (id > 0 && mounted) {
          record = record.copyWith(id: id);
          Navigator.of(context).pop(record);
        }
      } else {
        RecordManager().updateRecord(record);
        Navigator.of(context).pop(record);
      }
    } else {
      Navigator.of(context).pop();
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
                        widget.record == null ? 'New Event' : 'Edit Event',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: TestColors.black1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: TestConfiguration.pagePadding),
                      child: TextFormField(
                        initialValue: widget.record?.content,
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
                        DateLayout(date: _initialDateTime),
                        const SizedBox(width: 8),
                        TimeLayout(
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

  bool _canChangeDate() {
    if (widget.record != null) {
      return false;
    }
    return widget.dateTime != null;
  }
}

class DateLayout extends StatefulWidget {
  final DateTime date;
  final ValueChanged<DateTime>? onChanged;

  const DateLayout({super.key, required this.date, this.onChanged});

  @override
  State<StatefulWidget> createState() => _DateLayoutState();
}

class _DateLayoutState extends State<DateLayout> {
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _date = widget.date;
  }

  @override
  void didUpdateWidget(covariant DateLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    _date = widget.date;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TestColors.grey2,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () async {
          if (widget.onChanged == null) {
            DialogUtils.showToast(context, 'Cannot change date');
            return;
          }
          final time = await showDatePicker(
            context: context,
            initialDate: _date,
            firstDate: DateTime(2000),
            lastDate: DateTime.now(),
          );
          if (time != null) {
            widget.onChanged?.call(time);
            setState(() {
              _date = time;
            });
          }
        },
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer_outlined,
                  color: widget.onChanged == null ? TestColors.black1 : TestColors.primary,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(_date.toDateString(),
                    style: TextStyle(
                      color: widget.onChanged == null ? TestColors.black1 : TestColors.primary,
                      fontSize: 12,
                    )),
              ],
            )),
      ),
    );
  }
}

class TimeLayout extends StatefulWidget {
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onChanged;

  const TimeLayout({super.key, required this.time, required this.onChanged});

  @override
  State<StatefulWidget> createState() => _TimeLayoutState();
}

class _TimeLayoutState extends State<TimeLayout> {
  late TimeOfDay _time;

  @override
  void initState() {
    super.initState();
    _time = widget.time;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TestColors.grey2,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
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
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.timer_outlined,
                  color: TestColors.primary,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(TimeUtils.getTimeStr(_time), style: const TextStyle(color: TestColors.primary, fontSize: 12)),
              ],
            )),
      ),
    );
  }
}
