import 'package:flutter/widgets.dart';
import 'package:lenski/models/course_model.dart';

class CourseHome extends StatelessWidget {
  final Course course;
  const CourseHome({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(course.name),);
  }
}