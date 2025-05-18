import 'package:flutter/material.dart';
import 'package:lenski/models/book_model.dart';
import 'package:lenski/models/course_model.dart';
import 'package:lenski/screens/course/books/acid/add_book_button.dart';
import 'package:lenski/screens/course/books/library/empty_book_button.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/utils/colors.dart';
import 'package:lenski/utils/fonts.dart';

/// A button widget for displaying a book.
///
/// This component serves multiple purposes:
/// - Shows an existing book with cover image and progress indicator
/// - Shows an "add new book" button
/// - Shows an empty placeholder to maintain grid layout
///
/// Books display their title and completion percentage. Pressing a book
/// navigates to the book reader screen.
class BookButton extends StatefulWidget {
  /// The book to be displayed (null for add or empty buttons)
  final Book? book;
  
  /// The course to which the book belongs
  final Course? course;
  
  /// Whether this button is for adding a new book
  final bool? add;
  
  /// Callback function for when the add button is pressed
  final VoidCallback? onPressed;
  
  /// Callback function for when the book is deleted
  final VoidCallback? onDelete;
  
  /// Callback function for when the edit button is pressed
  final Function(Book)? onEdit;

  /// Creates a BookButton widget.
  /// 
  /// [book] is the book to be displayed.
  /// [course] is the course to which the book belongs.
  /// [add] indicates whether this button is for adding a new book.
  /// [onPressed] is the callback function to be called when the button is pressed.
  /// [onDelete] is the callback function to be called when the delete button is pressed.
  /// [onEdit] is the callback function to be called when the edit button is pressed.
  const BookButton({
    super.key,
    this.book,
    this.course,
    this.add = false,
    this.onPressed,
    this.onDelete,
    this.onEdit,
  });

  @override
  _BookButtonState createState() => _BookButtonState();
}

class _BookButtonState extends State<BookButton> {
  /// The book displayed by this button
  Book? book;

  @override
  void initState() {
    super.initState();
    book = widget.book;
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Handles the button press event.
  /// 
  /// If this is an add button, calls the onPressed callback.
  /// If this is a book button, navigates to the book screen.
  void _handleBookPress(BuildContext context) {
    if (widget.add == true) {
      if (widget.onPressed != null) {
        widget.onPressed!();
      }
    } else if (book != null) {
      Navigator.pushNamed(
        context,
        'Book',
        arguments: {'book': book!, 'course': widget.course!},
      ).then((updatedBook) {
        if (mounted && updatedBook != null && updatedBook is Book) {
          setState(() {
            book = updatedBook;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    const double bookWidth = 150;
    
    // Calculate completion percentage
    final percentage = (book != null && book!.totalLines > 0)
        ? book!.finished ? 100 : book!.currentLine == 1 ? 0 : ((book!.currentLine) / book!.totalLines * 100).toInt()
        : 100;

    // Adjust font size based on percentage width
    double fontSize;
    if (percentage < 10) {
      fontSize = 16;
    } else if (percentage < 100) {
      fontSize = 14;
    } else {
      fontSize = 12;
    }

    return Column(
      children: [
        InkWell(
          onTap: book != null || widget.add == true ? () => _handleBookPress(context) : widget.onPressed,
          child: Stack(
            children: [
              book == null
                  ? widget.add == true ? const AddBookButton(bookWidth: bookWidth) 
                  : const EmptyBookButton(bookWidth: bookWidth)
                  : Container(
                      width: bookWidth,
                      height: bookWidth * 1.5,
                      decoration: BoxDecoration(
                        color: book!.imageUrl == null ? AppColors.lightYellow : null,
                        image: book!.imageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(book!.imageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
              book != null && widget.add == false
                  ? Positioned(
                      bottom: 10,
                      right: 10,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Center(
                              child: Text(
                                '$percentage%',
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: appFonts['Detail'],
                                  color: AppColors.black,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              value: percentage / 100,
                              strokeWidth: 5,
                              backgroundColor: Colors.white,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.blue),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
              book != null && widget.add == false
                  ? Positioned(
                      top: 10,
                      left: 10,
                      child: IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        onPressed: () => widget.onEdit?.call(book!),
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 100 + p.standardPadding() * 2,
          child: Text(
            book?.name ?? ' ',
            style: TextStyle(
              fontSize: 16,
              fontFamily: appFonts['Paragraph'],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}