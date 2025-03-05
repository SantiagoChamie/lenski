import 'package:flutter/material.dart';
import 'dart:math';
import 'package:lenski/screens/course/books/add_book_button.dart';
import 'package:lenski/screens/course/books/empty_book_button.dart';

import 'package:lenski/utils/proportions.dart';

/// BookButton is a widget that displays a book with an image, name, and progress.
/// If the book is not yet added, it will display an empty book.
/// It will also display an add book button if it is the last book in the list.
// TODO: could work better with a book button selector as intermediary
class BookButton extends StatelessWidget {
  final String? id;
  final bool? add;
  final String? imageUrl;
  final String? name;
  final int? totalLines;
  final int? currentLine;
  final VoidCallback? onPressed;

  const BookButton({
    super.key,
    this.id,
    this.add = false,
    this.imageUrl,
    this.name,
    this.totalLines,
    this.currentLine,
    this.onPressed,
  });

  void _printBookType() {
    if (id == null && add == true) {
      print('Add Book Button');
    } else if (id == null) {
      print('Empty Book');
    } else {
      print('Full Book');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    const double bookWidth = 150;
    final randomColor = Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
    final percentage = (totalLines != null && currentLine != null && totalLines! > 0)
        ? (currentLine! / totalLines! * 100).toInt()
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
          onTap: _printBookType,
          child: Stack(
            children: [
              id == null
                ? add == true ? const AddBookButton(bookWidth: bookWidth) 
              : const EmptyBookButton(bookWidth: bookWidth)
                : Container(
                    width: bookWidth,
                    height: bookWidth * 1.5,
                    decoration: BoxDecoration(
                      color: imageUrl == null ? randomColor : null,
                      image: imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
              id != null && add == false
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
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 100 + p.standardPadding() * 2,
          child: Text(
            name ?? ' ',
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