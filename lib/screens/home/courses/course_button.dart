import 'package:flutter/material.dart';
import 'package:lenski/screens/home/competences/competence_icon.dart';
import 'package:lenski/screens/home/competences/competence_list.dart'; // Uncomment this import
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/data/course_repository.dart';
import 'package:lenski/utils/course_colors.dart';
import '../../../models/course_model.dart';
import '../../../widgets/flag_icon.dart';
import '../../../data/session_repository.dart'; // Add this import

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
  final _sessionRepository = SessionRepository(); // Add this
  int _totalWordsAdded = 0; // Add this
  bool _isLoading = true; // Add this

  @override
  void initState() {
    super.initState();
    _loadCourseStats();
  }

  // Add this method to load course stats
  Future<void> _loadCourseStats() async {
    try {
      // Get all sessions for this course
      final sessions = await _sessionRepository.getSessionsByCourse(widget.course.code);
      
      // Sum up all words added
      int totalWords = 0;
      for (var session in sessions) {
        totalWords += session.wordsAdded;
      }
      
      setState(() {
        _totalWordsAdded = totalWords;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
                  _buildCompetenceSection(widget.course),
                  const SizedBox(width: 50),
                  // Column with image and text in the center
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Circular flag above the course name
                      FlagIcon(
                        size: 150,
                        borderWidth: 7,
                        language: widget.course.name,
                      ),
                      const SizedBox(height: 20, width: 20),
                      Text(
                        widget.course.name, 
                        style: const TextStyle(
                          fontSize: 40, 
                          fontFamily: "Unbounded", 
                          color: Colors.white
                        )
                      ),
                      
                      // Add the gold star if goal is achieved
                      if (!_isLoading && _totalWordsAdded >= widget.course.totalGoal)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Icon(
                            Icons.star,
                            color: Colors.amber[300],
                            size: 32,
                          ),
                        ),
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
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(230),
                      borderRadius: BorderRadius.circular(33),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: isToday ? Colors.orange : Colors.grey[400],
                          size: 28,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.course.streak}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isToday ? Colors.orange : Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
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
              onPressed: () => _showDeleteDialog(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompetenceSection(Course course) {
    // Count enabled competences
    int enabledCompetences = 0;
    String enabledCompetenceType = '';
    
    if (course.listening) {
      enabledCompetences++;
      enabledCompetenceType = 'listening';
    }
    if (course.speaking) {
      enabledCompetences++;
      enabledCompetenceType = 'speaking';
    }
    if (course.reading) {
      enabledCompetences++;
      enabledCompetenceType = 'reading';
    }
    if (course.writing) {
      enabledCompetences++;
      enabledCompetenceType = 'writing';
    }
    
    // If exactly one competence is enabled, display just that icon
    if (enabledCompetences == 1) {
      return Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CompetenceIcon(
              size: 40, // Larger size for single icon
              type: enabledCompetenceType,
            ),
          ],
        ),
      );
    } 
    // Otherwise display the competence list
    else {
      return CompetenceList(course: course);
    }
  }

  void _showDeleteDialog(BuildContext context) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Course',
            style: TextStyle(
              fontSize: 24,
              fontFamily: "Unbounded",
            ),
          ),
          content: const Text('Do you want to hide this course or delete it permanently?',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop('cancel'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2C73DE),
                textStyle: const TextStyle(
                  fontSize: 14,
                ),
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange,
                textStyle: const TextStyle(
                  fontSize: 14,
                ),
              ),
              onPressed: () => Navigator.of(context).pop('hide'),
              child: const Text('Hide Course'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                textStyle: const TextStyle(
                  fontSize: 14,
                ),
              ),
              onPressed: () => Navigator.of(context).pop('delete'),
              child: const Text('Delete Permanently'),
            ),
          ],
        );
      },
    );

    if (choice == 'hide') {
      await _repository.makeInvisible(widget.course.code);
      widget.onDelete();
    } else if (choice == 'delete') {
      _showDeleteConfirmationDialog(context);
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion',
            style: TextStyle(
              fontSize: 24,
              fontFamily: "Unbounded",
            ),
          ),
          content: const Text(
            'Warning: This will permanently delete all data associated with this course \nincluding progress, sessions, and saved words. This action cannot be undone.',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                // Reopen the first dialog when user presses cancel
                _showDeleteDialog(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2C73DE),
                textStyle: const TextStyle(
                  fontSize: 14,
                ),
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                textStyle: const TextStyle(
                  fontSize: 14,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete Permanently'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _repository.deleteCourse(widget.course.code);
      widget.onDelete();
    }
  }
}