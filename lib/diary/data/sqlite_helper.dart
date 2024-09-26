import 'package:dribbble/diary/data/bean/template.dart';
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
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  static const _idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
  static const _textTypeNotNull = 'TEXT NOT NULL';
  static const _textType = 'TEXT';

  Future _createDB(Database db, int version) async {
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
  }

  Future<List<Template>> getAllTemplates() async {
    final db = await instance.database;
    final result = await db.query(templateTableName);
    return result.map((json) => Template.fromMap(json)).toList();
  }

  Future<int> createTemplate(Template template) async {
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
