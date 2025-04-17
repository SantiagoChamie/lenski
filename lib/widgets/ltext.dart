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

  const LText({
    super.key,
    required this.text,
    required this.fromLanguage,
    required this.toLanguage,
    required this.style,
    this.textAlign = TextAlign.center,
    this.position = 'above',
    this.cardTypes, // Add this parameter
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

    // First try: Split by sentence-ending punctuation
    final sentences = text.split(RegExp(r'(?<=[.!?])\s+'));
    if (sentences.isNotEmpty && sentences[0].length <= maxLength) {
      return sentences[0].trim();
    }

    // Second try: Split by all punctuation
    final fragments = text.split(RegExp(r'(?<=[.!?,;:()\[\]{}<>\-])\s*'));
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

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: widget.position == 'above' ? mousePosition!.dy - 200 : rect.bottom + 50,
        left: mousePosition!.dx - 150,
        child: Material(
          color: Colors.transparent,
          child: TranslationOverlay(
            text: truncatedText, // Use truncated text instead of full selection
            contextText: contextText,
            sourceLang: widget.toLanguage,
            targetLang: widget.fromLanguage,
            onClose: () => hideOverlay(instant: true),
            cardTypes: widget.cardTypes, // Pass the card types to the overlay
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

  // Add this method to _LTextState class:
  String findContext(String selectedText, String fullText, {int maxLength = 100}) {
    // First, create a sanitized version of the full text
    String sanitizedText = fullText.replaceAll('\n', ' ');
    // Approach 1: Split by sentence-ending punctuation
    final sentences = sanitizedText.split(RegExp(r'(?<=[.!?])\s+'));
    for (final sentence in sentences) {
      if (sentence.contains(selectedText) && sentence.length <= maxLength) {
        return sentence.trim();
      }
    }

    // Approach 2: Split by all punctuation (including sentence-ending)
    // Using positive lookbehind (?<=...) to keep the punctuation marks
    final fragments = sanitizedText.split(RegExp(r'(?<=[.!?,;:()\[\]{}<>\-])\s*'));
    for (final fragment in fragments) {
      if (fragment.contains(selectedText) && fragment.length <= maxLength) {
        return fragment.trim();
      }
    }

    // Approach 3: Split by original line breaks
    final lines = fullText.split('\n');
    for (final line in lines) {
      if (line.contains(selectedText) && line.length <= maxLength) {
        return line.trim();
      }
    }

    // Fallback: If no suitable context found, return a substring around the selected text
    int selectedIndex = sanitizedText.indexOf(selectedText);
    if (selectedIndex != -1) {
      int contextStart = selectedIndex - 50;
      int contextEnd = selectedIndex + selectedText.length + 50;
      
      if (contextStart < 0) contextStart = 0;
      if (contextEnd > sanitizedText.length) contextEnd = sanitizedText.length;
      
      return sanitizedText.substring(contextStart, contextEnd).trim();
    }

    // Last resort: return the selected text itself
    return selectedText;
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