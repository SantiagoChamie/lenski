import 'package:flutter/material.dart';
import 'package:lenski/screens/home/add_course/buttons/competence_selector_button.dart';
import 'package:lenski/screens/home/add_course/buttons/goal_selector_button.dart';
import 'package:lenski/screens/home/add_course/course_difficulty_text.dart';
import 'package:lenski/screens/home/add_course/buttons/language_selector_button.dart';
import 'package:lenski/utils/languages.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/models/course_model.dart';
import 'package:lenski/data/course_repository.dart';
import 'package:lenski/data/session_repository.dart';

/// A screen for editing an existing course
class EditCourseScreen extends StatefulWidget {
  final Function(Course updatedCourse) onBack;  // Change VoidCallback to a function that returns the updated course
  final Course course;

  /// Creates an EditCourseScreen widget.
  /// 
  /// [onBack] is the callback function to be called when the back button is pressed.
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
  final CourseRepository _courseRepository = CourseRepository();
  final SessionRepository _sessionRepository = SessionRepository(); // Add repository
  
  // Add statistics variables
  int _totalMinutesStudied = 0;
  int _totalWordsAdded = 0;
  int _totalWordsReviewed = 0;
  int _totalLinesRead = 0;
  bool _isLoadingStats = true;

  // Initialize with course values
  late String _selectedOriginLanguage;
  late String _selectedOriginLanguageCode;
  
  final List<String> _selectedCompetences = [];
  bool _isMessageDisplayed = false;
  
  // Goal values
  late int _dailyGoal;
  late int _totalGoal;

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
    
    // Load statistics
    _loadStatistics();
  }
  
  // Add this method to load statistics
  Future<void> _loadStatistics() async {
    setState(() {
      _isLoadingStats = true;
    });
    
    final sessions = await _sessionRepository.getSessionsByCourse(widget.course.code);
    
    int minutes = 0;
    int words = 0;
    int reviewed = 0;
    int lines = 0;
    
    for (var session in sessions) {
      minutes += session.minutesStudied;
      words += session.wordsAdded;
      reviewed += session.wordsReviewed;
      lines += session.linesRead;
    }
    
    setState(() {
      _totalMinutesStudied = minutes;
      _totalWordsAdded = words;
      _totalWordsReviewed = reviewed;
      _totalLinesRead = lines;
      _isLoadingStats = false;
    });
  }

  /// Updates the course in the repository.
  void _updateCourse() async {
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

    // Check if total goal is less than words already added
    if (_totalGoal < _totalWordsAdded) {
      if (!_isMessageDisplayed) {
        _isMessageDisplayed = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Total goal cannot be less than words already added ($_totalWordsAdded)'),
            duration: const Duration(seconds: 2),
          ),
        ).closed.then((_) {
          _isMessageDisplayed = false;
        });
      }
      return;
    }

    final updatedCourse = widget.course.copyWith(
      fromCode: _selectedOriginLanguageCode,
      listening: _selectedCompetences.contains('listening'),
      speaking: _selectedCompetences.contains('speaking'),
      reading: _selectedCompetences.contains('reading'),
      writing: _selectedCompetences.contains('writing'),
      dailyGoal: _dailyGoal,
      totalGoal: _totalGoal,
    );
    
    await _courseRepository.updateCourse(updatedCourse);
    widget.onBack(updatedCourse);  // Pass the updated course back to the parent
  }

  /// Updates the selected origin language and its associated code.
  void _updateSelectedOriginLanguage(String language, String flagUrl, String code) {
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
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: EdgeInsets.only(left: p.standardPadding(),right: p.standardPadding(),bottom: p.standardPadding()),
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
                              color: const Color(0xFFF5F0F6),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Source language selection only
                                const Text("Source Language", 
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "Unbounded")),
                                SizedBox(height: p.standardPadding()),
                                LanguageSelectorButton(
                                  onLanguageSelected: (language, flagUrl, code) => 
                                    _updateSelectedOriginLanguage(language, flagUrl, code),
                                  startingLanguage: _selectedOriginLanguage,
                                  isSource: false,
                                  hideTooltip: true,
                                ),
                                
                                const Divider(height: 40),
                                
                                // Skills section
                                const Text("Skills", 
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "Unbounded")),
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
                                const Text("Goals", 
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "Unbounded")),
                                SizedBox(height: p.standardPadding()),
                                Row(
                                  children: [
                                    // Daily goal selector
                                    const Icon(Icons.sunny, color: Color(0xFFEE9A1D), size: 24),
                                    SizedBox(width: p.standardPadding()),
                                    Expanded(
                                      child: GoalSelectorButton(
                                        initialValue: _dailyGoal,
                                        onValueChanged: (value) {
                                          setState(() {
                                            _dailyGoal = value;
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(width: p.standardPadding()),
                                    // Total goal selector
                                    const Icon(Icons.nightlight_round_outlined, color: Color(0xFF71BDE0), size: 24),
                                    SizedBox(width: p.standardPadding()),
                                    Expanded(
                                      child: GoalSelectorButton(
                                        initialValue: _totalGoal,
                                        isDaily: false,
                                        onValueChanged: (value) {
                                          setState(() {
                                            _totalGoal = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const Divider(height: 40),
                                
                                // Statistics in a row
                                _isLoadingStats 
                                    ? const Center(child: CircularProgressIndicator())
                                    : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _buildStatisticBox(
                                          Icons.watch_later_outlined, 
                                          'Study time', 
                                          _formatTime(_totalMinutesStudied)
                                        ),
                                        const SizedBox(width: 16),
                                        _buildStatisticBox(
                                          Icons.add_circle_outline, 
                                          'Words added', 
                                          '$_totalWordsAdded'
                                        ),
                                        const SizedBox(width: 16),
                                        _buildStatisticBox(
                                          Icons.replay, 
                                          'Words reviewed', 
                                          '$_totalWordsReviewed'
                                        ),
                                        const SizedBox(width: 16),
                                        _buildStatisticBox(
                                          Icons.menu_book, 
                                          'Lines read', 
                                          '$_totalLinesRead'
                                        ),
                                        const SizedBox(width: 16),
                                        _buildStatisticBox(
                                          Icons.local_fire_department, 
                                          'Streak', 
                                          '${widget.course.streak} days'
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
                      color: const Color(0xFFD9D0DB),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: CourseDifficultyText(
                            dailyWords: _dailyGoal,
                            competences: _selectedCompetences.length,
                            startingLanguage: _selectedOriginLanguageCode,  // Use selected value
                            targetLanguage: widget.course.code,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _updateCourse,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2C73DE),
                            padding: EdgeInsets.symmetric(
                              horizontal: p.standardPadding() * 2,
                              vertical: p.standardPadding(),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Save Changes",
                            style: TextStyle(fontFamily: "Telex", fontSize: 18, color: Colors.white),
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
              top: 30,
              right: 30,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.black87),
                onPressed: () => widget.onBack(widget.course),  // Pass the original course if canceled
                iconSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatTime(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else if (minutes < 24 * 60) { // Less than a day
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return '$hours h ${mins > 0 ? '$mins min' : ''}';
    } else if (minutes < 365 * 24 * 60) { // Less than a year
      final days = minutes ~/ (24 * 60);
      final remainingMinutes = minutes % (24 * 60);
      final hours = remainingMinutes ~/ 60;
      
      if (days > 7) {
        // For more than a week, just show days
        return '$days days';
      } else {
        // Show days and hours for less than a week
        return '$days day${days > 1 ? 's' : ''} ${hours > 0 ? '$hours h' : ''}';
      }
    } else { // Years or more
      final years = minutes ~/ (365 * 24 * 60);
      final remainingMinutes = minutes % (365 * 24 * 60);
      final days = remainingMinutes ~/ (24 * 60);
      
      if (days > 0) {
        return '$years year${years > 1 ? 's' : ''} $days day${days > 1 ? 's' : ''}';
      } else {
        return '$years year${years > 1 ? 's' : ''}';
      }
    }
  }
  
  // Add this helper method to create statistic boxes
  Widget _buildStatisticBox(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0F6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E0E6), width: 1),
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
          Icon(icon, color: const Color(0xFF2C73DE), size: 24),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF99909B),
                  fontFamily: "Varela Round",
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Varela Round",
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}