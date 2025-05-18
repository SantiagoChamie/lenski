import 'package:lenski/models/book_model.dart';

/// A model representing an archived book in the application.
///
/// When users complete books, they can be archived for future reference.
/// Archived books contain basic book information along with categorization
/// details and a timestamp of when they were completed.
class ArchivedBook {
  /// Unique identifier for the archived book in the database
  int? id;
  
  /// The title of the book
  String name;
  
  /// The language code of the book's content (e.g., "EN", "ES", "FR")
  String language;
  
  /// Primary categorization for the book (e.g., "fiction", "academic")
  String category;
  
  /// Optional secondary categorization for the book (e.g., "mystery", "science")
  String? subcategory;
  
  /// Optional URL to the book's cover image
  String? imageUrl;
  
  /// Timestamp stored as days since Unix epoch (1970-01-01)
  /// representing when the book was finished
  int finishedDate;

  /// Creates an ArchivedBook instance.
  ///
  /// [id] is the unique identifier from the database (null for new books).
  /// [name] is the title of the book.
  /// [language] is the language code of the book's content.
  /// [imageUrl] is the URL to the book's cover image (can be null).
  /// [category] is the primary categorization (defaults to empty string).
  /// [subcategory] is an optional secondary categorization.
  /// [finishedDate] is when the book was completed (defaults to current date).
  ArchivedBook({
    this.id,
    required this.name,
    required this.language,
    required this.imageUrl,
    this.category = '',
    this.subcategory,
    DateTime? finishedDate,
  }) : finishedDate = _dateTimeToInt(finishedDate ?? DateTime.now());

  /// Converts the ArchivedBook instance to a map for database storage.
  ///
  /// Returns a map with keys corresponding to database column names and
  /// values formatted appropriately for storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'language': language,
      'category': category,
      'subcategory': subcategory,
      'imageUrl': imageUrl,
      'finishedDate': finishedDate,
    };
  }

  /// Creates an ArchivedBook instance from a database record map.
  ///
  /// [map] is a map representation of the database record.
  ///
  /// Returns a new ArchivedBook instance populated from the map.
  factory ArchivedBook.fromMap(Map<String, dynamic> map) {
    return ArchivedBook(
      id: map['id'],
      name: map['name'],
      language: map['language'],
      category: map['category'],
      subcategory: map['subcategory'],
      imageUrl: map['imageUrl'],
      finishedDate: _intToDateTime(map['finishedDate']),
    );
  }

  /// Creates an ArchivedBook instance from a regular Book model.
  ///
  /// Used when archiving a completed book from the library.
  ///
  /// [book] is the original Book model to convert.
  ///
  /// Returns a new ArchivedBook instance with data from the book and
  /// the current date as the finished date.
  factory ArchivedBook.fromBook(Book book) {
    return ArchivedBook(
      name: book.name,
      language: book.language,
      imageUrl: book.imageUrl,
      finishedDate: DateTime.now(),
    );
  }

  /// Converts a DateTime object to an integer representing the number of days since Unix epoch.
  ///
  /// [date] is the DateTime to convert.
  ///
  /// Returns an integer representing days since January 1, 1970 UTC.
  static int _dateTimeToInt(DateTime date) {
    return date.toUtc().difference(DateTime.utc(1970, 1, 1)).inDays;
  }

  /// Converts an integer representing the number of days since Unix epoch to a DateTime object.
  ///
  /// [days] is the number of days since January 1, 1970 UTC.
  ///
  /// Returns a DateTime object corresponding to that date.
  static DateTime _intToDateTime(int days) {
    return DateTime.utc(1970, 1, 1).add(Duration(days: days));
  }
}