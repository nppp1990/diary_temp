import 'package:dribbble/diary/common/test_colors.dart';
import 'package:dribbble/diary/common/test_configuration.dart';
import 'package:dribbble/diary/widgets/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ToolbarTemplateItem extends StatefulWidget {
  final VoidCallback onTap;

  const ToolbarTemplateItem({super.key, required this.onTap});

  @override
  State<StatefulWidget> createState() => ToolbarTemplateItemState();
}

class ToolbarTemplateItemState extends State<ToolbarTemplateItem> {
  bool _showBubble = false;
  final OverlayPortalController _controller = OverlayPortalController();

  showBubbleDialog(bool show) {
    if (show == _showBubble) {
      return;
    }
    print('----show bubble dialog');
    if (show) {
      _controller.show();
      setState(() {
        _showBubble = show;
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _controller.isShowing) {
          _controller.hide();
          setState(() {
            _showBubble = false;
          });
        }
      });
    } else {
      _controller.hide();
      setState(() {
        _showBubble = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        showBubbleDialog(false);
        widget.onTap();
      },
      child: OverlayPortal(
        controller: _controller,
        overlayChildBuilder: (overlayContext) {
          final renderBox = context.findRenderObject() as RenderBox;
          final Offset offset = renderBox.localToGlobal(Offset.zero);
          return Positioned(
            top: offset.dy - 48 - 5,
            left: offset.dx - 15 + renderBox.size.width / 2,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                showBubbleDialog(false);
                widget.onTap();
              },
              child: const TemplateTipBubble(triangleOffset: 15),
            ),
          );
        },
        child: SvgPicture.asset(
          'assets/icons/ic_template.svg',
          width: TestConfiguration.toolBarIconSize,
          height: TestConfiguration.toolBarIconSize,
          colorFilter: ColorFilter.mode(_showBubble ? TestColors.primary : TestColors.black1, BlendMode.srcIn),
        ),
      ),
    );
  }
}

class TemplateTipBubble extends StatelessWidget {
  final double triangleOffset;

  const TemplateTipBubble({super.key, required this.triangleOffset});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 1000),
      opacity: 1,
      child: BubbleBorder(
          direction: TriangleDirection.bottomStart,
          triangleOffset: triangleOffset,
          triangleWidth: 8,
          triangleHeight: 8,
          borderRadius: 4,
          strokeWidth: 1,
          strokeColor: TestColors.primary,
          fillColor: const Color(0xFFECEAED).withOpacity(0.5),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            height: 40,
            child: const Center(
              child: Text(
                'try template?',
                style: TextStyle(
                  color: TestColors.primary,
                  fontSize: 14,
                ),
              ),
            ),
          )),
    );
  }
}
