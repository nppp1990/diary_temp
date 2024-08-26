import 'package:dribbble/clock/clock1/wheel/circle_wheel_scroll_view.dart';
import 'package:flutter/material.dart';

class WheelExamplePage extends StatelessWidget {
  const WheelExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: WheelExample(),
        ),
      ),
    );
  }
}

class WheelExample extends StatelessWidget {
  const WheelExample({super.key});

  Widget _buildItem(int i) {
    return Container(
      // color: Colors.yellow[100 * ((i % 8) + 1)],
      child: Align(
        alignment: Alignment.centerRight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 60,
            height: 60,
            // padding: const EdgeInsets.all(20),
            color: Colors.blue[100 * ((i % 8) + 1)],
            child: Center(
              child: Text(
                i.toString(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wheel example'),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            // height: 260,
            width: 260,
            child: CircleListScrollView(
              physics: const CircleFixedExtentScrollPhysics(),
              axis: Axis.vertical,
              itemExtent: 80,
              radius: 200,
              scaleOffset: const Offset(260 - 60, (80 - 60) / 2),
              onSelectedItemChanged: (int index) => print('Current index: $index'),
              children: List.generate(30, _buildItem),
            ),
          ),
        ),
      ),
    );
  }
}
