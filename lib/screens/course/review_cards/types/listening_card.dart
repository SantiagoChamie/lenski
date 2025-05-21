import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lenski/models/card_model.dart' as lenski_card;
import 'package:lenski/services/tts_service.dart';
import 'package:lenski/utils/colors.dart';
import 'package:lenski/utils/fonts.dart';

/// A widget that displays a listening practice card during review.
///
/// This component shows a card that prompts the user to listen to a word or phrase
/// and recall its meaning. Features include:
/// - Large play button for listening to the target word
/// - Optional context sentence that can also be played aloud
/// - Visual feedback using competence-specific colors
/// - Button to check the answer (translation)
class ListeningCard extends StatelessWidget {
  /// The card being reviewed
  final lenski_card.Card card;
  
  /// The language code of the course being studied
  final String courseCode;
  
  /// Callback function when the user wants to see the answer
  final VoidCallback onShowAnswer;
  
  /// Whether to show colored highlight for this competence type
  final bool showColors;

  /// Creates a ListeningCard widget.
  /// 
  /// [card] is the flashcard being reviewed.
  /// [courseCode] is the language code of the course.
  /// [onShowAnswer] is called when the user wants to see the translation.
  /// [showColors] determines whether to use competence-specific colors.
  const ListeningCard({
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
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
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
            children: [
              Container(
                decoration: BoxDecoration(
                  color: showColors ? AppColors.listening : const Color(0xFF808080), // Listening competence color
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.volume_up, color: Colors.white), // Keep white for contrast
                  iconSize: 80.0,
                  padding: const EdgeInsets.all(24),
                  onPressed: () async {
                    try {
                      await TtsService().speak(card.front, courseCode);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            localizations.installTtsMessage,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 24.0),
              if (card.context != card.front)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      localizations.listenToContext,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: AppColors.darkGrey,
                        fontFamily: appFonts['Paragraph'],
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Container(
                      decoration: const BoxDecoration(
                        color: AppColors.grey,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.volume_up, color: AppColors.black),
                        iconSize: 20.0,
                        onPressed: () async {
                          try {
                            await TtsService().speak(card.context, courseCode);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  localizations.installTtsMessage,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
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
}