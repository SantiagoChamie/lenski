import 'package:flutter/material.dart';
import 'package:lenski/data/metrics_repository.dart';
import 'package:lenski/models/course_metrics_model.dart';
import 'package:lenski/models/course_model.dart';

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
  int _currentIndex = 0;
  late final MetricsRepository _repository;
  late Future<CourseMetrics> _metricsFuture;
  
  @override
  void initState() {
    super.initState();
    _repository = MetricsRepository();
    _metricsFuture = _repository.getCourseMetrics(widget.course);
  }

  void _cycleMetric() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _cycleMetric,
      child: FutureBuilder<CourseMetrics>(
        future: _metricsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final metrics = [
              Container(
                height: widget.height,
                color: Colors.blue,
                child: Center(
                  child: Text(
                    '${snapshot.data!.totalCards} Cards',
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
              Container(
                height: widget.height,
                color: Colors.green,
                child: Center(
                  child: Text(
                    '${snapshot.data!.completedBooks} Books',
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
              Container(
                height: widget.height,
                color: Colors.orange,
                child: const Center(
                  child: Text(
                    'Metric 3',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
            ];
            return metrics[_currentIndex];
          }
          return Container(
            height: widget.height,
            color: Colors.grey,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }
}