import 'package:lenski/models/book_model.dart';

class ArchivedBook {
  int? id;
  String name;
  String language;
  String category;
  String? imageUrl;

  ArchivedBook({
    required this.id,
    required this.name,
    required this.language,
    required this.imageUrl,
    this.category = 'no category',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'language': language,
      'category': category,
      'imageUrl': imageUrl,
    };
  }

  factory ArchivedBook.fromMap(Map<String, dynamic> map) {
    return ArchivedBook(
      id: map['id'],
      name: map['name'],
      language: map['language'],
      category: map['category'],
      imageUrl: map['imageUrl'],
    );
  }

  factory ArchivedBook.fromBook(Book book) {
    return ArchivedBook(
      id: book.id,
      name: book.name,
      language: book.language,
      imageUrl: book.imageUrl,
    );
  }
}