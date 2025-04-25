import 'package:lenski/models/book_model.dart';

class ArchivedBook {
  int? id;
  String name;
  String language;
  String category;
  String? imageUrl;
  int finishedDate;  // Store as days since epoch

  ArchivedBook({
    this.id,
    required this.name,
    required this.language,
    required this.imageUrl,
    this.category = 'no category',
    DateTime? finishedDate,  // Accept DateTime in constructor
  }) : finishedDate = _dateTimeToInt(finishedDate ?? DateTime.now());

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'language': language,
      'category': category,
      'imageUrl': imageUrl,
      'finishedDate': finishedDate,
    };
  }

  factory ArchivedBook.fromMap(Map<String, dynamic> map) {
    return ArchivedBook(
      id: map['id'],
      name: map['name'],
      language: map['language'],
      category: map['category'],
      imageUrl: map['imageUrl'],
      finishedDate: _intToDateTime(map['finishedDate']),
    );
  }

  factory ArchivedBook.fromBook(Book book) {
    return ArchivedBook(
      name: book.name,
      language: book.language,
      imageUrl: book.imageUrl,
      finishedDate: DateTime.now(),
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