import 'package:circle_list/circle_list.dart';
import 'package:clickable_list_wheel_view/clickable_list_wheel_widget.dart';
import 'package:flutter/material.dart';

class FixedExtentListPage extends StatelessWidget {
  const FixedExtentListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('FixedExtentScrollController Example')),
        body: const Center(
          child: FixedExtentList(),
        ),
      ),
    );
  }
}

class FixedExtentList extends StatefulWidget {
  const FixedExtentList({super.key});

  @override
  State<StatefulWidget> createState() => _FixedExtentListState();
}

class _FixedExtentListState extends State<FixedExtentList> {
  final FixedExtentScrollController _controller = FixedExtentScrollController(initialItem: 2);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListWheelScrollView.useDelegate(
            controller: _controller,
            itemExtent: 50,
            physics: const FixedExtentScrollPhysics(),
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) => ListTile(
                title: Text('Item $index'),
              ),
              childCount: 20,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            _controller.animateToItem(
              5,
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
            );
          },
          child: const Text('Scroll to Item 5'),
        ),
      ],
    );
  }
}

class CircleListPage extends StatelessWidget {
  const CircleListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: CircleList(
          origin: const Offset(0, 0),
          children: List.generate(10, (index) {
            return Icon(
              Icons.details,
              color: index % 2 == 0 ? Colors.blue : Colors.orange,
            );
          }),
        ),
      ),
    );
  }
}


class LoopListPage extends StatelessWidget {
  final _scrollController = FixedExtentScrollController();

  static const double _itemHeight = 60;
  static const int _itemCount = 100;

  LoopListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ClickableListWheelScrollView(
          scrollController: _scrollController,
          itemHeight: _itemHeight,
          itemCount: _itemCount,
          onItemTapCallback: (index) {
            print("onItemTapCallback index: $index");
          },
          loop: true,
          child: ListWheelScrollView.useDelegate(
            controller: _scrollController,
            itemExtent: _itemHeight,
            physics: const FixedExtentScrollPhysics(),
            overAndUnderCenterOpacity: 0.5,
            perspective: 0.002,
            onSelectedItemChanged: (index) {
              print("onSelectedItemChanged index: $index");
            },
            childDelegate: ListWheelChildLoopingListDelegate(
              children: List.generate(
                _itemCount,
                (index) => _child(index),
              ),
              // builder: (context, index) => _child(index),
              // childCount: _itemCount,
            ),
          ),
        ),
      ),
    );
  }

  Widget _child(int index) {
    return SizedBox(
      height: _itemHeight,
      child: ListTile(
        leading: Icon(IconData(int.parse("0xe${index + 200}"), fontFamily: 'MaterialIcons'), size: 50),
        title: const Text('Heart Shaker'),
        subtitle: const Text('Description here'),
      ),
    );
  }
}