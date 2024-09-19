import 'package:dribbble/diary/widgets/edit/toolbar/text/icon_item.dart';
import 'package:flutter/material.dart';

class IndentIncrease extends StatelessWidget {
  final VoidCallback onPressed;

  const IndentIncrease({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconItem(
      icon: 'assets/icons/ic_indent_increase.svg',
      selected: false,
      onPressed: onPressed,
    );
  }
}

class IndentDecrease extends StatelessWidget {
  final VoidCallback onPressed;

  const IndentDecrease({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconItem(
      icon: 'assets/icons/ic_indent_decrease.svg',
      selected: false,
      onPressed: onPressed,
    );
  }
}
