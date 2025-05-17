import 'package:flutter/material.dart';
import 'package:lenski/utils/languages/language_attributes.dart';
import 'package:lenski/utils/colors.dart';
import 'package:lenski/utils/fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A widget that displays the difficulty and intensity of a course as styled text.
///
/// This widget calculates and displays two key metrics about a language course:
/// 1. Difficulty: Based on linguistic differences between the source and target languages
/// 2. Intensity: Based on the daily learning goals and number of competences
///
/// Each metric is color-coded to visually communicate the level (light/low to extreme).
class CourseDifficultyText extends StatelessWidget {
  /// The number of words or minutes to learn daily
  final int dailyWords;
  
  /// The language code of the source language
  final String startingLanguage;
  
  /// The language code of the target language
  final String targetLanguage;
  
  /// The number of selected competences
  final int competences;
  
  /// The type of goal ('learn', 'daily', or 'time')
  final String goalType;

  /// Creates a CourseDifficultyText widget.
  /// 
  /// [dailyWords] is the number of words to learn daily.
  /// [startingLanguage] is the language code of the source language.
  /// [targetLanguage] is the language code of the target language.
  /// [competences] is the number of selected competences.
  /// [goalType] is the type of goal ('learn', 'daily', or 'time').
  const CourseDifficultyText({
    super.key,
    required this.dailyWords,
    required this.startingLanguage,
    required this.targetLanguage,
    required this.competences,
    required this.goalType,
  });

  /// Calculates language difficulty based on linguistic differences.
  ///
  /// This method compares various linguistic attributes between the source and target
  /// languages to determine a difficulty score from 1-4.
  ///
  /// @param lang1 The source language code
  /// @param lang2 The target language code
  /// @return A difficulty score from 1 to 4
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

  /// Gets the difficulty level as a localized string.
  ///
  /// @param context The build context for localization
  /// @return A string representing the difficulty level
  String getDifficulty(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    int score = calculateLanguageDifficulty(startingLanguage, targetLanguage);
    
    switch (score) {
      case 1:
        return localizations.difficultyLight;
      case 2:
        return localizations.difficultyMedium;
      case 3:
        return localizations.difficultyHeavy;
      case 4:
        return localizations.difficultyExtreme;
      default:
        return localizations.difficultyUnknown;
    }
  }

  /// Gets the intensity level as a localized string.
  ///
  /// @param context The build context for localization
  /// @return A string representing the intensity level
  String getIntensity(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    // If goal type is 'daily', always return low intensity
    if (goalType == 'daily') {
      return localizations.intensityLow;
    }
    
    // For other goal types, calculate intensity based on type
    int intensityScore;
    
    switch (goalType) {
      case 'learn':
        // Original calculation for learn type
        intensityScore = dailyWords * competences;
        break;
      case 'time':
        // For time goals, multiply minutes by competences
        // Using dailyWords as minutes for time goal type
        intensityScore = (dailyWords*2/3).floor(); // Higher intensity for time commitment
        break;
      default:
        // Default fallback to original calculation
        intensityScore = dailyWords * competences;
    }
    
    // Determine intensity level based on the calculated score
    if (intensityScore < 20) return localizations.intensityLow;
    if (intensityScore < 40) return localizations.intensityMedium;
    if (intensityScore < 100) return localizations.intensityHigh;
    return localizations.intensityExtreme;
  }

  /// Returns the appropriate color based on the difficulty or intensity level.
  ///
  /// @param level The difficulty or intensity level
  /// @return The color associated with that level
  Color _getColor(String level, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    if (level == localizations.difficultyLight || level == localizations.intensityLow) {
      return AppColors.lightGreen;
    }
    if (level == localizations.difficultyMedium || level == localizations.intensityMedium) {
      return AppColors.yellow;
    }
    if (level == localizations.difficultyHeavy || level == localizations.intensityHigh) {
      return AppColors.error;  // Using error red for high/heavy
    }
    if (level == localizations.difficultyExtreme || level == localizations.intensityExtreme) {
      return AppColors.darkRed;
    }
    return AppColors.black;  // Default color
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final difficulty = getDifficulty(context);
    final intensity = getIntensity(context);
    
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontFamily: appFonts['Paragraph'],
          fontSize: 30,
          color:AppColors.black,
        ),
        children: [
          TextSpan(
            text: difficulty,
            style: TextStyle(color: _getColor(difficulty, context)),
          ),
          TextSpan(text: localizations.courseWithIntensity),
          TextSpan(
            text: intensity,
            style: TextStyle(color: _getColor(intensity, context)),
          ),
          TextSpan(text: localizations.intensity),
        ],
      ),
    );
  }
}