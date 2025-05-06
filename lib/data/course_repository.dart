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
          'CREATE TABLE courses('
          'id INTEGER PRIMARY KEY, '
          'name TEXT, '
          'level TEXT, '
          'code TEXT, '
          'fromCode TEXT, '
          'listening INTEGER, '
          'speaking INTEGER, '
          'reading INTEGER, '
          'writing INTEGER, '
          'color INTEGER, '
          'imageUrl TEXT, '
          'streak INTEGER DEFAULT 0, '
          'lastAccess INTEGER DEFAULT 0, '
          'dailyGoal INTEGER DEFAULT 100, '
          'totalGoal INTEGER DEFAULT 10000'
          ')',
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

  /// Checks and resets streak if more than one day has passed since last access
  Future<void> checkStreak(Course course) async {
    final todayDays = _dateTimeToInt(DateTime.now());
    
    if (todayDays - course.lastAccess > 1) {
      // Streak broken - more than one day has passed
      course.streak = 0;
      await updateCourse(course);
    }
  }

  /// Increments streak if accessing on a different day than last access
  Future<void> incrementStreak(Course course) async {
    final todayDays = _dateTimeToInt(DateTime.now());
    
    if (todayDays > course.lastAccess) {
      // New day, increment streak
      course.streak++;
      course.lastAccess = todayDays;
      await updateCourse(course);
    }
  }
  
  /// Checks if the course was accessed today
  Future<bool> wasAccessedToday(Course course) async {
    final todayDays = _dateTimeToInt(DateTime.now());
    return course.lastAccess == todayDays;
  }

  Future<Course> getCourse(String code) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'courses',
      where: 'code = ?',
      whereArgs: [code],
    );
    
    if (maps.isNotEmpty) {
      final course = Course.fromMap(maps.first);
      checkStreak(course); // Check for streak breaks
      return course;
    } else {
      throw Exception('Course not found');
    }
  }

  /// Retrieves all courses and checks their streaks
  Future<List<Course>> courses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('courses');
    final List<Course> courseList = List.generate(maps.length, (i) {
      final course = Course.fromMap(maps[i]);
      checkStreak(course); // Only check for streak breaks
      return course;
    });
    
    return courseList;
  }

  /// Helper method to convert DateTime to days since epoch
  static int _dateTimeToInt(DateTime date) {
    return _startOfDay(date).toUtc().difference(DateTime.utc(1970, 1, 1)).inDays;
  }

  /// Helper method to get the start of the day for a given DateTime
  static DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
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