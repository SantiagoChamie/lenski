import 'package:flutter/material.dart';
import 'package:lenski/utils/proportions.dart';
import 'add_course/add_course_button.dart';
import 'course_list.dart';
import 'course_model.dart';

// Define a global variable for the animation duration
const int animationDuration = 200;

class Courses extends StatefulWidget {
  const Courses({super.key});

  @override
  _CoursesState createState() => _CoursesState();
}

class _CoursesState extends State<Courses> {
  bool _isExpanded = false;
  bool _isCourseListVisible = true;

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        Future.delayed(Duration(milliseconds: animationDuration), () {
          setState(() {
            _isCourseListVisible = false;
          });
        });
      } else {
        _isCourseListVisible = true;
      }
    });
  }

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
        child: Stack(
          children: [
            AnimatedOpacity(
              opacity: _isExpanded ? 0.0 : 1.0,
              duration: const Duration(milliseconds: animationDuration),
              child: Visibility(
                visible: _isCourseListVisible,
                child: Column(
                  children: [
                    Expanded(
                      child: CourseList(courses: sampleCourses),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: animationDuration),
                height: _isExpanded ? MediaQuery.of(context).size.height - p.standardPadding() * 2 : p.sidebarButtonWidth(),
                child: AddCourseButton(onPressed: _toggleExpand),
              ),
            ),
          ],
        ),
      ),
    );
  }
}