import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../../models/course_model.dart';

/// A repository class for managing courses in the database.
class CourseRepository {
  static final CourseRepository _instance = CourseRepository._internal();
  Database? _database;

  /// Factory constructor to return the singleton instance of CourseRepository.
  factory CourseRepository() {
    return _instance;
  }

  /// Internal constructor for singleton pattern.
  CourseRepository._internal();

  /// Getter for the database. Initializes the database if it is not already initialized.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the database and creates the courses table if it does not exist.
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'courses.db');
    return openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE courses(id INTEGER PRIMARY KEY, name TEXT, level TEXT, code TEXT, fromCode TEXT, listening INTEGER, speaking INTEGER, reading INTEGER, writing INTEGER, color INTEGER, imageUrl TEXT)',
        );
      },
      version: 1,
    );
  }

  /// Inserts a new course into the database.
  /// 
  /// [course] is the course to be inserted.
  Future<void> insertCourse(Course course) async {
    final db = await database;
    await db.insert(
      'courses',
      course.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves all courses from the database.
  /// 
  /// Returns a list of courses.
  Future<List<Course>> courses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('courses');
    return List.generate(maps.length, (i) {
      return Course.fromMap(maps[i]);
    });
  }

  /// Updates an existing course in the database.
  /// 
  /// [course] is the course to be updated.
  Future<void> updateCourse(Course course) async {
    final db = await database;
    await db.update(
      'courses',
      course.toMap(),
      where: 'code = ?',
      whereArgs: [course.code],
    );
  }

  /// Deletes a course from the database.
  /// 
  /// [code] is the language code of the course to be deleted.
  Future<void> deleteCourse(String code) async {
    final db = await database;
    await db.delete(
      'courses',
      where: 'code = ?',
      whereArgs: [code],
    );
  }
}