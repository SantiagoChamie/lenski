import 'package:flutter/material.dart';
import 'package:lenski/screens/home/add_course/buttons/competence_selector_button.dart';
import 'package:lenski/screens/home/add_course/buttons/goal_selector_button.dart';
import 'package:lenski/screens/home/add_course/course_difficulty_text.dart';
import 'package:lenski/screens/home/add_course/buttons/language_selector_button.dart';
import 'package:lenski/utils/course_colors.dart';
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
  
  String _selectedOriginLanguage = 'Español';
  String _selectedOriginLanguageCode = languageCodes['Español']!;

  final List<String> _selectedCompetences = [];
  bool _isMessageDisplayed = false;
  
  // Add state variables for daily and total goals
  int _dailyGoal = 20;
  int _totalGoal = 2000;
  GoalType _currentGoalType = GoalType.learn; // Add this to track current goal type

  // Add a method to update the goal type
  void _updateGoalType(GoalType type) {
    setState(() {
      _currentGoalType = type;
    });
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _courseDescriptionController.dispose();
    super.dispose();
  }

  /// Creates a new course and adds it to the repository.
  /// If the course already exists, displays a message.
  void _createCourse() async {
    // First check if source and target languages are the same
    if (_selectedLanguageCode == _selectedOriginLanguageCode) {
      if (!_isMessageDisplayed) {
        _isMessageDisplayed = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Source and target languages cannot be the same!'),
            duration: Duration(seconds: 2),
          ),
        ).closed.then((_) {
          _isMessageDisplayed = false;
        });
      }
      return;
    }

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

    // Convert enum GoalType to string goalType
    String goalTypeStr;
    switch (_currentGoalType) {
      case GoalType.learn:
        goalTypeStr = 'learn';
        break;
      case GoalType.daily:
        goalTypeStr = 'daily';
        break;
      case GoalType.time:
        goalTypeStr = 'time';
        break;
    }

    final randomColor = CourseColors.getRandomColor();

    final newCourse = Course(
      name: _selectedLanguage,
      level: 'A1',
      code: _selectedLanguageCode,
      fromCode: _selectedOriginLanguageCode,
      listening: _selectedCompetences.contains('listening'),
      speaking: _selectedCompetences.contains('speaking'),
      reading: _selectedCompetences.contains('reading'),
      writing: _selectedCompetences.contains('writing'),
      color: randomColor,
      dailyGoal: _dailyGoal,
      totalGoal: _totalGoal,
      goalType: goalTypeStr, // Add this line to set the goalType
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
                              onLanguageSelected: (language, flagUrl, code) => _updatedSelectedOriginLanguage(language, flagUrl, code),
                              startingLanguage: _selectedOriginLanguage,
                              isSource: false,
                              selectorTitle: "Select source language",
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
                              selectorTitle: "Select target language",
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
                              competence: "writing",
                              onToggle: _toggleCompetence,
                            ),
                            SizedBox(height: p.standardPadding()),
                            CompetenceSelectorButton(
                              competence: "reading",
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
                            SizedBox(
                              width: p.createCourseButtonWidth(),
                              height: p.createCourseButtonHeight(),
                              child: const Icon(Icons.sunny, color: Color(0xFFEE9A1D), size: 40),
                            ),
                            SizedBox(height: p.standardPadding()),
                            GoalSelectorButton(
                              initialValue: 20,
                              initialGoalType: _currentGoalType, // Pass current goal type
                              onValueChanged: (value) {
                                setState(() {
                                  _dailyGoal = value;
                                });
                              },
                              onGoalTypeChanged: _updateGoalType, // Add this callback
                            ),
                            SizedBox(height: p.standardPadding()),
                            SizedBox(
                              width: p.createCourseButtonWidth(),
                              height: p.createCourseButtonHeight(),
                              child: const Icon(Icons.nightlight_round_outlined, color: Color(0xFF71BDE0), size: 40),
                            ),
                            SizedBox(height: p.standardPadding()),
                            GoalSelectorButton(
                              initialValue: 2000,
                              isDaily: false,
                              initialGoalType: _currentGoalType, // Pass same goal type
                              onValueChanged: (value) {
                                setState(() {
                                  _totalGoal = value;
                                });
                              },
                              onGoalTypeChanged: _updateGoalType, // Add this callback
                            ),
                            SizedBox(height: p.standardPadding()),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Center(
                            child: CourseDifficultyText(
                              dailyWords: _dailyGoal,
                              goalType: _currentGoalType.toString().split('.').last,
                              competences: _selectedCompetences.length,
                              startingLanguage: languageCodes[_selectedOriginLanguage]!,
                              targetLanguage: languageCodes[_selectedLanguage]!,
                              ),
                          ),
                        ), 
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
            right: 16.0,
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