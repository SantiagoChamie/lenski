import 'dart:async';
import 'package:flutter/material.dart';
import 'translation_overlay.dart';

class LText extends StatefulWidget {
  final String text;
  final String fromLanguage;
  final String toLanguage;
  final TextStyle style;
  //TODO: make position work with a widget
  final String position;

  const LText({
    super.key,
    required this.text,
    required this.fromLanguage,
    required this.toLanguage,
    required this.style,
    this.position = 'above',
  });

  @override
  _LTextState createState() => _LTextState();
}

class _LTextState extends State<LText> {
  Timer? timer;
  Timer? hideTimer;
  String? selectedText;
  OverlayEntry? overlayEntry;

  @override
  void dispose() {
    timer?.cancel();
    hideTimer?.cancel();
    overlayEntry?.remove();
    super.dispose();
  }

  void showOverlay(BuildContext context, String text, Rect rect) {
    overlayEntry?.remove();
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: widget.position == 'above' ? rect.top - 175 : rect.bottom + 50, // Adjust based on position
        left: rect.left - 100, // Adjust this value based on your requirements
        child: Material(
          color: Colors.transparent,
          child: TranslationOverlay(
            text: text,
            contextText: widget.text,
            sourceLang: widget.fromLanguage,
            targetLang: widget.toLanguage,
          ),
        ),
      ),
    );
    Overlay.of(context).insert(overlayEntry!);
  }

  void hideOverlay() {
    hideTimer?.cancel();
    hideTimer = Timer(const Duration(milliseconds: 200), () {
      overlayEntry?.remove();
      overlayEntry = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextSelectionTheme(
      data: const TextSelectionThemeData(
        selectionColor: Color(0xFFFFD38D),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SelectableText(
            widget.text,
            style: widget.style,
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
    );
  }
}