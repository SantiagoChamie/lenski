import 'package:flutter/material.dart';
import 'package:lenski/utils/proportions.dart';
import '../../../models/course_model.dart';

class CompetenceList extends StatelessWidget {
  final Course course;

  const CompetenceList({super.key, required this.course});

  Color _getColor(String type) {
    switch (type) {
      case 'listening':
        return const Color(0xFFD52CDE);
      case 'speaking':
        return const Color(0xFFDE2C50);
      case 'reading':
        return const Color(0xFFEDA42E);
      case 'writing':
        return const Color(0xFFEDE72D);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    final dotSize = p.standardPadding()/2; // Smaller size for dots

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: p.standardPadding()),
        if (course.listening) ...[
          Container(
            height: dotSize,
            width: dotSize,
            decoration: BoxDecoration(
              color: _getColor('listening'),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(height: p.standardPadding() / 4),
        ],
        if (course.speaking) ...[
          Container(
            height: dotSize,
            width: dotSize,
            decoration: BoxDecoration(
              color: _getColor('speaking'),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(height: p.standardPadding() / 4),
        ],
        if (course.reading) ...[
          Container(
            height: dotSize,
            width: dotSize,
            decoration: BoxDecoration(
              color: _getColor('reading'),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(height: p.standardPadding() / 4),
        ],
        if (course.writing) ...[
          Container(
            height: dotSize,
            width: dotSize,
            decoration: BoxDecoration(
              color: _getColor('writing'),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(height: p.standardPadding() / 4),
        ],
      ],
    );
  }
}