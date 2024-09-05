import 'package:flutter/material.dart';

/// https://dribbble.com/shots/21037899-Alarm-App-Design
class ClockPage2 extends StatelessWidget {
  const ClockPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(onPressed: () {
          showTimePicker(context: context, initialTime: TimeOfDay.now());
        }, child: const Text('ClockPage1')),
      ),
    );
  }


}
