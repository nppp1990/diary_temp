import 'package:dribbble/diary/data/bean/folder.dart';
import 'package:dribbble/diary/data/bean/template.dart';
import 'package:dribbble/diary/data/bean/record.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TestSqliteHelper {
  static final TestSqliteHelper instance = TestSqliteHelper._init();
  static Database? _database;
  static const String _dbName = 'test';

  TestSqliteHelper._init();

  static const String _fieldCreatedTime = 'createdTime';
  static const String _fieldModifiedTime = 'modifiedTime';

  ///  [Template] table fields
  static const String templateTableName = 'template';
  static const String templateId = 'id';
  static const String templateName = 'name';
  static const String templateDesc = 'desc';
  static const String templateData = 'data';
  static const String templateBackgroundColor = 'backgroundColor';
  static const String templateBackgroundImage = 'backgroundImage';

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB(_dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  static const _idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
  static const _textTypeNotNull = 'TEXT NOT NULL';
  static const _textType = 'TEXT';
  static const _intTypeNotNull = 'INTEGER NOT NULL';
  static const _intType = 'INTEGER';

  Future _createDB(Database db, int version) async {
    print('-------createDB');
    await db.execute('''
      CREATE TABLE $templateTableName (
        $templateId $_idType,
        $templateName $_textTypeNotNull,
        $templateDesc $_textType,
        $templateData $_textTypeNotNull,
        $templateBackgroundColor $_textType,
        $templateBackgroundImage $_textType
      )
    ''');
    await db.execute('''
      CREATE TABLE ${RecordManager.recordTableName} (
        ${RecordManager.recordId} $_idType,
        ${RecordManager.recordType} $_intTypeNotNull,
        ${RecordManager.recordTime} $_intTypeNotNull,
        ${RecordManager.recordContent} $_textType,
        ${RecordManager.recordMood} $_intType,
        ${RecordManager.recordMoodForAllDay} $_intType,
        ${RecordManager.recordBackgroundColor} $_textType,
        ${RecordManager.recordBackgroundImage} $_textType
      )
    ''');

    await db.execute('''
      CREATE TABLE ${FolderManager.folderTableName} (
        ${FolderManager.folderId} $_idType,
        ${FolderManager.folderName} $_textTypeNotNull UNIQUE,
        ${FolderManager.folderDiaryCount} $_intTypeNotNull,
        ${FolderManager.folderBackgroundImage} $_textType,
        ${FolderManager.folderBackgroundColor} $_textType
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // if (oldVersion == 1 && newVersion == 2) {
    //   await db.execute('''
    //     ALTER TABLE ${RecordManager.recordTableName}
    //     ADD COLUMN ${RecordManager.recordBackgroundColor} $_textType
    //   ''');
    //   await db.execute('''
    //     ALTER TABLE ${RecordManager.recordTableName}
    //     ADD COLUMN ${RecordManager.recordBackgroundImage} $_textType
    //   ''');
    // }
  }

  Future<List<Template>> getAllTemplates() async {
    final db = await instance.database;
    final result = await db.query(templateTableName);
    return result.map((json) => Template.fromMap(json)).toList();
  }

  Future<int> insertTemplate(Template template) async {
    try {
      final db = await instance.database;
      final id = await db.insert(templateTableName, template.toMap());
      return id;
    } catch (e) {
      return -1;
    }
  }

  Future<int> deleteTemplate(int id) async {
    final db = await instance.database;
    try {
      return await db.delete(
        templateTableName,
        where: '${TestSqliteHelper.templateId} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      return -1;
    }
  }

  Future<int> updateTemplate(Template template) async {
    final db = await instance.database;
    return db.update(
      templateTableName,
      template.toMap(),
      where: '${TestSqliteHelper.templateId} = ?',
      whereArgs: [template.id],
    );
  }
}

class RecordManager {
  /// [DiaryRecord] table fields
  static const String recordTableName = 'record';
  static const String recordId = 'id';
  static const String recordFolderId = 'folderId';
  static const String recordTagIds = 'tagIds';
  static const String recordType = 'type';
  static const String recordTime = 'time';
  static const String recordContent = 'content';
  static const String recordMood = 'mood';
  static const String recordMoodForAllDay = 'moodForAllDay';
  static const String recordBackgroundColor = 'backgroundColor';
  static const String recordBackgroundImage = 'backgroundImage';

  Future<List<DiaryRecord>> getAllRecord() async {
    print('-------getAllRecord');
    final db = await TestSqliteHelper.instance.database;
    try {
      // 按时间倒序
      final result = await db.query(recordTableName, orderBy: '$recordTime DESC');
      print('getAllRecord: $result');
      return result.map((json) => DiaryRecord.fromMap(json)).toList();
    } catch (e) {
      print(StackTrace.current.toString());
      print('getAllRecord error: $e');
      return [];
    }
  }

  Future<List<DiaryRecord>> queryRecordByTags(List<int> tagIds) async {
    final db = await TestSqliteHelper.instance.database;
    // 查询所有包含tagIds的记录：例如tagIds=[1,2]，则查询tagIds包含1和2的记录 数据库中recordTagIds = '1,2,3'
    try {
      final result = await db.query(
        recordTableName,
        where: '$recordTagIds LIKE ?',
        whereArgs: ['%${tagIds.join(',')}%'],
        orderBy: '$recordTime DESC',
      );
      return result.map((json) => DiaryRecord.fromMap(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<DiaryRecord>> queryRecordByFolder(int foldId) async {
    final db = await TestSqliteHelper.instance.database;
    try {
      final result = await db.query(
        recordTableName,
        where: '$recordFolderId = ?',
        whereArgs: [foldId],
        orderBy: '$recordTime DESC',
      );
      return result.map((json) => DiaryRecord.fromMap(json)).toList();
    } catch (e) {
      return [];
    }
  }


  Future<int> updateRecord(DiaryRecord record) async {
    final db = await TestSqliteHelper.instance.database;
    try {
      return db.update(
        recordTableName,
        record.toMap(),
        where: '$recordId = ?',
        whereArgs: [record.id],
      );
    } catch (e) {
      return -1;
    }
  }

  Future<int> insertRecord(DiaryRecord record) async {
    print('-------insertRecord');
    try {
      final db = await TestSqliteHelper.instance.database;
      final id = await db.insert(recordTableName, record.toMap());
      return id;
    } catch (e) {
      return -1;
    }
  }

  Future<int> deleteRecord(int? id) async {
    if (id == null) {
      return -1;
    }
    final db = await TestSqliteHelper.instance.database;
    try {
      return await db.delete(
        recordTableName,
        where: '$recordId = ?',
        whereArgs: [id],
      );
    } catch (e) {
      return -1;
    }
  }
}

class FolderManager {
  /// [Folder] table fields
  static const String folderTableName = 'folder';
  static const String folderId = 'id';
  static const String folderName = 'name';
  static const String folderDiaryCount = 'diaryCount';
  static const String folderBackgroundImage = 'backgroundImage';
  static const String folderBackgroundColor = 'backgroundColor';

  Future<List<Folder>> getAllFolders() async {
    final db = await TestSqliteHelper.instance.database;
    final result = await db.query(folderTableName);
    return result.map((json) => Folder.fromMap(json)).toList();
  }

  Future<int> insertFolder(Folder folder) async {
    try {
      final db = await TestSqliteHelper.instance.database;
      final id = await db.insert(folderTableName, folder.toMap());
      return id;
    } catch (e) {
      return -1;
    }
  }

  Future<int> deleteFolder(int? id) async {
    if (id == null) {
      return -1;
    }
    final db = await TestSqliteHelper.instance.database;
    try {
      return await db.delete(
        folderTableName,
        where: '${FolderManager.folderId} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      return -1;
    }
  }

  Future<int> updateFolder(Folder folder) async {
    final db = await TestSqliteHelper.instance.database;
    return db.update(
      folderTableName,
      folder.toMap(),
      where: '${FolderManager.folderId} = ?',
      whereArgs: [folder.id],
    );
  }

}
