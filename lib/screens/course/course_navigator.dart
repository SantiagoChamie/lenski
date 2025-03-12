import 'package:flutter/material.dart';
import 'package:lenski/models/course_model.dart';
import 'package:lenski/screens/course/books/library.dart';
import 'package:lenski/screens/course/books/add_book_screen.dart';
import 'package:lenski/screens/course/review_cards/review_pile.dart';

/// A widget that navigates between different screens within a course.
class CourseNavigator extends StatefulWidget {
  final Course course;

  /// Creates a CourseNavigator widget.
  /// 
  /// [course] is the course for which the navigator is being created.
  const CourseNavigator({super.key, required this.course});

  @override
  _CourseNavigatorState createState() => _CourseNavigatorState();
}

class _CourseNavigatorState extends State<CourseNavigator> {
  bool _showAddBookScreen = false;

  /// Toggles the visibility of the add book screen.
  void _toggleAddBookScreen() {
    setState(() {
      _showAddBookScreen = !_showAddBookScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _showAddBookScreen
        ? AddBookScreen(onBackPressed: _toggleAddBookScreen, languageCode: widget.course.code)
        : Row(
            children: [
              ReviewPile(course: widget.course),
              const Spacer(),
              Center(child: Library(course: widget.course, onAddBookPressed: _toggleAddBookScreen)),
            ],
          );
  }
}