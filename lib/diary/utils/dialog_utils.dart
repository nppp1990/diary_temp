import 'dart:ui';

import 'package:dribbble/diary/button1.dart';
import 'package:dribbble/diary/common/test_colors.dart';
import 'package:dribbble/diary/common/test_configuration.dart';
import 'package:dribbble/diary/widgets/card.dart';
import 'package:flutter/material.dart';

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

  static showConfirmDialog(BuildContext context, {
    required String title,
    String? content,
    String? confirmText,
    String? cancelText,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: OffsetCard(
          offset: const Offset(6, 6),
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
              padding: const EdgeInsets.all(TestConfiguration.dialogPadding),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (content != null)
                     ...[
                       Expanded(child: Text(content, style: const TextStyle(fontSize: 16))),
                       const SizedBox(height: 16),
                     ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pop(-1);
                          },
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
                          onTap: () {
                            Navigator.of(context).pop(1);
                          },
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
                  ]),
            ),
          ),
        ),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
