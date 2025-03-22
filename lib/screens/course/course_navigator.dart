import 'package:flutter/material.dart';
import 'package:lenski/models/course_model.dart';
import 'package:lenski/screens/course/books/library.dart';
import 'package:lenski/screens/course/books/add_book_screen.dart';
import 'package:lenski/screens/course/review_cards/review_pile.dart';
import 'package:lenski/screens/course/review_cards/add_card_screen.dart';

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
  bool _showAddCardScreen = false;

  /// Toggles the visibility of the add book screen.
  void _toggleAddBookScreen() {
    setState(() {
      _showAddBookScreen = !_showAddBookScreen;
    });
  }

  /// Toggles the visibility of the add card screen.
  void _toggleAddCardScreen() {
    setState(() {
      _showAddCardScreen = !_showAddCardScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showAddBookScreen) {
      return AddBookScreen(onBackPressed: _toggleAddBookScreen, languageCode: widget.course.code);
    } else {
      return Row(
        children: [
          _showAddCardScreen ? AddCardScreen(onBackPressed: _toggleAddCardScreen, course: widget.course) 
            : ReviewPile(course: widget.course, onNewPressed: _toggleAddCardScreen),
          const Spacer(),
          Center(child: Library(course: widget.course, onAddBookPressed: _toggleAddBookScreen)),
        ],
      );
    }
  }
}