import 'package:flutter/material.dart';
import '../../../models/course_model.dart';
import 'course_button.dart';
import 'package:lenski/data/course_repository.dart';

/// A list of courses in a scrollable view
class CourseList extends StatefulWidget {
  final List<Course> courses;

  /// Creates a CourseList widget.
  /// 
  /// [courses] is the initial list of courses to be displayed.
  const CourseList({super.key, required this.courses});

  @override
  _CourseListState createState() => _CourseListState();
}

class _CourseListState extends State<CourseList> {
  late List<Course> _courses;

  @override
  void initState() {
    super.initState();
    _courses = widget.courses;
  }

  /// Refreshes the list of courses by fetching the latest data from the repository.
  void _refreshCourses() async {
    final courses = await CourseRepository().courses();
    setState(() {
      _courses = courses;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_courses.isEmpty) {
      return const Center(
        child: Text(
          'Add a course to start learning!',
          style: TextStyle(fontFamily: "Varela Round", fontSize: 20),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: _courses.map((course) => CourseButton(course: course, onDelete: _refreshCourses, courseCount: _courses.length)).toList(),
      ),
    );
  }
}