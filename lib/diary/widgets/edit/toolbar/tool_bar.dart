import 'dart:async';

import 'package:dribbble/diary/common/test_colors.dart';
import 'package:dribbble/diary/common/test_configuration.dart';
import 'package:dribbble/diary/utils/dialog_utils.dart';
import 'package:dribbble/diary/utils/keyboard.dart';
import 'package:dribbble/diary/widgets/edit/edit_demo3.dart';
import 'package:dribbble/diary/widgets/edit/toolbar/history.dart';
import 'package:dribbble/diary/widgets/edit/toolbar/template/template_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_svg/svg.dart';

import 'color/color_toolbar_item.dart';
import 'text/text_box.dart';

class Toolbar extends StatefulWidget {
  final QuillController controller;
  final GlobalKey templateItemKey;

  const Toolbar({super.key, required this.controller, required this.templateItemKey});

  @override
  State<StatefulWidget> createState() => _ToolbarState();
}

class _ToolbarState extends State<Toolbar> {
  QuillController get controller => widget.controller;

  bool _showTextBox = false;
  bool _showEmotionBox = false;
  late StreamSubscription<bool> keyboardSubscription;
  bool _showToolBar = false;

  @override
  void initState() {
    super.initState();
    keyboardSubscription = KeyboardVisibilityController().onChange.listen((bool visible) {
      if (!context.mounted) {
        return;
      }

      print('-----keyboard visible: $visible, isCurrent: ${ModalRoute.of(context)!.isCurrent}');

      if (visible) {
        if (!_showToolBar) {
          final isCurrentPage = ModalRoute.of(context)?.isCurrent ?? false;
          if (isCurrentPage) {
            setState(() {
              _showToolBar = true;
            });
          }
        }
      } else {
        if (_showToolBar) {
          setState(() {
            _showToolBar = false;
            _clearSelected();
          });
        }
      }
    });
  }


  @override
  void dispose() {
    keyboardSubscription.cancel();
    super.dispose();
  }

  @override
  void activate() {
    super.activate();
    print('-----activate toolbar');
  }

  @override
  void deactivate() {
    super.deactivate();
    print('-----deactivate toolbar');
  }



  @override
  Widget build(BuildContext context) {
    print('-----build toolbar');
    return Visibility(
      visible: _showToolBar,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: 1, color: TestColors.greyDivider1),
          Container(
            height: TestConfiguration.toolBarHeight,
            width: double.infinity,
            color: TestColors.toolBarBackground,
            child: Row(
              children: [
                Expanded(child: ToolbarTemplateItem(key: widget.templateItemKey, onTap: () {
                  DialogUtils.showConfirmDialog(context, 'test', 'content', () {
                    print('----confirm');
                  });
                })),
                _buildToolbarButton('assets/icons/ic_background.svg', controller, false, () {
                  KeyboardUtils.hideKeyboard(context);
                  ToolBarDialogProvider.of(context).showBackgroundDialog(true);
                }),
                _buildToolbarButton('assets/icons/ic_emotion.svg', controller, false, () {
                  KeyboardUtils.hideKeyboard(context);
                  ToolBarDialogProvider.of(context).showEmotionDialog(true);
                }),
                _buildToolbarButton('assets/icons/ic_text.svg', controller, _showTextBox, () {
                  bool show = !_showTextBox;
                  setState(() {
                    _clearSelected();
                    _showTextBox = show;
                  });
                }),
                ColorBarItem(controller: controller),
                HistoryOpItem(isUndo: true, controller: controller),
                HistoryOpItem(isUndo: false, controller: controller),
              ],
            ),
          ),
          if (_showBox) Container(height: 1, color: TestColors.greyDivider1),
          if (_showTextBox) ToolTextBox(controller: controller),
        ],
      ),
    );
  }

  _clearSelected() {
    _showTextBox = false;
    _showEmotionBox = false;
  }

  bool get _showBox => _showTextBox || _showEmotionBox;

  _buildToolbarButton(String iconPath, QuillController controller, bool selected, VoidCallback onPressed) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => onPressed(),
        child: Center(
          child: SvgPicture.asset(
            iconPath,
            width: TestConfiguration.toolBarIconSize,
            height: TestConfiguration.toolBarIconSize,
            colorFilter: ColorFilter.mode(selected ? TestColors.primary : TestColors.black1, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
