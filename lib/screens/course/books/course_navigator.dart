import 'package:flutter/material.dart';
import 'package:lenski/models/course_model.dart';
import 'package:lenski/screens/course/books/library.dart';
import 'package:lenski/screens/course/books/add_book_screen.dart';

class CourseNavigator extends StatefulWidget {
  final Course course;
  const CourseNavigator({super.key, required this.course});

  @override
  _CourseNavigatorState createState() => _CourseNavigatorState();
}

class _CourseNavigatorState extends State<CourseNavigator> {
  bool _showAddBookScreen = false;

  void _toggleAddBookScreen() {
    setState(() {
      _showAddBookScreen = !_showAddBookScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _showAddBookScreen
        ? AddBookScreen(onBackPressed: _toggleAddBookScreen)
        : Row(
            children: [
              const Placeholder(),
              const Spacer(),
              Center(child: Library(languageCode: widget.course.code, onAddBookPressed: _toggleAddBookScreen)),
            ],
          );
  }
}