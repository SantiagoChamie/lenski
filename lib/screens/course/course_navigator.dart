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
import 'package:lenski/utils/colors.dart';

/// A widget that navigates between different screens within a course.
///
/// This component serves as a central navigation hub for all course-related activities:
/// - Reviewing flash cards (via ReviewPile)
/// - Adding new flash cards (via AddCardScreen)
/// - Managing books in the library (via Library)
/// - Editing course settings (via EditCourseScreen)
/// - Accessing archived content
///
/// The navigator tracks the current screen state and provides smooth transitions
/// between different course activities while maintaining the course state.
class CourseNavigator extends StatefulWidget {
  /// The course being navigated
  final Course course;
  
  /// Optional callback triggered when the course data is updated
  final Function(Course updatedCourse)? onCourseUpdate;

  /// Creates a CourseNavigator widget.
  /// 
  /// [course] is the course for which the navigator is being created.
  /// [onCourseUpdate] is called when the course is updated, allowing parent
  /// widgets to react to changes in course data.
  const CourseNavigator({
    super.key, 
    required this.course,
    this.onCourseUpdate,
  });

  @override
  _CourseNavigatorState createState() => _CourseNavigatorState();
}

class _CourseNavigatorState extends State<CourseNavigator> {
  /// The currently active course (may be updated from the original)
  late Course _currentCourse;
  
  /// Whether the add book screen is currently displayed
  bool _showAddBookScreen = false;
  
  /// Whether the add card screen is currently displayed
  bool _showAddCardScreen = false;
  
  /// Whether a book is currently being edited
  bool _isEditingBook = false;
  
  /// Whether the edit course screen is currently displayed
  bool _showEditCourseScreen = false;
  
  /// The book currently being edited, if any
  Book? _bookToEdit;

  @override
  void initState() {
    super.initState();
    _currentCourse = widget.course; // Initialize with the provided course
  }

  /// Toggles the visibility of the add book screen.
  ///
  /// When showing the add book screen, resets any book editing state
  /// to ensure a clean state for adding a new book.
  void _toggleAddBookScreen() {
    setState(() {
      _showAddBookScreen = !_showAddBookScreen;
      if (_showAddBookScreen) {
        _isEditingBook = false;
        _bookToEdit = null;
      }
    });
  }

  /// Shows the edit book screen for a specific book.
  ///
  /// @param book The book to be edited
  void _showEditBookScreen(Book book) {
    setState(() {
      _bookToEdit = book;
      _isEditingBook = true;
      _showAddBookScreen = false;
    });
  }

  /// Closes the edit book screen and resets related state.
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

  /// Toggles the visibility of the course edit screen.
  void _toggleEditCourseScreen() {
    setState(() {
      _showEditCourseScreen = !_showEditCourseScreen;
    });
  }

  /// Updates the course with the edited version and notifies parent widgets.
  ///
  /// @param updatedCourse The new version of the course after editing
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

  /// Refreshes the current course state, triggering a UI rebuild.
  ///
  /// This is typically called after operations that modify the course
  /// (like adding cards) to ensure the UI reflects the latest data.
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
                      onCardAdded: _refreshCourse,
                    )
                  : ReviewPile(course: _currentCourse, onNewPressed: _toggleAddCardScreen),
              const Spacer(),
              Center(
                child: Library(
                  course: _currentCourse,
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
                  color: AppColors.blue,
                  width: 2,
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.settings),
                color: AppColors.blue,
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
                  color: AppColors.blue,
                  width: 2,
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.archive_outlined),
                color: AppColors.blue,
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