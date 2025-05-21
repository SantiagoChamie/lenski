import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lenski/models/course_model.dart';
import 'package:lenski/screens/course/course_navigator.dart';
import 'package:lenski/screens/course/metrics.dart';
import 'package:lenski/utils/languages/welcome_messages.dart';
import 'package:lenski/widgets/flag_icon.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/utils/colors.dart';
import 'package:lenski/utils/fonts.dart';
import 'package:lenski/widgets/ltext.dart';
import 'package:lenski/data/course_repository.dart';

/// A screen that displays the home page for a specific course.
///
/// This component serves as the main dashboard for a language course, featuring:
/// - Course flag and welcome message in the target language
/// - Progress metrics and statistics
/// - Access to review cards, library, and other course activities
///
/// The screen maintains the latest course data and responds to changes made
/// in other parts of the application by refreshing metrics and course status.
class CourseHome extends StatefulWidget {
  /// The course to display
  final Course course;

  /// Creates a CourseHome widget.
  /// 
  /// [course] is the course for which the home screen is being created.
  const CourseHome({super.key, required this.course});

  @override
  State<CourseHome> createState() => _CourseHomeState();
}

class _CourseHomeState extends State<CourseHome> {
  /// The current course data (may be updated from the original)
  late Course _currentCourse;
  
  /// Counter used to force metrics refresh when incremented
  int _refreshCounter = 0;
  
  /// Whether course data is currently being loaded
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _currentCourse = widget.course;
    _fetchLatestCourseData();
  }
  
  /// Fetches the most recent course data from the repository.
  ///
  /// This ensures the screen displays up-to-date information about streak,
  /// progress, and other course details that may have changed.
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  /// Updates the course data when changes are made in child components.
  ///
  /// @param updatedCourse The new version of the course data
  void _handleCourseUpdate(Course updatedCourse) {
    setState(() {
      _currentCourse = updatedCourse;
      _refreshCounter++; // Increment on updates, forcing metrics refresh
    });
  }

  /// Triggers a refresh of the metrics display.
  ///
  /// This is typically called when a new card is added through LText
  /// to ensure the metrics display the updated progress.
  void _refreshMetrics() {
    setState(() {
      _refreshCounter++; // Increment counter to force metrics refresh
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    final localizations = AppLocalizations.of(context)!;
    
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.blue,
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: p.standardPadding() * 2, 
            left: p.standardPadding() * 2, 
            bottom: p.standardPadding() * 2
          ),
          child: Row(
            children: [
              FlagIcon(
                size: 100.0,
                borderWidth: 5.0,
                borderColor: AppColors.grey,
                language: _currentCourse.name,
              ),
              SizedBox(width: p.standardPadding()),
              LText(
                text: getWelcomeMessage(_currentCourse.name),
                style: TextStyle(
                  fontSize: 24.0,
                  color: AppColors.black,
                  fontFamily: _currentCourse.code != 'EL' 
                    ? appFonts['Title'] 
                    : "Lexend",
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.dotted,
                  decorationColor: AppColors.black,
                ),
                fromLanguage: _currentCourse.fromCode,
                toLanguage: _currentCourse.code,
                position: 'below',
                onCardAdded: () => _refreshMetrics(),
              ),
              Container(
                margin: const EdgeInsets.only(left: 8.0),
                child: Tooltip(
                  message: localizations.highlightTextTooltip,
                  preferBelow: false,
                  child: const Icon(
                    Icons.help_outline,
                    size: 20.0,
                    color: AppColors.darkGrey,
                  ),
                ),
              ),
              const Spacer(),
              Flexible(
                child: Metrics(
                  course: _currentCourse,
                  refreshKey: _refreshCounter,
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