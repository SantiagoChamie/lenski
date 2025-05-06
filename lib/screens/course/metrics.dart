import 'package:flutter/material.dart';
import 'package:lenski/data/metrics_repository.dart';
import 'package:lenski/data/session_repository.dart';
import 'package:lenski/models/course_metrics_model.dart';
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
  late final MetricsRepository _repository;
  late final SessionRepository _sessionRepository;
  late Future<CourseMetrics> _metricsFuture;
  late Future<Session> _sessionFuture;
  late Future<void> _initPrefs;
  int _currentIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _repository = MetricsRepository();
    _sessionRepository = SessionRepository();
    _refreshData();
    _initPrefs = _loadLastMetric();
  }

  void _refreshData() {
    _metricsFuture = _repository.getCourseMetrics(widget.course);
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
    final lastMetric = prefs.getInt('last_metric_${widget.course.code}') ?? 1;
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
      _currentIndex = (_currentIndex + 1) % 4;
      _saveLastMetric(_currentIndex);
    });
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
          child: FutureBuilder<List<dynamic>>(
            future: Future.wait([_metricsFuture, _sessionFuture]),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final courseMetrics = snapshot.data![0] as CourseMetrics;
                final todaySession = snapshot.data![1] as Session;
                
                final metrics = [
                  SizedBox(
                    height: widget.height,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Icon(
                          Icons.psychology,
                          size: 28,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${courseMetrics.totalCards}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const Text(
                          ' Words Learned',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.blue,
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
                        Icon(
                          Icons.trending_up,
                          size: 28,
                          color: todaySession.wordsAdded >= widget.course.dailyGoal 
                              ? const Color(0xFF4CAF50)  // Complete: Material green
                              : const Color(0xFFEE9A1D), // Incomplete: Orange (matches daily goal UI)
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${todaySession.wordsAdded}/${widget.course.dailyGoal}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: todaySession.wordsAdded >= widget.course.dailyGoal
                              ? const Color(0xFF4CAF50)  // Complete: Material green
                              : const Color(0xFFEE9A1D), // Incomplete: Orange (matches daily goal UI)
                          ),
                        ),
                        Text(
                          ' Daily Goal',
                          style: TextStyle(
                            fontSize: 24,
                            color: todaySession.wordsAdded >= widget.course.dailyGoal 
                              ? const Color(0xFF4CAF50)  // Complete: Material green
                              : const Color(0xFFEE9A1D), // Incomplete: Orange (matches daily goal UI)
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
                          Icons.menu_book,
                          size: 28,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${courseMetrics.completedBooks}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const Text(
                          ' Books Finished',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.green,
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
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.course.streak}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const Text(
                          ' Day Streak',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.orange,
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