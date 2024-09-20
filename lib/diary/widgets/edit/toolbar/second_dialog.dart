import 'package:dribbble/diary/common/test_colors.dart';
import 'package:dribbble/diary/common/test_configuration.dart';
import 'package:dribbble/diary/widgets/edit/edit_demo3.dart';
import 'package:dribbble/diary/widgets/icon/arrow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

abstract class Test {
  static void showSecondDialog(BuildContext context, Widget child) {
    showDialog(
      context: context,
      builder: (context) => SecondDialog(
        title: 'Title',
        child: child,
      ),
    );
  }
}

/// 位于底部，用于展示toolbar子项的对话框
/// 动画效果：从右边滑入
/// 假dialog：没有蒙层效果，但是要求点击dialog外部时，dialog消失，并且拦截返回键
class SecondDialog extends StatefulWidget {
  final String title;
  final Widget child;
  final VoidCallback? onDismiss;

  const SecondDialog({super.key, required this.title, required this.child, this.onDismiss});

  @override
  State<StatefulWidget> createState() => _SecondDialogState();
}

class _SecondDialogState extends State<SecondDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1, end: 0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _handlePop(BuildContext context) async {
    _controller.reverse();
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!context.mounted) {
      return;
    }
    // ToolBarDialogProvider.of(context).hideDialog();
    widget.onDismiss?.call();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        _handlePop(context);
      },
      child: Container(
        color: Colors.transparent,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  _handlePop(context);
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: FractionalTranslation(
                translation: Offset(_animation.value, 0),
                child: Container(
                  width: double.infinity,
                  // height: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x33000000),
                        offset: Offset(0, -2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: TestConfiguration.dialogPadding),
                      SizedBox(
                        height: 36,
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: TestConfiguration.dialogPadding),
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    widget.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: GestureDetector(
                                    onTap: () {
                                      _handlePop(context);
                                    },
                                    child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: TestColors.second,
                                          borderRadius: BorderRadius.circular(8),
                                          border: const Border.fromBorderSide(
                                              BorderSide(color: TestColors.black1, width: 2)),
                                        ),
                                        child: const Center(
                                          child: LeftArrow(
                                            color: TestColors.black1,
                                            strokeWidth: 2,
                                            size: 16,
                                          ),
                                        )),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      _handlePop(context);
                                    },
                                    child: SizedBox(
                                        width: 36,
                                        height: 36,
                                        child: SvgPicture.asset(
                                          'assets/icons/ic_right.svg',
                                          colorFilter: const ColorFilter.mode(TestColors.black1, BlendMode.srcIn),
                                          width: 16,
                                          height: 16,
                                        )),
                                  ),
                                ),
                              ],
                            )),
                      ),
                      widget.child,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
