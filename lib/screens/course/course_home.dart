import 'package:flutter/material.dart';
import 'package:lenski/models/course_model.dart';
import 'package:lenski/screens/course/course_navigator.dart';
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
                imageUrl: course.imageUrl,
              ),
              SizedBox(width: p.standardPadding()),
              //TODO: fix bug where the text keeps displaying even after navigation event
              LText(
                text: welcomeMessages[course.name]!,
                style: const TextStyle(
                  fontSize: 24.0,
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontFamily: "Unbounded",
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.dotted,
                  decorationColor: Color.fromARGB(255, 0, 0, 0),
                ),
                fromLanguage: course.fromCode,
                toLanguage: course.code,
                position: 'below',
              ),
              const Spacer(),
              /*Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFD9D0DB),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), bottomLeft: Radius.circular(10.0)),
                ),
                child: IconButton(
                  icon: const Icon(Icons.star, color: Colors.black, size: 30.0),
                  onPressed: () {
                    // Add your onPressed code here!
                  },
                ),
              ),*/
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