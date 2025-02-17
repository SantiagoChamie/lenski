import 'package:flutter/material.dart';
import 'package:lenski/utils/proportions.dart';
import 'add_course_button.dart';
import 'course_list.dart';

class Courses extends StatelessWidget {
  const Courses({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    return Center(
      child:  Padding(
        padding: EdgeInsets.all(p.standardPadding()),
        child: const Column(
          children: [
            CourseList(),
            Spacer(),
            AddCourseButton(),
          ],
        ),
      ),
    );
  }
}