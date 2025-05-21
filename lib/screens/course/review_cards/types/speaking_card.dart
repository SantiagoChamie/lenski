import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lenski/models/card_model.dart' as lenski_card;
import 'package:lenski/utils/colors.dart';
import 'package:lenski/utils/fonts.dart';

/// A widget that displays a speaking practice card during review.
///
/// This component shows a card that prompts the user to practice speaking
/// a word or phrase aloud. Features include:
/// - The target word prominently displayed
/// - An example sentence with the word highlighted
/// - Visual feedback using competence-specific colors
/// - Button to check the correct pronunciation
class SpeakingCard extends StatelessWidget {
  /// The card being reviewed
  final lenski_card.Card card;
  
  /// The language code of the course being studied
  final String courseCode;
  
  /// Callback function when the user wants to see the answer
  final VoidCallback onShowAnswer;
  
  /// Whether to show colored highlight for this competence type
  final bool showColors;

  /// Creates a SpeakingCard widget.
  /// 
  /// [card] is the flashcard being reviewed.
  /// [courseCode] is the language code of the course.
  /// [onShowAnswer] is called when the user wants to check their answer.
  /// [showColors] determines whether to use competence-specific colors.
  const SpeakingCard({
    super.key,
    required this.card,
    required this.courseCode,
    required this.onShowAnswer,
    this.showColors = true,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return SizedBox(
      width: double.infinity, // Make container take full width
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center, // Align text to the left
        children: [
          Text(
            '${courseCode.toLowerCase()}.',
            style: TextStyle(
              fontSize: 18.0,
              color: AppColors.darkGrey,
              fontFamily: appFonts['Paragraph'],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Align text to the left
            children: [
              Text(
                card.front,
                style: TextStyle(
                  fontSize: 24.0,
                  color: AppColors.black,
                  fontFamily: appFonts['Paragraph'],
                ),
              ),
              if (card.context != card.front)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text.rich(
                    TextSpan(
                      children: _buildContextTextSpans(),
                    ),
                  ),
                ),
            ],
          ),
          ElevatedButton(
            onPressed: onShowAnswer,
            child: Text(
              localizations.checkAnswer,
              style: TextStyle(
                fontSize: 18.0,
                color: AppColors.black,
                fontFamily: appFonts['Detail'],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the context text spans with proper highlighting of the front text.
  /// First tries to find the word using word boundaries, and if that fails,
  /// falls back to a simple substring search.
  List<TextSpan> _buildContextTextSpans() {
    // First try: Use word boundaries to find the index of the front text in the context
    int index = _findWordWithBoundariesIndex(card.context, card.front);
    
    // Second try (fallback): If not found with word boundaries, try simple substring search
    if (index == -1) {
      index = card.context.toLowerCase().indexOf(card.front.toLowerCase());
    }
    
    // If front text isn't found by either method, just show the context as plain text
    if (index == -1) {
      return [
        TextSpan(
          text: card.context,
          style: TextStyle(
            fontSize: 18.0,
            color: AppColors.darkGrey,
            fontFamily: appFonts['Paragraph'],
          ),
        ),
      ];
    }
    
    // If front text is found (by either method), split into three parts
    return [
      // Text before the highlighted word
      TextSpan(
        text: card.context.substring(0, index),
        style: TextStyle(
          fontSize: 18.0,
          color: AppColors.darkGrey,
          fontFamily: appFonts['Paragraph'],
        ),
      ),
      // The highlighted word - use the actual text from the context for proper casing
      TextSpan(
        text: card.context.substring(index, index + card.front.length),
        style: TextStyle(
          fontSize: 18.0,
          color: showColors ? AppColors.reading : AppColors.darkGrey,
          fontFamily: appFonts['Paragraph'],
          fontWeight: FontWeight.bold,
        ),
      ),
      // Text after the highlighted word
      TextSpan(
        text: card.context.substring(index + card.front.length),
        style: TextStyle(
          fontSize: 18.0,
          color: AppColors.darkGrey,
          fontFamily: appFonts['Paragraph'],
        ),
      ),
    ];
  }

  /// Finds the index of a word with proper word boundaries.
  ///
  /// This ensures that the word is found as a complete word rather than
  /// as part of another word.
  ///
  /// @param text The text to search in
  /// @param word The word to search for
  /// @return The starting index of the word, or -1 if not found
  int _findWordWithBoundariesIndex(String text, String word) {
    // Define all characters that can act as word boundaries, including quotes and punctuation
    const String rawBc = ' \t\n\r.,;:!?()[]{}<>/\\|=+-_*&^%\$#@~`"\'‟„«»‹›。！？，；：（）【】［］｛｝「」『』、、；';
    
    // Escape special regex characters in the word
    final String safeBc = RegExp.escape(rawBc);
    
    // Create a pattern that matches the word when surrounded by start/end of string or boundary chars
    final String boundaryClass = '[$safeBc]';
    final String pattern = r'(^|' + boundaryClass + r')'
                     + RegExp.escape(word)
                     + r'($|' + boundaryClass + r')';
    
    // Create and use the RegExp to find the first match
    final RegExp wordRegExp = RegExp(pattern);
    final Match? match = wordRegExp.firstMatch(text);
    
    // If found, return the start index of the captured word (group 2)
    // We need to adjust the index to account for the boundary character
    if (match != null) {
      return match.start + (match.group(1)?.length ?? 0);
    }
    return -1;
  }
}