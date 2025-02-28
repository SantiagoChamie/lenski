import 'package:flutter/material.dart';

class CourseDifficultyText extends StatelessWidget {
  final String difficulty;
  final String intensity;

  const CourseDifficultyText({
    super.key,
    required this.difficulty,
    required this.intensity,
  });

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