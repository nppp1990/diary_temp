import 'package:dribbble/diary/common/test_configuration.dart';
import 'package:flutter/material.dart';

import 'icon_item.dart';

enum AlignType {
  left,
  center,
  right,
}

class AlignItems extends StatefulWidget {
  final AlignType selectedAlign;
  final ValueChanged<AlignType> onAlignChanged;

  const AlignItems({super.key, this.selectedAlign = AlignType.left, required this.onAlignChanged});

  @override
  State<StatefulWidget> createState() => _AlignItemsState();
}

class _AlignItemsState extends State<AlignItems> {
  late AlignType _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedAlign;
  }

  @override
  void didUpdateWidget(covariant AlignItems oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedAlign != oldWidget.selectedAlign) {
      setState(() {
        _selected = widget.selectedAlign;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconItem(
            icon: 'assets/icons/ic_align_left.svg',
            // tip: 'Align left',
            selected: _selected == AlignType.left,
            onPressed: () => _onAlignChanged(AlignType.left)),
        const SizedBox(width: TestConfiguration.boxItemPadding),
        IconItem(
            icon: 'assets/icons/ic_align_mid.svg',
            selected: _selected == AlignType.center,
            onPressed: () => _onAlignChanged(AlignType.center)),
        const SizedBox(width: TestConfiguration.boxItemPadding),
        IconItem(
            icon: 'assets/icons/ic_align_right.svg',
            selected: _selected == AlignType.right,
            onPressed: () => _onAlignChanged(AlignType.right)),
      ],
    );
  }

  void _onAlignChanged(AlignType align) {
    widget.onAlignChanged(align);
    setState(() {
      _selected = align;
    });
  }
}
