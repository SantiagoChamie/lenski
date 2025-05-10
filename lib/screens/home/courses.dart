import 'package:flutter/material.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/screens/navigation/navigation_handler.dart';
import 'dart:async';
import 'add_course/add_course_navigator.dart';
import 'courses/course_list.dart';
import '../../models/course_model.dart';
import '../../data/course_repository.dart';

/// A StatefulWidget that displays a list of courses and an option to add new courses.
class Courses extends StatefulWidget {
  const Courses({super.key});

  @override
  _CoursesState createState() => _CoursesState();
}

class _CoursesState extends State<Courses> {
  bool _isExpanded = false;
  final CourseRepository _courseRepository = CourseRepository();
  StreamSubscription? _homeNavSubscription;

  @override
  void initState() {
    super.initState();
    
    // Subscribe to home navigation events
    _homeNavSubscription = NavigationHandlerState.onHomeNavigation.listen((_) {
      // If the add course screen is expanded, close it
      if (_isExpanded) {
        setState(() {
          _isExpanded = false;
        });
      }
    });
  }
  
  @override
  void dispose() {
    // Cancel the subscription when the widget is disposed
    _homeNavSubscription?.cancel();
    super.dispose();
  }

  /// Toggles the visibility of the add course screen.
  void _toggleAddCourseScreen() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Initialize Proportions with the current context
    final p = Proportions(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(p.standardPadding()),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Course>>(
                future: _courseRepository.courses(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error loading courses'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const CourseList(courses: []);
                  } else {
                    return CourseList(courses: snapshot.data!);
                  }
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: AddCourseNavigator(
                onToggle: _toggleAddCourseScreen,
                isExpanded: _isExpanded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}