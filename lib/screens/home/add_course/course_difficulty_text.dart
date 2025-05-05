import 'package:flutter/material.dart';
import 'package:lenski/utils/languages.dart';

/// A widget that displays the difficulty and intensity of a course as styled text.
class CourseDifficultyText extends StatelessWidget {
  
  final int dailyWords;
  final String startingLanguage;
  final String targetLanguage;
  final int competences;

  /// Creates a CourseDifficultyText widget.
  /// 
  /// [difficulty] is the difficulty level of the course.
  /// 
  /// [intensity] is the intensity level of the course.
  const CourseDifficultyText({
    super.key,
    required this.dailyWords,
    required this.startingLanguage,
    required this.targetLanguage,
    required this.competences,
  });

  int calculateLanguageDifficulty(String lang1, String lang2) {
    final langA = languageAttributes[lang1];
    final langB = languageAttributes[lang2];

    if (langA == null || langB == null) {
      throw ArgumentError('One or both language codes are not recognized.');
    }

    double score = 0;

    if (langA['languageFamily'] != langB['languageFamily']) score += 1;
    if (langA['alphabet'] != langB['alphabet']) score += 1;

    score += langB['grammarComplexity'];

    if (langA['wordOrder'] != langB['wordOrder']) score += 0.5;

    if (langA['formalityLevels'] != langB['formalityLevels']) score += 0.5;
    if (langA['writingDirection'] != langB['writingDirection']) score += 0.3;

    if (langA['genderedWords'] != langB['genderedWords']) score += 0.5;
    if (langA['pluralWords'] != langB['pluralWords']) score += 0.2;    

    return score.floor().clamp(1, 4);
  }

  String get difficulty {
    int score = calculateLanguageDifficulty(startingLanguage, targetLanguage);
    switch (score) {
      case 1:
        return "Light";
      case 2:
        return "Medium";
      case 3:
        return "Heavy";
      case 4:
        return "Extreme";
      default:
        return "Unknown";
    }
  }

  String get intensity {
    // Calculate intensity as daily words × number of competences
    int intensityScore = dailyWords * competences;
    
    // Determine intensity level based on the calculated score
    if (intensityScore < 20) return "low";
    if (intensityScore < 40) return "medium";
    if (intensityScore < 100) return "high";
    return "extreme";
  }

  /// Returns the appropriate color based on the difficulty or intensity level.
  Color _getColor(String level) {  // Changed parameter type to String
    switch (level.toLowerCase()) {
      case 'light':
      case 'low':
        return const Color(0xFF0BAE44);
      case 'medium':
        return const Color(0xFFEE9A1D);
      case 'heavy':
      case 'high':
        return Colors.red;
      case 'extreme':
        return const Color(0xFF9B1D1D);
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontFamily: "Varela Round",
          fontSize: 30,
          color: Colors.black,
        ),
        children: [
          TextSpan(
            text: difficulty,
            style: TextStyle(color: _getColor(difficulty)),  // Pass difficulty string
          ),
          const TextSpan(text: " course with "),
          TextSpan(
            text: intensity,
            style: TextStyle(color: _getColor(intensity)),  // Pass intensity string
          ),
          const TextSpan(text: " intensity"),
        ],
      ),
    );
  }
}