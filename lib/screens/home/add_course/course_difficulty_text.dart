import 'package:flutter/material.dart';

/// A widget that displays the difficulty and intensity of a course as styled text.
class CourseDifficultyText extends StatelessWidget {
  final String difficulty;
  final String intensity;

  /// Creates a CourseDifficultyText widget.
  /// 
  /// [difficulty] is the difficulty level of the course.
  /// [intensity] is the intensity level of the course.
  const CourseDifficultyText({
    super.key,
    required this.difficulty,
    required this.intensity,
  });

  /// Returns the appropriate color based on the difficulty or intensity level.
  Color _getColor(String level) {
    switch (level.toLowerCase()) {
      case 'light':
      case 'low':
        return const Color(0xFF0BAE44);
      case 'medium':
        return const Color(0xFFEE9A1D);
      case 'heavy':
      case 'high':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontFamily: "Varela Round",
          fontSize: 30,
          color: Colors.black,
        ),
        children: [
          TextSpan(
            text: difficulty,
            style: TextStyle(color: _getColor(difficulty)),
          ),
          const TextSpan(text: " course with "),
          TextSpan(
            text: intensity,
            style: TextStyle(color: _getColor(intensity)),
          ),
          const TextSpan(text: " intensity"),
        ],
      ),
    );
  }
}