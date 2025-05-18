import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lenski/data/session_repository.dart';
import 'package:lenski/models/course_model.dart';
import 'package:lenski/models/session_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lenski/utils/colors.dart';
import 'package:lenski/utils/fonts.dart';

/// A widget that displays metrics about a course's progress.
///
/// This component shows two alternating metrics that the user can toggle between:
/// 1. Daily goal progress (words, activity, or minutes depending on goal type)
/// 2. Day streak count
///
/// Features:
/// - Color-coded indicators (green for completed goals, yellow/orange for in-progress)
/// - Tap to cycle between metrics
/// - Automatic persistence of the last viewed metric type
/// - Responsive layout to fit different container heights
class Metrics extends StatefulWidget {
  /// Height of the metrics container
  final double height;
  
  /// The course for which to display metrics
  final Course course;
  
  /// An object used to force refresh when changed
  final Object refreshKey;

  /// Creates a Metrics widget.
  /// 
  /// [height] is the height of the metrics container.
  /// [course] is the course for which to display metrics.
  /// [refreshKey] is used to force a refresh when changed.
  const Metrics({
    super.key, 
    this.height = 100,
    required this.course,
    this.refreshKey = const Object(),
  });

  @override
  State<Metrics> createState() => _MetricsState();
}

class _MetricsState extends State<Metrics> {
  /// Repository for session data operations
  late final SessionRepository _sessionRepository;
  
  /// Future for loading today's session data
  late Future<Session> _sessionFuture;
  
  /// Future for loading preferences
  late Future<void> _initPrefs;
  
  /// Index of the currently displayed metric (0 = goal, 1 = streak)
  int _currentIndex = 1;
  
  @override
  void initState() {
    super.initState();
    _sessionRepository = SessionRepository();
    _refreshData();
    _initPrefs = _loadLastMetric();
  }

  /// Refreshes session data from the repository.
  void _refreshData() {
    _sessionFuture = _sessionRepository.getOrCreateTodaySession(widget.course.code);
  }

  @override
  void didUpdateWidget(Metrics oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.course.code != widget.course.code || 
        oldWidget.course.hashCode != widget.course.hashCode ||
        oldWidget.refreshKey != widget.refreshKey) {
      _refreshData();
    }
  }

  /// Loads the last viewed metric index from persistent storage.
  ///
  /// This allows the app to remember which metric the user was viewing
  /// for each course separately.
  Future<void> _loadLastMetric() async {
    final prefs = await SharedPreferences.getInstance();
    final lastMetric = prefs.getInt('last_metric_${widget.course.code}') ?? 0;
    setState(() {
      _currentIndex = lastMetric;
    });
  }

  /// Saves the current metric index to persistent storage.
  ///
  /// This will be used to restore the same metric view when the user
  /// returns to this course.
  Future<void> _saveLastMetric(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_metric_${widget.course.code}', index);
  }

  /// Cycles to the next available metric.
  ///
  /// Currently toggles between goal progress and streak count.
  void _cycleMetric() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % 2;
      _saveLastMetric(_currentIndex);
    });
  }

  /// Returns the appropriate icon for the course's goal type.
  ///
  /// @param goalType The type of goal ('learn', 'daily', or 'time')
  /// @return An IconData representing the goal type
  IconData _getGoalIcon(String goalType) {
    switch (goalType) {
      case 'learn':
        return Icons.trending_up;
      case 'daily':
        return Icons.calendar_today;
      case 'time':
        return Icons.timer;
      default:
        return Icons.trending_up;
    }
  }
  
  /// Checks if the daily goal has been met for a course session.
  ///
  /// @param course The course containing the goal definition
  /// @param session The session containing progress data
  /// @return true if the goal is met, false otherwise
  bool _isGoalMet(Course course, Session session) {
    switch (course.goalType) {
      case 'learn':
        return session.wordsAdded >= course.dailyGoal;
      case 'daily':
        // For daily type, check if any activity was done
        return session.wordsAdded > 0 || 
               session.wordsReviewed > 0 || 
               session.linesRead > 0 ||
               session.minutesStudied > 0;
      case 'time':
        return session.minutesStudied >= course.dailyGoal;
      default:
        return session.wordsAdded >= course.dailyGoal;
    }
  }
  
  /// Returns a formatted progress text for the daily goal.
  ///
  /// @param course The course containing the goal definition
  /// @param session The session containing progress data
  /// @return A string representing progress (e.g., "5/10")
  String _getGoalProgressText(Course course, Session session) {
    switch (course.goalType) {
      case 'learn':
        return course.dailyGoal > 0 ? '${session.wordsAdded}/${course.dailyGoal}' : session.wordsAdded.toString();
      case 'daily':
        // For daily type, show 1/1 if any activity was done, 0/1 if not
        final hasActivity = session.wordsAdded > 0 || 
                           session.wordsReviewed > 0 || 
                           session.linesRead > 0 ||
                           session.minutesStudied > 0;
        return hasActivity ? '1/1' : '0/1';
      case 'time':
        return course.dailyGoal > 0 ? '${session.minutesStudied}/${course.dailyGoal}' : session.minutesStudied.toString();
      default:
        return '${session.wordsAdded}/${course.dailyGoal}';
    }
  }
  
  /// Returns the localized label text for the goal type.
  ///
  /// @param goalType The type of goal ('learn', 'daily', or 'time')
  /// @param context The build context for localization
  /// @return A localized string describing the goal type
  String _getGoalLabel(String goalType, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    switch (goalType) {
      case 'learn':
        return localizations.wordsToday;
      case 'daily':
        return localizations.dailyActivity;
      case 'time':
        return localizations.minutesToday;
      default:
        return localizations.dailyGoal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return FutureBuilder(
      future: _initPrefs,
      builder: (context, prefsSnapshot) {
        if (prefsSnapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: widget.height,
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.yellow,
              ),
            ),
          );
        }

        return GestureDetector(
          onTap: _cycleMetric,
          child: FutureBuilder<Session>(
            future: _sessionFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final todaySession = snapshot.data!;
                
                final metrics = [
                  SizedBox(
                    height: widget.height,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          _getGoalIcon(widget.course.goalType),
                          size: 28,
                          color: _isGoalMet(widget.course, todaySession) 
                              ? AppColors.success  // Complete: Green
                              : AppColors.yellow,  // Incomplete: Yellow
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getGoalProgressText(widget.course, todaySession),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: appFonts['Subtitle'],
                            color: _isGoalMet(widget.course, todaySession)
                              ? AppColors.success  // Complete: Green
                              : AppColors.yellow,  // Incomplete: Yellow
                          ),
                        ),
                        Text(
                          _getGoalLabel(widget.course.goalType, context),
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: appFonts['Subtitle'],
                            color: _isGoalMet(widget.course, todaySession) 
                              ? AppColors.success
                              : AppColors.yellow,
                          ),
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: widget.height,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          size: 28,
                          color: AppColors.yellow,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.course.streak}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: appFonts['Subtitle'],
                            color: AppColors.yellow,
                          ),
                        ),
                        Text(
                          localizations.dayStreak,
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: appFonts['Subtitle'],
                            color: AppColors.yellow,
                          ),
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
                  ),
                ];
                return metrics[_currentIndex];
              }
              return SizedBox(
                height: widget.height,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.yellow,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}