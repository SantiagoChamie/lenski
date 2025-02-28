import 'package:flutter/material.dart';
import '../../../models/course_model.dart';
import 'course_button.dart';

/// A list of courses in a scrollable view
class CourseList extends StatelessWidget {
  final List<Course> courses;

  const CourseList({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    // Create a scrollable list of courses
    // TODO: for when the user selects a grid view
    return SingleChildScrollView(
      child: Column(
        children: courses.map((course) => CourseButton(course: course)).toList(),
      ),
    );
  }
}