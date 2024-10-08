import 'package:dribbble/diary/data/bean/record.dart';
import 'package:dribbble/diary/utils/dialog_utils.dart';
import 'package:dribbble/diary/utils/time_utils.dart';
import 'package:dribbble/diary/widgets/calendar/test_calendar.dart';
import 'package:flutter/material.dart';

class DiaryCalendarDialog extends StatefulWidget {
  final Map<DateKey, List<DiaryRecord>> recordsMap;
  final DateTime? selectedDay;

  static show(
    BuildContext context, {
    required Map<DateKey, List<DiaryRecord>> recordsMap,
    required DateTime? selectedDay,
  }) {
    return showDialog(
      context: context,
      builder: (context) => DiaryCalendarDialog(
        recordsMap: recordsMap,
        selectedDay: selectedDay,
      ),
    );
  }

  const DiaryCalendarDialog({
    super.key,
    required this.recordsMap,
    this.selectedDay,
  });

  @override
  State<StatefulWidget> createState() => _DiaryCalendarDialogState();
}

class _DiaryCalendarDialogState extends State<DiaryCalendarDialog> {
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.selectedDay ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: 'select date',
      titleMargin: 4,
      content: SizedBox(
        // headerHeight: 2 * 2 + 30 + 8 * 2 = 50
        // weekdayHeight: 16
        // dayHeight: 50 * 6 = 300
        height: 370,
        width: 1000,
        child: DiaryCalendar(
          recordsMap: widget.recordsMap,
          selectedDay: _selectedDay,
          onDayChanged: (day) {
            _selectedDay = day;
          },
        ),
      ),
      onConfirm: () {
        print('selected day: $_selectedDay');
        Navigator.of(context).pop(_selectedDay);
      },
    );
  }
}
