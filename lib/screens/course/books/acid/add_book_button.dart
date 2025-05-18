import 'package:flutter/material.dart';
import 'package:lenski/utils/colors.dart';

/// A button widget for adding a new book.
///
/// This component shows a button with a plus icon that represents
/// the action of adding a new book to the library. It maintains a consistent
/// appearance with the book items in the grid.
class AddBookButton extends StatelessWidget {
  /// The width of the button
  final double bookWidth;

  /// Creates an AddBookButton widget.
  /// 
  /// [bookWidth] is the width of the book button, which determines both the
  /// width and height (using a 1.5 aspect ratio) of the resulting button.
  const AddBookButton({super.key, required this.bookWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: bookWidth,
      height: bookWidth * 1.5,
      decoration: BoxDecoration(
        color: AppColors.grey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(
          Icons.add,
          color: AppColors.black,
          size: 40,
        ),
      ),
    );
  }
}