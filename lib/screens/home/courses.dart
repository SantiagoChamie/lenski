import 'package:flutter/material.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/utils/colors.dart';
import 'package:lenski/utils/fonts.dart';
import 'package:lenski/screens/navigation/navigation_handler.dart';
import 'dart:async';
import 'add_course/add_course_navigator.dart';
import 'courses/course_list.dart';
import '../../models/course_model.dart';
import '../../data/course_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A screen that displays a list of courses and provides functionality to add new courses.
///
/// This widget serves as the main home screen of the application, showing all the
/// user's courses and providing navigation to:
/// - Individual course screens
/// - Add course workflow
///
/// Features:
/// - Dynamically loaded course list
/// - Expandable add course panel
/// - Automatic collapsing of add course panel on home navigation
class Courses extends StatefulWidget {
  const Courses({super.key});

  @override
  _CoursesState createState() => _CoursesState();
}

class _CoursesState extends State<Courses> {
  /// Whether the add course panel is expanded
  bool _isExpanded = false;
  
  /// Repository for accessing course data
  final CourseRepository _courseRepository = CourseRepository();
  
  /// Subscription to home navigation events
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
  ///
  /// This method is called when the user clicks on the add course button.
  void _toggleAddCourseScreen() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Initialize Proportions with the current context
    final p = Proportions(context);
    final localizations = AppLocalizations.of(context)!;

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
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.blue,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        localizations.errorLoadingCourses,
                        style: TextStyle(
                          fontFamily: appFonts['Detail'],
                          color: AppColors.darkGrey,
                        ),
                        textAlign: TextAlign.center,
                      )
                    );
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