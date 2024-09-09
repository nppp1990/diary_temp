import 'package:dribbble/diary/widgets/turn/turn_page_view.dart';
import 'package:flutter/material.dart';

// https://pub-web.flutter-io.cn/packages/turn_page_transitionp


void main() {
  runApp(const MaterialApp(home: PageTurnEffect()));
}

class PageTurnEffect extends StatelessWidget{
  const PageTurnEffect({super.key});

  static const List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.yellow,
    Colors.pink,
    Colors.teal,
    Colors.cyan,
    Colors.lime,
  ];

  @override
  Widget build(BuildContext context) {
    final controller = TurnPageController(duration: const Duration(seconds: 1), cornerRadius: 20);
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 100),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: TurnPageView.builder(
              controller: controller,
              itemCount: 10,
              itemBuilder: (context, index) => _Page(index),
              overleafColorBuilder: (index) => Colors.grey,
              animationTransitionPoint: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => controller.nextPage(),
            child: const Text('Next Page'),
          ),
        ],
      )
    );
  }
}

class _Page extends StatelessWidget {
  final int index;

  const _Page(this.index);

  static const List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.yellow,
    Colors.pink,
    Colors.teal,
    Colors.cyan,
    Colors.lime,
  ];

  @override
  Widget build(BuildContext context) {
    print('----build page $index----');
    return Container(
      height: 500,
      decoration: BoxDecoration(
        color: colors[index % colors.length],
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Center(
        child: Text(
          'Page $index',
          style: const TextStyle(
            fontSize: 24,
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}