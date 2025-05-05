import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/session_model.dart';

/// A repository class for managing user session data in the database.
class SessionRepository {
  static final SessionRepository _instance = SessionRepository._internal();
  Database? _database;

  /// Factory constructor to return the singleton instance of SessionRepository.
  factory SessionRepository() {
    return _instance;
  }

  /// Internal constructor for singleton pattern.
  SessionRepository._internal();

  /// Getter for the database. Initializes the database if not already initialized.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the database and creates the sessions table if it doesn't exist.
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'sessions.db');
    return openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE sessions('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'courseCode TEXT NOT NULL, '
          'date INTEGER NOT NULL, '
          'wordsAdded INTEGER DEFAULT 0, '
          'wordsReviewed INTEGER DEFAULT 0, '
          'linesRead INTEGER DEFAULT 0, '
          'minutesStudied INTEGER DEFAULT 0, '
          'UNIQUE(courseCode, date)'  // Ensure one session per course per day
          ')',
        );
      },
      version: 1,
    );
  }
    /// Converts a DateTime object to an integer representing the number of days since Unix epoch.
  static int _dateTimeToInt(DateTime date) {
    return DateTime(date.year, date.month, date.day)
        .toUtc()
        .difference(DateTime.utc(1970, 1, 1))
        .inDays;
  }

  /// Gets or creates a session for today for the specified course.
  Future<Session> getOrCreateTodaySession(String courseCode) async {
    final today = _dateTimeToInt(DateTime.now());
    final db = await database;
    
    // Try to find existing session for today
    final List<Map<String, dynamic>> maps = await db.query(
      'sessions',
      where: 'courseCode = ? AND date = ?',
      whereArgs: [courseCode, today],
    );
    
    if (maps.isNotEmpty) {
      return Session.fromMap(maps.first);
    } 
    
    // No session found, create a new one
    final session = Session(courseCode: courseCode);
    await insertSession(session);
    return session;
  }

  /// Inserts a new session into the database.
  Future<void> insertSession(Session session) async {
    final db = await database;
    await db.insert(
      'sessions',
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Updates session statistics for today.
  Future<void> updateSessionStats({
    required String courseCode, 
    int? wordsAdded, 
    int? wordsReviewed, 
    int? linesRead,
    int? minutesStudied,
  }) async {
    final session = await getOrCreateTodaySession(courseCode);
    
    // Update the session with new stats
    if (wordsAdded != null) session.wordsAdded += wordsAdded;
    if (wordsReviewed != null) session.wordsReviewed += wordsReviewed;
    if (linesRead != null) session.linesRead += linesRead;
    if (minutesStudied != null) session.minutesStudied += minutesStudied;
    
    // Save the updated session
    await updateSession(session);
  }

  /// Updates an existing session in the database.
  Future<void> updateSession(Session session) async {
    final db = await database;
    await db.update(
      'sessions',
      session.toMap(),
      where: 'courseCode = ? AND date = ?',
      whereArgs: [session.courseCode, session.date],
    );
  }

  /// Gets all sessions for a specific course.
  Future<List<Session>> getSessionsByCourse(String courseCode) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sessions',
      where: 'courseCode = ?',
      whereArgs: [courseCode],
      orderBy: 'date DESC',
    );
    
    return List.generate(maps.length, (i) => Session.fromMap(maps[i]));
  }

  /// Gets sessions between two dates for a specific course.
  Future<List<Session>> getSessionsInDateRange(
    String courseCode, 
    DateTime startDate, 
    DateTime endDate
  ) async {
    final startDay = _dateTimeToInt(startDate);
    final endDay = _dateTimeToInt(endDate);
    
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sessions',
      where: 'courseCode = ? AND date >= ? AND date <= ?',
      whereArgs: [courseCode, startDay, endDay],
      orderBy: 'date DESC',
    );
    
    return List.generate(maps.length, (i) => Session.fromMap(maps[i]));
  }

  /// Gets weekly statistics for a course.
  Future<Map<String, int>> getWeeklyStats(String courseCode) async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final sessions = await getSessionsInDateRange(
      courseCode,
      weekStart, 
      now,
    );
    
    int totalWordsAdded = 0;
    int totalWordsReviewed = 0;
    int totalLinesRead = 0;
    int totalMinutesStudied = 0;
    
    for (var session in sessions) {
      totalWordsAdded += session.wordsAdded;
      totalWordsReviewed += session.wordsReviewed;
      totalLinesRead += session.linesRead;
      totalMinutesStudied += session.minutesStudied;
    }
    
    return {
      'wordsAdded': totalWordsAdded,
      'wordsReviewed': totalWordsReviewed,
      'linesRead': totalLinesRead,
      'minutesStudied': totalMinutesStudied,
      'daysActive': sessions.length,
    };
  }

  /// Deletes all sessions for a specific course.
  Future<void> deleteSessionsByCourse(String courseCode) async {
    final db = await database;
    await db.delete(
      'sessions',
      where: 'courseCode = ?',
      whereArgs: [courseCode],
    );
  }
}