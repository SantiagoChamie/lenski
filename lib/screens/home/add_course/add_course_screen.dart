import 'package:flutter/material.dart';

class AddCourseScreen extends StatefulWidget {
  @override
  _AddCourseScreenState createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _courseNameController = TextEditingController();
  final _courseDescriptionController = TextEditingController();

  @override
  void dispose() {
    _courseNameController.dispose();
    _courseDescriptionController.dispose();
    super.dispose();
  }

  void _addCourse() {
    if (_formKey.currentState!.validate()) {
      // Add course to the list (this is just a placeholder, implement your logic here)
      print('Course Name: ${_courseNameController.text}');
      print('Course Description: ${_courseDescriptionController.text}');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Course'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _courseNameController,
                decoration: InputDecoration(labelText: 'Course Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a course name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _courseDescriptionController,
                decoration: InputDecoration(labelText: 'Course Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a course description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addCourse,
                child: Text('Add Course'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}