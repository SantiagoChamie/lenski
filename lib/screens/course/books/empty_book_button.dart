import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class EmptyBookButton extends StatelessWidget {
  final double bookWidth;

  const EmptyBookButton({super.key, required this.bookWidth});

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      color: Colors.grey,
      strokeWidth: 2,
      borderType: BorderType.RRect,
      radius: const Radius.circular(8),
      dashPattern: const [6, 3],
      child: Container(
        width: bookWidth,
        height: bookWidth * 1.5,
        color: Colors.transparent,
      ),
    );
  }
}