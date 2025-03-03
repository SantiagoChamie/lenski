import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lenski/screens/home/add_course/buttons/competence_selector_button.dart';
import 'package:lenski/screens/home/add_course/course_difficulty_text.dart';
import 'package:lenski/screens/home/add_course/buttons/language_selector_button.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/models/course_model.dart';
import 'package:lenski/data/course_repository.dart';

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

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _courseNameController = TextEditingController();
  final _courseDescriptionController = TextEditingController();
  final CourseRepository _courseRepository = CourseRepository();

  String _selectedLanguage = 'English';
  String _selectedFlagUrl = 'https://upload.wikimedia.org/wikipedia/en/thumb/a/ae/Flag_of_the_United_Kingdom.svg/640px-Flag_of_the_United_Kingdom.svg.png';
  String _selectedOriginLanguage = 'Español';
  final List<String> _selectedCompetences = [];
  bool _isMessageDisplayed = false;

  @override
  void dispose() {
    _courseNameController.dispose();
    _courseDescriptionController.dispose();
    super.dispose();
  }

  void _createCourse() async {
    // Check if at least one competence is selected
    if (_selectedCompetences.isEmpty) {
      if (!_isMessageDisplayed) {
        _isMessageDisplayed = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one competence!'),
            duration: Duration(seconds: 2),
          ),
        ).closed.then((_) {
          _isMessageDisplayed = false;
        });
      }
      return;
    }

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
      code: _selectedLanguage.substring(0, 2).toLowerCase(),
      fromCode: _selectedOriginLanguage.substring(0, 2).toLowerCase(),
      listening: _selectedCompetences.contains('listening'),
      speaking: _selectedCompetences.contains('speaking'),
      reading: _selectedCompetences.contains('reading'),
      writing: _selectedCompetences.contains('writing'),
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

  void _updateSelectedLanguage(String language, String flagUrl) {
    setState(() {
      _selectedLanguage = language;
      _selectedFlagUrl = flagUrl;
    });
  }

  void _updatedSelectedOriginLanguage(String language, String flagUrl) {
    setState(() {
      _selectedOriginLanguage = language;
    });
  }

  void _toggleCompetence(String competence) {
    setState(() {
      if (_selectedCompetences.contains(competence)) {
        _selectedCompetences.remove(competence);
      } else {
        _selectedCompetences.add(competence);
      }
    });
  }

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
                              onLanguageSelected: (language, flagUrl) => _updatedSelectedOriginLanguage(language, flagUrl),
                              startingLanguage: _selectedOriginLanguage,
                            ),
                            SizedBox(height: p.standardPadding()),
                            SizedBox(
                              width: p.createCourseButtonWidth(),
                              height: p.createCourseButtonHeight(),
                              child: const Icon(Icons.arrow_downward_rounded, color: Colors.black, size: 40),
                            ),
                            SizedBox(height: p.standardPadding()),
                            LanguageSelectorButton(
                              onLanguageSelected: (language, flagUrl) => _updateSelectedLanguage(language, flagUrl),
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
                            CompetenceSelectorButton(
                              competence: "listening",
                              onToggle: _toggleCompetence,
                            ),
                            SizedBox(height: p.standardPadding()),
                            CompetenceSelectorButton(
                              competence: "speaking",
                              onToggle: _toggleCompetence,
                            ),
                            SizedBox(height: p.standardPadding()),
                            CompetenceSelectorButton(
                              competence: "reading",
                              onToggle: _toggleCompetence,
                            ),
                            SizedBox(height: p.standardPadding()),
                            CompetenceSelectorButton(
                              competence: "writing",
                              onToggle: _toggleCompetence,
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
                      children: [
                        const Expanded(
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
                        ),
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