import 'package:lenski/data/archive_repository.dart';
import 'package:lenski/data/book_repository.dart';
import 'package:lenski/data/card_repository.dart';
import 'package:lenski/data/session_repository.dart';
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
    // Path for the database
    String path = join(await getDatabasesPath(), 'lenski.db');
    
    // Create or open the database
    return await openDatabase(
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
          'totalGoal INTEGER DEFAULT 10000, '
          'visible INTEGER DEFAULT 1, '
          'goalType TEXT DEFAULT "learn", '
          'goalComplete INTEGER DEFAULT 0'
          ')',
        );
      },
      version: 4,
    );
  }

  /// Inserts a new course into the database.
  /// 
  /// If the course already exists, it updates specific fields and makes it visible again.
  /// 
  /// [course] is the course to be inserted.
  Future<void> insertCourse(Course course) async {
    final db = await database;
    
    // Check if course already exists
    final List<Map<String, dynamic>> existingCourses = await db.query(
      'courses',
      where: 'code = ?',
      whereArgs: [course.code],
    );
    
    if (existingCourses.isNotEmpty) {
      // Course exists, update specific fields and make visible
      final existingCourse = Course.fromMap(existingCourses.first);
      final updatedCourse = existingCourse.copyWith(
        fromCode: course.fromCode,
        listening: course.listening,
        speaking: course.speaking,
        reading: course.reading,
        writing: course.writing,
        dailyGoal: course.dailyGoal,
        totalGoal: course.totalGoal,
        goalType: course.goalType,
        visible: true,
      );
      
      await updateCourse(updatedCourse);
    } else {
      // New course, insert it
      await db.insert(
        'courses',
        course.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
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

  /// Retrieves all visible courses and checks their streaks
  Future<List<Course>> courses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'courses',
      where: 'visible = ?',
      whereArgs: [1],
    );
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

  /// Deletes a course from the database along with all associated data.
  /// 
  /// This includes:
  /// - All flashcards for the language
  /// - All books for the language
  /// - All session data for the course
  /// - The course record itself
  /// 
  /// [code] is the language code of the course to be deleted.
  Future<void> deleteCourse(String code) async {
    // Get references to other repositories
    final cardRepository = CardRepository();
    final bookRepository = BookRepository();
    final archiveRepository = ArchiveRepository();
    final sessionRepository = SessionRepository();
    
    try {
      // 1. Delete all sessions for this course
      await sessionRepository.deleteSessionsByCourse(code);
      
      // 2. Delete all cards for this language
      final db = await cardRepository.database;
      await db.delete(
        'cards',
        where: 'language = ?',
        whereArgs: [code],
      );
      
      // 3. Delete all books for this language
      // First get all books for this language
      final books = await bookRepository.booksByLanguage(code);
      
      // Delete each book (this will also delete associated book databases)
      for (var book in books) {
        if (book.id != null) {
          await bookRepository.deleteBook(book.id!);
        }
      }
      
      // Also delete any archived books for this language
      final archiveDb = await bookRepository.database;
      await archiveDb.delete(
        'archived_books',
        where: 'language = ?',
        whereArgs: [code],
      );
      
      // 4. Finally, delete the course itself
      final courseDb = await database;
      await courseDb.delete(
        'courses',
        where: 'code = ?',
        whereArgs: [code],
      );
      
    } catch (e) {
      // Handle any errors
      print('Error deleting course: $e');
      throw Exception('Failed to delete course: $e');
    }
  }

  /// Makes a course invisible instead of completely deleting it.
  /// This allows the course to be restored later while hiding it from the main screen.
  /// 
  /// [code] is the language code of the course to be made invisible.
  Future<void> makeInvisible(String code) async {
    final db = await database;
    
    try {
      // Find the course first
      final List<Map<String, dynamic>> maps = await db.query(
        'courses',
        where: 'code = ?',
        whereArgs: [code],
      );
      
      if (maps.isNotEmpty) {
        
        // Update only the visible field in the database
        await db.update(
          'courses',
          {'visible': 0},
          where: 'code = ?',
          whereArgs: [code],
        );
      }
    } catch (e) {
      // Handle any errors
      print('Error making course invisible: $e');
      throw Exception('Failed to make course invisible');
    }
  }
}