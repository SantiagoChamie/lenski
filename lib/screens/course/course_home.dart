import 'package:flutter/material.dart';
import 'package:lenski/models/course_model.dart';
import 'package:lenski/screens/course/course_navigator.dart';
import 'package:lenski/screens/course/metrics.dart';
import 'package:lenski/widgets/flag_icon.dart';
import 'package:lenski/utils/languages.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/widgets/ltext.dart';

/// A screen that displays the home page for a specific course.
class CourseHome extends StatelessWidget {
  final Course course;

  /// Creates a CourseHome widget.
  /// 
  /// [course] is the course for which the home screen is being created.
  const CourseHome({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: p.standardPadding() * 2, left: p.standardPadding() * 2, bottom: p.standardPadding() * 2),
          child: Row(
            children: [
              FlagIcon(
                size: 100.0,
                borderWidth: 5.0,
                borderColor: const Color(0xFFD9D0DB),
                language: course.name,
              ),
              SizedBox(width: p.standardPadding()),
              LText(
                text: getWelcomeMessage(course.name),
                style: TextStyle(
                  fontSize: 24.0,
                  color: const Color.fromARGB(255, 0, 0, 0),
                  fontFamily: course.code != 'EL' ? "Unbounded": "Lexend",
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.dotted,
                  decorationColor: const Color.fromARGB(255, 0, 0, 0),
                ),
                fromLanguage: course.fromCode,
                toLanguage: course.code,
                position: 'below',
              ),
              Container(
                margin: const EdgeInsets.only(left: 8.0),
                child: const Tooltip(
                  message: 'Highlight text to see its translation',
                  preferBelow: false,
                  child: Icon(
                    Icons.help_outline,
                    size: 20.0,
                    color: Color.fromARGB(255, 145, 139, 146),
                  ),
                ),
              ),
              const Spacer(),
              Flexible(
                child: Metrics(course: course),
              ),
              SizedBox(width: p.standardPadding()),
            ],
          ),
        ),
        Expanded(
          child: CourseNavigator(course: course),
        ),
      ],
    );
  }
}