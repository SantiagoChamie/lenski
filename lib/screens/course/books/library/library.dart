import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lenski/models/course_model.dart';
import 'package:lenski/screens/course/books/library/book_button.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/data/book_repository.dart';
import 'package:lenski/models/book_model.dart';
import 'package:lenski/utils/fonts.dart';
import 'package:lenski/utils/colors.dart';
import 'dart:math' as math;

/// A widget that displays a library of books for a specific course.
///
/// This component shows a grid of book buttons for a language course. Features include:
/// - Displaying existing books for the course
/// - Add button for creating new books
/// - Empty placeholders to maintain grid layout
/// - Responsive grid layout based on screen width
class Library extends StatefulWidget {
  /// The course for which books are displayed
  final Course course;
  
  /// Callback function for when the add book button is pressed
  final VoidCallback onAddBookPressed;
  
  /// Callback function for editing a book
  final Function(Book) onEditBook;

  /// Creates a Library widget.
  /// 
  /// [course] is the course for which the library is being created.
  /// [onAddBookPressed] is the callback function to be called when the add book button is pressed.
  /// [onEditBook] is the callback function to be called when a book is to be edited.
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
  ///
  /// Returns a Future containing the list of books for the current course language.
  Future<List<Book>> _fetchBooks() async {
    return await BookRepository().booksByLanguage(widget.course.code);
  }

  /// Refreshes the list of books by fetching the latest data from the repository.
  ///
  /// This is typically called after operations that modify the books collection,
  /// such as adding or deleting a book.
  void _refreshBooks() {
    setState(() {
      _booksFuture = _fetchBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    final localizations = AppLocalizations.of(context)!;

    return FutureBuilder<List<Book>>(
      future: _booksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              localizations.errorLoadingBooks,
              style: TextStyle(
                color: AppColors.error,
                fontFamily: appFonts['Paragraph'],
              ),
            ),
          );
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

          // Calculate number of columns based on screen width and standard padding
          const  buttonWidth = 140.0; // Approximate width of a BookButton
          final availableWidth = p.mainScreenWidth() / 2;
          final columnsPerRow = (availableWidth / (buttonWidth + p.standardPadding() * 2)).floor();
          
          // Calculate how many buttons we need to add to complete the last row
          // and ensure we have at least 2 rows
          final currentButtons = bookButtons.length;
          final minButtons = columnsPerRow * 2; // Minimum 2 rows
          final buttonsInLastRow = currentButtons % columnsPerRow;
          final emptyButtonsNeeded = buttonsInLastRow > 0 
              ? columnsPerRow - buttonsInLastRow 
              : 0;
          
          // Add empty buttons to reach minimum of 2 rows or complete the last row
          final totalButtonsNeeded = math.max(minButtons - currentButtons, emptyButtonsNeeded);
          for (var i = 0; i < totalButtonsNeeded; i++) {
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