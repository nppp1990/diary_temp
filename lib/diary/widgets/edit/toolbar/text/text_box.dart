import 'package:dribbble/diary/common/test_colors.dart';
import 'package:dribbble/diary/common/test_configuration.dart';
import 'package:dribbble/diary/widgets/edit/toolbar/text/indent.dart';
import 'package:dribbble/diary/widgets/edit/toolbar/text/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'align.dart';
import 'header.dart';
import 'list.dart';

class ToolTextBox extends StatefulWidget {
  final QuillController controller;

  const ToolTextBox({super.key, required this.controller});

  @override
  State<StatefulWidget> createState() => _ToolTextBoxState();
}

class _ToolTextBoxState extends State<ToolTextBox> {
  QuillController get controller => widget.controller;

  void _textChanged() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(_textChanged);
  }

  @override
  void dispose() {
    controller.removeListener(_textChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TestConfiguration.boxItemPadding),
      width: double.infinity,
      color: TestColors.toolBarBackground,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              AlignItems(selectedAlign: _getTextAlign(), onAlignChanged: _updateAlign),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: TestConfiguration.boxItemPadding * 0.5),
                width: 1,
                height: TestConfiguration.boxItemSize1 * 0.8,
                color: TestColors.greyDivider1,
              ),
              IndentIncrease(onPressed: _increaseIndent),
              const SizedBox(width: TestConfiguration.boxItemPadding),
              IndentDecrease(onPressed: _decreaseIndent),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: TestConfiguration.boxItemPadding * 0.5),
                width: 1,
                height: TestConfiguration.boxItemSize1 * 0.8,
                color: TestColors.greyDivider1,
              ),
              Expanded(child: ListItems(selected: _getListType(), onListChanged: _updateList)),
            ],
          ),
          const SizedBox(height: TestConfiguration.boxItemPadding),
          Row(
            children: [
              TextHeaderItems(
                selectedHeaderType: _getHeaderType(),
                onTypeChanged: _updateHeader,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: TestConfiguration.boxItemPadding * 0.5),
                width: 1,
                height: TestConfiguration.boxItemSize1 * 0.8,
                color: TestColors.greyDivider1,
              ),
              BoldItem(controller: controller),
              const SizedBox(width: TestConfiguration.boxItemPadding),
              ItalicItem(controller: controller),
              const SizedBox(width: TestConfiguration.boxItemPadding),
              UnderlineItem(controller: controller),
              const SizedBox(width: TestConfiguration.boxItemPadding),
              StrikeThroughItem(controller: controller),
            ],
          )
        ],
      ),
    );
  }

  AlignType _getTextAlign() {
    if (controller.getSelectionStyle().attributes.containsKey(Attribute.align.key)) {
      var alignment = controller.getSelectionStyle().attributes[Attribute.align.key];
      if (alignment == Attribute.leftAlignment) {
        return AlignType.left;
      } else if (alignment == Attribute.centerAlignment) {
        return AlignType.center;
      } else if (alignment == Attribute.rightAlignment) {
        return AlignType.right;
      } else {
        return AlignType.left;
      }
    } else {
      return AlignType.left;
    }
  }

  void _updateAlign(AlignType align) {
    switch (align) {
      case AlignType.left:
        controller.formatSelection(Attribute.leftAlignment);
        break;
      case AlignType.center:
        controller.formatSelection(Attribute.centerAlignment);
        break;
      case AlignType.right:
        controller.formatSelection(Attribute.rightAlignment);
        break;
    }
  }

  HeaderType? _getHeaderType() {
    if (controller.getSelectionStyle().attributes.containsKey(Attribute.header.key)) {
      var header = controller.getSelectionStyle().attributes[Attribute.header.key];
      if (header == Attribute.h1) {
        return HeaderType.h1;
      } else if (header == Attribute.h2) {
        return HeaderType.h2;
      } else if (header == Attribute.h3) {
        return HeaderType.h3;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  void _updateHeader(HeaderType? type) {
    if (type == null) {
      controller.formatSelection(Attribute.header);
      return;
    }
    switch (type) {
      case HeaderType.h1:
        controller.formatSelection(Attribute.h1);
        break;
      case HeaderType.h2:
        controller.formatSelection(Attribute.h2);
        break;
      case HeaderType.h3:
        controller.formatSelection(Attribute.h3);
        break;
    }
  }

  void _increaseIndent() {
    controller.indentSelection(true);
  }

  void _decreaseIndent() {
    controller.indentSelection(false);
  }

  ListType? _getListType() {
    var attrs = controller.getSelectionStyle().attributes;
    if (attrs.containsKey(Attribute.blockQuote.key)) {
      return ListType.quote;
    }
    if (attrs.containsKey(Attribute.list.key)) {
      var list = controller.getSelectionStyle().attributes[Attribute.list.key];
      if (list == Attribute.ol) {
        return ListType.ol;
      } else if (list == Attribute.ul) {
        return ListType.ul;
      } else if (list == Attribute.checked || list == Attribute.unchecked) {
        return ListType.check;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  bool _isChecked(Map<String, Attribute> attrs) {
    var attribute = attrs[Attribute.list.key];
    if (attribute == null) {
      return false;
    }
    return attribute.value == Attribute.unchecked.value || attribute.value == Attribute.checked.value;
  }

  void _updateList(ListType? type) {
    if (type == null) {
      controller.formatSelection(Attribute.clone(Attribute.list, null));
      controller.formatSelection(Attribute.clone(Attribute.blockQuote, null));
      return;
    }
    switch (type) {
      case ListType.ol:
        controller.formatSelection(Attribute.ol);
        break;
      case ListType.ul:
        controller.formatSelection(Attribute.ul);
        break;
      case ListType.check:
        controller.formatSelection(Attribute.unchecked);
        // var current = _isChecked(controller.getSelectionStyle().attributes);
        // controller.formatSelection(current ? Attribute.clone(Attribute.unchecked, null) : Attribute.unchecked);
        break;
      case ListType.quote:
        controller.formatSelection(Attribute.blockQuote);
        break;
    }
  }
}
