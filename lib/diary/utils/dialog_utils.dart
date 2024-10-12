import 'package:dribbble/diary/common/test_colors.dart';
import 'package:dribbble/diary/common/test_configuration.dart';
import 'package:dribbble/diary/widgets/card.dart';
import 'package:flutter/material.dart';

class ContentDialog extends StatelessWidget {
  final double? cardHeight;
  final String title;
  final TextStyle titleStyle;
  final double titleMargin;
  final Widget? content;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const ContentDialog({
    super.key,
    this.cardHeight,
    required this.title,
    this.titleStyle = const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    this.titleMargin = 16.0,
    this.content,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      content: OffsetCard(
        offset: const Offset(6, 6),
        cardHeight: cardHeight,
        decoration: BoxDecoration(
          color: TestColors.third,
          border: Border.all(color: TestColors.black1, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: TestColors.black1, width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: TestConfiguration.dialogPadding),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: TestConfiguration.dialogPadding),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: titleMargin),
              if (content != null) ...[
                content!,
                const SizedBox(height: 16),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: TestConfiguration.dialogPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Material(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: InkWell(
                        onTap: onCancel ?? () => Navigator.of(context).pop(-1),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: TestColors.grey1, width: 1),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            child: Text(
                              cancelText ?? 'Cancel',
                              style: const TextStyle(
                                color: TestColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Material(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      color: TestColors.second,
                      child: InkWell(
                        onTap: onConfirm ?? () => Navigator.of(context).pop(1),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: TestColors.black1, width: 1),
                          ),
                          child: Text(
                            confirmText ?? 'Confirm',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}

abstract class DialogUtils {
  static void showToast(BuildContext context, String message, {Duration duration = const Duration(seconds: 1)}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      content: Text(message),
      duration: duration,
    ));
  }

  static showConfirmContentDialog(
    BuildContext context, {
    required String title,
    Widget? content,
    String? confirmText,
    String? cancelText,
    double? cardHeight,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ContentDialog(
        cardHeight: cardHeight,
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
      ),
    );
  }

  static showConfirmDialog(
    BuildContext context, {
    required String title,
    String? content,
    String? confirmText,
    String? cancelText,
  }) {
    return showConfirmContentDialog(
      context,
      title: title,
      content: content != null
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: TestConfiguration.dialogPadding),
              child: Text(content, style: const TextStyle(fontSize: 16)))
          : null,
      confirmText: confirmText,
      cancelText: cancelText,
    );
  }

  static OverlayEntry getContextMenuOverlay(
    BuildContext context, {
    required int itemCount,
    required Widget Function(BuildContext context, int i) itemBuilder,
    required double menuHeight,
    required double menuWidth,
    required GestureTapCallback hideContextMenu,
    double gap = 10,
    Offset? position,
  }) {
    double top;
    double left;
    bool isFromTop;
    bool isFromLeft;
    final renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    if (position != null) {
      isFromTop = position.dy + menuHeight + gap < MediaQuery.of(context).size.height;
      isFromLeft = position.dx + menuWidth + gap < MediaQuery.of(context).size.width;
      top = isFromTop ? position.dy : position.dy - menuHeight;
      left = isFromLeft ? position.dx : position.dx - menuWidth;
    } else {
      isFromTop = offset.dy + renderBox.size.height + menuHeight + gap < MediaQuery.of(context).size.height;
      isFromLeft = offset.dx + renderBox.size.width / 2 + menuWidth + gap < MediaQuery.of(context).size.width;

      top = isFromTop ? offset.dy + renderBox.size.height - 10 : offset.dy - menuHeight + gap;
      left = offset.dx + (isFromLeft ? renderBox.size.width / 2 : -menuWidth + renderBox.size.width / 2);
    }

    return OverlayEntry(builder: (context) {
      return Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: hideContextMenu,
            ),
          ),
          Positioned(
            top: top,
            left: left,
            // menu动画：从左到右、从上到下
            child: _MenuAnimation(
              isFromTop: isFromTop,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                elevation: 4,
                child: SizedBox(
                  width: menuWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 0; i < itemCount; i++) itemBuilder.call(context, i),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _MenuAnimation extends StatefulWidget {
  final Duration duration = const Duration(milliseconds: 200);
  final Widget child;
  final bool isFromTop;

  const _MenuAnimation({
    this.isFromTop = true,
    required this.child,
  });

  @override
  State<StatefulWidget> createState() => _MenuAnimationState();
}

class _MenuAnimationState extends State<_MenuAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, widget.isFromTop ? -0.1 : 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
