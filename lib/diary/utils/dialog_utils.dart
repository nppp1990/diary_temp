import 'dart:ui';

import 'package:dribbble/diary/button1.dart';
import 'package:dribbble/diary/common/test_colors.dart';
import 'package:dribbble/diary/common/test_configuration.dart';
import 'package:dribbble/diary/widgets/card.dart';
import 'package:flutter/material.dart';

abstract class DialogUtils {
  static showConfirmDialog(BuildContext context, String title, String content, VoidCallback onConfirm) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: OffsetCard(
          // cardHeight: 300,
          offset: const Offset(6, 6),
          decoration: BoxDecoration(
            color: TestColors.third,
            border: Border.all(color: TestColors.black1, width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: double.infinity,
            // height: 300,
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
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(child: Text(content, style: const TextStyle(fontSize: 16))),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: TestColors.grey1, width: 1),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              child: Text(
                                '取消',
                                style: TextStyle(
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
                            Navigator.of(context).pop();
                            onConfirm();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: TestColors.second,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: TestColors.black1, width: 1),
                            ),
                            child: const Text(
                              '确定',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        // TextButton(
                        //   onPressed: () {
                        //     Navigator.of(context).pop();
                        //     onConfirm();
                        //   },
                        //   child: const Text('确定'),
                        // ),
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
