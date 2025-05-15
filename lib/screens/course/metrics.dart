import 'package:flutter/material.dart';
import 'package:lenski/data/session_repository.dart';
import 'package:lenski/models/course_model.dart';
import 'package:lenski/models/session_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Metrics extends StatefulWidget {
  final double height;
  final Course course;
  final Object refreshKey;

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
  late final SessionRepository _sessionRepository;
  late Future<Session> _sessionFuture;
  late Future<void> _initPrefs;
  int _currentIndex = 1;
  
  @override
  void initState() {
    super.initState();
    _sessionRepository = SessionRepository();
    _refreshData();
    _initPrefs = _loadLastMetric();
  }

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

  Future<void> _loadLastMetric() async {
    final prefs = await SharedPreferences.getInstance();
    final lastMetric = prefs.getInt('last_metric_${widget.course.code}') ?? 0;
    setState(() {
      _currentIndex = lastMetric;
    });
  }

  Future<void> _saveLastMetric(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_metric_${widget.course.code}', index);
  }

  void _cycleMetric() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % 2;
      _saveLastMetric(_currentIndex);
    });
  }

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
  
  String _getGoalLabel(String goalType) {
    switch (goalType) {
      case 'learn':
        return ' Words Today';
      case 'daily':
        return ' Daily Activity';
      case 'time':
        return ' Minutes Today';
      default:
        return ' Daily Goal';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initPrefs,
      builder: (context, prefsSnapshot) {
        if (prefsSnapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: widget.height,
            child: const Center(
              child: CircularProgressIndicator(),
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
                              ? const Color(0xFF4CAF50)  // Complete: Material green
                              : const Color(0xFFEE9A1D), // Incomplete: Orange
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getGoalProgressText(widget.course, todaySession),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _isGoalMet(widget.course, todaySession)
                              ? const Color(0xFF4CAF50)  // Complete: Material green
                              : const Color(0xFFEE9A1D), // Incomplete: Orange
                          ),
                        ),
                        Text(
                          _getGoalLabel(widget.course.goalType),
                          style: TextStyle(
                            fontSize: 24,
                            color: _isGoalMet(widget.course, todaySession) 
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFEE9A1D),
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
                          color: Color(0xFFEE9A1D),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.course.streak}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFEE9A1D),
                          ),
                        ),
                        const Text(
                          ' Day Streak',
                          style: TextStyle(
                            fontSize: 24,
                            color: Color(0xFFEE9A1D),
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
                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),
        );
      },
    );
  }
}