import 'package:flutter/material.dart';
import 'package:lenski/screens/home/add_course/buttons/competence_selector_button.dart';
import 'package:lenski/screens/home/add_course/course_difficulty_text.dart';
import 'package:lenski/screens/home/add_course/buttons/language_selector_button.dart';
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
      body: Stack(
        children: [
          SingleChildScrollView( // Wrap the main content in SingleChildScrollView
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color:  Color(0xFFF5F0F6), // Set the background color
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(33.0),
                      topRight: Radius.circular(33.0),
                    ),
                  ),
                  height: p.createCourseTopHeight(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: p.createCourseColumnWidth()-1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(height: p.createCourseButtonHeight()),
                            const Text("Language", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, fontFamily: "Unbounded")),
                            SizedBox(height: p.standardPadding()*3),
                            const LanguageSelectorButton(),
                            SizedBox(height: p.standardPadding()),
                            SizedBox(width: p.createCourseButtonWidth(), height: p.createCourseButtonHeight(),
                              child: const Icon(Icons.arrow_downward_rounded, color: Colors.black ,size: 40)),
                            SizedBox(height: p.standardPadding()),
                            const LanguageSelectorButton(),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 400,
                        color: Colors.grey,
                      ),
                      SizedBox(
                        width: p.createCourseColumnWidth(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(height: p.createCourseButtonHeight()),
                            const Text("Skills", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, fontFamily: "Unbounded")),
                            SizedBox(height: p.standardPadding()*3),
                            const CompetenceSelectorButton(competence: "listening"),
                            SizedBox(height: p.standardPadding()),
                            const CompetenceSelectorButton(competence: "speaking"),
                            SizedBox(height: p.standardPadding()),
                            const CompetenceSelectorButton(competence: "reading",),
                            SizedBox(height: p.standardPadding()),
                            const CompetenceSelectorButton(competence: "writing"),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 400,
                        color: Colors.grey,
                      ),
                      SizedBox(
                        width: p.createCourseColumnWidth()-1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(height: p.createCourseButtonHeight()),
                            const Text("Goal", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, fontFamily: "Unbounded")),
                            SizedBox(height: p.standardPadding()*3),
                            Text("Coming soon...", style: TextStyle(fontSize: 20, fontFamily: "Telex", color: Colors.grey[700]),),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Third element: Container with background color and Row inside
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFD9D0DB),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(33.0),
                      bottomRight: Radius.circular(33.0),
                    ),
                  ),
                  height: p.createCourseBottomHeight(),
                  child: Padding(
                    padding: EdgeInsets.all(p.standardPadding()),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Center(
                            // Course difficulty text
                            child: CourseDifficultyText(difficulty: "Light", intensity: "medium")
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
                                onPressed: widget.onBack,
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
          Positioned(
            top: 16.0,
            left: 16.0,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: widget.onBack,
            ),
          ),
        ],
      ),
    );
  }
}