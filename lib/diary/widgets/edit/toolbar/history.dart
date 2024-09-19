import 'package:dribbble/diary/common/test_colors.dart';
import 'package:dribbble/diary/common/test_configuration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_svg/svg.dart';

class HistoryOpItem extends StatefulWidget {
  final bool isUndo;
  final QuillController controller;

  const HistoryOpItem({super.key, required this.isUndo, required this.controller});

  @override
  State<StatefulWidget> createState() => _HistoryOpItemState();
}

class _HistoryOpItemState extends State<HistoryOpItem> {
  bool _canPressed = false;

  QuillController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _updateCanPressed(); // Set the init state
    controller.changes.listen((event) async {
      _updateCanPressedWithSetState();
    });
  }

  void _updateCanPressed() {
    if (widget.isUndo) {
      _canPressed = controller.hasUndo;
      return;
    }
    _canPressed = controller.hasRedo;
  }

  void _updateCanPressedWithSetState() {
    if (!mounted) {
      return;
    }
    setState(_updateCanPressed);
  }

  void _updateHistory() {
    if (widget.isUndo) {
      if (controller.hasUndo) {
        controller.undo();
      }
      return;
    }
    if (controller.hasRedo) {
      controller.redo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _updateHistory,
        child: Center(
          child: SvgPicture.asset(
            widget.isUndo? 'assets/icons/ic_undo.svg' : 'assets/icons/ic_redo.svg',
            width: TestConfiguration.toolBarIconSize,
            height: TestConfiguration.toolBarIconSize,
            colorFilter: ColorFilter.mode(_canPressed ? TestColors.black1 : TestColors.disabled, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
