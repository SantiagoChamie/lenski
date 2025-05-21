import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../models/course_model.dart';
import '../../../data/course_repository.dart';
import '../../../utils/fonts.dart';
import 'course_button.dart';

/// A scrollable list that displays courses with interactive buttons.
///
/// This widget renders a vertical list of course buttons, each representing
/// a course that the user has created. If no courses exist, it displays
/// a message prompting the user to add a course.
///
/// Features:
/// - Responsive layout that adapts to available space
/// - Automatically refreshes when courses are added or deleted
/// - Empty state handling with user guidance
class CourseList extends StatefulWidget {
  /// The initial list of courses to display
  final List<Course> courses;

  /// Creates a CourseList widget.
  /// 
  /// [courses] is the initial list of courses to be displayed.
  const CourseList({super.key, required this.courses});

  @override
  _CourseListState createState() => _CourseListState();
}

class _CourseListState extends State<CourseList> {
  /// The current list of courses to display
  late List<Course> _courses;

  @override
  void initState() {
    super.initState();
    _courses = widget.courses;
  }

  /// Refreshes the list of courses by fetching the latest data from the repository.
  ///
  /// This method is called when a course is added or deleted to ensure
  /// the UI reflects the current state of the data.
  void _refreshCourses() async {
    final courses = await CourseRepository().courses();
    if (mounted) {
      setState(() {
        _courses = courses;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    if (_courses.isEmpty) {
      return Center(
        child: Text(
          localizations.addCoursePrompt,
          style: TextStyle(
            fontFamily: appFonts['Paragraph'],
            fontSize: 20,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: _courses.map((course) => 
          CourseButton(
            course: course, 
            onDelete: _refreshCourses, 
            courseCount: _courses.length,
          )
        ).toList(),
      ),
    );
  }
}