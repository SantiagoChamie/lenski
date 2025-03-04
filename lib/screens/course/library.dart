import 'package:flutter/material.dart';

class Library extends StatelessWidget {
  final List<String> books;

  const Library({super.key, required this.books});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3 columns
            childAspectRatio: 0.7, // Adjust the aspect ratio as needed
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
          ),
          itemCount: books.length,
          itemBuilder: (context, index) {
            return Card(
              child: Center(
                child: Text(
                  books[index],
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}