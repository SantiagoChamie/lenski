import 'dart:ui';

/// A model class representing a course.
class Course {
  String name;
  String level;
  String code;
  String fromCode;
  bool listening;
  bool speaking;
  bool reading;
  bool writing;
  Color color;
  String imageUrl;
  int streak;
  int lastAccess;
  int dailyGoal; // Daily word reading goal
  int totalGoal; // Total word reading goal
  bool visible; // Whether the course should be visible on the main screen
  String goalType; // Type of goal: 'learn', 'daily', or 'time'

  /// Creates a Course object.
  /// 
  /// [name] is the name of the course.
  /// [level] is the level of the course.
  /// [code] is the language code of the course.
  /// [fromCode] is the language code from which the course is being learned.
  /// [listening] indicates if the course includes listening competence.
  /// [speaking] indicates if the course includes speaking competence.
  /// [reading] indicates if the course includes reading competence.
  /// [writing] indicates if the course includes writing competence.
  /// [color] is the color associated with the course.
  /// [imageUrl] is the URL of the course's image.
  /// [streak] is the current streak count.
  /// [lastAccess] is the last day the course was accessed (stored as days since epoch).
  /// [dailyGoal] is the targeted number of words to read per day.
  /// [totalGoal] is the total number of words goal for the course.
  /// [visible] indicates if the course should be visible on the main screen.
  /// [goalType] indicates the type of goal for this course ('learn', 'daily', or 'time').
  Course({
    required this.name,
    required this.level,
    required this.code,
    required this.fromCode,
    required this.listening,
    required this.speaking,
    required this.reading,
    required this.writing,
    required this.color,
    required this.imageUrl,
    this.streak = 0,
    DateTime? lastAccess,
    required this.dailyGoal,
    required this.totalGoal,
    this.visible = true,
    this.goalType = 'learn', // Default to 'learn'
  }) : lastAccess = _dateTimeToInt(
         lastAccess ?? DateTime.now().subtract(const Duration(days: 1))
       );

  /// Converts a Course object into a Map.
  /// The keys must correspond to the names of the columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'level': level,
      'code': code,
      'fromCode': fromCode,
      'listening': listening ? 1 : 0,
      'speaking': speaking ? 1 : 0,
      'reading': reading ? 1 : 0,
      'writing': writing ? 1 : 0,
      'color': color.toARGB32(),
      'imageUrl': imageUrl,
      'streak': streak,
      'lastAccess': lastAccess,
      'dailyGoal': dailyGoal,
      'totalGoal': totalGoal,
      'visible': visible ? 1 : 0,
      'goalType': goalType,
    };
  }

  /// Extracts a Course object from a Map.
  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      name: map['name'],
      level: map['level'],
      code: map['code'],
      fromCode: map['fromCode'],
      listening: map['listening'] == 1,
      speaking: map['speaking'] == 1,
      reading: map['reading'] == 1,
      writing: map['writing'] == 1,
      color: Color(map['color']),
      imageUrl: map['imageUrl'],
      streak: map['streak'] ?? 0,
      lastAccess: _intToDateTime(map['lastAccess'] ?? _dateTimeToInt(DateTime.now().subtract(const Duration(days: 1)))),
      dailyGoal: map['dailyGoal'],
      totalGoal: map['totalGoal'],
      visible: map['visible'] == null ? true : map['visible'] == 1,
      goalType: map['goalType'] ?? 'learn', // Default to 'learn' if not specified
    );
  }

  /// Creates a copy of the Course object with updated fields.
  Course copyWith({
    String? name,
    String? level,
    String? code,
    String? fromCode,
    bool? listening,
    bool? speaking,
    bool? reading,
    bool? writing,
    Color? color,
    String? imageUrl,
    int? streak,
    DateTime? lastAccess,
    int? dailyGoal,
    int? totalGoal,
    bool? visible,
    String? goalType,
  }) {
    return Course(
      name: name ?? this.name,
      level: level ?? this.level,
      code: code ?? this.code,
      fromCode: fromCode ?? this.fromCode,
      listening: listening ?? this.listening,
      speaking: speaking ?? this.speaking,
      reading: reading ?? this.reading,
      writing: writing ?? this.writing,
      color: color ?? this.color,
      imageUrl: imageUrl ?? this.imageUrl,
      streak: streak ?? this.streak,
      lastAccess: lastAccess ?? _intToDateTime(this.lastAccess),
      dailyGoal: dailyGoal ?? this.dailyGoal,
      totalGoal: totalGoal ?? this.totalGoal,
      visible: visible ?? this.visible,
      goalType: goalType ?? this.goalType,
    );
  }

  /// Converts a DateTime object to an integer representing the number of days since Unix epoch.
  static int _dateTimeToInt(DateTime date) {
    return date.toUtc().difference(DateTime.utc(1970, 1, 1)).inDays;
  }

  /// Converts an integer representing the number of days since Unix epoch to a DateTime object.
  static DateTime _intToDateTime(int days) {
    return DateTime.utc(1970, 1, 1).add(Duration(days: days));
  }
}