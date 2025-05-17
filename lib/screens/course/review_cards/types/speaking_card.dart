import 'package:flutter/material.dart';
import 'package:lenski/models/card_model.dart' as lenski_card;
import 'package:lenski/utils/colors.dart';
import 'package:lenski/utils/fonts.dart';

class SpeakingCard extends StatelessWidget {
  final lenski_card.Card card;
  final String courseCode;
  final VoidCallback onShowAnswer;
  final bool showColors;

  const SpeakingCard({
    super.key,
    required this.card,
    required this.courseCode,
    required this.onShowAnswer,
    this.showColors = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Make container take full width
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center, // Align text to the left
        children: [
          Text(
            '${courseCode.toLowerCase()}.',
            style: const TextStyle(
              fontSize: 18.0,
              color: Color(0xFF99909B),
              fontFamily: "Varela Round",
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Align text to the left
            children: [
              Text(
                card.front,
                style: const TextStyle(
                  fontSize: 24.0,
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontFamily: "Varela Round",
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
            child: const Text(
              'Show answer',
              style: TextStyle(
                fontSize: 18.0,
                color: Color(0xFF000000),
                fontFamily: "Sansation",
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the context text spans with proper highlighting of the front text
  /// using word boundary detection for accurate matching.
  List<TextSpan> _buildContextTextSpans() {
    // Use word boundaries to find the index of the front text in the context
    final int index = _findWordWithBoundariesIndex(card.context, card.front);
    
    // If front text isn't in context with word boundaries, just show the context as plain text
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
    
    // If front text is in context, split into three parts
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
      // The highlighted word
      TextSpan(
        text: card.front,
        style: TextStyle(
          fontSize: 18.0,
          color: showColors ? AppColors.speaking : AppColors.darkGrey,
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