import 'package:flutter/material.dart';
import 'package:lenski/models/card_model.dart' as lenski_card;
import 'package:lenski/services/tts_service.dart';
import 'package:lenski/widgets/ltext.dart';

class BackCard extends StatelessWidget {
  final lenski_card.Card card;
  final String courseFromCode;
  final Function(int) onDifficultySelected;

  const BackCard({
    super.key,
    required this.card,
    required this.courseFromCode,
    required this.onDifficultySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '${courseFromCode.toLowerCase()}.',
          style: const TextStyle(
            fontSize: 18.0,
            color: Color(0xFF99909B),
            fontFamily: "Varela Round",
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              card.back,
              style: const TextStyle(
                fontSize: 24.0,
                color: Color.fromARGB(255, 0, 0, 0),
                fontFamily: "Varela Round",
              ),
            ),
            const SizedBox(height: 8.0),
            LText(
              text: card.front,
              toLanguage: card.language,
              fromLanguage: courseFromCode,
              style: const TextStyle(
                fontSize: 18.0,
                color: Color(0xFF99909B),
                fontFamily: "Varela Round",
              ),
            ),
            const SizedBox(height: 16.0),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFD9D0DB),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.volume_up, color: Colors.black),
                iconSize: 40.0,
                onPressed: () async {
                  try {
                    await TtsService().speak(card.front, card.language);
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
            if (card.context != card.front) ...[
              const SizedBox(height: 16.0),
              LText(
                text: card.context,
                fromLanguage: courseFromCode,
                toLanguage: card.language,
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Color(0xFF99909B),
                  fontFamily: "Varela Round",
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => onDifficultySelected(1),
              child: const Text(
                'Hard',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Color(0xFF000000),
                  fontFamily: "Sansation",
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            ElevatedButton(
              onPressed: () => onDifficultySelected(4),
              child: const Text(
                'Easy',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Color(0xFF000000),
                  fontFamily: "Sansation",
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}