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
      body: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F0F6), // Set the background color
          borderRadius: BorderRadius.circular(33.0), // Set the border radius
        ),
        padding: const EdgeInsets.all(0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // First element: Back button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onBack,
                  ),
                ],
              ),
            ),
            // Second element: Row with three placeholders
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Placeholder(fallbackHeight: 50, fallbackWidth: 50),
                Placeholder(fallbackHeight: 50, fallbackWidth: 50),
                Placeholder(fallbackHeight: 50, fallbackWidth: 50),
              ],
            ),
            // Third element: Container with background color and Row inside
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFD9D0DB),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(33.0),
                  bottomRight: Radius.circular(33.0),
                ),
              ),
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  // Add your widgets here
                  Text('Row Content'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}