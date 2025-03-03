import 'package:flutter/material.dart';
import 'package:lenski/models/course_model.dart';
import 'package:lenski/screens/home/courses/flag_icon.dart';
import 'package:lenski/utils/proportions.dart';

class CourseHome extends StatelessWidget {
  final Course course;
  const CourseHome({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: p.standardPadding()*2, left: p.standardPadding()*2),
          child: Row(
            children: [
              FlagIcon(
                size: 100.0,
                borderWidth: 5.0,
                borderColor: const Color(0xFFD9D0DB),
                imageUrl: course.imageUrl,
              ),
              SizedBox(width: p.standardPadding()),
              const Text(
                'Welcome!',
                style: TextStyle(
                  fontSize: 24.0,
                  color: Color(0xFFEE9A1D),
                  fontFamily: "Unbounded",
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.dotted,
                  decorationColor: Color(0xFFEE9A1D),
                ),
              ),
              const Spacer(),
              Container(
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
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Text(course.name),
          ),
        ),
      ],
    );
  }
}