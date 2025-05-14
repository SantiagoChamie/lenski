import 'dart:async';
import 'package:flutter/material.dart';
import 'translation_overlay.dart';

class LText extends StatefulWidget {
  final String text;
  final String fromLanguage;
  final String toLanguage;
  final TextStyle style;
  final TextAlign textAlign;
  final String position;
  final List<String>? cardTypes; // New parameter
  final VoidCallback? onCardAdded; // Add this parameter

  const LText({
    super.key,
    required this.text,
    required this.fromLanguage,
    required this.toLanguage,
    required this.style,
    this.textAlign = TextAlign.center,
    this.position = 'above',
    this.cardTypes, // Add this parameter
    this.onCardAdded,
  });

  @override
  _LTextState createState() => _LTextState();
}

class _LTextState extends State<LText> {
  Timer? timer;
  Timer? hideTimer;
  String? selectedText;
  OverlayEntry? overlayEntry;
  Offset? mousePosition; // Store the current mouse position

  @override
  void dispose() {
    timer?.cancel();
    hideTimer?.cancel();
    overlayEntry?.remove();
    super.dispose();
  }

  String truncateSelectedText(String text, {int maxLength = 100}) {
    if (text.length <= maxLength) return text;

    // First try: Split by sentence-ending punctuation (including CJK and Arabic)
    final sentences = text.split(RegExp(r'(?<=[.!?。！？؟])\s*'));
    if (sentences.isNotEmpty && sentences[0].length <= maxLength) {
      return sentences[0].trim();
    }

    // Second try: Split by all punctuation (including CJK and Arabic)
    final fragments = text.split(RegExp(r'(?<=[.!?,;:()\[\]{}<>\-。！？，；：（）【】［］｛｝「」『』、،؛])\s*'));
    if (fragments.isNotEmpty && fragments[0].length <= maxLength) {
      return fragments[0].trim();
    }

    // Last resort: Just truncate at maxLength
    return text.substring(0, maxLength).trim();
  }

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
            cardTypes: widget.cardTypes, // Pass the card types to the overlay
            onCardAdded: widget.onCardAdded, // Pass the callback to the overlay
          ),
        ),
      ),
    );
    Overlay.of(context).insert(overlayEntry!);
  }

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

  String findTranslationContext(String selectedText, String fullText) {
    // Create a sanitized version of the full text
    String sanitizedText = fullText.replaceAll('\n', ' ');

    // First try with word boundaries
    final containsWithBoundaries = _containsWordWithBoundaries(sanitizedText, selectedText);
    
    // Use only Approach 1 (sentence-based) with a longer max length
    final sentences = sanitizedText.split(RegExp(r'(?<=[.!?。！？？])\s*'));
    
    // First attempt: search with word boundaries
    if (containsWithBoundaries) {
      for (final sentence in sentences) {
        if (_containsWordWithBoundaries(sentence, selectedText) && sentence.length <= 1000) {
          return _cleanTrailingPunctuation(sentence.trim());
        }
      }
    }
    
    // Second attempt: fall back to regular contains
    for (final sentence in sentences) {
      if (sentence.contains(selectedText) && sentence.length <= 1000) {
        return _cleanTrailingPunctuation(sentence.trim());
      }
    }

    // If no suitable sentence found, return a larger substring around the selected text
    if (containsWithBoundaries) {
      // Try to find the position with word boundaries
      int selectedIndex = _findWordWithBoundariesIndex(sanitizedText, selectedText);
      if (selectedIndex != -1) {
        int contextStart = selectedIndex - 500;
        int contextEnd = selectedIndex + selectedText.length + 500;
        
        if (contextStart < 0) contextStart = 0;
        if (contextEnd > sanitizedText.length) contextEnd = sanitizedText.length;
        
        return sanitizedText.substring(contextStart, contextEnd).trim();
      }
    }
    
    // Fall back to the current approach
    int selectedIndex = sanitizedText.indexOf(selectedText);
    if (selectedIndex != -1) {
      int contextStart = selectedIndex - 500;
      int contextEnd = selectedIndex + selectedText.length + 500;
      
      if (contextStart < 0) contextStart = 0;
      if (contextEnd > sanitizedText.length) contextEnd = sanitizedText.length;
      
      return sanitizedText.substring(contextStart, contextEnd).trim();
    }

    // Last resort: return the selected text itself
    return selectedText;
  }

  String findContext(String selectedText, String fullText, {int maxLength = 100}) {
    // First, create a sanitized version of the full text
    String sanitizedText = fullText.replaceAll('\n', ' ');
    
    // Check if the selected text exists with word boundaries
    final containsWithBoundaries = _containsWordWithBoundaries(sanitizedText, selectedText);

    // Approach 1: Split by sentence-ending punctuation (including CJK and Arabic)
    final sentences = sanitizedText.split(RegExp(r'(?<=[.!?。！？？])\s*'));
    
    // First try with word boundaries
    if (containsWithBoundaries) {
      for (final sentence in sentences) {
        if (_containsWordWithBoundaries(sentence, selectedText) && sentence.length <= maxLength) {
          return _cleanTrailingPunctuation(sentence.trim());
        }
      }
    }
    
    // Fall back to regular contains
    for (final sentence in sentences) {
      if (sentence.contains(selectedText) && sentence.length <= maxLength) {
        return _cleanTrailingPunctuation(sentence.trim());
      }
    }

    // Approach 2: Split by all punctuation (including CJK and Arabic)
    final fragments = sanitizedText.split(RegExp(r'(?<=[.!?,;:()\[\]{}<>\-。！？，；：（）【】［］｛｝「」『』、、；¿¡])\s*'));
    
    // First try with word boundaries
    if (containsWithBoundaries) {
      for (final fragment in fragments) {
        if (_containsWordWithBoundaries(fragment, selectedText) && fragment.length <= maxLength) {
          return _cleanTrailingPunctuation(fragment.trim());
        }
      }
    }
    
    // Fall back to regular contains
    for (final fragment in fragments) {
      if (fragment.contains(selectedText) && fragment.length <= maxLength) {
        return _cleanTrailingPunctuation(fragment.trim());
      }
    }

    // Approach 3: Split by original line breaks
    final lines = fullText.split('\n');
    
    // First try with word boundaries
    if (containsWithBoundaries) {
      for (final line in lines) {
        if (_containsWordWithBoundaries(line, selectedText) && line.length <= maxLength) {
          return _cleanTrailingPunctuation(line.trim());
        }
      }
    }
    
    // Fall back to regular contains
    for (final line in lines) {
      if (line.contains(selectedText) && line.length <= maxLength) {
        return _cleanTrailingPunctuation(line.trim());
      }
    }

    // Fallback: If no suitable context found, return a substring around the selected text
    if (containsWithBoundaries) {
      int selectedIndex = _findWordWithBoundariesIndex(sanitizedText, selectedText);
      if (selectedIndex != -1) {
        int contextStart = selectedIndex - 50;
        int contextEnd = selectedIndex + selectedText.length + 50;
        
        if (contextStart < 0) contextStart = 0;
        if (contextEnd > sanitizedText.length) contextEnd = sanitizedText.length;
        
        return _cleanTrailingPunctuation(sanitizedText.substring(contextStart, contextEnd).trim());
      }
    }
    
    // Fall back to current approach
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

  /// Checks if a string contains a word with proper word boundaries
  bool _containsWordWithBoundaries(String text, String word) {
    // Create a RegExp that matches the word with word boundaries
    // \b represents a word boundary in RegExp
    final RegExp wordRegExp = RegExp(r'\b' + RegExp.escape(word) + r'\b');
    return wordRegExp.hasMatch(text);
  }

  /// Finds the index of a word with proper word boundaries
  int _findWordWithBoundariesIndex(String text, String word) {
    final RegExp wordRegExp = RegExp(r'\b' + RegExp.escape(word) + r'\b');
    final match = wordRegExp.firstMatch(text);
    return match?.start ?? -1;
  }

  /// Cleans trailing punctuation while preserving balanced pairs
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
      '¡': '!'
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
        data: const TextSelectionThemeData(
          selectionColor: Color(0xFFFFD38D),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SelectableText(
              widget.text,
              style: widget.style,
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
                        text: TextSpan(text: widget.text, style: widget.style),
                        textDirection: TextDirection.ltr,
                      );
                      textPainter.layout();
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