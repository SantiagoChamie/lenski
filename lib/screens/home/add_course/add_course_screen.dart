import 'package:flutter/material.dart';
import 'package:lenski/screens/home/add_course/language_selector_button.dart';
import 'package:lenski/utils/proportions.dart';

class AddCourseScreen extends StatefulWidget {
  final VoidCallback onBack;
  final String lightText;
  final Color lightColor;
  final String mediumText;
  final Color mediumColor;
  final String durationText;
  final String dailyTimeText;

  const AddCourseScreen({
    super.key,
    required this.onBack,
    this.lightText = "Light",
    this.lightColor = const Color(0xFF0BAE44),
    this.mediumText = "medium",
    this.mediumColor = const Color(0xFFEE9A1D),
    this.durationText = "<150 days",
    this.dailyTimeText = "15 min/day",
  });

  @override
  _AddCourseScreenState createState() => _AddCourseScreenState();
}

void onPressed() {
  // Define what happens when the button is pressed
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
    final p = Proportions(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F0F6), // Set the background color
          borderRadius: BorderRadius.circular(33.0), // Set the border radius
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // First element: Back button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onBack,
                  ),
                ],
              ),
            ),
            // Second element: Row with three columns and separators
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text("Language", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, fontFamily: "Unbounded")),
                      SizedBox(height: p.standardPadding()*3),
                      LanguageSelectorButton(),
                      const Icon(Icons.arrow_downward_rounded, color: Colors.black),
                      LanguageSelectorButton(),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 400,
                    color: Colors.grey,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text("Skills", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, fontFamily: "Unbounded")),
                      SizedBox(height: p.standardPadding()*3),
                      ElevatedButton(onPressed: () {}, child: const Text("Button 1")),
                      ElevatedButton(onPressed: () {}, child: const Text("Button 2")),
                      ElevatedButton(onPressed: () {}, child: const Text("Button 3")),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 400,
                    color: Colors.grey,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text("Goal", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, fontFamily: "Unbounded")),
                      SizedBox(height: p.standardPadding()*3),
                      ElevatedButton(onPressed: () {}, child: const Text("Button 1")),
                      ElevatedButton(onPressed: () {}, child: const Text("Button 2")),
                      ElevatedButton(onPressed: () {}, child: const Text("Button 3")),
                    ],
                  ),
                ],
              ),
            ),
            // TODO: make third element independent from whole 
            // Third element: Container with background color and Row inside
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFD9D0DB),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(33.0),
                  bottomRight: Radius.circular(33.0),
                ),
              ),
              height: 150,
              child: Padding(
                padding: EdgeInsets.all(p.standardPadding() * 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontFamily: "Varela Round",
                              fontSize: 30,
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(
                                text: widget.lightText,
                                style: TextStyle(color: widget.lightColor),
                              ),
                              const TextSpan(text: " course with "),
                              TextSpan(
                                text: widget.mediumText,
                                style: TextStyle(color: widget.mediumColor),
                              ),
                              const TextSpan(text: " intensity"),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(widget.durationText, style: const TextStyle(fontFamily: "Sansation", fontSize: 20)),
                        Text(widget.dailyTimeText, style: const TextStyle(fontFamily: "Sansation", fontSize: 20)),
                      ],
                    ),
                    const SizedBox(width: 16), // Add some spacing between the second and third elements
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2C73DE), // Background color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10), // Rectangular border
                              ),
                            ),
                            child: const Text(
                              "Start learning!",
                              style: TextStyle(fontFamily: "Telex", fontSize: 30, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}