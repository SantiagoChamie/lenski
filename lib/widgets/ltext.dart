import 'dart:async';
import 'package:flutter/material.dart';

/// LText is a widget that when selected will display the translation of the text
/// from the selected language to the target language.
class LText extends StatelessWidget {
  final String text;
  final String fromLanguage;
  final String toLanguage;
  final TextStyle style;

  const LText({
    super.key,
    required this.text,
    required this.fromLanguage,
    required this.toLanguage,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    Timer? timer;

    return TextSelectionTheme(
      data: const TextSelectionThemeData(
        selectionColor: Color(0xFFFFD38D),
      ),
      child: SelectableText(
        text,
        style: style,
        onSelectionChanged: (TextSelection selection, SelectionChangedCause? cause) {
          if (selection.baseOffset != selection.extentOffset) {
            timer?.cancel();
            timer = Timer(const Duration(milliseconds: 200), () {
              final selectedText = text.substring(selection.start, selection.end);
              print('Selected text: $selectedText');
            });
          }
        },
      ),
    );
  }
}