import 'dart:math';

import 'package:flutter/material.dart';
//import 'package:lenski/screens/home/add_course/buttons/competence_selector_button.dart';
import 'package:lenski/screens/home/add_course/course_difficulty_text.dart';
import 'package:lenski/screens/home/add_course/buttons/language_selector_button.dart';
import 'package:lenski/utils/languages.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/models/course_model.dart';
import 'package:lenski/data/course_repository.dart';

/// A screen for adding a new course
class AddCourseScreen extends StatefulWidget {
  final VoidCallback onBack;
  final String lightText;
  final Color lightColor;
  final String mediumText;
  final Color mediumColor;
  final String durationText;
  final String dailyTimeText;

  /// Creates an AddCourseScreen widget.
  /// 
  /// [onBack] is the callback function to be called when the back button is pressed.
  /// [lightText] is the text for the light difficulty level.
  /// [lightColor] is the color for the light difficulty level.
  /// [mediumText] is the text for the medium difficulty level.
  /// [mediumColor] is the color for the medium difficulty level.
  /// [durationText] is the text for the course duration.
  /// [dailyTimeText] is the text for the daily time commitment.
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

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _courseNameController = TextEditingController();
  final _courseDescriptionController = TextEditingController();
  final CourseRepository _courseRepository = CourseRepository();

  //TODO: make this elegant
  String _selectedLanguage = 'English';
  String _selectedLanguageCode = languageCodes['English']!;
  String _selectedFlagUrl = languageFlags['English']!;
  
  String _selectedOriginLanguage = 'Español';
  String _selectedOriginLanguageCode = languageCodes['Español']!;

  // final List<String> _selectedCompetences = [];
  bool _isMessageDisplayed = false;

  @override
  void dispose() {
    _courseNameController.dispose();
    _courseDescriptionController.dispose();
    super.dispose();
  }

  /// Creates a new course and adds it to the repository.
  /// If the course already exists, displays a message.
  void _createCourse() async {
    // Check if at least one competence is selected
    // if (_selectedCompetences.isEmpty) {
    //   if (!_isMessageDisplayed) {
    //     _isMessageDisplayed = true;
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(
    //         content: Text('Please select at least one competence!'),
    //         duration: Duration(seconds: 2),
    //       ),
    //     ).closed.then((_) {
    //       _isMessageDisplayed = false;
    //     });
    //   }
    //   return;
    // }

    //TODO: color selector option
    final List<Color> pastelColors = [
      const Color(0xFFFFCC85), // Light Orange
      const Color(0xFF99CCFF), // Light Blue
      const Color(0xFFFFAEAE), // Light Red
    ];

    final random = Random();
    final randomColor = pastelColors[random.nextInt(pastelColors.length)];

    final newCourse = Course(
      name: _selectedLanguage,
      level: 'A1',
      code: _selectedLanguageCode,
      fromCode: _selectedOriginLanguageCode,
      listening: false, // _selectedCompetences.contains('listening'),
      speaking: false, // _selectedCompetences.contains('speaking'),
      reading: false, // _selectedCompetences.contains('reading'),
      writing: false, // _selectedCompetences.contains('writing'),
      color: randomColor,
      imageUrl: _selectedFlagUrl,
    );

    final existingCourses = await _courseRepository.courses();
    final courseExists = existingCourses.any((course) =>
        course.code == newCourse.code);

    if (courseExists) {
      if (!_isMessageDisplayed) {
        _isMessageDisplayed = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course already exists!'),
            duration: Duration(seconds: 2),
          ),
        ).closed.then((_) {
          _isMessageDisplayed = false;
        });
      }
    } else {
      await _courseRepository.insertCourse(newCourse);
      widget.onBack();
    }
  }

  /// Updates the selected language and its associated flag URL and code.
  void _updateSelectedLanguage(String language, String flagUrl, String code) {
    setState(() {
      _selectedLanguage = language;
      _selectedFlagUrl = flagUrl;
      _selectedLanguageCode = code;
    });
  }

  /// Updates the selected origin language and its associated flag URL and code.
  void _updatedSelectedOriginLanguage(String language, String flagUrl, String code) {
    setState(() {
      _selectedOriginLanguage = language;
      _selectedOriginLanguageCode = code;
    });
  }

  // void _toggleCompetence(String competence) {
  //   setState(() {
  //     if (_selectedCompetences.contains(competence)) {
  //       _selectedCompetences.remove(competence);
  //     } else {
  //       _selectedCompetences.add(competence);
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F0F6),
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
                        width: p.createCourseColumnWidth() - 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(height: p.createCourseButtonHeight()),
                            const Text("Language", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, fontFamily: "Unbounded")),
                            SizedBox(height: p.standardPadding() * 3),
                            LanguageSelectorButton(
                              onLanguageSelected: (language, flagUrl, code) => _updatedSelectedOriginLanguage(language, flagUrl, code),
                              startingLanguage: _selectedOriginLanguage,
                              isSource: false,
                            ),
                            SizedBox(height: p.standardPadding()),
                            SizedBox(
                              width: p.createCourseButtonWidth(),
                              height: p.createCourseButtonHeight(),
                              child: const Icon(Icons.arrow_downward_rounded, color: Colors.black, size: 40),
                            ),
                            SizedBox(height: p.standardPadding()),
                            LanguageSelectorButton(
                              onLanguageSelected: (language, flagUrl, code) => _updateSelectedLanguage(language, flagUrl, code),
                              startingLanguage: _selectedLanguage,
                            ),
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
                            SizedBox(height: p.standardPadding() * 3),
                            Text(
                              "Coming soon...",
                              style: TextStyle(fontSize: 20, fontFamily: "Telex", color: Colors.grey[700]),
                            ),
                            // CompetenceSelectorButton(
                            //   competence: "listening",
                            //   onToggle: _toggleCompetence,
                            // ),
                            // SizedBox(height: p.standardPadding()),
                            // CompetenceSelectorButton(
                            //   competence: "speaking",
                            //   onToggle: _toggleCompetence,
                            // ),
                            // SizedBox(height: p.standardPadding()),
                            // CompetenceSelectorButton(
                            //   competence: "reading",
                            //   onToggle: _toggleCompetence,
                            // ),
                            // SizedBox(height: p.standardPadding()),
                            // CompetenceSelectorButton(
                            //   competence: "writing",
                            //   onToggle: _toggleCompetence,
                            // ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 400,
                        color: Colors.grey,
                      ),
                      SizedBox(
                        width: p.createCourseColumnWidth() - 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(height: p.createCourseButtonHeight()),
                            const Text("Goal", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, fontFamily: "Unbounded")),
                            SizedBox(height: p.standardPadding() * 3),
                            Text(
                              "Coming soon...",
                              style: TextStyle(fontSize: 20, fontFamily: "Telex", color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
                      mainAxisAlignment: MainAxisAlignment.center, //TODO remove when returning difficulty text
                      children: [
                        //TODO: implement difficulty text
                        /* const Expanded(
                          child: Center(
                            child: CourseDifficultyText(difficulty: "Light", intensity: "medium"),
                          ),
                        ), 
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(widget.durationText, style: const TextStyle(fontFamily: "Sansation", fontSize: 20)),
                            Text(widget.dailyTimeText, style: const TextStyle(fontFamily: "Sansation", fontSize: 20)),
                          ],
                        ), */
                        const SizedBox(width: 16),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _createCourse,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2C73DE),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
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