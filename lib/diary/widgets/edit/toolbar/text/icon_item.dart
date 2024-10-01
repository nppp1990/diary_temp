import 'package:dribbble/diary/common/test_colors.dart';
import 'package:dribbble/diary/common/test_configuration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/extensions.dart';
import 'package:flutter_svg/svg.dart';

class IconItem extends StatelessWidget {
  final String icon;
  final String? tip;
  final bool selected;
  final VoidCallback onPressed;
  final double iconScale;

  const IconItem({
    super.key,
    required this.icon,
    this.iconScale = 0.7,
    this.tip,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return UtilityWidgets.maybeTooltip(
      message: tip,
      child: InkWell(
        onTap: () => onPressed(),
        child: Container(
          height: TestConfiguration.boxItemSize1,
          width: TestConfiguration.boxItemSize1,
          decoration: selected
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(TestConfiguration.boxItemBorderRadius),
                  border: Border.all(
                    color: TestColors.primary,
                    width: 1,
                  ),
                )
              : null,
          child: Center(
            child: SvgPicture.asset(
              icon,
              colorFilter: ColorFilter.mode(selected ? TestColors.primary : TestColors.black1, BlendMode.srcIn),
              width: TestConfiguration.boxItemSize1 * iconScale,
              height: TestConfiguration.boxItemSize1 * iconScale,
            ),
          ),
        ),
      ),
    );
  }
}

class ToggleIconItem extends StatefulWidget {
  final String icon;
  final bool selected;
  final ValueChanged<bool>? onSelectChanged;

  const ToggleIconItem({
    super.key,
    required this.icon,
    required this.selected,
    this.onSelectChanged,
  });

  @override
  State<StatefulWidget> createState() => _ToggleIconItemState();
}

class _ToggleIconItemState extends State<ToggleIconItem> {
  late bool _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  @override
  void didUpdateWidget(covariant ToggleIconItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      setState(() {
        _selected = widget.selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconItem(
      icon: widget.icon,
      selected: _selected,
      onPressed: () {
        setState(() {
          _selected = !_selected;
          widget.onSelectChanged?.call(_selected);
        });
      },
    );
  }
}
