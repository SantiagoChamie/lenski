import 'package:flutter/material.dart';
import 'package:lenski/models/course_model.dart';

class ReviewScreen extends StatelessWidget {
  final Course course;

  const ReviewScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(course.name),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Text('Reviewing course: ${course.name}'),
      ),
    );
  }
}