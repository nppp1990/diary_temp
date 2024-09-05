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
    final controller = TurnPageController();
    return Scaffold(
      body: TurnPageView.builder(
        controller: controller,
        itemCount: 10,
        itemBuilder: (context, index) => _Page(index),
        overleafColorBuilder: (index) => colors[index],
        animationTransitionPoint: 0.5,
      ),
    );
  }
}

class _Page extends StatelessWidget {
  final int index;

  const _Page(this.index);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 500,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
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