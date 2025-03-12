class Card {
  final int? id;
  final String front;
  final String back;
  final String context;
  final int dueDate; // Store dueDate as an integer
  final String language;
  final int prevInterval; // New parameter

  Card({
    this.id,
    required this.front,
    required this.back,
    required this.context,
    required DateTime dueDate, // Accept DateTime in constructor
    required this.language,
    this.prevInterval = 0, // Initialize prevInterval as 0
  }) : dueDate = _dateTimeToInt(dueDate); // Convert DateTime to integer

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'front': front,
      'back': back,
      'context': context,
      'dueDate': dueDate, // Store as integer
      'language': language,
      'prevInterval': prevInterval, // Include prevInterval
    };
  }

  factory Card.fromMap(Map<String, dynamic> map) {
    return Card(
      id: map['id'],
      front: map['front'],
      back: map['back'],
      context: map['context'],
      dueDate: _intToDateTime(map['dueDate']), // Convert integer to DateTime
      language: map['language'],
      prevInterval: map['prevInterval'], // Include prevInterval
    );
  }

  static int _dateTimeToInt(DateTime date) {
    return date.toUtc().difference(DateTime.utc(1970, 1, 1)).inDays;
  }

  static DateTime _intToDateTime(int days) {
    return DateTime.utc(1970, 1, 1).add(Duration(days: days));
  }
}