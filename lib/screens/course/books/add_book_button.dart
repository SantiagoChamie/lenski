import 'package:flutter/material.dart';

/// A button widget for adding a new book.
class AddBookButton extends StatelessWidget {
  final double bookWidth;

  /// Creates an AddBookButton widget.
  /// 
  /// [bookWidth] is the width of the book button.
  const AddBookButton({super.key, required this.bookWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: bookWidth,
      height: bookWidth * 1.5,
      decoration: BoxDecoration(
        color: const Color(0xFFD9D0DB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(
          Icons.add,
          color: Colors.black,
          size: 40,
        ),
      ),
    );
  }
}