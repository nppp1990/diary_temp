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
                    InkWell(
                      onTap: onCancel ?? () => Navigator.of(context).pop(-1),
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
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: onConfirm ?? () => Navigator.of(context).pop(1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: TestColors.second,
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
              child: Expanded(
                child: Text(content, style: const TextStyle(fontSize: 16)),
              ))
          : null,
      confirmText: confirmText,
      cancelText: cancelText,
    );
  }
}
