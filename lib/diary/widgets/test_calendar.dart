import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class TestCalendarPage extends StatelessWidget {
  const TestCalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Calendar'),
      ),
      body: Center(
          child: TableCalendar(
        firstDay: DateTime.utc(2010, 10, 16),
        lastDay: DateTime.utc(2030, 3, 14),
        focusedDay: DateTime.now(),
      )),
    );
  }
}
