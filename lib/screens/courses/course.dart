import 'package:flutter/material.dart';
import 'package:lenski/screens/courses/competences/competence_list.dart';
import 'package:lenski/utils/proportions.dart';
import 'course_model.dart';


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
            // Define what happens when the button is pressed
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: course.color, // Example of using a parameter
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(33), // Adjust the radius as needed
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icons on the left indicating the competences
              CompetenceList(course: course),
              // Column with image and text in the center
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Circular flag above the course name
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 5),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        course.imageUrl,
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10, width: 10),
                  Text(course.name, style: const TextStyle(fontSize: 30, fontFamily: "Unbounded", color: Colors.white)),
                ],
              ),
              // Level on the right
              //TODO: Bug: Level not showing when there is only one course
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Transform.translate(
                      offset: const Offset(0, -20), // Adjust the value as needed
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.bookmark,
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