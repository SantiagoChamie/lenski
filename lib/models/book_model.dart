/// A model class representing a book.
class Book {
  int? id;
  String name;
  String? imageUrl;
  int totalLines;
  int currentLine;
  String language;
  bool finished;  // New attribute

  /// Creates a Book object.
  /// 
  /// [id] is the unique identifier for the book.
  /// [name] is the name of the book.
  /// [imageUrl] is the URL of the book's image.
  /// [totalLines] is the total number of lines in the book.
  /// [currentLine] is the current line being read in the book.
  /// [language] is the language code of the book.
  /// [finished] indicates whether the book is finished.
  Book({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.totalLines,
    required this.currentLine,
    required this.language,
    this.finished = false,  // Default value
  });

  /// Creates a copy of this Book but with the given fields replaced with the new values.
  Book copyWith({
    int? id,
    String? name,
    String? imageUrl,
    int? totalLines,
    int? currentLine,
    String? language,
    bool? finished,
  }) {
    return Book(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      totalLines: totalLines ?? this.totalLines,
      currentLine: currentLine ?? this.currentLine,
      language: language ?? this.language,
      finished: finished ?? this.finished,
    );
  }

  /// Converts a Book object into a Map.
  /// The keys must correspond to the names of the columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'totalLines': totalLines,
      'currentLine': currentLine,
      'language': language,
      'finished': finished ? 1 : 0,  // Convert bool to int for SQLite
    };
  }

  /// Extracts a Book object from a Map.
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      name: map['name'],
      imageUrl: map['imageUrl'],
      totalLines: map['totalLines'],
      currentLine: map['currentLine'],
      language: map['language'],
      finished: map['finished'] == 1,  // Convert int to bool from SQLite
    );
  }
}