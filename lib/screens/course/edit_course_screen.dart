import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lenski/screens/home/add_course/buttons/competence_selector_button.dart';
import 'package:lenski/screens/home/add_course/buttons/goal_selector_button.dart';
import 'package:lenski/screens/home/add_course/course_difficulty_text.dart';
import 'package:lenski/screens/home/add_course/buttons/language_selector_button.dart';
import 'package:lenski/utils/languages/languages.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/utils/colors.dart';
import 'package:lenski/utils/fonts.dart';
import 'package:lenski/models/course_model.dart';
import 'package:lenski/data/course_repository.dart';
import 'package:lenski/data/session_repository.dart';

/// A screen for editing an existing course.
///
/// This component provides an interface for modifying various course parameters:
/// - Source language (the language the user already knows)
/// - Competences selection (listening, speaking, reading, writing)
/// - Daily and total goal settings
///
/// The screen also displays statistics about the course progress and helps ensure
/// users don't set invalid goals (e.g., lower than current progress).
class EditCourseScreen extends StatefulWidget {
  /// Callback function triggered when the back button is pressed
  final Function(Course updatedCourse) onBack;
  
  /// The course being edited
  final Course course;

  /// Creates an EditCourseScreen widget.
  /// 
  /// [onBack] is the callback function to be called when the back button is pressed.
  /// It returns the updated course, or the original course if edits are cancelled.
  /// 
  /// [course] is the course to be edited.
  const EditCourseScreen({
    super.key,
    required this.onBack,
    required this.course,
  });

  @override
  _EditCourseScreenState createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  /// Repository for course data operations
  final CourseRepository _courseRepository = CourseRepository();
  
  /// Repository for session data operations
  final SessionRepository _sessionRepository = SessionRepository();
  
  /// Focus node for keyboard events (e.g., Escape key to cancel)
  final FocusNode _keyboardFocusNode = FocusNode();
  
  /// Total study time in minutes for this course
  int _totalMinutesStudied = 0;
  
  /// Total number of words added in this course
  int _totalWordsAdded = 0;
  
  /// Total number of words reviewed in this course
  int _totalWordsReviewed = 0;
  
  /// Total number of lines read in this course
  int _totalLinesRead = 0;
  
  /// Number of days with any learning activity
  int _daysPracticed = 0;
  
  /// Whether statistics are currently being loaded
  bool _isLoadingStats = true;

  /// Currently selected source language name
  late String _selectedOriginLanguage;
  
  /// Language code for the selected source language
  late String _selectedOriginLanguageCode;
  
  /// List of selected competences for the course
  final List<String> _selectedCompetences = [];
  
  /// Whether an error message is currently displayed
  bool _isMessageDisplayed = false;
  
  /// Number of words or minutes for daily goal
  late int _dailyGoal;
  
  /// Total number of words or minutes to learn (overall course goal)
  late int _totalGoal;
  
  /// Type of goal (learn, daily, or time)
  late GoalType _currentGoalType;

  @override
  void initState() {
    super.initState();
    
    // Initialize values from the existing course
    _selectedOriginLanguageCode = widget.course.fromCode;
    _selectedOriginLanguage = codeToLanguage[widget.course.fromCode]!;
    
    // Initialize competences
    if (widget.course.reading) _selectedCompetences.add('reading');
    if (widget.course.writing) _selectedCompetences.add('writing');
    if (widget.course.speaking) _selectedCompetences.add('speaking');
    if (widget.course.listening) _selectedCompetences.add('listening');
    
    _dailyGoal = widget.course.dailyGoal;
    _totalGoal = widget.course.totalGoal;
    
    // Convert string goalType to enum GoalType
    switch (widget.course.goalType) {
      case 'learn':
        _currentGoalType = GoalType.learn;
        break;
      case 'daily':
        _currentGoalType = GoalType.daily;
        break;
      case 'time':
        _currentGoalType = GoalType.time;
        break;
      default:
        _currentGoalType = GoalType.learn;
    }
    
    // Load statistics
    _loadStatistics();
    
    // Request focus when screen initializes (for keyboard shortcuts)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _keyboardFocusNode.requestFocus();
    });
  }
  
  @override
  void dispose() {
    _keyboardFocusNode.dispose(); // Dispose the focus node
    super.dispose();
  }

  /// Loads and calculates course statistics from the session repository.
  ///
  /// This method:
  /// - Retrieves all sessions for the current course
  /// - Calculates total statistics (time, words, lines read, etc.)
  /// - Identifies unique days with learning activity
  /// - Updates state variables with the calculated values
  Future<void> _loadStatistics() async {
    setState(() {
      _isLoadingStats = true;
    });
    
    final sessions = await _sessionRepository.getSessionsByCourse(widget.course.code);
    
    int minutes = 0;
    int words = 0;
    int deleted = 0;
    int reviewed = 0;
    int lines = 0;
    final Set<int> daysWithActivity = {}; // Set to track unique days with activity
    
    for (var session in sessions) {
      minutes += session.minutesStudied;
      words += session.wordsAdded;
      deleted += session.cardsDeleted;
      reviewed += session.wordsReviewed;
      lines += session.linesRead;
      
      // Add to days practiced if any activity was recorded
      if (session.wordsAdded > 0 || 
          session.wordsReviewed > 0 || 
          session.linesRead > 0 ||
          session.minutesStudied > 0) {
        daysWithActivity.add(session.date);
      }
    }
    
    // Calculate number of active competences
    int activeCompetences = 0;
    if (widget.course.reading) activeCompetences++;
    if (widget.course.writing) activeCompetences++;
    if (widget.course.speaking) activeCompetences++;
    if (widget.course.listening) activeCompetences++;
    
    // Ensure we don't divide by zero
    activeCompetences = activeCompetences > 0 ? activeCompetences : 1;
    
    // Calculate adjusted words added
    int adjustedWords = words - (deleted * (1 / activeCompetences)).floor();
    
    setState(() {
      _totalMinutesStudied = minutes;
      _totalWordsAdded = adjustedWords > 0 ? adjustedWords : 0;
      _totalWordsReviewed = reviewed;
      _totalLinesRead = lines;
      _daysPracticed = daysWithActivity.length;
      _isLoadingStats = false;
    });
  }

  /// Updates the course in the repository with the edited values.
  ///
  /// This method:
  /// - Validates that languages are not the same
  /// - Checks that at least one competence is selected
  /// - Validates that new goals don't conflict with existing progress
  /// - Creates and saves the updated course if all validations pass
  void _updateCourse() async {
    final localizations = AppLocalizations.of(context)!;
    
    // First check if source and target languages are the same
    if (_selectedOriginLanguageCode == widget.course.code) {
      if (!_isMessageDisplayed) {
        _isMessageDisplayed = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.sameLanguageError),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.error,
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
            backgroundColor: AppColors.error,
          ),
        ).closed.then((_) {
          _isMessageDisplayed = false;
        });
      }
      return;
    }

    // Check if total goal is valid based on goal type
    bool isGoalValid = true;
    String errorMessage = '';

    switch (_currentGoalType) {
      case GoalType.learn:
        if (_totalGoal < _totalWordsAdded) {
          isGoalValid = false;
          errorMessage = localizations.goalTooSmallWords(_totalWordsAdded);
        }
        break;
      case GoalType.daily:
        if (_totalGoal < _daysPracticed) {
          isGoalValid = false;
          errorMessage = localizations.goalTooSmallDays(_daysPracticed);
        }
        break;
      case GoalType.time:
        if (_totalGoal*60 < _totalMinutesStudied) {
          isGoalValid = false;
          errorMessage = localizations.goalTooSmallTime(_formatTime(_totalMinutesStudied));
        }
        break;
    }

    if (!isGoalValid && !_isMessageDisplayed) {
      _isMessageDisplayed = true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.error,
        ),
      ).closed.then((_) {
        _isMessageDisplayed = false;
      });
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

    final updatedCourse = widget.course.copyWith(
      fromCode: _selectedOriginLanguageCode,
      listening: _selectedCompetences.contains('listening'),
      speaking: _selectedCompetences.contains('speaking'),
      reading: _selectedCompetences.contains('reading'),
      writing: _selectedCompetences.contains('writing'),
      dailyGoal: _dailyGoal,
      totalGoal: _totalGoal,
      goalType: goalTypeStr,
    );
    
    await _courseRepository.updateCourse(updatedCourse);
    widget.onBack(updatedCourse);  // Pass the updated course back to the parent
  }

  /// Updates the selected source language and its associated code.
  ///
  /// @param language The name of the selected language
  /// @param flagUrl The URL of the flag image for the selected language
  /// @param code The language code for the selected language
  void _updateSelectedOriginLanguage(String language, String flagUrl, String code) {
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

  /// Updates the current goal type.
  ///
  /// @param type The new goal type to set
  void _updateGoalType(GoalType type) {
    setState(() {
      _currentGoalType = type;
    });
  }

  /// Formats a duration in minutes into a human-readable string.
  ///
  /// This method handles different time scales appropriately:
  /// - Less than an hour: "X min"
  /// - Less than a day: "X h Y min"
  /// - Less than a week: "X days Y h"
  /// - More than a week: "X days"
  /// - More than a year: "X years Y days" or "X years"
  ///
  /// @param minutes The number of minutes to format
  /// @return A formatted time string
  String _formatTime(int minutes) {
    final localizations = AppLocalizations.of(context)!;
    
    if (minutes < 60) {
      return localizations.minutesFormat(minutes);
    } else if (minutes < 24 * 60) { // Less than a day
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return mins > 0 
          ? localizations.hoursMinutesFormat(hours, mins)
          : localizations.hoursFormat(hours);
    } else if (minutes < 365 * 24 * 60) { // Less than a year
      final days = minutes ~/ (24 * 60);
      final remainingMinutes = minutes % (24 * 60);
      final hours = remainingMinutes ~/ 60;
      
      if (days > 7) {
        // For more than a week, just show days
        return localizations.daysFormat(days);
      } else {
        // Show days and hours for less than a week
        return hours > 0 
            ? localizations.daysHoursFormat(days, hours, days == 1 ? '' : 's') 
            : localizations.daysFormat(days);
      }
    } else { // Years or more
      final years = minutes ~/ (365 * 24 * 60);
      final remainingMinutes = minutes % (365 * 24 * 60);
      final days = remainingMinutes ~/ (24 * 60);
      
      if (days > 0) {
        return localizations.yearsDaysFormat(years, days, years == 1 ? '' : 's', days == 1 ? '' : 's');
      } else {
        return localizations.yearsFormat(years, years == 1 ? '' : 's');
      }
    }
  }
  
  /// Creates a statistics box with an icon, label and value.
  ///
  /// @param icon The icon to display
  /// @param label The descriptive label text
  /// @param value The value to display
  /// @return A styled container displaying the statistic
  Widget _buildStatisticBox(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.grey.withAlpha(128), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.blue, size: 24),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.darkGrey,
                  fontFamily: appFonts['Paragraph'],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: appFonts['Paragraph'],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    final localizations = AppLocalizations.of(context)!;
    
    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      onKeyEvent: (KeyEvent event) {
        // Only process KeyDownEvent
        if (event is KeyDownEvent) {
          // Check for Escape key
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            widget.onBack(widget.course); // Return original course when cancelled
          }
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              // Main content
              Padding(
                padding: EdgeInsets.only(
                  left: p.standardPadding(),
                  right: p.standardPadding(),
                  bottom: p.standardPadding()
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [                  
                    // Main content - make it expandable
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(p.standardPadding()),
                              decoration: BoxDecoration(
                                color: AppColors.lightGrey,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Source language selection only
                                  Text(
                                    localizations.sourceLanguageTitle, 
                                    style: TextStyle(
                                      fontSize: 18, 
                                      fontWeight: FontWeight.bold, 
                                      fontFamily: appFonts['Title']
                                    ),
                                  ),
                                  SizedBox(height: p.standardPadding()),
                                  LanguageSelectorButton(
                                    onLanguageSelected: (language, flagUrl, code) => 
                                      _updateSelectedOriginLanguage(language, flagUrl, code),
                                    startingLanguage: _selectedOriginLanguage,
                                    isSource: false,
                                    selectorTitle: localizations.selectSourceLanguage,
                                    hideTooltip: true,
                                  ),
                                  
                                  const Divider(height: 40),
                                  
                                  // Skills section
                                  Text(
                                    localizations.skillsColumnTitle, 
                                    style: TextStyle(
                                      fontSize: 18, 
                                      fontWeight: FontWeight.bold, 
                                      fontFamily: appFonts['Title']
                                    ),
                                  ),
                                  SizedBox(height: p.standardPadding()),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      CompetenceSelectorButton(
                                        competence: "listening",
                                        onToggle: _toggleCompetence,
                                        isSelected: _selectedCompetences.contains('listening'),
                                        isSmall: true,
                                      ),
                                      SizedBox(width: p.standardPadding()),
                                      CompetenceSelectorButton(
                                        competence: "speaking",
                                        onToggle: _toggleCompetence,
                                        isSelected: _selectedCompetences.contains('speaking'),
                                        isSmall: true, 
                                      ),
                                      SizedBox(width: p.standardPadding()),
                                      CompetenceSelectorButton(
                                        competence: "writing",
                                        onToggle: _toggleCompetence,
                                        isSelected: _selectedCompetences.contains('writing'),
                                        isSmall: true,
                                      ),
                                      SizedBox(width: p.standardPadding()),
                                      CompetenceSelectorButton(
                                        competence: "reading",
                                        onToggle: _toggleCompetence,
                                        isSelected: _selectedCompetences.contains('reading'),
                                        isSmall: true,
                                      ),
                                    ],
                                  ),
                                  
                                  const Divider(height: 40),
                                  
                                  // Goals section - both selectors in one row
                                  Text(
                                    localizations.goalColumnTitle, 
                                    style: TextStyle(
                                      fontSize: 18, 
                                      fontWeight: FontWeight.bold, 
                                      fontFamily: appFonts['Title']
                                    ),
                                  ),
                                  SizedBox(height: p.standardPadding()),
                                  Row(
                                    children: [
                                      // Daily goal selector
                                      const Icon(Icons.sunny, color: AppColors.yellow, size: 24),
                                      SizedBox(width: p.standardPadding()),
                                      Expanded(
                                        child: GoalSelectorButton(
                                          initialValue: _dailyGoal,
                                          initialGoalType: _currentGoalType,
                                          onValueChanged: (value) {
                                            setState(() {
                                              _dailyGoal = value;
                                            });
                                          },
                                          onGoalTypeChanged: _updateGoalType,
                                        ),
                                      ),
                                      SizedBox(width: p.standardPadding()),
                                      // Total goal selector
                                      const Icon(Icons.nightlight_round_outlined, color: AppColors.lightBlue, size: 24),
                                      SizedBox(width: p.standardPadding()),
                                      Expanded(
                                        child: GoalSelectorButton(
                                          initialValue: _totalGoal,
                                          isDaily: false,
                                          initialGoalType: _currentGoalType,
                                          onValueChanged: (value) {
                                            setState(() {
                                              _totalGoal = value;
                                            });
                                          },
                                          onGoalTypeChanged: _updateGoalType,
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  const Divider(height: 40),
                                  
                                  // Statistics in a row
                                  _isLoadingStats 
                                      ? const Center(
                                          child: CircularProgressIndicator(
                                            color: AppColors.blue,
                                          ),
                                        )
                                      : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          _buildStatisticBox(
                                            Icons.watch_later_outlined, 
                                            localizations.studyTimeLabel, 
                                            _formatTime(_totalMinutesStudied)
                                          ),
                                          const SizedBox(width: 16),
                                          _buildStatisticBox(
                                            Icons.add_circle_outline, 
                                            localizations.wordsAddedLabel, 
                                            '$_totalWordsAdded'
                                          ),
                                          const SizedBox(width: 16),
                                          _buildStatisticBox(
                                            Icons.replay, 
                                            localizations.wordsReviewedLabel, 
                                            '$_totalWordsReviewed'
                                          ),
                                          const SizedBox(width: 16),
                                          _buildStatisticBox(
                                            Icons.menu_book, 
                                            localizations.linesReadLabel, 
                                            '$_totalLinesRead'
                                          ),
                                          const SizedBox(width: 16),
                                          _buildStatisticBox(
                                            Icons.calendar_today,
                                            localizations.daysPracticedLabel,  
                                            '$_daysPracticed'
                                          ),
                                        ],
                                      ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: p.standardPadding()),
                    // Bottom container with difficulty text and save button
                    Container(
                      padding: EdgeInsets.all(p.standardPadding()),
                      decoration: BoxDecoration(
                        color: AppColors.grey,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: CourseDifficultyText(
                              dailyWords: _dailyGoal,
                              goalType: _currentGoalType.toString().split('.').last,
                              competences: _selectedCompetences.length,
                              startingLanguage: _selectedOriginLanguageCode,
                              targetLanguage: widget.course.code,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _updateCourse,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blue,
                              padding: EdgeInsets.symmetric(
                                horizontal: p.standardPadding() * 2,
                                vertical: p.standardPadding(),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              localizations.saveChangesButton,
                              style: TextStyle(
                                fontFamily: appFonts['Subtitle'], 
                                fontSize: 18, 
                                color: Colors.white
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // X button in the upper right corner
              Positioned(
                top: 10,
                right: 30,
                child: IconButton(
                  icon: Icon(Icons.close, color: AppColors.black),
                  onPressed: () => widget.onBack(widget.course),
                  iconSize: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}