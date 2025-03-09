import 'package:flutter/material.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/services/translation_service.dart';
import 'package:lenski/data/card_repository.dart';
import 'package:lenski/models/card_model.dart' as custom_card; // Alias the import
import 'dart:io';

class TranslationOverlay extends StatefulWidget {
  final String text;
  final String contextText;
  final String sourceLang;
  final String targetLang;

  const TranslationOverlay({
    super.key,
    required this.text,
    required this.contextText,
    required this.sourceLang,
    required this.targetLang,
  });

  @override
  _TranslationOverlayState createState() => _TranslationOverlayState();
}

class _TranslationOverlayState extends State<TranslationOverlay> {
  late Future<String> _translatedText;
  late Future<bool> _cardExists;

  @override
  void initState() {
    super.initState();
    _translatedText = _fetchTranslation();
    _cardExists = _checkCardExists();
  }

  Future<String> _fetchTranslation() async {
    try {
      return await TranslationService().translate(
        text: widget.text,
        sourceLang: widget.sourceLang,
        targetLang: widget.targetLang,
        context: widget.contextText,
      );
    } on SocketException {
      return Future.error('Could not connect to the internet');
    } catch (e) {
      return Future.error('Error: $e');
    }
  }

  Future<bool> _checkCardExists() async {
    return await TranslationService().cardExists(widget.text, widget.contextText);
  }

  Future<void> _addCard(String backText) async {
    final card = custom_card.Card( // Use the alias here
      front: widget.text,
      back: backText,
      context: widget.contextText,
      dueDate: DateTime.now(), // Pass DateTime directly
      language: widget.sourceLang,
    );
    await CardRepository().insertCard(card);
  }

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    return FutureBuilder<String>(
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
                      if (!cardExistsSnapshot.data!)
                      SizedBox(height: p.standardPadding()),
                      if (!cardExistsSnapshot.data!)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
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
    );
  }
}