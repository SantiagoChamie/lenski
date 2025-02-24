import 'package:flutter/material.dart';

class AddCourseScreen extends StatefulWidget {
  final VoidCallback onBack;

  const AddCourseScreen({super.key, required this.onBack});

  @override
  _AddCourseScreenState createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _courseNameController = TextEditingController();
  final _courseDescriptionController = TextEditingController();

  @override
  void dispose() {
    _courseNameController.dispose();
    _courseDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ClipRRect(
        borderRadius: BorderRadius.circular(33.0), // Set the border radius here
        child: Container(
          color: const Color(0xFFD9D0DB), // Set the background color to black
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: widget.onBack,
                  ),
                  const Text('Add New Course'),
                ],
              ),
              const Expanded(
                child: Text("gello"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}