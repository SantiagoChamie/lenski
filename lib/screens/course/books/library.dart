import 'package:flutter/material.dart';
import 'package:lenski/models/course_model.dart';
import 'package:lenski/screens/course/books/book_button.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/data/book_repository.dart';
import 'package:lenski/models/book_model.dart';

/// A widget that displays a library of books for a specific course.
class Library extends StatefulWidget {
  final Course course;
  final VoidCallback onAddBookPressed;
  final Function(Book) onEditBook;

  /// Creates a Library widget.
  /// 
  /// [course] is the course for which the library is being created.
  /// [onAddBookPressed] is the callback function to be called when the add book button is pressed.
  const Library({
    super.key,
    required this.course,
    required this.onAddBookPressed,
    required this.onEditBook,
  });

  @override
  _LibraryState createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  late Future<List<Book>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _booksFuture = _fetchBooks();
  }

  /// Fetches the list of books for the course from the repository.
  Future<List<Book>> _fetchBooks() async {
    return await BookRepository().booksByLanguage(widget.course.code);
  }

  /// Refreshes the list of books by fetching the latest data from the repository.
  void _refreshBooks() {
    setState(() {
      _booksFuture = _fetchBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);

    return FutureBuilder<List<Book>>(
      future: _booksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading books'));
        } else {
          List<BookButton> bookButtons = [];
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final books = snapshot.data!;
            bookButtons = books.map((book) => BookButton(
              book: book,
              onDelete: _refreshBooks,
              course: widget.course,
              onEdit: widget.onEditBook,
            )).toList();
          }

          // Add the "Add Book" button
          bookButtons.add(BookButton(add: true, onPressed: widget.onAddBookPressed));

          // Ensure there are at least 6 buttons in total
          while (bookButtons.length < 6) {
            bookButtons.add(const BookButton());
          }

          return SizedBox(
            width: p.mainScreenWidth() / 2,
            child: Padding(
              padding: EdgeInsets.only(right: p.standardPadding(), top: p.standardPadding()),
              child: SingleChildScrollView(
                child: Center(
                  child: Wrap(
                    spacing: p.standardPadding() * 2, // Horizontal spacing between books
                    runSpacing: p.standardPadding(), // Vertical spacing between books
                    children: bookButtons,
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}