import 'package:lenski/data/book_repository.dart';
import 'package:lenski/models/book_model.dart';

/// A class that processes the book text.
/// First it will divide the text by sentences
/// The first sentence will be assigned as the title of the book
/// The rest of the sentences will be assigned as the content of the book
/// The book will be saved to the database
/// A special databse is then created for the book
class BookCreator {
  final BookRepository _bookRepository = BookRepository();

  void processBook(String text, String code) async {
    final sentences = text.split(RegExp(r'(?<=[.!?])\s+|\n')).where((s) => s.trim().isNotEmpty).toList();
    if (sentences.isEmpty) return;
    final title = sentences.first;
    final content = sentences;
    final book = Book(
      id: null, // Auto-incremented by the database
      name: title,
      imageUrl: null, // Add appropriate image URL if needed
      totalLines: content.length,
      currentLine: 1,
      language: code, // Set the appropriate language code
    );

    await _bookRepository.insertBook(book);

    // Assuming the book ID is auto-incremented and set after insertion
    final insertedBook = await _bookRepository.booksByLanguage(code).then((books) => books.last);
    await _bookRepository.createBookDatabase(insertedBook.id!, content);
  }
}