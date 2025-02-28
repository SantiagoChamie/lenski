import 'package:flutter/material.dart';
import 'package:lenski/screens/course/course_home.dart';
import 'package:lenski/screens/home/competences/competence_list.dart';
import 'package:lenski/utils/proportions.dart';
import '../../../models/course_model.dart';
import 'flag_icon.dart';

/// CourseButton is a widget that displays a course as a button.
/// It shows the competences, the course name, the flag, and the level.
class CourseButton extends StatelessWidget {
  final Course course;

  const CourseButton({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    return Padding(
      padding: EdgeInsets.only(bottom: p.standardPadding()),
      child: SizedBox(
        width: double.infinity,
        height: p.courseButtonHeight(3),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CourseHome(course: course),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: course.color, // Example of using a parameter
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(33), // Adjust the radius as needed
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Icons on the left indicating the competences
              CompetenceList(course: course),
              const SizedBox(width: 50),
              // Column with image and text in the center
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Circular flag above the course name
                  FlagIcon(
                    size: 150,
                    borderWidth: 7,
                    imageUrl: course.imageUrl,
                  ),
                  const SizedBox(height: 20, width: 20),
                  Text(course.name, style: const TextStyle(fontSize: 40, fontFamily: "Unbounded", color: Colors.white)),
                ],
              ),
              const Spacer(),
              //TODO: Bug: Level not showing when there is only one course
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Transform.translate(
                      offset: const Offset(0, -12), // Adjust the value as needed
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.bookmark_sharp,
                            color: Colors.green,
                            size: 100,
                          ),
                          Text(
                            course.level,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontFamily: "Unbounded",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}