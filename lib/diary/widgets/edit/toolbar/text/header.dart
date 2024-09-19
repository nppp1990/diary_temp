import 'package:dribbble/diary/common/test_configuration.dart';
import 'package:flutter/material.dart';

import 'icon_item.dart';

enum HeaderType {
  h1,
  h2,
  h3,
}

class TextHeaderItems extends StatefulWidget {
  final HeaderType? selectedHeaderType;
  final ValueChanged<HeaderType?> onTypeChanged;

  const TextHeaderItems({super.key, required this.selectedHeaderType, required this.onTypeChanged});

  @override
  State<StatefulWidget> createState() => _TextHeaderItemsState();
}

class _TextHeaderItemsState extends State<TextHeaderItems> {
  late HeaderType? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedHeaderType;
  }

  @override
  void didUpdateWidget(covariant TextHeaderItems oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedHeaderType != oldWidget.selectedHeaderType) {
      setState(() {
        _selected = widget.selectedHeaderType;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconItem(
            icon: 'assets/icons/ic_h1.svg',
            selected: _selected == HeaderType.h1,
            onPressed: () => _onTypeChanged(HeaderType.h1)),
        const SizedBox(width: TestConfiguration.boxItemPadding),
        IconItem(
            icon: 'assets/icons/ic_h2.svg',
            selected: _selected == HeaderType.h2,
            onPressed: () => _onTypeChanged(HeaderType.h2)),
        const SizedBox(width: TestConfiguration.boxItemPadding),
        IconItem(
            icon: 'assets/icons/ic_h3.svg',
            selected: _selected == HeaderType.h3,
            onPressed: () => _onTypeChanged(HeaderType.h3)),
      ],
    );
  }

  void _onTypeChanged(HeaderType type) {
    if (_selected == type) {
      _selected = null;
    } else {
      _selected = type;
    }
    widget.onTypeChanged(_selected);
    setState(() {});
  }
}
