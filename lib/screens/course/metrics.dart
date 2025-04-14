import 'package:flutter/material.dart';
import 'package:lenski/data/metrics_repository.dart';
import 'package:lenski/models/course_metrics_model.dart';
import 'package:lenski/models/course_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Metrics extends StatefulWidget {
  final double height;
  final Course course;

  const Metrics({
    super.key, 
    this.height = 100,
    required this.course,
  });

  @override
  State<Metrics> createState() => _MetricsState();
}

class _MetricsState extends State<Metrics> {
  late final MetricsRepository _repository;
  late Future<CourseMetrics> _metricsFuture;
  late Future<void> _initPrefs;
  int _currentIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _repository = MetricsRepository();
    _metricsFuture = _repository.getCourseMetrics(widget.course);
    _initPrefs = _loadLastMetric();
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
      _currentIndex = (_currentIndex + 1) % 3;
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
          child: FutureBuilder<CourseMetrics>(
            future: _metricsFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final metrics = [
                  SizedBox(
                    height: widget.height,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.psychology,
                          size: 28,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${snapshot.data!.totalCards}',
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
                      ],
                    ),
                  ),
                  SizedBox(
                    height: widget.height,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.menu_book,
                          size: 28,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${snapshot.data!.completedBooks}',
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
                      ],
                    ),
                  ),
                  SizedBox(
                    height: widget.height,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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