import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lenski/models/card_model.dart' as lenski_card;
import 'package:lenski/utils/colors.dart';
import 'package:lenski/utils/fonts.dart';

/// A widget that displays a writing practice card during review.
///
/// This component shows a card with a context sentence where the target word
/// is replaced with a text field. The user must type the correct word to practice
/// writing skills. Features include:
/// - Gap text where the target word needs to be filled in
/// - Visual feedback using competence-specific colors
/// - Translation hint to help recall the word
/// - Button to check the answer
class WritingCard extends StatefulWidget {
  /// The card being reviewed
  final lenski_card.Card card;
  
  /// The language code of the course being studied
  final String courseCode;
  
  /// Callback function when the user wants to see the answer
  final VoidCallback onShowAnswer;
  
  /// Whether to show colored highlight for this competence type
  final bool showColors;

  /// Creates a WritingCard widget.
  /// 
  /// [card] is the flashcard being reviewed.
  /// [courseCode] is the language code of the course.
  /// [onShowAnswer] is called when the user wants to check their answer.
  /// [showColors] determines whether to use competence-specific colors.
  const WritingCard({
    super.key,
    required this.card,
    required this.courseCode,
    required this.onShowAnswer,
    this.showColors = true,
  });

  @override
  State<WritingCard> createState() => _WritingCardState();
}

class _WritingCardState extends State<WritingCard> {
  final TextEditingController _controller = TextEditingController();
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
            '${widget.courseCode.toLowerCase()}.',
            style: TextStyle(
              fontSize: 18.0,
              color: AppColors.darkGrey,
              fontFamily: appFonts['Paragraph'],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text.rich(
                TextSpan(
                  text: widget.card.context.contains(widget.card.front)
                      ? widget.card.context.substring(0, widget.card.context.indexOf(widget.card.front))
                      : widget.card.context,
                  style: TextStyle(
                    fontSize: 24.0,
                    color: AppColors.black,
                    fontFamily: appFonts['Paragraph'],
                  ),
                  children: widget.card.context.contains(widget.card.front)
                      ? [
                          WidgetSpan(
                            child: SizedBox(
                              width: 120,
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  textSelectionTheme: TextSelectionThemeData(
                                    selectionColor: widget.showColors ? AppColors.writing : const Color.fromARGB(255, 176, 176, 176), // Writing competence color
                                  ),
                                ),
                                child: TextField(
                                  controller: _controller,
                                  cursorColor: widget.showColors ? AppColors.writing : const Color(0xFF808080), // Writing competence color
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: AppColors.black),
                                    ),
                                    border: const UnderlineInputBorder(),
                                    isDense: true,
                                  ),
                                  style: TextStyle(
                                    fontSize: 24.0,
                                    color: AppColors.black,
                                    fontFamily: appFonts['Paragraph'],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          TextSpan(
                            text: widget.card.context.substring(
                              widget.card.context.indexOf(widget.card.front) + widget.card.front.length,
                            ),
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                '~${widget.card.back}~',
                style: TextStyle(
                  fontSize: 18.0,
                  color: AppColors.darkGrey,
                  fontFamily: appFonts['Paragraph'],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: widget.onShowAnswer,
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