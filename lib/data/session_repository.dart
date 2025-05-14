import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/session_model.dart';
import '../data/course_repository.dart';

/// A repository class for managing user session data in the database.
class SessionRepository {
  static final SessionRepository _instance = SessionRepository._internal();
  Database? _database;
  final CourseRepository _courseRepository = CourseRepository();

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
          'cardsDeleted INTEGER DEFAULT 0, '
          'streakIncremented INTEGER DEFAULT 0, '
          'UNIQUE(courseCode, date)'
          ')',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Add cardsDeleted column if upgrading from version 1
          await db.execute('ALTER TABLE sessions ADD COLUMN cardsDeleted INTEGER DEFAULT 0');
        }
      },
      version: 2, // Increment the version number
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

  /// Updates session statistics for today and checks if daily goal is met.
  Future<void> updateSessionStats({
    required String courseCode, 
    int? wordsAdded, 
    int? wordsReviewed, 
    int? linesRead,
    int? minutesStudied,
    int? cardsDeleted,
  }) async {
    final session = await getOrCreateTodaySession(courseCode);
    
    // Update the session with new stats
    if (wordsAdded != null) session.wordsAdded += wordsAdded;
    if (wordsReviewed != null) session.wordsReviewed += wordsReviewed;
    if (linesRead != null) session.linesRead += linesRead;
    if (minutesStudied != null) session.minutesStudied += minutesStudied;
    if (cardsDeleted != null) session.cardsDeleted += cardsDeleted;
    
    // Save the updated session
    await updateSession(session);
    
    // Always check if any goal is met when stats are updated
    await _checkAndUpdateStreak(courseCode, session);
  }

  /// Checks if goal is met based on course goal type and updates streak if needed.
  Future<void> _checkAndUpdateStreak(String courseCode, Session session) async {
    final db = await database;
    final today = _dateTimeToInt(DateTime.now());
    
    // Check if streak was already incremented today
    final List<Map<String, dynamic>> sessionMaps = await db.query(
      'sessions',
      columns: ['streakIncremented'],
      where: 'courseCode = ? AND date = ?',
      whereArgs: [courseCode, today],
    );
    
    // If streak was already incremented today, exit early
    if (sessionMaps.isNotEmpty && sessionMaps.first['streakIncremented'] == 1) {
      return;
    }
    
    // Get the course to check goal and potentially update streak
    final course = await _courseRepository.getCourse(courseCode);
    
    // Check if daily goal is met based on the course's goal type
    bool isDailyGoalMet = false;
    
    switch (course.goalType) {
      case 'learn':
        isDailyGoalMet = session.wordsAdded >= course.dailyGoal;
        break;
      case 'daily':
        // For daily type, any activity counts as meeting the goal
        // Explicitly EXCLUDING cardsDeleted from this check as specified
        isDailyGoalMet = session.wordsAdded > 0 || 
                    session.wordsReviewed > 0 || 
                    session.linesRead > 0 ||
                    session.minutesStudied > 0;
        break;
      case 'time':
        isDailyGoalMet = session.minutesStudied >= course.dailyGoal;
        break;
      default:
        // Default to 'learn' behavior
        isDailyGoalMet = session.wordsAdded >= course.dailyGoal;
    }
    
    // If daily goal is met, increment streak and mark as incremented
    if (isDailyGoalMet) {
      await _courseRepository.incrementStreak(course);
      
      // Mark streak as incremented for today
      await db.update(
        'sessions',
        {'streakIncremented': 1},
        where: 'courseCode = ? AND date = ?',
        whereArgs: [courseCode, today],
      );
    }
    
    // Check if the total goal has been met (course completion)
    final sessions = await getSessionsByCourse(courseCode);
    bool isCourseGoalComplete = false;
    
    switch (course.goalType) {
      case 'learn':
        // Calculate total words and deleted cards
        int words = 0;
        int deleted = 0;
        for (var s in sessions) {
          words += s.wordsAdded;
          deleted += s.cardsDeleted;
        }
        
        // Calculate number of active competences
        int activeCompetences = 0;
        if (course.reading) activeCompetences++;
        if (course.writing) activeCompetences++;
        if (course.speaking) activeCompetences++;
        if (course.listening) activeCompetences++;
        
        // Ensure we don't divide by zero
        activeCompetences = activeCompetences > 0 ? activeCompetences : 1;
        
        // Calculate adjusted words added
        int adjustedWords = words - (deleted * (1 / activeCompetences)).floor();
        
        // Ensure we don't go negative
        adjustedWords = adjustedWords > 0 ? adjustedWords : 0;
        
        isCourseGoalComplete = adjustedWords >= course.totalGoal;
        break;
        
      case 'daily':
        // Count unique days with any activity
        final Set<int> daysWithActivity = {};
        for (var s in sessions) {
          if (s.wordsAdded > 0 || 
              s.wordsReviewed > 0 || 
              s.linesRead > 0 ||
              s.minutesStudied > 0) {
            daysWithActivity.add(s.date);
          }
        }
        isCourseGoalComplete = daysWithActivity.length >= course.totalGoal;
        break;
        
      case 'time':
        // Sum up all minutes studied
        int totalMinutes = 0;
        for (var s in sessions) {
          totalMinutes += s.minutesStudied;
        }
        isCourseGoalComplete = totalMinutes >= course.totalGoal;
        break;
        
      default:
        // Default to 'learn' behavior
        int words = 0;
        int deleted = 0;
        for (var s in sessions) {
          words += s.wordsAdded;
          deleted += s.cardsDeleted;
        }
        
        int activeCompetences = 0;
        if (course.reading) activeCompetences++;
        if (course.writing) activeCompetences++;
        if (course.speaking) activeCompetences++;
        if (course.listening) activeCompetences++;
        
        activeCompetences = activeCompetences > 0 ? activeCompetences : 1;
        
        int adjustedWords = words - (deleted * (1 / activeCompetences)).floor();
        adjustedWords = adjustedWords > 0 ? adjustedWords : 0;
        
        isCourseGoalComplete = adjustedWords >= course.totalGoal;
    }
    
    // Update the course's goalComplete status if needed
    if (isCourseGoalComplete != course.goalComplete) {
      course.goalComplete = isCourseGoalComplete;
      await _courseRepository.updateCourse(course);
    }
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
    int totalCardsDeleted = 0;
    
    for (var session in sessions) {
      totalWordsAdded += session.wordsAdded;
      totalWordsReviewed += session.wordsReviewed;
      totalLinesRead += session.linesRead;
      totalMinutesStudied += session.minutesStudied;
      totalCardsDeleted += session.cardsDeleted;
    }
    
    return {
      'wordsAdded': totalWordsAdded,
      'wordsReviewed': totalWordsReviewed,
      'linesRead': totalLinesRead,
      'minutesStudied': totalMinutesStudied,
      'cardsDeleted': totalCardsDeleted,
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