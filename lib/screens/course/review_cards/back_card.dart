import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lenski/models/card_model.dart' as lenski_card;
import 'package:lenski/services/tts_service.dart';
import 'package:lenski/widgets/ltext.dart';
import 'package:lenski/utils/colors.dart';
import 'package:lenski/utils/fonts.dart';

/// A widget that displays the back side of a flashcard during review.
///
/// This component shows the answer/translation of a flashcard along with:
/// - The source language indicator
/// - The translated text (back of card)
/// - The original text (front of card)
/// - A text-to-speech button to hear pronunciation
/// - Example context sentence if available
/// - Difficulty rating buttons (Hard/Easy)
///
/// Users can mark cards as easy or difficult which affects their next review date
/// through a spaced repetition algorithm.
class BackCard extends StatelessWidget {
  /// The card being reviewed
  final lenski_card.Card card;
  
  /// Source language code for the card's content
  final String courseFromCode;
  
  /// Callback function when a difficulty is selected
  final Function(int) onDifficultySelected;
  
  /// Optional callback to refresh cards after operations that might modify the card deck
  final VoidCallback? onRefresh;

  /// Creates a BackCard widget.
  /// 
  /// [card] is the flashcard that is being reviewed.
  /// [courseFromCode] is the language code from which the card is being translated.
  /// [onDifficultySelected] is called when user rates card difficulty (1=hard, 4=easy).
  /// [onRefresh] is called when cards need to be refreshed (e.g., after adding a new card).
  const BackCard({
    super.key,
    required this.card,
    required this.courseFromCode,
    required this.onDifficultySelected,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '${courseFromCode.toLowerCase()}.',
          style: TextStyle(
            fontSize: 18.0,
            color: AppColors.darkGrey,
            fontFamily: appFonts['Paragraph'],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              card.back,
              style: TextStyle(
                fontSize: 24.0,
                color: AppColors.black,
                fontFamily: appFonts['Paragraph'],
              ),
            ),
            const SizedBox(height: 8.0),
            LText(
              text: card.front,
              toLanguage: card.language,
              fromLanguage: courseFromCode,
              style: TextStyle(
                fontSize: 18.0,
                color: AppColors.darkGrey,
                fontFamily: appFonts['Paragraph'],
              ),
              onCardAdded: onRefresh, // Connect to refresh callback when cards are added
            ),
            const SizedBox(height: 16.0),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.grey,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.volume_up, color: AppColors.black),
                iconSize: 40.0,
                onPressed: () async {
                  try {
                    await TtsService().speak(card.front, card.language);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(localizations.installTtsMessage),
                      ),
                    );
                  }
                },
                tooltip: localizations.speakingCardTooltip,
              ),
            ),
            if (card.context != card.front) ...[
              const SizedBox(height: 16.0),
              Text(
                card.context,
                style: TextStyle(
                  fontSize: 16.0,
                  color: AppColors.darkGrey,
                  fontFamily: appFonts['Paragraph'],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => onDifficultySelected(1),
              child: Text(
                'Hard',
                style: TextStyle(
                  fontSize: 18.0,
                  color: AppColors.black,
                  fontFamily: appFonts['Detail'],
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            ElevatedButton(
              onPressed: () => onDifficultySelected(4),
              child: Text(
                'Easy',
                style: TextStyle(
                  fontSize: 18.0,
                  color: AppColors.black,
                  fontFamily: appFonts['Detail'],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}