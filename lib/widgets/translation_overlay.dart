import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
/// This component shows a floating overlay with the translation of selected text,
/// along with controls to:
/// - Add the word to flashcards
/// - Hear the pronunciation of the word
/// - Toggle between contextual and non-contextual translation
///
/// The overlay is typically triggered by selecting/highlighting text in a reading view
/// and can be dismissed by tapping outside or using the close button.
class TranslationOverlay extends StatefulWidget {
  /// The selected text to be translated
  final String text;
  
  /// The surrounding text that provides context for translation
  final String contextText;
  
  /// Context used specifically for translation (might differ from contextText)
  final String translationContext;
  
  /// Source language code (what is being translated from)
  final String sourceLang;
  
  /// Target language code (what is being translated to)
  final String targetLang;
  
  /// Callback function to close the overlay
  final VoidCallback onClose;
  
  /// Optional list of card types to create (reading, writing, etc.)
  final List<String>? cardTypes;
  
  /// Optional callback when a card is added to the flashcards
  final VoidCallback? onCardAdded;

  /// Creates a TranslationOverlay widget.
  /// 
  /// [text] is the selected text to be translated.
  /// [contextText] is the surrounding text that provides context.
  /// [translationContext] is the specific context used for translation.
  /// [sourceLang] is the language code of the source text.
  /// [targetLang] is the language code to translate into.
  /// [onClose] is called when the overlay should be closed.
  /// [cardTypes] specifies what types of flashcards to create.
  /// [onCardAdded] is called when a flashcard is successfully added.
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
  
  /// Future that resolves to whether a card with this text already exists
  late Future<bool> _cardExists;
  
  /// Whether a card has been added during this overlay session
  bool _cardAdded = false;
  
  /// Whether to use surrounding context for translation
  bool _useContext = true;
  
  /// Whether contextual translation feature is enabled in settings
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
  /// This determines whether the user can toggle between contextual and
  /// non-contextual translations in the overlay.
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
  /// Depending on the _useContext flag, this will either translate with or without
  /// considering the surrounding context text.
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

  /// Toggles between using context and not using context for translation.
  ///
  /// This refreshes the translation using the new context setting and
  /// is only available if contextual translation is enabled in settings.
  void _toggleUseContext() {
    if (!_contextualTranslationEnabled) return; // Don't toggle if feature is disabled
    
    setState(() {
      _useContext = !_useContext;
      _translatedText = _fetchTranslation();
      _cardExists = _checkCardExists();
    });
  }

  /// Checks if a card with the given text and context already exists.
  ///
  /// This helps prevent creating duplicate flashcards for the same word or phrase.
  Future<bool> _checkCardExists() async {
    return await TranslationService().cardExists(
      widget.text, 
      _useContext ? widget.contextText : widget.text
    );
  }

  /// Adds new flashcards to the repository and updates session statistics.
  ///
  /// This creates cards for each competence type requested (reading, writing, etc.)
  /// with increasing due dates to space out the initial reviews.
  ///
  /// @param backText The translated text to use as the back of the flashcard
  Future<void> _addCard(String backText) async {
    final localizations = AppLocalizations.of(context)!;
    
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
        context: widget.contextText, //_useContext ? widget.contextText: widget.text
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

    // Call the onCardAdded callback if provided
    if (widget.onCardAdded != null) {
      widget.onCardAdded!();
    }

    setState(() {
      _cardAdded = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(
        localizations.cardAddedSuccessfully
      )),
    );
    
    widget.onClose(); // Close overlay after adding card
  }

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    final localizations = AppLocalizations.of(context)!;
    
    // Use FocusTraversalGroup to prevent keyboard focus stealing
    return Stack(
      children: [
        // Use MouseRegion to handle mouse events without stealing focus
        MouseRegion(
          child: GestureDetector(
            // Empty callbacks to intercept gestures without changing focus
            onTap: () {},
            child: FutureBuilder<String>(
              future: _translatedText,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
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
                } else if (snapshot.hasError) {
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
                      snapshot.error.toString(),
                      style: TextStyle(
                        fontSize: 16.0,
                        fontFamily: appFonts['Paragraph'],
                      ),
                    ),
                  );
                } else {
                  return FutureBuilder<bool>(
                    future: _cardExists,
                    builder: (context, cardExistsSnapshot) {
                      if (cardExistsSnapshot.connectionState == ConnectionState.waiting) {
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
                      } else if (cardExistsSnapshot.hasError) {
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
                            cardExistsSnapshot.error.toString(),
                            style: TextStyle(
                              fontSize: 16.0,
                              fontFamily: appFonts['Paragraph'],
                            ),
                          ),
                        );
                      } else {
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${widget.targetLang}.'.toLowerCase(),
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: appFonts['Paragraph'],
                                    ),
                                  ),
                                  SizedBox(width: p.standardPadding()),
                                  Text(
                                    snapshot.data ?? '',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontFamily: appFonts['Paragraph'],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: p.standardPadding() / 2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${widget.sourceLang}.'.toLowerCase(),
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: appFonts['Paragraph'],
                                    ),
                                  ),
                                  SizedBox(width: p.standardPadding()),
                                  Text(
                                    widget.text,
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontFamily: appFonts['Paragraph'],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: p.standardPadding()),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Add card button (only if card doesn't exist yet)
                                  if (!cardExistsSnapshot.data! && !_cardAdded)
                                  Container(
                                    decoration: const BoxDecoration(
                                      color: AppColors.grey,
                                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                    ),
                                    child: Tooltip(
                                      message: localizations.addToPile,
                                      child: RawMaterialButton(
                                        focusNode: null, // Prevent stealing focus
                                        constraints: const BoxConstraints(
                                          minWidth: 48.0,
                                          minHeight: 48.0,
                                        ),
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        shape: const CircleBorder(),
                                        child: const Icon(Icons.add, color: AppColors.black, size: 30.0),
                                        onPressed: () async {
                                          if (snapshot.hasData) {
                                            await _addCard(snapshot.data!);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: p.standardPadding()/2),
                                  
                                  // Text-to-speech button
                                  Container(
                                    decoration: const BoxDecoration(
                                      color: AppColors.grey,
                                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                    ),
                                    child: RawMaterialButton(
                                      focusNode: null, // Prevent stealing focus
                                      constraints: const BoxConstraints(
                                        minWidth: 48.0,
                                        minHeight: 48.0,
                                      ),
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      shape: const CircleBorder(),
                                      child: const Icon(Icons.volume_up, color: AppColors.black, size: 30.0),
                                      onPressed: () async {
                                        try {
                                          if (snapshot.hasData) {
                                            await TtsService().speak(widget.text, widget.sourceLang);
                                          }
                                        } catch(e) { 
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text(localizations.installTtsMessage)),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                  
                                  // Contextual translation toggle button (only if enabled)
                                  if(_contextualTranslationEnabled) 
                                    SizedBox(width: p.standardPadding()/2),
                                  if(_contextualTranslationEnabled)
                                  Container(
                                    decoration: const BoxDecoration(
                                      color: AppColors.grey,
                                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                    ),
                                    child: Tooltip(
                                      message: _useContext 
                                          ? localizations.usingContextualTranslation 
                                          : localizations.usingWordOnlyTranslation,
                                      child: RawMaterialButton(
                                        focusNode: null, // Prevent stealing focus
                                        constraints: const BoxConstraints(
                                          minWidth: 48.0,
                                          minHeight: 48.0,
                                        ),
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        shape: const CircleBorder(),
                                        onPressed: _toggleUseContext,
                                        child: Text(
                                          _useContext ? 'C' : 'NC',
                                          style: TextStyle(
                                            color: AppColors.black,
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: appFonts['Paragraph'],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  );
                }
              },
            ),
          ),
        ),
        // Close button (using RawMaterialButton to prevent focus capture)
        Positioned(
          top: 0,
          right: 0,
          child: RawMaterialButton(
            focusNode: null, // Prevent stealing focus
            constraints: const BoxConstraints(
              minWidth: 24.0,
              minHeight: 24.0,
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: const CircleBorder(),
            onPressed: widget.onClose,
            child: const Icon(Icons.close, color: AppColors.black, size: 16),
          ),
        ),
      ],
    );
  }
}