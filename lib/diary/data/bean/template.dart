import 'dart:convert';
import 'dart:ui';

import 'package:dribbble/diary/data/sqlite_helper.dart';
import 'package:dribbble/diary/utils/color.dart';
import 'package:flutter_quill/quill_delta.dart';

final class Template {
  final int? id;
  final String name;
  final String? desc;
  final String data;
  final Color? backgroundColor;
  final String? backgroundImage;
  String? _content;
  final bool isBuiltIn;

  Template({
    this.id,
    required this.name,
    this.desc,
    required this.data,
    this.backgroundColor,
    this.backgroundImage,
    this.isBuiltIn = false,
  });

  String get content {
    _content ??= _getPlainTextFromJson(data);
    return _content!;
  }

  String _getPlainTextFromJson(String deltaJson) {
    final delta = Delta.fromJson(jsonDecode(deltaJson));
    String allText = '';
    for (final op in delta.operations) {
      if (op.isInsert) {
        allText += op.value;
      }
    }
    return allText;
  }

  Map<String, dynamic> toMap() {
    return {
      TestSqliteHelper.templateId: id,
      TestSqliteHelper.templateName: name,
      TestSqliteHelper.templateDesc: desc,
      TestSqliteHelper.templateData: data,
      TestSqliteHelper.templateBackgroundColor: ColorUtils.colorToHex(backgroundColor),
      TestSqliteHelper.templateBackgroundImage: backgroundImage,
    };
  }

  factory Template.fromMap(Map<String, dynamic> map) {
    return Template(
      id: map[TestSqliteHelper.templateId],
      name: map[TestSqliteHelper.templateName],
      desc: map[TestSqliteHelper.templateDesc],
      data: map[TestSqliteHelper.templateData],
      backgroundColor: ColorUtils.hexToColor(map[TestSqliteHelper.templateBackgroundColor]),
      backgroundImage: map[TestSqliteHelper.templateBackgroundImage],
    );
  }
}
