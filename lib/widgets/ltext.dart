import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lenski/utils/colors.dart';
import 'package:lenski/utils/fonts.dart';
import 'translation_overlay.dart';

/// A selectable text widget that displays text with translation capabilities.
///
/// When text is selected within this widget, it shows a translation overlay
/// with the translation of the selected text. The widget handles extracting
/// appropriate context for more accurate translations.
///
/// Features:
/// - Text selection with custom highlight color
/// - Translation overlay on selection
/// - Context extraction for improved translation accuracy
/// - Card creation for language learning
class LText extends StatefulWidget {
  /// The text content to display and make selectable for translation
  final String text;
  
  /// Source language code (e.g. 'en')
  final String fromLanguage;
  
  /// Target language code (e.g. 'es')
  final String toLanguage;
  
  /// Text style to apply to the displayed text
  final TextStyle style;
  
  /// Alignment of the text within its container
  final TextAlign textAlign;
  
  /// Position of the translation overlay relative to the selection ('above' or 'below')
  final String position;
  
  /// Types of study cards to create when adding selected text to study
  final List<String>? cardTypes;
  
  /// Callback that runs after successfully adding a card
  final VoidCallback? onCardAdded;

  const LText({
    super.key,
    required this.text,
    required this.fromLanguage,
    required this.toLanguage,
    required this.style,
    this.textAlign = TextAlign.center,
    this.position = 'above',
    this.cardTypes,
    this.onCardAdded,
  });

  @override
  _LTextState createState() => _LTextState();
}

class _LTextState extends State<LText> {
  /// Timer to delay showing the translation overlay after selection
  Timer? timer;
  
  /// Timer to delay hiding the translation overlay
  Timer? hideTimer;
  
  /// Currently selected text content
  String? selectedText;
  
  /// Reference to the overlay entry currently displayed
  OverlayEntry? overlayEntry;
  
  /// Current mouse position used for overlay positioning
  Offset? mousePosition;

  @override
  void dispose() {
    timer?.cancel();
    hideTimer?.cancel();
    overlayEntry?.remove();
    super.dispose();
  }

  /// Truncates selected text to ensure it stays within reasonable limits.
  ///
  /// This is useful for very long selections to prevent processing issues.
  /// The function tries different approaches to intelligently truncate text
  /// by finding natural breakpoints like sentence endings.
  ///
  /// @param text The text to truncate
  /// @param maxLength Maximum allowed length for the text
  /// @return Truncated text that makes logical sense
  String truncateSelectedText(String text, {int maxLength = 100}) {
    if (text.length <= maxLength) return text;

    // First try: Split by sentence-ending punctuation (including CJK and Arabic)
    final sentences = text.split(RegExp(r'(?<=[.!?。！？؟])\s*'));
    if (sentences.isNotEmpty && sentences[0].length <= maxLength) {
      return sentences[0].trim();
    }

    // Second try: Split by all punctuation (including CJK and Arabic)
    final fragments = text.split(RegExp(r'(?<=[.!?,;:()\[\]{}<>\-。！？，；：（）【】［］｛｝「」『』、、；])\s*'));
    if (fragments.isNotEmpty && fragments[0].length <= maxLength) {
      return fragments[0].trim();
    }

    // Last resort: Just truncate at maxLength
    return text.substring(0, maxLength).trim();
  }

  /// Displays the translation overlay at the current mouse position.
  ///
  /// Creates an overlay entry containing the TranslationOverlay widget
  /// with the selected text and appropriate context.
  ///
  /// @param context The build context
  /// @param text The selected text to translate
  /// @param rect The rectangle representing the selected text's bounds
  void showOverlay(BuildContext context, String text, Rect rect) {
    overlayEntry?.remove();

    // Remove newline characters and truncate the selected text
    final sanitizedText = text.replaceAll('\n', ' ');
    final truncatedText = truncateSelectedText(sanitizedText);
    
    // Find the context using our existing algorithm
    final contextText = findContext(truncatedText, widget.text);

    // Find the translation context using the new approach (longer context)
    final translationContext = findTranslationContext(truncatedText, widget.text);

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: widget.position == 'above' ? mousePosition!.dy - 200 : rect.bottom + 50,
        left: mousePosition!.dx - 150,
        child: Material(
          color: Colors.transparent,
          child: TranslationOverlay(
            text: truncatedText, // Use truncated text instead of full selection
            contextText: contextText,
            translationContext: translationContext,
            sourceLang: widget.toLanguage,
            targetLang: widget.fromLanguage,
            onClose: () => hideOverlay(instant: true),
            cardTypes: widget.cardTypes,
            onCardAdded: widget.onCardAdded,
          ),
        ),
      ),
    );
    Overlay.of(context).insert(overlayEntry!);
  }

  /// Hides the current translation overlay.
  ///
  /// Can either hide instantly or with a short delay.
  ///
  /// @param instant Whether to hide the overlay immediately or with delay
  void hideOverlay({bool instant = false}) {
    hideTimer?.cancel();
    if (instant) {
      overlayEntry?.remove();
      overlayEntry = null;
      return;
    } else {
      hideTimer = Timer(const Duration(milliseconds: 200), () {
        overlayEntry?.remove();
        overlayEntry = null;
      });
    }
  }

  /// Extracts a short context for creating cards.
  ///
  /// Attempts to find a natural text boundary (like a sentence) containing the selected text,
  /// while keeping the output under the specified maximum length.
  /// For text without standard sentence-ending punctuation, uses enhanced boundary detection.
  ///
  /// @param selectedText The text that was selected by the user
  /// @param fullText The complete text content to extract context from
  /// @param maxLength Maximum length for the context string
  /// @return A string containing the selected text with minimal context
  String findContext(String selectedText, String fullText, {int maxLength = 100}) {
    // Create a sanitized version of the full text
    String sanitizedText = fullText.replaceAll('\n', ' ');
    
    // Check if text contains any sentence-ending punctuation
    final sentenceEndingRegex = RegExp(r'[.!?。！？？]');
    final hasSentenceEndings = sentenceEndingRegex.hasMatch(sanitizedText);
    
    // Check if the selected text exists with enhanced word boundaries
    final containsWithBoundaries = _containsWordWithBoundaries(sanitizedText, selectedText);
    
    // If there are no sentence-ending characters, use a modified approach
    // but still try word boundaries first
    if (!hasSentenceEndings) {
      final lines = fullText.split('\n');
      
      // First try: Look for the word with boundaries in lines
      if (containsWithBoundaries) {
        for (final line in lines) {
          if (_containsWordWithBoundaries(line, selectedText) && line.length <= maxLength) {
            return _cleanTrailingPunctuation(line.trim());
          }
        }
        
        // If no suitable line found with boundaries, try a substring approach with boundaries
        int selectedIndex = _findWordWithBoundariesIndex(sanitizedText, selectedText);
        if (selectedIndex != -1) {
          int contextStart = selectedIndex - 50;
          int contextEnd = selectedIndex + selectedText.length + 50;
          
          if (contextStart < 0) contextStart = 0;
          if (contextEnd > sanitizedText.length) contextEnd = sanitizedText.length;
          
          return _cleanTrailingPunctuation(sanitizedText.substring(contextStart, contextEnd).trim());
        }
      }
      
      // Second try: Look for the text without boundaries in lines
      for (final line in lines) {
        if (line.contains(selectedText) && line.length <= maxLength) {
          return _cleanTrailingPunctuation(line.trim());
        }
      }
      
      // If no suitable line found, use substring approach without boundaries
      int selectedIndex = sanitizedText.indexOf(selectedText);
      if (selectedIndex != -1) {
        int contextStart = selectedIndex - 50;
        int contextEnd = selectedIndex + selectedText.length + 50;
        
        if (contextStart < 0) contextStart = 0;
        if (contextEnd > sanitizedText.length) contextEnd = sanitizedText.length;
        
        return _cleanTrailingPunctuation(sanitizedText.substring(contextStart, contextEnd).trim());
      }
      
      // Last resort: return the selected text itself
      return selectedText;
    }
    
    // Continue with the existing approach for texts with sentence endings
    // Split using different approaches
    final sentences = sanitizedText.split(RegExp(r'(?<=[.!?。！？？])\s*'));
    final fragments = sanitizedText.split(RegExp(r'(?<=[.!?,;:()\[\]{}<>\-。！？，；：（）【】［］｛｝「」『』、、；¿¡""''‟„«»‹›])\s*'));
    final lines = fullText.split('\n');
    
    // FIRST: Try all approaches WITH word boundaries
    if (containsWithBoundaries) {
      // Approach 1: Try sentences with word boundaries
      for (final sentence in sentences) {
        if (_containsWordWithBoundaries(sentence, selectedText) && sentence.length <= maxLength) {
          return _cleanTrailingPunctuation(sentence.trim());
        }
      }
      
      // Approach 2: Try fragments with word boundaries
      for (final fragment in fragments) {
        if (_containsWordWithBoundaries(fragment, selectedText) && fragment.length <= maxLength) {
          return _cleanTrailingPunctuation(fragment.trim());
        }
      }
      
      // Approach 3: Try lines with word boundaries
      for (final line in lines) {
        if (_containsWordWithBoundaries(line, selectedText) && line.length <= maxLength) {
          return _cleanTrailingPunctuation(line.trim());
        }
      }
      
      // If no suitable context found with boundaries, try a substring with boundaries
      int selectedIndex = _findWordWithBoundariesIndex(sanitizedText, selectedText);
      if (selectedIndex != -1) {
        int contextStart = selectedIndex - 50;
        int contextEnd = selectedIndex + selectedText.length + 50;
        
        if (contextStart < 0) contextStart = 0;
        if (contextEnd > sanitizedText.length) contextEnd = sanitizedText.length;
        
        return _cleanTrailingPunctuation(sanitizedText.substring(contextStart, contextEnd).trim());
      }
    }
    
    // SECOND: Fall back to approaches WITHOUT word boundaries
    
    // Try sentences without word boundaries
    for (final sentence in sentences) {
      if (sentence.contains(selectedText) && sentence.length <= maxLength) {
        return _cleanTrailingPunctuation(sentence.trim());
      }
    }
    
    // Try fragments without word boundaries
    for (final fragment in fragments) {
      if (fragment.contains(selectedText) && fragment.length <= maxLength) {
        return _cleanTrailingPunctuation(fragment.trim());
      }
    }
    
    // Try lines without word boundaries
    for (final line in lines) {
      if (line.contains(selectedText) && line.length <= maxLength) {
        return _cleanTrailingPunctuation(line.trim());
      }
    }

    // Last resort: try substring approach without boundaries
    int selectedIndex = sanitizedText.indexOf(selectedText);
    if (selectedIndex != -1) {
      int contextStart = selectedIndex - 50;
      int contextEnd = selectedIndex + selectedText.length + 50;
      
      if (contextStart < 0) contextStart = 0;
      if (contextEnd > sanitizedText.length) contextEnd = sanitizedText.length;
      
      return _cleanTrailingPunctuation(sanitizedText.substring(contextStart, contextEnd).trim());
    }

    // If all else fails, return the selected text itself
    return selectedText;
  }

  /// Extracts a suitable context for translation purposes.
  ///
  /// Gets a larger context window (up to 1000 chars) suitable for AI translation
  /// models that benefit from more surrounding context.
  ///
  /// @param selectedText The text that was selected by the user
  /// @param fullText The complete text content to extract context from
  /// @return A string containing the selected text with appropriate context
  String findTranslationContext(String selectedText, String fullText) {
    int maxLength = 1000;

    // Create a sanitized version of the full text
    String sanitizedText = fullText.replaceAll('\n', ' ');

    // Check if the text contains the selected text with word boundaries
    final containsWithBoundaries = _containsWordWithBoundaries(sanitizedText, selectedText);
    
    // Split the text into sentences and fragments (now including quotes and more punctuation)
    final sentences = sanitizedText.split(RegExp(r'(?<=[.!?。！？？])\s*'));
    final fragments = sanitizedText.split(RegExp(r'(?<=[.!?,;:()\[\]{}<>\-。！？，；：（）【】［］｛｝「」『』、、；¿¡""''‟„«»‹›])\s*'));
    
    // FIRST: Try all approaches WITH word boundaries
    if (containsWithBoundaries) {
      // Try sentences with word boundaries
      for (final sentence in sentences) {
        if (_containsWordWithBoundaries(sentence, selectedText) && sentence.length <= maxLength) {
          return _cleanTrailingPunctuation(sentence.trim());
        }
      }
      
      // Try fragments with word boundaries
      for (final fragment in fragments) {
        if (_containsWordWithBoundaries(fragment, selectedText) && fragment.length <= maxLength) {
          return _cleanTrailingPunctuation(fragment.trim());
        }
      }
      
      // If no suitable sentence/fragment found with boundaries, try a larger substring around the selected text
      int selectedIndex = _findWordWithBoundariesIndex(sanitizedText, selectedText);
      if (selectedIndex != -1) {
        int contextStart = selectedIndex - maxLength ~/ 2;
        int contextEnd = selectedIndex + selectedText.length + maxLength ~/ 2;
        
        if (contextStart < 0) contextStart = 0;
        if (contextEnd > sanitizedText.length) contextEnd = sanitizedText.length;
        
        return sanitizedText.substring(contextStart, contextEnd).trim();
      }
    }
    
    // SECOND: Fall back to approaches WITHOUT word boundaries
    // Try sentences without requiring word boundaries
    for (final sentence in sentences) {
      if (sentence.contains(selectedText) && sentence.length <= maxLength) {
        return _cleanTrailingPunctuation(sentence.trim());
      }
    }
    
    // Try fragments without requiring word boundaries
    for (final fragment in fragments) {
      if (fragment.contains(selectedText) && fragment.length <= maxLength) {
        return _cleanTrailingPunctuation(fragment.trim());
      }
    }
    
    // Fall back to substring approach without boundaries
    int selectedIndex = sanitizedText.indexOf(selectedText);
    if (selectedIndex != -1) {
      int contextStart = selectedIndex - maxLength ~/ 2;
      int contextEnd = selectedIndex + selectedText.length + maxLength ~/ 2;
      
      if (contextStart < 0) contextStart = 0;
      if (contextEnd > sanitizedText.length) contextEnd = sanitizedText.length;
      
      return sanitizedText.substring(contextStart, contextEnd).trim();
    }

    // Last resort: return the selected text itself
    return selectedText;
  }

  /// Checks if a string contains a word with proper word boundaries.
  ///
  /// This ensures that the word is found as a complete word rather than
  /// as part of another word. Uses both standard word boundaries and punctuation
  /// as potential boundaries.
  ///
  /// @param text The text to search in
  /// @param word The word to search for
  /// @return True if the word exists with proper boundaries
  bool _containsWordWithBoundaries(String text, String word) {
    // Define all characters that can act as word boundaries, including quotes and punctuation
    const String rawBc = ' \t\n\r.,;:!?()[]{}<>/\\|=+-_*&^%\$#@~`"\'‟„«»‹›。！？，；：（）【】［］｛｝「」『』、、；';
    
    // Escape special regex characters in the word
    final String safeBc = RegExp.escape(rawBc);

    // Create a pattern that matches the word when surrounded by start/end of string or boundary chars
    final String boundaryClass = '[$safeBc]';
    final String pattern = r'(^|' + boundaryClass + r')'
                     + RegExp.escape(word)
                     + r'($|' + boundaryClass + r')';

    // Create and use the RegExp
    return RegExp(pattern).hasMatch(text);
  }

  /// Finds the index of a word with proper word boundaries.
  ///
  /// Uses an enhanced definition of word boundaries that includes
  /// punctuation and quotation marks.
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

  /// Cleans trailing punctuation while preserving balanced pairs.
  ///
  /// This ensures that paired punctuation like brackets and quotes are kept intact,
  /// while removing unbalanced trailing punctuation.
  ///
  /// @param text The text to clean
  /// @return Text with properly balanced punctuation
  String _cleanTrailingPunctuation(String text) {
    if (text.isEmpty) return text;
    
    // Define paired punctuation to check for balance
    final punctuationPairs = {
      '(': ')',
      '[': ']',
      '{': '}',
      '<': '>',
      '「': '」',
      '『': '』',
      '（': '）',
      '【': '】',
      '［': '］',
      '｛': '｝',
      '¿': '?',
      '¡': '!',
      '“': '”',
      '‘': '’',
      '"': '"',
      '\'': '\'',
      '《': '》',
      '〈': '〉',
      '‹' : '›',
      '«': '»',
    };
    
    // Check if the text ends with any punctuation
    final regex = RegExp(r'[.!?,;:()\[\]{}<>。！？，；：（）【】［］｛｝「」『』、、；¿¡]+$');
    final match = regex.firstMatch(text);
    
    if (match == null) return text; // No trailing punctuation
    
    final trailingPunctuation = match.group(0)!;
    final textWithoutTrailing = text.substring(0, text.length - trailingPunctuation.length);
    
    // Check each character in the trailing punctuation
    for (int i = 0; i < trailingPunctuation.length; i++) {
      final char = trailingPunctuation[i];
      
      // If it's a closing punctuation, check if it has a matching opening
      if (punctuationPairs.containsValue(char)) {
        final openingChar = punctuationPairs.entries
            .firstWhere((entry) => entry.value == char, orElse: () => const MapEntry('', ''))
            .key;
        
        if (openingChar.isNotEmpty && textWithoutTrailing.contains(openingChar)) {
          // This is a balanced pair, so keep it
          return text;
        }
      }
      
      // If it's an opening punctuation that should have a closing match
      if (punctuationPairs.containsKey(char)) {
        final closingChar = punctuationPairs[char]!;
        if (trailingPunctuation.contains(closingChar)) {
          // This is a balanced pair, so keep it
          return text;
        }
      }
    }
    
    // If we get here, the trailing punctuation isn't balanced, so remove it
    return textWithoutTrailing;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        setState(() {
          mousePosition = event.position; // Update mouse position on hover
        });
      },
      child: TextSelectionTheme(
        data: TextSelectionThemeData(
          selectionColor: AppColors.lightYellow, // Use app color instead of hardcoded
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Create a text style that uses the app font system
            final TextStyle textStyle = widget.style.copyWith(
              fontFamily: widget.style.fontFamily ?? appFonts['Paragraph'],
            );
            
            return SelectableText(
              widget.text,
              style: textStyle,
              textAlign: widget.textAlign,
              onSelectionChanged: (TextSelection selection, SelectionChangedCause? cause) {
                if (selection.baseOffset != selection.extentOffset) {
                  hideTimer?.cancel();
                  timer?.cancel();
                  timer = Timer(const Duration(milliseconds: 200), () {
                    setState(() {
                      selectedText = widget.text.substring(selection.start, selection.end);
                      final renderBox = context.findRenderObject() as RenderBox;
                      final textPainter = TextPainter(
                        text: TextSpan(text: widget.text, style: textStyle),
                        textDirection: TextDirection.ltr,
                      );
                      textPainter.layout(maxWidth: constraints.maxWidth);
                      final startOffset = textPainter.getOffsetForCaret(
                        TextPosition(offset: selection.start),
                        Rect.zero,
                      );
                      final endOffset = textPainter.getOffsetForCaret(
                        TextPosition(offset: selection.end),
                        Rect.zero,
                      );
                      final startGlobalOffset = renderBox.localToGlobal(startOffset);
                      final endGlobalOffset = renderBox.localToGlobal(endOffset);
                      final rect = Rect.fromPoints(startGlobalOffset, endGlobalOffset);
                      showOverlay(context, selectedText!, rect);
                    });
                  });
                } else {
                  hideOverlay();
                }
              },
            );
          },
        ),
      ),
    );
  }
}