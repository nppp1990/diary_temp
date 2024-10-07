import 'package:dribbble/diary/common/test_colors.dart';
import 'package:dribbble/diary/common/test_configuration.dart';
import 'package:dribbble/diary/data/bean/record.dart';
import 'package:dribbble/diary/utils/docs.dart';
import 'package:dribbble/diary/utils/time_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:table_calendar/table_calendar.dart';

class TestCalendarPage extends StatelessWidget {
  final Map<DateTime, List<DiaryRecord>> recordsMap;
  final DateTime? selectedDay;

  const TestCalendarPage({super.key, required this.recordsMap, this.selectedDay});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Calendar'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(38.0),
          child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DiaryCalendar(recordsMap: recordsMap, selectedDay: selectedDay),
                  const SizedBox(height: 16),
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: TestColors.red1,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  )
                ],
              )),
        ),
      ),
    );
  }
}

class DiaryCalendarInfo {
  final DateTime date;
  final int? mood;
  final List<DiaryRecord>? records;

  DiaryCalendarInfo({
    required this.date,
    this.mood,
    required this.records,
  });
}

class DiaryCalendar extends StatefulWidget {
  final Map<DateTime, List<DiaryRecord>> recordsMap;
  final DateTime? selectedDay;

  const DiaryCalendar({super.key, required this.recordsMap, this.selectedDay});

  @override
  State<StatefulWidget> createState() => _DiaryCalendarState();
}

class _DiaryCalendarState extends State<DiaryCalendar> {
  Map<DateKey, DiaryCalendarInfo> testMap = {};
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late CalendarFormat _calendarFormat;

  @override
  void initState() {
    super.initState();
    widget.recordsMap.forEach((key, value) {
      final dateKey = DateKey.fromDateTime(key);
      int? mood = DocUtils.getDayMood(value);
      testMap[dateKey] = DiaryCalendarInfo(date: key, records: value, mood: mood);
    });
    _focusedDay = widget.selectedDay ?? DateTime.now();
    _selectedDay = _focusedDay;
    _calendarFormat = CalendarFormat.month;
  }

  Widget? _buildCalendarItem1(BuildContext context, DateTime date, DateTime _) {
    final dateKey = DateKey.fromDateTime(date);
    final diaryCalendarInfo = testMap[dateKey];
    bool isSelected = date.isSameDay(_selectedDay);
    if (diaryCalendarInfo == null) {
      if (isSelected) {
        return Container(
          margin: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: TestColors.primary, width: 1.0),
          ),
          child: Center(
            child: Text(
              date.day.toString(),
              style: const TextStyle(
                color: TestColors.primary,
                height: 1,
                fontSize: 16,
              ),
            ),
          ),
        );
      } else {
        return null;
      }
    } else {
      final String moodPath;
      final ColorFilter? moodColor;
      final BoxDecoration? decoration;
      final Color tipColor;
      if (diaryCalendarInfo.mood == null) {
        moodPath = TestConfiguration.moodAddImage;
        if (isSelected) {
          moodColor = const ColorFilter.mode(TestColors.primary, BlendMode.srcIn);
        } else {
          moodColor = const ColorFilter.mode(TestColors.black1, BlendMode.srcIn);
        }
        tipColor = TestColors.black1;
        decoration = null;
      } else {
        moodPath = TestConfiguration.moodImages[diaryCalendarInfo.mood!];
        if (isSelected) {
          decoration = BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: TestColors.primary, width: 1.0),
          );
        } else {
          decoration = null;
        }
        tipColor = TestColors.moodColors[diaryCalendarInfo.mood!];
        moodColor = null;
      }
      return Tooltip(
        preferBelow: false,
        richMessage: TextSpan(
          children: [
            TextSpan(
              text: '${date.day.toString()} ${diaryCalendarInfo.mood == null ? '' : ':'}',
              style: TextStyle(color: tipColor),
            ),
            if (diaryCalendarInfo.mood != null)
              TextSpan(
                text: TestConfiguration.moodTexts[diaryCalendarInfo.mood!],
                style: TextStyle(color: tipColor),
              ),
          ],
        ),
        // message: 'Mood: ${diaryCalendarInfo.mood}',
        child: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.all(6.0),
          decoration: decoration,
          child: SvgPicture.asset(
            moodPath,
            width: double.infinity,
            height: double.infinity,
            colorFilter: moodColor,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // final rowHeight = MediaQuery.of(context).size.width / 7;
    return TableCalendar(
      rowHeight: 50,
      selectedDayPredicate: (day) {
        return isSameDay(day, _selectedDay);
      },
      calendarStyle: const CalendarStyle(
        isTodayHighlighted: false,
        disabledTextStyle: TextStyle(color: TestColors.grey1, fontSize: 16),
      ),
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      focusedDay: _focusedDay,
      onPageChanged: (focusedDay) {
        print('--------onPageChanged: $focusedDay');
        _focusedDay = focusedDay;
      },
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        // titleCentered: true,
        titleTextStyle: const TextStyle(color: TestColors.black1, fontSize: 16),
        leftChevronMargin: const EdgeInsets.symmetric(horizontal: 2),
        rightChevronMargin: const EdgeInsets.symmetric(horizontal: 2),
        todayIndicatorBuilder: (context) {
          DateTime today = DateTime.now();
          if (today.isSameDay(_selectedDay) && today.isSameMonth(_focusedDay)) {
            return const SizedBox.shrink();
          } else {
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                setState(() {
                  _selectedDay = today;
                  _focusedDay = today;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: TodayIndicator(day: today.day),
              ),
            );
          }
        },
      ),
      calendarFormat: _calendarFormat,
      // onFormatChanged: (format) {
      //   print('format: $format');
      //   setState(() {
      //     _calendarFormat = format;
      //   });
      // },
      onDaySelected: (selectedDay, focusedDay) {
        if (!isSameDay(_selectedDay, selectedDay)) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        }
      },
      calendarBuilders: CalendarBuilders(
        prioritizedBuilder: _buildCalendarItem1,
      ),
    );
  }
}

class TodayIndicator extends StatelessWidget {
  final int day;

  const TodayIndicator({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: Stack(
        children: [
          SvgPicture.asset(
            'assets/icons/ic_calendar_today.svg',
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(TestColors.black1, BlendMode.srcIn),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                day.toString(),
                style: const TextStyle(
                  color: TestColors.black1,
                  fontSize: 10,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DateKey {
  final int year;
  final int month;
  final int day;

  DateKey({
    required this.year,
    required this.month,
    required this.day,
  });

  factory DateKey.fromDateTime(DateTime dateTime) {
    return DateKey(year: dateTime.year, month: dateTime.month, day: dateTime.day);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is DateKey) {
      return year == other.year && month == other.month && day == other.day;
    }
    return false;
  }

  @override
  int get hashCode => year.hashCode ^ month.hashCode ^ day.hashCode;
}
