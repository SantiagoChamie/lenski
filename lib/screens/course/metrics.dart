import 'package:flutter/material.dart';

class Metrics extends StatefulWidget {
  final double height;

  const Metrics({super.key, this.height=100});

  @override
  State<Metrics> createState() => _MetricsState();
}

class _MetricsState extends State<Metrics> {
  int _currentIndex = 0;
  
  late final List<Widget> _metrics;

  @override
  void initState() {
    super.initState();
    _metrics = [
      Container(
        height: widget.height,
        color: Colors.blue,
        child: const Center(
          child: Text(
            'Metric 1',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
      ),
      Container(
        height: widget.height,
        color: Colors.red,
        child: const Center(
          child: Text(
            'Metric 2',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
      ),
      Container(
        height: widget.height,
        color: Colors.green,
        child: const Center(
          child: Text(
            'Metric 3',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
      ),
    ];
  }

  void _cycleMetric() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _metrics.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _cycleMetric,
      child: _metrics[_currentIndex],
    );
  }
}