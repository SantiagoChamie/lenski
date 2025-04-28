import 'package:flutter/material.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/services/translation_service.dart';
import 'package:lenski/services/tts_service.dart'; // Import the TTS service
import 'package:lenski/data/card_repository.dart';
import 'package:lenski/models/card_model.dart' as custom_card; // Alias the import
import 'dart:io';

/// A widget that displays a translation overlay for the selected text.
class TranslationOverlay extends StatefulWidget {
  final String text;
  final String contextText;
  final String sourceLang;
  final String targetLang;
  final VoidCallback onClose; // Callback to close the overlay
  final List<String>? cardTypes; // New parameter

  const TranslationOverlay({
    super.key,
    required this.text,
    required this.contextText,
    required this.sourceLang,
    required this.targetLang,
    required this.onClose, // Add this parameter
    this.cardTypes, // Add this parameter
  });

  @override
  _TranslationOverlayState createState() => _TranslationOverlayState();
}

class _TranslationOverlayState extends State<TranslationOverlay> {
  late Future<String> _translatedText;
  late Future<bool> _cardExists;
  bool _cardAdded = false; // State variable to track if the card is added
  bool _useContext = true; // New state variable for context toggle

  @override
  void initState() {
    super.initState();
    _translatedText = _fetchTranslation();
    _cardExists = _checkCardExists();
  }

  /// Fetches the translation for the selected text using the TranslationService.
  Future<String> _fetchTranslation() async {
    try {
      return await TranslationService().translate(
        text: widget.text,
        sourceLang: widget.sourceLang,
        targetLang: widget.targetLang,
        context: _useContext ? widget.contextText : widget.text, // Use text as context if not using context
      );
    } on SocketException {
      return Future.error('Could not connect to the internet');
    } catch (e) {
      return Future.error('Error: $e');
    }
  }

  /// Toggles the use of context for translation.
  void _toggleContext() {
    setState(() {
      _useContext = !_useContext;
      _translatedText = _fetchTranslation(); // Refresh translation with new context setting
    });
  }

  /// Checks if a card with the given text and context already exists in the CardRepository.
  Future<bool> _checkCardExists() async {
    return await TranslationService().cardExists(widget.text, widget.contextText);
  }

  /// Adds new cards to the CardRepository.
  Future<void> _addCard(String backText) async {
    // If no cardTypes provided, default to reading only
    final types = widget.cardTypes ?? ['reading'];
    
    // Define the order of card types
    const typeOrder = ['reading', 'listening', 'writing', 'speaking'];
    
    // Sort the types based on the defined order
    types.sort((a, b) => typeOrder.indexOf(a).compareTo(typeOrder.indexOf(b)));
    
    // Create cards in sequence with different due dates
    for (int i = 0; i < types.length; i++) {
      final card = custom_card.Card(
        front: widget.text,
        back: backText,
        context: _useContext ? widget.contextText : widget.text,
        dueDate: DateTime.now().add(Duration(days: i)),
        language: widget.sourceLang,
        type: types[i],
      );
      await CardRepository().insertCard(card);
    }

    setState(() {
      _cardAdded = true;
    });
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
                child: const CircularProgressIndicator(color: Color(0xFF2C73DE))
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
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontFamily: 'Varela Round',
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
                      child: const CircularProgressIndicator(color: Color(0xFF2C73DE))
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
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontFamily: 'Varela Round',
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
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Varela Round',
                                ),
                              ),
                              SizedBox(width: p.standardPadding()),
                              Text(
                                snapshot.data ?? '',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontFamily: 'Varela Round',
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
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Varela Round',
                                ),
                              ),
                              SizedBox(width: p.standardPadding()),
                              Text(
                                widget.text,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontFamily: 'Varela Round',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: p.standardPadding()),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!cardExistsSnapshot.data! && !_cardAdded)
                              Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD9D0DB),
                                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.add, color: Colors.black, size: 30.0),
                                  onPressed: () async {
                                    if (snapshot.hasData) {
                                      await _addCard(snapshot.data!);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Card added successfully')),
                                      );
                                    }
                                  },
                                ),
                              ),
                              SizedBox(width: p.standardPadding()/2),
                              Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD9D0DB),
                                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.volume_up, color: Colors.black, size: 30.0),
                                  onPressed: () async {
                                    try{
                                    if (snapshot.hasData) {
                                      await TtsService().speak(widget.text, widget.sourceLang);
                                    }
                                  }catch(e){ 
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Install the text-to-speech for this language in your device to access this functinality')),
                                    );
                                  }
                                  },
                                ),
                              ),
                              SizedBox(width: p.standardPadding()/2),
                              Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD9D0DB),
                                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                ),
                                child: Tooltip(
                                  message: _useContext ? 'Using contextual translation' : 'Using non-contextual translation',
                                  child: IconButton(
                                    icon: Text(
                                      _useContext ? 'C' : 'NC',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Varela Round',
                                      ),
                                    ),
                                    iconSize: 30.0, // Match other buttons' size
                                    padding: const EdgeInsets.all(8.0),
                                    constraints: const BoxConstraints(
                                      minWidth: 48.0,
                                      minHeight: 48.0,
                                    ),
                                    onPressed: _toggleContext,
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
}