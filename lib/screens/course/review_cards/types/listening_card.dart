import 'package:flutter/material.dart';
import 'package:lenski/models/card_model.dart' as lenski_card;
import 'package:lenski/services/tts_service.dart';

class ListeningCard extends StatelessWidget {
  final lenski_card.Card card;
  final String courseCode;
  final VoidCallback onShowAnswer;

  const ListeningCard({
    super.key,
    required this.card,
    required this.courseCode,
    required this.onShowAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '${courseCode.toLowerCase()}.',
            style: const TextStyle(
              fontSize: 18.0,
              color: Color(0xFF99909B),
              fontFamily: "Varela Round",
            ),
          ),
          Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFD52CDE), // Listening competence color
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.volume_up, color: Colors.white),
                  iconSize: 80.0,
                  padding: const EdgeInsets.all(24),
                  onPressed: () async {
                    try {
                      await TtsService().speak(card.front, courseCode);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Install the text-to-speech for this language in your device to access this functionality'
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 24.0),
              if (card.context != card.front)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Listen to context',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Color(0xFF99909B),
                        fontFamily: "Varela Round",
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFD9D0DB),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.volume_up, color: Colors.black),
                        iconSize: 20.0,
                        onPressed: () async {
                          try {
                            await TtsService().speak(card.context, courseCode);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Install the text-to-speech for this language in your device to access this functionality'
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),
          ElevatedButton(
            onPressed: onShowAnswer,
            child: const Text(
              'Show answer',
              style: TextStyle(
                fontSize: 18.0,
                color: Color(0xFF000000),
                fontFamily: "Sansation",
              ),
            ),
          ),
        ],
      ),
    );
  }
}