import 'package:dribbble/diary/common/test_colors.dart';
import 'package:dribbble/diary/common/test_configuration.dart';
import 'package:dribbble/diary/utils/color.dart';
import 'package:dribbble/diary/utils/keyboard.dart';
import 'package:dribbble/diary/widgets/edit/edit_demo3.dart';
import 'package:dribbble/diary/widgets/icon/close.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

const List<Color> _backgroundColors = [
  Colors.white,
  Color(0xFFE5E6E9),
  Color(0xFFF7BFBD),
  Color(0xFFF8DDB9),
  Color(0xFFFCF69D),
  Color(0xFFC9F1C4),
  Color(0xFFD2DFFD),
  Color(0xFFDDCBF9),
  Color(0xFFF2F3F5),
  Color(0xFFBCBFC4),
  Color(0xFFF26E6A),
  Color(0xFFF5A555),
  Color(0xFFF8E759),
  Color(0xFF77CF64),
  Color(0xFFA5BCFD),
  Color(0xFFC4A7F7),
];

const List<Color> _textColors = [
  TestColors.black1,
  Color(0xFF909090),
  Color(0xFFC4394F),
  Color(0xFFCF7C35),
  Color(0xFFCC9F40),
  Color(0xFF51983D),
  Color(0xFF345C78),
  Color(0xFF563DBD),
];

class ColorBarItem extends StatefulWidget {
  final QuillController controller;

  const ColorBarItem({super.key, required this.controller});

  @override
  State<StatefulWidget> createState() => _ColorBarItemState();
}

class _ColorBarItemState extends State<ColorBarItem> {
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

  Color _getColor(bool isBackground) {
    String key = isBackground ? Attribute.background.key : Attribute.color.key;
    final attrs = controller.getSelectionStyle();
    if (!attrs.attributes.containsKey(key)) {
      return isBackground ? Colors.white : TestColors.black1;
    }
    String value = attrs.attributes[key]!.value;
    return QuilColors.stringToColor(value);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () async {
        await KeyboardUtils.hideKeyboardByChannel();
        // KeyboardUtils.hideKeyboard(context);
        if (context.mounted) {
          ToolBarDialogProvider.of(context).showColorDialog(true);
        }
      },
      child: Center(
        child: Container(
          width: TestConfiguration.toolBarIconSize + 6,
          height: TestConfiguration.toolBarIconSize + 6,
          decoration: BoxDecoration(
            color: _getColor(true),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Center(
            child: Text(
              'A',
              style: TextStyle(
                color: _getColor(false),
                fontSize: TestConfiguration.toolBarIconSize,
                height: 1,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    ));
  }
}

class ColorSelectDialog extends StatelessWidget {
  final QuillController controller;

  const ColorSelectDialog({
    super.key,
    required this.controller,
    // required this.onBackgroundColorChanged,
    // required this.onTextColorChanged,
  });

  Color _getColor(bool isBackground) {
    String key = isBackground ? Attribute.background.key : Attribute.color.key;
    final attrs = controller.getSelectionStyle();
    if (!attrs.attributes.containsKey(key)) {
      return isBackground ? Colors.white : TestColors.black1;
    }
    String value = attrs.attributes[key]!.value;
    return QuilColors.stringToColor(value);
  }

  void _onColorSelected(Color? color, bool isBackground) {
    String? hex;
    if (color == null) {
      hex = null;
    } else {
      hex = colorToHex(color);
      hex = '#$hex';
    }
    // todo bug: 文字有背景时，光标看不见，https://github.com/singerdmx/flutter-quill/issues/1720
    controller.skipRequestKeyboard = true;
    controller.formatSelection(
      isBackground ? BackgroundAttribute(hex) : ColorAttribute(hex),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = _getColor(false);
    final backgroundColor = _getColor(true);
    return Column(
      children: [
        _TextColorSelectLayout(
            selected: textColor,
            onColorSelected: (value) {
              _onColorSelected(value, false);
            }),
        _BackgroundColorSelectLayout(
          selected: backgroundColor,
          onColorSelected: (value) {
            _onColorSelected(value, true);
          },
        ),
      ],
    );
  }
}

class _TextColorSelectLayout extends StatefulWidget {
  final Color selected;
  final ValueChanged<Color> onColorSelected;

  const _TextColorSelectLayout({required this.selected, required this.onColorSelected});

  @override
  State<StatefulWidget> createState() => _TextColorSelectLayoutState();
}

class _TextColorSelectLayoutState extends State<_TextColorSelectLayout> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.selected;
  }

  @override
  void didUpdateWidget(covariant _TextColorSelectLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      _selectedColor = widget.selected;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(TestConfiguration.dialogPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Text color',
            style: TextStyle(
              fontSize: TestConfiguration.t3,
              height: 1,
            ),
          ),
          const SizedBox(height: TestConfiguration.dialogPadding),
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _textColors.length,
              crossAxisSpacing: 2, // 水平间距
              childAspectRatio: 1.0, // 宽高比为1，确保方格
            ),
            shrinkWrap: true,
            itemCount: _textColors.length,
            itemBuilder: (context, index) {
              final color = _textColors[index];
              final isSelected = _selectedColor == color;
              return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    widget.onColorSelected(color);
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: TestColors.toolBarBackground,
                      border: isSelected ? Border.all(color: TestColors.primary, width: 2) : null,
                    ),
                    child: LayoutBuilder(builder: (context, constraints) {
                      return Center(
                        child: Text(
                          'A',
                          style: TextStyle(
                            color: color,
                            fontSize: constraints.maxWidth * 0.7,
                            height: 1,
                          ),
                        ),
                      );
                    }),
                  ));
            },
          ),
          const SizedBox(height: TestConfiguration.dialogPadding),
        ],
      ),
    );
  }
}

class _BackgroundColorSelectLayout extends StatefulWidget {
  final Color selected;
  final ValueChanged<Color?> onColorSelected;

  const _BackgroundColorSelectLayout({required this.selected, required this.onColorSelected});

  @override
  State<StatefulWidget> createState() => _BackgroundColorSelectLayoutState();
}

class _BackgroundColorSelectLayoutState extends State<_BackgroundColorSelectLayout> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.selected;
  }

  @override
  void didUpdateWidget(covariant _BackgroundColorSelectLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      _selectedColor = widget.selected;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(TestConfiguration.dialogPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Background color',
              style: TextStyle(
                fontSize: TestConfiguration.t3,
                height: 1,
              ),
            ),
            const SizedBox(height: TestConfiguration.dialogPadding),
            GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  crossAxisSpacing: 2, // 水平间距
                  mainAxisSpacing: 2,
                  childAspectRatio: 1.0, // 宽高比为1，确保方格
                ),
                shrinkWrap: true,
                itemCount: _backgroundColors.length,
                itemBuilder: (context, index) {
                  final color = _backgroundColors[index];
                  final isSelected = _selectedColor == color;
                  Widget grid;
                  if (index == 0) {
                    grid = Container(
                        decoration: BoxDecoration(
                            color: color, border: isSelected ? Border.all(color: TestColors.primary, width: 2) : null),
                        child: const Padding(
                          padding: EdgeInsets.all(2),
                          child: IconClose(
                            color: TestColors.greyDivider2,
                            showRightLine: false,
                            strokeWidth: 2,
                          ),
                        ));
                  } else {
                    grid = Container(
                        decoration: BoxDecoration(
                            color: color, border: isSelected ? Border.all(color: TestColors.primary, width: 2) : null));
                  }
                  return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        if (color == _backgroundColors[0]) {
                          widget.onColorSelected(null);
                        } else {
                          widget.onColorSelected(color);
                        }
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      child: grid);
                }),
            const SizedBox(height: TestConfiguration.dialogPadding),
          ],
        ));
  }
}
