import 'package:flutter/material.dart';
import 'package:lenski/utils/proportions.dart';
import '../course_model.dart';
import 'competence_icon.dart';

class CompetenceList extends StatelessWidget {
  final Course course;

  const CompetenceList({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: p.standardPadding() / 2),
        if (course.listening)
          const CompetenceIcon(
            icon: Icons.hearing,
            color: Color(0xFFD52CDE),
          ),
        if (course.speaking)
          const CompetenceIcon(
            icon: Icons.mic,
            color: Color(0xFFDE2C50),
          ),
        if (course.reading)
          const CompetenceIcon(
            icon: Icons.menu_book_sharp,
            color: Color(0xFFEDA42E),
          ),
        if (course.writing)
          const CompetenceIcon(
            icon: Icons.edit_outlined,
            color: Color(0xFFEDE72D),
          ),
      ],
    );
  }
}