import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

/// A widget that displays an empty book button with a dotted border.
///
/// Used as a placeholder in the library grid to maintain consistent layout.
/// Shows a transparent container with a dotted border outline.
class EmptyBookButton extends StatelessWidget {
  /// The width of the book button
  final double bookWidth;
  
  /// The stroke width of the dotted border
  final double stokeWidth = 2;

  /// Creates an EmptyBookButton widget.
  /// 
  /// [bookWidth] is the width of the book button.
  const EmptyBookButton({super.key, required this.bookWidth});

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      color: Colors.grey,
      strokeWidth: stokeWidth,
      borderType: BorderType.RRect,
      radius: const Radius.circular(8),
      dashPattern: const [6, 3],
      child: Container(
        width: bookWidth-4,
        height: bookWidth * 1.5 - stokeWidth*2,
        color: Colors.transparent,
      ),
    );
  }
}