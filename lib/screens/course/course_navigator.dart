import 'package:flutter/material.dart';
import 'package:lenski/models/book_model.dart';
import 'package:lenski/models/course_model.dart';
import 'package:lenski/screens/course/books/edit_book_screen.dart';
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
  bool _isEditingBook = false;  // Renamed from _showEditBookScreen
  Book? _bookToEdit;

  void _toggleAddBookScreen() {
    setState(() {
      _showAddBookScreen = !_showAddBookScreen;
      if (_showAddBookScreen) {
        _isEditingBook = false;  // Updated reference
        _bookToEdit = null;
      }
    });
  }

  void _showEditBookScreen(Book book) {
    setState(() {
      _bookToEdit = book;
      _isEditingBook = true;  // Updated reference
      _showAddBookScreen = false;
    });
  }

  void _closeEditBookScreen() {
    setState(() {
      _isEditingBook = false;  // Updated reference
      _bookToEdit = null;
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
      return AddBookScreen(
        onBackPressed: _toggleAddBookScreen,
        languageCode: widget.course.code
      );
    } else if (_isEditingBook && _bookToEdit != null) {  // Updated reference
      return EditBookScreen(
        book: _bookToEdit!,
        onBackPressed: _closeEditBookScreen,
      );
    } else {
      return Row(
        children: [
          _showAddCardScreen 
              ? AddCardScreen(onBackPressed: _toggleAddCardScreen, course: widget.course)
              : ReviewPile(course: widget.course, onNewPressed: _toggleAddCardScreen),
          const Spacer(),
          Center(
            child: Library(
              course: widget.course,
              onAddBookPressed: _toggleAddBookScreen,
              onEditBook: _showEditBookScreen,
            ),
          ),
        ],
      );
    }
  }
}