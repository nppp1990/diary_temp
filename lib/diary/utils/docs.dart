import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/quill_delta.dart';

abstract class DocUtils {

  static double calculateTextHeight({
    required String text,
    required TextStyle style,
    required double maxWidth,
    int? maxLine,
  }) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLine,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    var computeLineMetrics = textPainter.computeLineMetrics();
    if (computeLineMetrics.isEmpty) {
      return 0;
    }
    print('-----computeLineMetrics: $computeLineMetrics');
    print('-----length: ${computeLineMetrics.length}');
    for (var line in computeLineMetrics) {
      print('-----line: $line');
    }
    // get height
    return computeLineMetrics.fold(0, (previousValue, element) => previousValue + element.height);
  }

  static List<LineMetrics> test({
    required String text,
    required TextStyle style,
    required double maxWidth,
  }) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: null,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    return textPainter.computeLineMetrics();
  }

  String getPlainTextFromJson(String deltaJson) {
    final delta = Delta.fromJson(jsonDecode(deltaJson));
    String allText = '';
    for (final op in delta.operations) {
      if (op.isInsert) {
        allText += op.value;
      }
    }
    return allText;
  }

  String getPlainTextFromDelta(Delta delta) {
    String allText = '';
    for (final op in delta.operations) {
      if (op.isInsert) {
        allText += op.value;
      }
    }
    return allText;
  }
}
