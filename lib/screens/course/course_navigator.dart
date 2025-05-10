import 'package:flutter/material.dart';
import 'package:lenski/models/book_model.dart';
import 'package:lenski/models/course_model.dart';
import 'package:lenski/screens/course/books/acid/edit_book_screen.dart';
import 'package:lenski/screens/course/books/library/library.dart';
import 'package:lenski/screens/course/books/acid/add_book_screen.dart';
import 'package:lenski/screens/course/edit_course_screen.dart';
import 'package:lenski/screens/course/review_cards/review_pile.dart';
import 'package:lenski/screens/course/review_cards/add_card_screen.dart';
import 'package:lenski/utils/proportions.dart';

/// A widget that navigates between different screens within a course.
class CourseNavigator extends StatefulWidget {
  final Course course;
  final Function(Course updatedCourse)? onCourseUpdate; // Add this callback

  /// Creates a CourseNavigator widget.
  /// 
  /// [course] is the course for which the navigator is being created.
  /// [onCourseUpdate] is called when the course is updated.
  const CourseNavigator({
    super.key, 
    required this.course,
    this.onCourseUpdate,
  });

  @override
  _CourseNavigatorState createState() => _CourseNavigatorState();
}

class _CourseNavigatorState extends State<CourseNavigator> {
  late Course _currentCourse; // Add this to track the current course
  bool _showAddBookScreen = false;
  bool _showAddCardScreen = false;
  bool _isEditingBook = false;
  bool _showEditCourseScreen = false;
  Book? _bookToEdit;

  @override
  void initState() {
    super.initState();
    _currentCourse = widget.course; // Initialize with the provided course
  }

  void _toggleAddBookScreen() {
    setState(() {
      _showAddBookScreen = !_showAddBookScreen;
      if (_showAddBookScreen) {
        _isEditingBook = false;
        _bookToEdit = null;
      }
    });
  }

  void _showEditBookScreen(Book book) {
    setState(() {
      _bookToEdit = book;
      _isEditingBook = true;
      _showAddBookScreen = false;
    });
  }

  void _closeEditBookScreen() {
    setState(() {
      _isEditingBook = false;
      _bookToEdit = null;
    });
  }

  /// Toggles the visibility of the add card screen.
  void _toggleAddCardScreen() {
    setState(() {
      _showAddCardScreen = !_showAddCardScreen;
    });
  }

  /// Handles the course edit screen and updates the course if changed.
  void _toggleEditCourseScreen() {
    if (_showEditCourseScreen) {
      setState(() {
        _showEditCourseScreen = false;
      });
    } else {
      setState(() {
        _showEditCourseScreen = true;
      });
    }
  }

  /// Updates the course with the edited version.
  void _handleCourseUpdate(Course updatedCourse) {
    setState(() {
      _currentCourse = updatedCourse;
      _showEditCourseScreen = false;
    });
    
    // Notify parent component of the update
    if (widget.onCourseUpdate != null) {
      widget.onCourseUpdate!(updatedCourse);
    }
  }

  // Add a method to refresh the course data which will rebuild the metrics
  void _refreshCourse() {
    setState(() {
      // This empty setState will rebuild the widget with the latest data
    });
    
    // Notify parent if needed
    if (widget.onCourseUpdate != null) {
      widget.onCourseUpdate!(_currentCourse);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    if (_showAddBookScreen) {
      return AddBookScreen(
        onBackPressed: _toggleAddBookScreen,
        languageCode: _currentCourse.code, // Use updated course
      );
    } else if (_isEditingBook && _bookToEdit != null) {
      return EditBookScreen(
        book: _bookToEdit!,
        onBackPressed: _closeEditBookScreen,
      );
    } else if (_showEditCourseScreen) {
      return EditCourseScreen(
        onBack: _handleCourseUpdate, // Use the new handler that accepts the updated course
        course: _currentCourse, // Use updated course
      );
    } else {
      return Stack(
        children: [
          Row(
            children: [
              _showAddCardScreen
                  ? AddCardScreen(
                      onBackPressed: _toggleAddCardScreen, 
                      course: _currentCourse,
                      onCardAdded: _refreshCourse, // Add this callback
                    )
                  : ReviewPile(course: _currentCourse, onNewPressed: _toggleAddCardScreen), // Use updated course
              const Spacer(),
              Center(
                child: Library(
                  course: _currentCourse, // Use updated course
                  onAddBookPressed: _toggleAddBookScreen,
                  onEditBook: _showEditBookScreen,
                ),
              ),
            ],
          ),
          // Edit Course button
          Positioned(
            bottom: p.standardPadding() * 2 + 40, // Position above archive button
            right: p.standardPadding(),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: const Color(0xFF2C73DE),
                  width: 2,
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.settings),
                color: const Color(0xFF2C73DE),
                onPressed: _toggleEditCourseScreen,
              ),
            ),
          ),
          // Archive button
          Positioned(
            bottom: p.standardPadding(),
            right: p.standardPadding(),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: const Color(0xFF2C73DE),
                  width: 2,
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.archive_outlined),
                color: const Color(0xFF2C73DE),
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    'Archive',
                    arguments: _currentCourse, // Use updated course
                  );
                },
              ),
            ),
          ),
        ],
      );
    }
  }
}