import 'package:flutter/material.dart';
import 'package:lenski/utils/proportions.dart';
import '../../../models/course_model.dart';
import 'competence_icon.dart';

/// A list of competences for a course
class CompetenceList extends StatelessWidget {
  final Course course;

  const CompetenceList({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    final iconSize = p.standardPadding() * 2; // Example size, adjust as needed

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: p.standardPadding()),
        if (course.listening) ...[
          CompetenceIcon(
            type: 'listening',
            size: iconSize,
          ),
          SizedBox(height: p.standardPadding() / 2),
        ],
        if (course.speaking) ...[
          CompetenceIcon(
            type: 'speaking',
            size: iconSize,
          ),
          SizedBox(height: p.standardPadding() / 2),
        ],
        if (course.reading) ...[
          CompetenceIcon(
            type: 'reading',
            size: iconSize,
          ),
          SizedBox(height: p.standardPadding() / 2),
        ],
        if (course.writing) ...[
          CompetenceIcon(
            type: 'writing',
            size: iconSize,
          ),
          SizedBox(height: p.standardPadding() / 2),
        ],
      ],
    );
  }
}