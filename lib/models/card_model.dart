/// A model class representing a flashcard.
class Card {
  final int? id;
  final String front;
  final String back;
  final String context;
  final int dueDate; // Store dueDate as an integer
  final String language;
  final int prevInterval; // New parameter

  /// Creates a Card object.
  /// 
  /// [id] is the unique identifier for the card.
  /// [front] is the front text of the card.
  /// [back] is the back text of the card.
  /// [context] is the context in which the card is used.
  /// [dueDate] is the due date for reviewing the card, stored as an integer.
  /// [language] is the language code of the card.
  /// [prevInterval] is the previous interval for the card.
  Card({
    this.id,
    required this.front,
    required this.back,
    required this.context,
    required DateTime dueDate, // Accept DateTime in constructor
    required this.language,
    this.prevInterval = 0, // Initialize prevInterval as 0
  }) : dueDate = _dateTimeToInt(dueDate); // Convert DateTime to integer

  /// Converts a Card object into a Map.
  /// The keys must correspond to the names of the columns in the database.
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

  /// Extracts a Card object from a Map.
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

  /// Converts a DateTime object to an integer representing the number of days since Unix epoch.
  static int _dateTimeToInt(DateTime date) {
    return date.toUtc().difference(DateTime.utc(1970, 1, 1)).inDays;
  }

  /// Converts an integer representing the number of days since Unix epoch to a DateTime object.
  static DateTime _intToDateTime(int days) {
    return DateTime.utc(1970, 1, 1).add(Duration(days: days));
  }
}