import 'package:flutter/material.dart';
import 'package:lenski/screens/course/course_home.dart';
//import 'package:lenski/screens/home/competences/competence_list.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/data/course_repository.dart';
import 'package:lenski/utils/course_colors.dart';
import '../../../models/course_model.dart';
import '../../../widgets/flag_icon.dart';

/// CourseButton is a widget that displays a course as a button.
/// It shows the competences, the course name, the flag, and the level.
class CourseButton extends StatefulWidget {
  final Course course;
  final VoidCallback onDelete;
  final int courseCount;

  /// Creates a CourseButton widget.
  /// 
  /// [course] is the course to be displayed.
  /// [onDelete] is the callback function to be called when the delete button is pressed.
  /// [courseCount] is the total number of courses.
  const CourseButton({super.key, required this.course, required this.onDelete, required this.courseCount});

  @override
  State<CourseButton> createState() => _CourseButtonState();
}

class _CourseButtonState extends State<CourseButton> {
  bool _showColorMenu = false;
  final _repository = CourseRepository();

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    return Padding(
      padding: EdgeInsets.only(bottom: p.standardPadding()),
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: p.courseButtonHeight(widget.courseCount),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to the CourseHome screen using NavigationHandler
                final navigatorKey = Navigator.of(context).widget.key as GlobalKey<NavigatorState>;
                navigatorKey.currentState?.pushNamed(
                  'Course',
                  arguments: widget.course,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.course.color, // Example of using a parameter
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(33), // Adjust the radius as needed
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Icons on the left indicating the competences
                  //TODO: Uncomment this line to display the competences
                  //CompetenceList(course: course),
                  const SizedBox(width: 50),
                  // Column with image and text in the center
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Circular flag above the course name
                      FlagIcon(
                        size: 150,
                        borderWidth: 7,
                        imageUrl: widget.course.imageUrl,
                      ),
                      const SizedBox(height: 20, width: 20),
                      Text(widget.course.name, style: const TextStyle(fontSize: 40, fontFamily: "Unbounded", color: Colors.white)),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          // Add Streak Indicator
          if (widget.course.streak > 0)
            Positioned(
              bottom: 10,
              left: 10,
              child: FutureBuilder<bool>(
                future: _repository.wasAccessedToday(widget.course),
                builder: (context, snapshot) {
                  final isToday = snapshot.data ?? false;
                  return Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: isToday ? Colors.orange : const Color(0xFFF5F0F6),
                        size: 28,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.course.streak}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isToday ? Colors.orange : const Color(0xFFF5F0F6),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          // Settings button
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () {
                setState(() {
                  _showColorMenu = !_showColorMenu;
                });
              },
            ),
          ),
          // Color menu
          if (_showColorMenu)
            Positioned(
              top: 10,
              right: 50,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(51),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: CourseColors.colors.map((Color color) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () async {
                          final updatedCourse = widget.course.copyWith(color: color);
                          await _repository.updateCourse(updatedCourse);
                          widget.onDelete();
                          setState(() {
                            _showColorMenu = false;
                          });
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          // Delete button
          Positioned(
            bottom: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await _repository.deleteCourse(widget.course.code);
                widget.onDelete();
              },
            ),
          ),
        ],
      ),
    );
  }
}