import 'package:flutter/material.dart';
import 'package:lenski/models/course_model.dart';
import 'package:lenski/screens/course/course_navigator.dart';
import 'package:lenski/screens/course/metrics.dart';
import 'package:lenski/widgets/flag_icon.dart';
import 'package:lenski/utils/languages.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/widgets/ltext.dart';
import 'package:lenski/data/course_repository.dart'; // Add this import

/// A screen that displays the home page for a specific course.
class CourseHome extends StatefulWidget {
  final Course course;

  /// Creates a CourseHome widget.
  /// 
  /// [course] is the course for which the home screen is being created.
  const CourseHome({super.key, required this.course});

  @override
  State<CourseHome> createState() => _CourseHomeState();
}

class _CourseHomeState extends State<CourseHome> {
  late Course _currentCourse;
  // Add this to track refreshes
  int _refreshCounter = 0;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _currentCourse = widget.course;
    _fetchLatestCourseData();
  }
  
  // Fetch the latest course data from the repository
  Future<void> _fetchLatestCourseData() async {
    try {
      final CourseRepository repository = CourseRepository();
      final updatedCourse = await repository.getCourse(_currentCourse.code);
      
      if (mounted) {
        setState(() {
          _currentCourse = updatedCourse;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching course data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _handleCourseUpdate(Course updatedCourse) {
    setState(() {
      _currentCourse = updatedCourse;
      _refreshCounter++; // Increment on updates, forcing metrics refresh
    });
  }

  // Add this new method to refresh metrics
  void _refreshMetrics() {
    setState(() {
      _refreshCounter++; // Increment counter to force metrics refresh
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: p.standardPadding() * 2, left: p.standardPadding() * 2, bottom: p.standardPadding() * 2),
          child: Row(
            children: [
              FlagIcon(
                size: 100.0,
                borderWidth: 5.0,
                borderColor: const Color(0xFFD9D0DB),
                language: _currentCourse.name,
              ),
              SizedBox(width: p.standardPadding()),
              LText(
                text: getWelcomeMessage(_currentCourse.name),
                style: TextStyle(
                  fontSize: 24.0,
                  color: const Color.fromARGB(255, 0, 0, 0),
                  fontFamily: _currentCourse.code != 'EL' ? "Unbounded": "Lexend",
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.dotted,
                  decorationColor: const Color.fromARGB(255, 0, 0, 0),
                ),
                fromLanguage: _currentCourse.fromCode,
                toLanguage: _currentCourse.code,
                position: 'below',
                onCardAdded: () => _refreshMetrics(), // Add this callback
              ),
              Container(
                margin: const EdgeInsets.only(left: 8.0),
                child: const Tooltip(
                  message: 'Highlight text to see its translation',
                  preferBelow: false,
                  child: Icon(
                    Icons.help_outline,
                    size: 20.0,
                    color: Color.fromARGB(255, 145, 139, 146),
                  ),
                ),
              ),
              const Spacer(),
              Flexible(
                child: Metrics(
                  course: _currentCourse,
                  refreshKey: _refreshCounter, // Pass the counter as refresh key
                ),
              ),
              SizedBox(width: p.standardPadding()),
            ],
          ),
        ),
        Expanded(
          child: CourseNavigator(
            course: _currentCourse,
            onCourseUpdate: _handleCourseUpdate,
          ),
        ),
      ],
    );
  }
}