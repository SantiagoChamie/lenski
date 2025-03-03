import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/course_model.dart';

class CourseRepository {
  static final CourseRepository _instance = CourseRepository._internal();
  Database? _database;

  factory CourseRepository() {
    return _instance;
  }

  CourseRepository._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'courses.db');
    return openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE courses(id INTEGER PRIMARY KEY, name TEXT, level TEXT, code TEXT, listening INTEGER, speaking INTEGER, reading INTEGER, writing INTEGER, color INTEGER, imageUrl TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> insertCourse(Course course) async {
    final db = await database;
    await db.insert(
      'courses',
      course.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Course>> courses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('courses');
    return List.generate(maps.length, (i) {
      return Course.fromMap(maps[i]);
    });
  }

  Future<void> updateCourse(Course course) async {
    final db = await database;
    await db.update(
      'courses',
      course.toMap(),
      where: 'id = ?',
      whereArgs: [course.id],
    );
  }

  Future<void> deleteCourse(int id) async {
    final db = await database;
    await db.delete(
      'courses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}