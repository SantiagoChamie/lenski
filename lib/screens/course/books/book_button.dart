import 'package:flutter/material.dart';
import 'package:lenski/models/book_model.dart';
import 'package:lenski/models/course_model.dart';
import 'dart:math';
import 'package:lenski/screens/course/books/add_book_button.dart';
import 'package:lenski/screens/course/books/empty_book_button.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/data/book_repository.dart';
import 'package:lenski/screens/course/books/book_screen.dart';

class BookButton extends StatefulWidget {
  final Book? book;
  final Course? course;
  final bool? add;
  final VoidCallback? onPressed;
  final VoidCallback? onDelete;

  const BookButton({
    super.key,
    this.book,
    this.course,
    this.add = false,
    this.onPressed,
    this.onDelete,
  });

  @override
  _BookButtonState createState() => _BookButtonState();
}

class _BookButtonState extends State<BookButton> {
  Book? book;

  @override
  void initState() {
    super.initState();
    book = widget.book;
  }

  void _printBookType(BuildContext context) {
    if (widget.add == true) {
      if (widget.onPressed != null) {
        widget.onPressed!();
      }
    } else if (book != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookScreen(book: book!, course: widget.course!),
        ),
      ).then((updatedBook) {
        if (updatedBook != null && updatedBook is Book) {
          setState(() {
            book = updatedBook;
          });
        }
      });
    }
  }

  Future<void> _deleteBook(BuildContext context) async {
    if (book != null) {
      final bookRepository = BookRepository();
      await bookRepository.deleteBook(book!.id!);
      if (widget.onDelete != null) {
        widget.onDelete!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    const double bookWidth = 150;
    final randomColor = Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
    final percentage = (book != null && book!.totalLines > 0)
        ? ((book!.currentLine - 1) / book!.totalLines * 100).toInt()
        : 100;

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
          onTap: book != null || widget.add == true ? () => _printBookType(context) : widget.onPressed,
          child: Stack(
            children: [
              book == null
                ? widget.add == true ? const AddBookButton(bookWidth: bookWidth) 
              : const EmptyBookButton(bookWidth: bookWidth)
                : Container(
                    width: bookWidth,
                    height: bookWidth * 1.5,
                    decoration: BoxDecoration(
                      color: book!.imageUrl == null ? randomColor : null,
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
                              fontFamily: 'Sansation',
                              color: const Color.fromARGB(255, 0, 0, 0),
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
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2C73DE)),
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
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteBook(context),
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
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Varela Round',
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