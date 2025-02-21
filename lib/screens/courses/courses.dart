import 'package:flutter/material.dart';
import 'package:lenski/utils/proportions.dart';
import 'add_course_button.dart';
import 'course_list.dart';
import 'course_model.dart';

class Courses extends StatelessWidget {
  const Courses({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);

    // Sample courses for testing
    final List<Course> sampleCourses = [
      Course(
        name: 'English',
        level: 'A1',
        code: 'en',
        listening: true,
        speaking: false,
        reading: true,
        writing: false,
        position: 1,
        color: const Color(0xFFFFAEAE),
        imageUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/a/ae/Flag_of_the_United_Kingdom.svg/640px-Flag_of_the_United_Kingdom.svg.png',
      ),
      Course(
        name: 'Español',
        level: 'A2',
        code: 'es',
        listening: false,
        speaking: true,
        reading: false,
        writing: true,
        position: 2,
        color: const Color(0xFFFFCC85),
        imageUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/9/9a/Flag_of_Spain.svg/1920px-Flag_of_Spain.svg.png',
      ),
    ];

    return Center(
      child: Padding(
        padding: EdgeInsets.all(p.standardPadding()),
        child: Column(
          children: [
            Expanded(
              child: CourseList(courses: sampleCourses),
            ),
            const AddCourseButton(),
          ],
        ),
      ),
    );
  }
}