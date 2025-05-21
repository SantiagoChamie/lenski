/// A model class representing a daily user session for a specific course.
class Session {
  final String courseCode;   // Foreign key to course
  final int date;            // Days since epoch (matching Course date format)
  int wordsAdded;            // Number of new words learned today
  int wordsReviewed;         // Number of words reviewed today
  int linesRead;             // Number of lines read today
  int minutesStudied;        // Minutes spent studying today
  int cardsDeleted;          // Number of cards deleted today
  bool streakIncremented;    // Whether streak was incremented today

  /// Creates a Session object.
  /// 
  /// [courseCode] is the code of the course this session belongs to.
  /// [date] represents the day of this session (stored as days since epoch).
  /// [wordsAdded] is the number of new words learned in this session.
  /// [wordsReviewed] is the number of words reviewed in this session.
  /// [linesRead] is the number of lines read in this session.
  /// [minutesStudied] is the time spent studying in this session.
  /// [cardsDeleted] is the number of cards deleted in this session.
  /// [streakIncremented] indicates whether the streak was incremented today.
  Session({
    required this.courseCode,
    DateTime? date,
    this.wordsAdded = 0,
    this.wordsReviewed = 0,
    this.linesRead = 0,
    this.minutesStudied = 0,
    this.cardsDeleted = 0,
    this.streakIncremented = false,
  }) : date = _dateTimeToInt(date ?? DateTime.now());

  /// Converts a Session object into a Map.
  /// The keys correspond to the columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'courseCode': courseCode,
      'date': date,
      'wordsAdded': wordsAdded,
      'wordsReviewed': wordsReviewed,
      'linesRead': linesRead,
      'minutesStudied': minutesStudied,
      'cardsDeleted': cardsDeleted,
      'streakIncremented': streakIncremented ? 1 : 0,
    };
  }

  /// Extracts a Session object from a Map.
  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      courseCode: map['courseCode'],
      date: _intToDateTime(map['date']),
      wordsAdded: map['wordsAdded'] ?? 0,
      wordsReviewed: map['wordsReviewed'] ?? 0,
      linesRead: map['linesRead'] ?? 0,
      minutesStudied: map['minutesStudied'] ?? 0,
      cardsDeleted: map['cardsDeleted'] ?? 0,
      streakIncremented: map['streakIncremented'] == 1,
    );
  }

  /// Creates a copy of the Session object with updated fields.
  Session copyWith({
    String? courseCode,
    DateTime? date,
    int? wordsAdded,
    int? wordsReviewed,
    int? linesRead,
    int? minutesStudied,
    int? cardsDeleted,
    bool? streakIncremented,
  }) {
    return Session(
      courseCode: courseCode ?? this.courseCode,
      date: date ?? _intToDateTime(this.date),
      wordsAdded: wordsAdded ?? this.wordsAdded,
      wordsReviewed: wordsReviewed ?? this.wordsReviewed,
      linesRead: linesRead ?? this.linesRead,
      minutesStudied: minutesStudied ?? this.minutesStudied,
      cardsDeleted: cardsDeleted ?? this.cardsDeleted,
      streakIncremented: streakIncremented ?? this.streakIncremented,
    );
  }

  /// Converts a DateTime object to an integer representing the number of days since Unix epoch.
  static int _dateTimeToInt(DateTime date) {
    return DateTime(date.year, date.month, date.day)
        .toUtc()
        .difference(DateTime.utc(1970, 1, 1))
        .inDays;
  }

  /// Converts an integer representing the number of days since Unix epoch to a DateTime object.
  static DateTime _intToDateTime(int days) {
    return DateTime.utc(1970, 1, 1).add(Duration(days: days));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Session &&
        other.courseCode == courseCode &&
        other.date == date;
  }

  @override
  int get hashCode => courseCode.hashCode ^ date.hashCode;
}