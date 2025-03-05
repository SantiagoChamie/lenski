class Book {
  int id;
  String name;
  String imageUrl;
  int totalLines;
  int currentLine;
  String language;

  Book({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.totalLines,
    required this.currentLine,
    required this.language,
  });
  // Convert a Course into a Map. The keys must correspond to the names of the columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'totalLines': totalLines,
      'currentLine': currentLine,
      'language': language,
    };
  }

  // Extract a Course object from a Map.
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      name: map['name'],
      imageUrl: map['imageUrl'],
      totalLines: map['totalLines'],
      currentLine: map['currentLine'],
      language: map['language'],
    );
  }
}