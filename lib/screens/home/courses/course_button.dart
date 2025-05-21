import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lenski/screens/home/competences/competence_icon.dart';
import 'package:lenski/screens/home/competences/competence_list.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/utils/colors.dart';
import 'package:lenski/utils/fonts.dart';
import 'package:lenski/data/course_repository.dart';
import 'package:lenski/screens/home/courses/course_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/course_model.dart';
import '../../../widgets/flag_icon.dart';
import '../../../data/session_repository.dart';

/// A button representing a language learning course.
///
/// This widget displays a course as an interactive button, showing key information:
/// - Course name and flag
/// - Active competences (reading, writing, speaking, listening)
/// - Streak count
/// - Goal completion indicator
/// 
/// It also provides functionality for:
/// - Navigating to the course details
/// - Changing the course color
/// - Hiding or deleting the course
class CourseButton extends StatefulWidget {
  /// The course to display
  final Course course;
  
  /// Callback function triggered after course deletion or update
  final VoidCallback onDelete;
  
  /// The total number of courses (used for sizing)
  final int courseCount;

  /// Creates a CourseButton widget.
  /// 
  /// [course] is the course to be displayed.
  /// [onDelete] is the callback function to be called when the delete button is pressed.
  /// [courseCount] is the total number of courses.
  const CourseButton({
    super.key, 
    required this.course, 
    required this.onDelete, 
    required this.courseCount
  });

  @override
  State<CourseButton> createState() => _CourseButtonState();
}

class _CourseButtonState extends State<CourseButton> {
  /// Whether to show the color selection menu
  bool _showColorMenu = false;
  
  /// Repository for course data operations
  final _repository = CourseRepository();
  
  /// Repository for session data operations
  final _sessionRepository = SessionRepository();
  
  /// Whether the course goal has been met
  bool _isGoalMet = false;
  
  /// Whether course stats are currently loading
  bool _isLoading = true;
  
  /// Whether to show streak indicators (from settings)
  bool _streakIndicatorEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadCourseStats();
    _loadStreakIndicatorSetting();
  }

  /// Loads course statistics including goal completion status.
  ///
  /// This method:
  /// 1. Sets the initial goal completion state from the course model
  /// 2. If not already complete, checks the database for updated completion status
  /// 3. Updates the UI if the completion status has changed
  Future<void> _loadCourseStats() async {
    try {
      // Set initial state from course model
      setState(() {
        _isGoalMet = widget.course.goalComplete;
        _isLoading = false;
      });
      
      if(_isGoalMet) return; // No need to check if the goal is already met
      
      // Check for course completion explicitly (this will update the database if needed)
      final updatedStatus = widget.course.totalGoal > 0 ?  
        await _sessionRepository.checkCourseCompletion(widget.course.code) : false;
      
      // Only update state if the status has changed and the widget is still mounted
      if (mounted && updatedStatus) {
        setState(() {
          _isGoalMet = updatedStatus;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Loads the streak indicator display setting from shared preferences.
  ///
  /// This determines whether to show the streak counter on course buttons.
  Future<void> _loadStreakIndicatorSetting() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _streakIndicatorEnabled = prefs.getBool('streak_indicator_enabled') ?? true;
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
                backgroundColor: widget.course.color, // Maintain user's selected color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(33),
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
                        style: TextStyle(
                          fontSize: 40, 
                          fontFamily: appFonts['Title'], 
                          color: Colors.white
                        )
                      ),
                      
                      // Add the gold star if goal is achieved based on goal type
                      if (!_isLoading && _isGoalMet)
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(
                            Icons.star,
                            color: AppColors.gold,
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
          // Add Streak Indicator (conditionally)
          if (_streakIndicatorEnabled && widget.course.streak > 0)
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
                          color: isToday ? AppColors.streak : AppColors.darkGrey,
                          size: 28,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.course.streak}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: appFonts['Paragraph'],
                            color: isToday ? AppColors.streak : AppColors.darkGrey,
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
              icon: Icon(Icons.delete, color: AppColors.error),
              onPressed: () => _showDeleteDialog(context),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the competence icons section of the course button.
  ///
  /// Shows either a single large icon if only one competence is enabled,
  /// or a list of smaller icons for multiple competences.
  ///
  /// @param course The course object containing competence information
  /// @return A widget representing the competence section
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

  /// Shows a dialog asking the user whether to hide or delete the course.
  ///
  /// @param context The build context
  void _showDeleteDialog(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    
    final choice = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            localizations.removeCourseTitle,
            style: TextStyle(
              fontSize: 24,
              fontFamily: appFonts['Title'],
            ),
          ),
          content: Text(
            localizations.removeCoursePrompt,
            style: TextStyle(
              fontSize: 16,
              fontFamily: appFonts['Paragraph'],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop('cancel'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.blue,
                textStyle: TextStyle(
                  fontSize: 14,
                  fontFamily: appFonts['Detail'],
                ),
              ),
              child: Text(localizations.cancel),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.warning,
                textStyle: TextStyle(
                  fontSize: 14,
                  fontFamily: appFonts['Detail'],
                ),
              ),
              onPressed: () => Navigator.of(context).pop('hide'),
              child: Text(localizations.hideCourse),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
                textStyle: TextStyle(
                  fontSize: 14,
                  fontFamily: appFonts['Detail'],
                ),
              ),
              onPressed: () => Navigator.of(context).pop('delete'),
              child: Text(localizations.deletePermanently),
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

  /// Shows a confirmation dialog before permanently deleting a course.
  ///
  /// @param context The build context
  void _showDeleteConfirmationDialog(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            localizations.confirmDeleteTitle,
            style: TextStyle(
              fontSize: 24,
              fontFamily: appFonts['Title'],
            ),
          ),
          content: Text(
            localizations.confirmDeleteMessage,
            style: TextStyle(
              fontSize: 16,
              fontFamily: appFonts['Paragraph'],
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
                foregroundColor: AppColors.blue,
                textStyle: TextStyle(
                  fontSize: 14,
                  fontFamily: appFonts['Detail'],
                ),
              ),
              child: Text(localizations.cancel),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
                textStyle: TextStyle(
                  fontSize: 14,
                  fontFamily: appFonts['Detail'],
                ),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(localizations.deletePermanently),
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