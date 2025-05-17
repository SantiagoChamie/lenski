import 'package:flutter/material.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/services/translation_service.dart';
import 'package:lenski/services/tts_service.dart';
import 'package:lenski/data/card_repository.dart';
import 'package:lenski/data/session_repository.dart';
import 'package:lenski/models/card_model.dart' as custom_card;
import 'package:lenski/utils/colors.dart';
import 'package:lenski/utils/fonts.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

/// A widget that displays a translation overlay for the selected text.
/// 
/// This overlay shows the selected text, its translation, and provides
/// options to add the text as a study card, listen to pronunciation,
/// and toggle between contextual and non-contextual translations.
class TranslationOverlay extends StatefulWidget {
  /// The text to be translated
  final String text;
  
  /// The surrounding text for context
  final String contextText;
  
  /// Context specifically for translation purposes
  final String translationContext;
  
  /// Source language code (e.g. 'en')
  final String sourceLang;
  
  /// Target language code (e.g. 'es')
  final String targetLang;
  
  /// Callback to close the overlay
  final VoidCallback onClose;
  
  /// Types of cards to create when adding this text to study
  final List<String>? cardTypes;
  
  /// Callback that runs after successfully adding a card
  final VoidCallback? onCardAdded;

  const TranslationOverlay({
    super.key,
    required this.text,
    required this.contextText,
    required this.translationContext,
    required this.sourceLang,
    required this.targetLang,
    required this.onClose,
    this.cardTypes,
    this.onCardAdded,
  });

  @override
  _TranslationOverlayState createState() => _TranslationOverlayState();
}

class _TranslationOverlayState extends State<TranslationOverlay> {
  /// Future that resolves to the translated text
  late Future<String> _translatedText;
  
  /// Future that checks if this text already exists as a card
  late Future<bool> _cardExists;
  
  /// Whether the card has been added in this session
  bool _cardAdded = false;
  
  /// Whether to use context for translation
  bool _useContext = true;
  
  /// Whether the contextual translation feature is enabled globally
  bool _contextualTranslationEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadContextualTranslationSetting();
    _translatedText = _fetchTranslation();
    _cardExists = _checkCardExists();
  }

  /// Loads the contextual translation setting from shared preferences.
  /// 
  /// If the feature is disabled globally, forces context to always be used.
  Future<void> _loadContextualTranslationSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _contextualTranslationEnabled = prefs.getBool('contextual_translation_enabled') ?? false;
      // If the feature is disabled, always use context
      if (!_contextualTranslationEnabled) {
        _useContext = true;
      }
    });
  }

  /// Fetches the translation for the selected text using the TranslationService.
  /// 
  /// Uses either contextual or non-contextual translation based on user preference.
  /// Returns an error message if translation fails.
  Future<String> _fetchTranslation() async {
    try {
      return await TranslationService().translate(
        text: widget.text,
        sourceLang: widget.sourceLang,
        targetLang: widget.targetLang,
        context: _useContext ? widget.translationContext : widget.text,
      );
    } on SocketException {
      return Future.error('Could not connect to the internet');
    } catch (e) {
      return Future.error('Error: $e');
    }
  }

  /// Toggles between using context or not for translation.
  /// 
  /// This will refresh the translation and card existence check.
  void _toggleUseContext() {
    if (!_contextualTranslationEnabled) return;
    
    setState(() {
      _useContext = !_useContext;
      _translatedText = _fetchTranslation();
      _cardExists = _checkCardExists();
    });
  }

  /// Checks if a card with the given text and context already exists.
  Future<bool> _checkCardExists() async {
    return await TranslationService().cardExists(
      widget.text, 
      _useContext ? widget.contextText : widget.text
    );
  }

  /// Adds new study cards to the CardRepository and updates session statistics.
  /// 
  /// Creates one card for each type (reading, listening, writing, speaking)
  /// with progressive due dates. Updates session stats and notifies listeners.
  Future<void> _addCard(String backText) async {
    // If no cardTypes provided, default to reading only
    final types = widget.cardTypes ?? ['reading'];
    
    // Define the order of card types
    const typeOrder = ['reading', 'listening', 'writing', 'speaking'];
    
    // Sort the types based on the defined order
    types.sort((a, b) => typeOrder.indexOf(a).compareTo(typeOrder.indexOf(b)));
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Create cards in sequence with different due dates
    for (int i = 0; i < types.length; i++) {
      final card = custom_card.Card(
        front: widget.text,
        back: backText,
        context: _useContext ? widget.contextText: widget.text,
        dueDate: today.add(Duration(days: i)),
        language: widget.sourceLang,
        type: types[i],
      );
      await CardRepository().insertCard(card);
    }

    // Update session statistics - increment words added by 1
    final sessionRepo = SessionRepository();
    await sessionRepo.updateSessionStats(
      courseCode: widget.sourceLang,
      wordsAdded: 1,
    );

    setState(() {
      _cardAdded = true;
    });
    
    widget.onCardAdded?.call();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    return Stack(
      children: [
        FutureBuilder<String>(
          future: _translatedText,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingContainer(p);
            } else if (snapshot.hasError) {
              return _buildErrorContainer(p, snapshot.error.toString());
            } else {
              return FutureBuilder<bool>(
                future: _cardExists,
                builder: (context, cardExistsSnapshot) {
                  if (cardExistsSnapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingContainer(p);
                  } else if (cardExistsSnapshot.hasError) {
                    return _buildErrorContainer(p, cardExistsSnapshot.error.toString());
                  } else {
                    return _buildTranslationContainer(p, snapshot.data ?? '', cardExistsSnapshot.data ?? false);
                  }
                },
              );
            }
          },
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            iconSize: 10,
            splashColor: Colors.transparent, 
            highlightColor: Colors.transparent,
            onPressed: widget.onClose,
          ),
        ),
      ],
    );
  }

  /// Creates a container with a loading indicator.
  Widget _buildLoadingContainer(Proportions p) {
    return Container(
      padding: EdgeInsets.all(p.standardPadding()),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const CircularProgressIndicator(color: AppColors.blue)
    );
  }

  /// Creates a container to display errors.
  Widget _buildErrorContainer(Proportions p, String errorMessage) {
    return Container(
      padding: EdgeInsets.all(p.standardPadding()),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        errorMessage,
        style: TextStyle(
          fontSize: 16.0,
          fontFamily: appFonts['Paragraph'],
        ),
      ),
    );
  }

  /// Creates the main translation container with text and action buttons.
  Widget _buildTranslationContainer(Proportions p, String translatedText, bool cardExists) {
    return Container(
      padding: EdgeInsets.all(p.standardPadding()),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLanguageRow(p, widget.targetLang.toLowerCase(), translatedText),
          SizedBox(height: p.standardPadding() / 2),
          _buildLanguageRow(p, widget.sourceLang.toLowerCase(), widget.text),
          SizedBox(height: p.standardPadding()),
          _buildActionButtonsRow(p, translatedText, cardExists),
        ],
      ),
    );
  }

  /// Creates a row with language label and text content.
  Widget _buildLanguageRow(Proportions p, String languageCode, String content) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$languageCode.',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            fontFamily: appFonts['Paragraph'],
          ),
        ),
        SizedBox(width: p.standardPadding()),
        Text(
          content,
          style: TextStyle(
            fontSize: 16.0,
            fontFamily: appFonts['Paragraph'],
          ),
        ),
      ],
    );
  }

  /// Creates a row with action buttons (add card, TTS, context toggle).
  Widget _buildActionButtonsRow(Proportions p, String translatedText, bool cardExists) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!cardExists && !_cardAdded)
          _buildActionButton(
            icon: const Icon(Icons.add, color: Colors.black, size: 30.0),
            onPressed: () async {
              await _addCard(translatedText);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Card added successfully')),
              );
            },
          ),
        if (!cardExists && !_cardAdded)
          SizedBox(width: p.standardPadding() / 2),
        _buildActionButton(
          icon: const Icon(Icons.volume_up, color: Colors.black, size: 30.0),
          onPressed: () async {
            try {
              await TtsService().speak(widget.text, widget.sourceLang);
            } catch(e) { 
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Install the text-to-speech for this language in your device to access this functionality')),
              );
            }
          },
        ),
        if (_contextualTranslationEnabled)
          SizedBox(width: p.standardPadding() / 2),
        if (_contextualTranslationEnabled)
          _buildContextToggleButton(),
      ],
    );
  }

  /// Creates an action button with standard styling.
  Widget _buildActionButton({required Widget icon, required VoidCallback onPressed}) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.grey,
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      child: IconButton(
        icon: icon,
        onPressed: onPressed,
      ),
    );
  }

  /// Creates the context toggle button with tooltip.
  Widget _buildContextToggleButton() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.grey,
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      child: Tooltip(
        message: _useContext ? 'Using contextual translation' : 'Using word-only translation',
        child: IconButton(
          icon: Text(
            _useContext ? 'C' : 'NC',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              fontFamily: appFonts['Paragraph'],
            ),
          ),
          iconSize: 30.0,
          padding: const EdgeInsets.all(8.0),
          constraints: const BoxConstraints(
            minWidth: 48.0,
            minHeight: 48.0,
          ),
          onPressed: _toggleUseContext,
        ),
      ),
    );
  }
}