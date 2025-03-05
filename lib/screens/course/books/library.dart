import 'package:flutter/material.dart';
import 'package:lenski/screens/course/books/book_button.dart';
import 'package:lenski/utils/proportions.dart';

class Library extends StatelessWidget {
  const Library({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);

    return SizedBox(
      width: p.mainScreenWidth() / 2,
      child: Padding(
        padding: EdgeInsets.only(left: p.standardPadding()),
        child: SingleChildScrollView(
          child: Center(
            child: Wrap(
              spacing: p.standardPadding()*2, // Horizontal spacing between books
              runSpacing: p.standardPadding(), // Vertical spacing between books
              children: List.generate(9, (index) {
                return BookButton();
              }),
            ),
          ),
        ),
      ),
    );
  }
}