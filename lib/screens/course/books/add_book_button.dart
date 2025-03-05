import 'package:flutter/material.dart';

class AddBookButton extends StatelessWidget {
  final double bookWidth;

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