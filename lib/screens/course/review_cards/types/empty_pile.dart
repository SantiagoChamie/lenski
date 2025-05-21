import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lenski/utils/colors.dart';
import 'package:lenski/utils/fonts.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/widgets/flag_icon.dart';

/// A widget that displays when there are no flashcards to review.
///
/// This component shows a message to the user when they've completed all
/// their due cards. Features include:
/// - Visual feedback indicating the emptied pile
/// - Language flag indicator
/// - Close button to return to the previous screen
class EmptyPile extends StatelessWidget {
  /// The language for which no cards remain
  final String language;

  /// Creates an EmptyPile widget.
  /// 
  /// [language] is the name of the language for which no cards remain for review.
  const EmptyPile({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    final boxPadding = p.standardPadding() * 4;
    const iconSize = 80.0;
    final localizations = AppLocalizations.of(context)!;
    
    return Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(boxPadding),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(5.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26, // Keep as is for shadow effect
                      blurRadius: 4.0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(p.standardPadding()),
                    child: Text(
                      localizations.noNewCardsRemaining,
                      style: TextStyle(
                        fontSize: 24.0,
                        color: AppColors.black,
                        fontFamily: appFonts['Paragraph'],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: boxPadding - iconSize / 3,
            left: boxPadding - iconSize / 3,
            child: FlagIcon(
              size: iconSize,
              borderWidth: 5.0,
              borderColor: AppColors.grey,
              language: language,
            ),
          ),
          Positioned(
            top: boxPadding + 10,
            right: boxPadding + 10,
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.close_rounded),
            ),
          ),
        ],
      );
  }
}