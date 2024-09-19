import 'package:dribbble/diary/widgets/edit/toolbar/text/icon_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class ToolbarToggleItem extends StatelessWidget {
  final QuillController controller;
  final Attribute attribute;
  final String icon;

  const ToolbarToggleItem({
    super.key,
    required this.controller,
    required this.attribute,
    required this.icon,
  });

  bool _hasValue() {
    return attribute.key == Attribute.list.key ||
        attribute.key == Attribute.header.key ||
        attribute.key == Attribute.script.key ||
        attribute.key == Attribute.align.key;
  }

  // bool _getIsToggled(Map<String, Attribute> attrs) {
  //   if (widget.attribute.key == Attribute.list.key ||
  //       widget.attribute.key == Attribute.header.key ||
  //       widget.attribute.key == Attribute.script.key ||
  //       widget.attribute.key == Attribute.align.key) {
  //     final attribute = attrs[widget.attribute.key];
  //     if (attribute == null) {
  //       return false;
  //     }
  //     return attribute.value == widget.attribute.value;
  //   }
  //   return attrs.containsKey(widget.attribute.key);
  // }

  bool _isToggled(QuillController controller) {
    final style = controller.getSelectionStyle();
    if (_hasValue()) {
      final current = style.attributes[attribute.key];
      if (current == null) {
        return false;
      }
      return current.value == attribute.value;
    }
    return style.attributes.containsKey(attribute.key);
  }

  @override
  Widget build(BuildContext context) {
    final bool isSelected = _isToggled(controller);
    return ToggleIconItem(
      icon: icon,
      selected: isSelected,
      onSelectChanged: (value) {
        if (value) {
          controller.formatSelection(attribute);
        } else {
          controller.formatSelection(Attribute.clone(attribute, null));
        }
      },
    );
  }
}

class BoldItem extends StatelessWidget {
  final QuillController controller;

  const BoldItem({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ToolbarToggleItem(
      controller: controller,
      attribute: Attribute.bold,
      icon: 'assets/icons/ic_text_bold.svg',
    );
  }
}

class ItalicItem extends StatelessWidget {
  final QuillController controller;

  const ItalicItem({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ToolbarToggleItem(
      controller: controller,
      attribute: Attribute.italic,
      icon: 'assets/icons/ic_text_italic.svg',
    );
  }
}

class UnderlineItem extends StatelessWidget {
  final QuillController controller;

  const UnderlineItem({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ToolbarToggleItem(
      controller: controller,
      attribute: Attribute.underline,
      icon: 'assets/icons/ic_text_underline.svg',
    );
  }
}

class StrikeThroughItem extends StatelessWidget {
  final QuillController controller;

  const StrikeThroughItem({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ToolbarToggleItem(
      controller: controller,
      attribute: Attribute.strikeThrough,
      icon: 'assets/icons/ic_text_strikethrough.svg',
    );
  }
}
