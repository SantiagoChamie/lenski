import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lenski/screens/home/add_course/buttons/competence_selector_button.dart';
import 'package:lenski/screens/home/add_course/buttons/goal_selector_button.dart';
import 'package:lenski/screens/home/add_course/course_difficulty_text.dart';
import 'package:lenski/screens/home/add_course/buttons/language_selector_button.dart';
import 'package:lenski/screens/home/courses/course_colors.dart';
import 'package:lenski/utils/languages/languages.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/models/course_model.dart';
import 'package:lenski/data/course_repository.dart';
import 'package:lenski/utils/colors.dart';
import 'package:lenski/utils/fonts.dart';

/// A screen for adding a new course to the app.
///
/// This screen provides an interface for creating a new language learning course with:
/// - Source and target language selection
/// - Competence selection (listening, speaking, reading, writing)
/// - Goal setting (daily and total goals)
///
/// The screen also displays a calculated difficulty level based on the selected languages
/// and an intensity level based on the selected goals and competences.
class AddCourseScreen extends StatefulWidget {
  /// Callback function triggered when the back button is pressed
  final VoidCallback onBack;

  /// Creates an AddCourseScreen widget.
  /// 
  /// [onBack] is the callback function to be called when the back button is pressed.
  /// [lightText] is the text for the light difficulty level.
  /// [lightColor] is the color for the light difficulty level.
  /// [mediumText] is the text for the medium difficulty level.
  /// [mediumColor] is the color for the medium difficulty level.
  const AddCourseScreen({
    super.key,
    required this.onBack,
  });

  @override
  _AddCourseScreenState createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  /// Controller for the course name text field
  final _courseNameController = TextEditingController();
  
  /// Controller for the course description text field
  final _courseDescriptionController = TextEditingController();
  
  /// Repository for course data operations
  final CourseRepository _courseRepository = CourseRepository();

  /// Currently selected target language name
  String _selectedLanguage = 'English';
  
  /// Language code for the selected target language
  String _selectedLanguageCode = languageCodes['English']!;
  
  /// Currently selected source language name
  String _selectedOriginLanguage = 'Español';
  
  /// Language code for the selected source language
  String _selectedOriginLanguageCode = languageCodes['Español']!;

  /// List of selected competences for the course
  final List<String> _selectedCompetences = [];
  
  /// Whether an error message is currently displayed
  bool _isMessageDisplayed = false;
  
  /// Number of words or minutes for daily goal
  int _dailyGoal = 20;
  
  /// Total number of words or minutes to learn (overall course goal)
  int _totalGoal = 2000;
  
  /// Type of goal (learn, daily, or time)
  GoalType _currentGoalType = GoalType.learn;

  /// Updates the goal type when user changes the selection
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
  ///
  /// Validates that:
  /// - Source and target languages are different
  /// - At least one competence is selected
  /// - The course doesn't already exist
  ///
  /// If validation passes, creates and inserts the course, then calls onBack.
  /// Otherwise, displays an appropriate error message.
  void _createCourse() async {
    final localizations = AppLocalizations.of(context)!;
    
    // First check if source and target languages are the same
    if (_selectedLanguageCode == _selectedOriginLanguageCode) {
      if (!_isMessageDisplayed) {
        _isMessageDisplayed = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.sameLanguageError),
            duration: const Duration(seconds: 2),
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
          SnackBar(
            content: Text(localizations.noCompetenceError),
            duration: const Duration(seconds: 2),
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
      goalType: goalTypeStr,
    );

    final existingCourses = await _courseRepository.courses();
    final courseExists = existingCourses.any((course) =>
        course.code == newCourse.code);

    if (courseExists) {
      if (!_isMessageDisplayed) {
        _isMessageDisplayed = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.courseExistsError),
            duration: const Duration(seconds: 2),
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

  /// Updates the selected target language and its associated code.
  ///
  /// @param language The name of the selected language
  /// @param flagUrl The URL of the flag image for the selected language
  /// @param code The language code for the selected language
  void _updateSelectedLanguage(String language, String flagUrl, String code) {
    setState(() {
      _selectedLanguage = language;
      _selectedLanguageCode = code;
    });
  }

  /// Updates the selected source language and its associated code.
  ///
  /// @param language The name of the selected language
  /// @param flagUrl The URL of the flag image for the selected language
  /// @param code The language code for the selected language
  void _updatedSelectedOriginLanguage(String language, String flagUrl, String code) {
    setState(() {
      _selectedOriginLanguage = language;
      _selectedOriginLanguageCode = code;
    });
  }

  /// Toggles a competence selection on or off.
  ///
  /// @param competence The competence type to toggle ('listening', 'speaking', 'reading', 'writing')
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
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.lightGrey,
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
                            Text(
                              localizations.languageColumnTitle,
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                fontFamily: appFonts['Title']
                              ),
                            ),
                            SizedBox(height: p.standardPadding() * 3),
                            LanguageSelectorButton(
                              onLanguageSelected: (language, flagUrl, code) => _updatedSelectedOriginLanguage(language, flagUrl, code),
                              startingLanguage: _selectedOriginLanguage,
                              isSource: false,
                              selectorTitle: localizations.selectSourceLanguage,
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
                              selectorTitle: localizations.selectTargetLanguage,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 400,
                        color: AppColors.grey,
                      ),
                      SizedBox(
                        width: p.createCourseColumnWidth(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(height: p.createCourseButtonHeight()),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  localizations.skillsColumnTitle,
                                  style: TextStyle(
                                    fontSize: 25, 
                                    fontWeight: FontWeight.bold,
                                    fontFamily: appFonts['Title']
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Tooltip(
                                  message: localizations.skillsInfo,
                                  child: const Icon(Icons.help_outline, color: AppColors.darkGrey),
                                ),
                              ],
                            ),
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
                        color: AppColors.grey,
                      ),
                      SizedBox(
                        width: p.createCourseColumnWidth() - 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(height: p.createCourseButtonHeight()),
                            Text(
                              localizations.goalColumnTitle,
                              style: TextStyle(
                                fontSize: 25, 
                                fontWeight: FontWeight.bold,
                                fontFamily: appFonts['Title']
                              ),
                            ),
                            SizedBox(height: p.standardPadding() * 3),
                            SizedBox(
                              width: p.createCourseButtonWidth(),
                              height: p.createCourseButtonHeight(),
                              child: const Icon(Icons.sunny, color: AppColors.yellow, size: 40),
                            ),
                            SizedBox(height: p.standardPadding()),
                            GoalSelectorButton(
                              initialValue: 20,
                              initialGoalType: _currentGoalType,
                              onValueChanged: (value) {
                                setState(() {
                                  _dailyGoal = value;
                                });
                              },
                              onGoalTypeChanged: _updateGoalType,
                            ),
                            SizedBox(height: p.standardPadding()),
                            SizedBox(
                              width: p.createCourseButtonWidth(),
                              height: p.createCourseButtonHeight(),
                              child: const Icon(Icons.nightlight_round_outlined, color: AppColors.lightBlue, size: 40),
                            ),
                            SizedBox(height: p.standardPadding()),
                            GoalSelectorButton(
                              initialValue: 2000,
                              isDaily: false,
                              initialGoalType: _currentGoalType,
                              onValueChanged: (value) {
                                setState(() {
                                  _totalGoal = value;
                                });
                              },
                              onGoalTypeChanged: _updateGoalType,
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
                    color: AppColors.grey,
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
                                  backgroundColor: AppColors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  localizations.startLearningButton,
                                  style: TextStyle(
                                    fontFamily: appFonts['Subtitle'],
                                    fontSize: 30,
                                    color: Colors.white
                                  ),
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