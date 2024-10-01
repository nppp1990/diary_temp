import 'package:dribbble/diary/common/test_configuration.dart';
import 'package:flutter/material.dart';

import 'icon_item.dart';

enum ListType {
  ol,
  ul,
  check,
  quote,
}

class ListItems extends StatefulWidget {
  final ListType? selected;
  final ValueChanged<ListType?> onListChanged;

  const ListItems({super.key, this.selected = ListType.ol, required this.onListChanged});

  @override
  State<StatefulWidget> createState() => _ListItemsState();
}

class _ListItemsState extends State<ListItems> {
  late ListType? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  @override
  void didUpdateWidget(covariant ListItems oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      setState(() {
        _selected = widget.selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thickness: 1,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconItem(
                icon: 'assets/icons/ic_list_ol.svg',
                selected: _selected == ListType.ol,
                onPressed: () => _onListChanged(ListType.ol)),
            const SizedBox(width: TestConfiguration.boxItemPadding),
            IconItem(
                icon: 'assets/icons/ic_list_ul.svg',
                selected: _selected == ListType.ul,
                onPressed: () => _onListChanged(ListType.ul)),
            const SizedBox(width: TestConfiguration.boxItemPadding),
            IconItem(
                icon: 'assets/icons/ic_check_list.svg',
                selected: _selected == ListType.check,
                onPressed: () => _onListChanged(ListType.check)),
            const SizedBox(width: TestConfiguration.boxItemPadding),
            IconItem(
                iconScale: 0.8,
                icon: 'assets/icons/ic_quote.svg',
                selected: _selected == ListType.quote,
                onPressed: () => _onListChanged(ListType.quote)),
          ],
        ),
      ),
    );
  }

  void _onListChanged(ListType type) {
    if (_selected == type) {
      _selected = null;
    } else {
      _selected = type;
    }
    widget.onListChanged(_selected);
    setState(() {});
  }
}
