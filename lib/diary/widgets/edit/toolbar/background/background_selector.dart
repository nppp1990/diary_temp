import 'package:dribbble/diary/common/test_colors.dart';
import 'package:dribbble/diary/common/test_configuration.dart';
import 'package:dribbble/diary/widgets/bg_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BackgroundSelector extends StatefulWidget {
  final double height;
  final BackgroundInfo? backgroundInfo;
  final ValueChanged<BackgroundInfo?>? onBackgroundChanged;
  final EdgeInsetsGeometry padding;

  const BackgroundSelector({
    super.key,
    this.height = 400,
    this.padding = const EdgeInsets.all(TestConfiguration.dialogPadding),
    this.backgroundInfo,
    required this.onBackgroundChanged,
  });

  @override
  State<StatefulWidget> createState() => _BackgroundSelectorState();
}

final List<BackgroundInfo?> _backgroundList = [
  null,
  const BackgroundInfo(backgroundColor: Color(0xFFF8F8F8)),
  const BackgroundInfo(backgroundColor: Color(0xFFFCEDE1)),
  const BackgroundInfo(backgroundColor: Color(0xFFE4F7F6)),
  const BackgroundInfo(backgroundColor: Color(0xFFFDEEFB)),
  const BackgroundInfo(backgroundColor: Color(0xFFD8E6E8)),
  const BackgroundInfo(backgroundColor: Color(0xFFCACFCA)),
  const BackgroundInfo(backgroundColor: Color(0xFFEEFEE4)),
  const BackgroundInfo(backgroundColor: Color(0xFF395C78)),
  const BackgroundInfo(backgroundColor: Color(0xFF4CA477)),
  const BackgroundInfo(assetImage: AssetImage('assets/images/bg_base1.png')),
  const BackgroundInfo(assetImage: AssetImage('assets/images/bg_base2.png')),
  const BackgroundInfo(assetImage: AssetImage('assets/images/bg_test1.jpg')),
  const BackgroundInfo(assetImage: AssetImage('assets/images/bg_test2.jpg')),
  const BackgroundInfo(assetImage: AssetImage('assets/images/bg_test3.jpeg')),
];

class _BackgroundSelectorState extends State<BackgroundSelector> {
  BackgroundInfo? _selectedBackground;

  @override
  void initState() {
    super.initState();
    _selectedBackground = widget.backgroundInfo;
    // _selectedBackground = widget.controller.backgroundInfo.value;
  }

  @override
  void didUpdateWidget(covariant BackgroundSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.backgroundInfo != oldWidget.backgroundInfo) {
      _selectedBackground = widget.backgroundInfo;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: Padding(
          padding: widget.padding,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 6, // 水平间距
              mainAxisSpacing: 6, // 垂直间距
              childAspectRatio: 0.6, // 宽高比
            ),
            shrinkWrap: true,
            itemCount: _backgroundList.length,
            itemBuilder: (context, index) {
              final BackgroundInfo? info = _backgroundList[index];
              final bool isSelected = info == _selectedBackground;
              Widget child;
              if (info == null) {
                child = Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: isSelected
                        ? Border.all(color: TestColors.primary, width: 2)
                        : Border.all(color: TestColors.greyDivider2, width: 1),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/ic_stop.svg',
                      colorFilter: const ColorFilter.mode(TestColors.greyDivider2, BlendMode.srcIn),
                      width: 30,
                      height: 30,
                    ),
                  ),
                );
              } else if (info.isColor) {
                child = Container(
                  decoration: BoxDecoration(
                    color: info.backgroundColor,
                    borderRadius: BorderRadius.circular(6),
                    border: isSelected ? Border.all(color: TestColors.primary, width: 2) : null,
                  ),
                );
              } else {
                child = Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: info.assetImage!,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(6),
                    border: isSelected ? Border.all(color: TestColors.primary, width: 2) : null,
                  ),
                );
              }
              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  setState(() {
                    _selectedBackground = info;
                  });
                  widget.onBackgroundChanged?.call(info);
                },
                child: child,
              );
            },
          ),
        ),
      ),
    );
  }
}
