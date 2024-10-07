import 'package:dribbble/diary/data/bean/record.dart';
import 'package:dribbble/diary/data/sqlite_helper.dart';
import 'package:dribbble/diary/utils/color.dart';
import 'package:flutter/material.dart';

class Folder {
  final int? id;
  final String name;
  final int diaryCount;
  final String? backgroundImage;
  final Color? backgroundColor;

  Folder({
    this.id,
    required this.name,
    required this.diaryCount,
    this.backgroundImage,
    this.backgroundColor,
  });

  Map<String, dynamic> toMap() {
    return {
      FolderManager.folderId: id,
      FolderManager.folderName: name,
      FolderManager.folderDiaryCount: diaryCount,
      FolderManager.folderBackgroundImage: backgroundImage,
      FolderManager.folderBackgroundColor: ColorUtils.colorToHex(backgroundColor),
    };
  }

  static Folder fromMap(Map<String, dynamic> map) {
    return Folder(
      id: map[FolderManager.folderId],
      name: map[FolderManager.folderName],
      diaryCount: map[FolderManager.folderDiaryCount],
      backgroundImage: map[FolderManager.folderBackgroundImage],
      backgroundColor: ColorUtils.hexToColor(map[FolderManager.folderBackgroundColor]),
    );
  }
}

// class FilterFolder extends Folder {
//   List<RecordType> types;
//
// }
