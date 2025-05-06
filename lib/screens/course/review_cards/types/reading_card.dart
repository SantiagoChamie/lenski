import 'package:flutter/material.dart';
import 'package:lenski/models/card_model.dart' as lenski_card;

class ReadingCard extends StatelessWidget {
  final lenski_card.Card card;
  final String courseCode;
  final VoidCallback onShowAnswer;

  const ReadingCard({
    super.key,
    required this.card,
    required this.courseCode,
    required this.onShowAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Make container take full width
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center, // Align text to the left
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
            crossAxisAlignment: CrossAxisAlignment.center, // Align text to the left
            children: [
              Text(
                card.front,
                style: const TextStyle(
                  fontSize: 24.0,
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontFamily: "Varela Round",
                ),
              ),
              if (card.context != card.front)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text.rich(
                    TextSpan(
                      children: _buildContextTextSpans(),
                    ),
                  ),
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

  List<TextSpan> _buildContextTextSpans() {
    // Check if the front text is contained in the context
    final int index = card.context.indexOf(card.front);
    
    // If front text isn't in context, just show the context as plain text
    if (index == -1) {
      return [
        TextSpan(
          text: card.context,
          style: const TextStyle(
            fontSize: 18.0,
            color: Color(0xFF99909B),
            fontFamily: "Varela Round",
          ),
        ),
      ];
    }
    
    // If front text is in context, split into three parts
    return [
      // Text before the highlighted word
      TextSpan(
        text: card.context.substring(0, index),
        style: const TextStyle(
          fontSize: 18.0,
          color: Color(0xFF99909B),
          fontFamily: "Varela Round",
        ),
      ),
      // The highlighted word
      TextSpan(
        text: card.front,
        style: const TextStyle(
          fontSize: 18.0,
          color: Color(0xFFEDA42E),
          fontFamily: "Varela Round",
          fontWeight: FontWeight.bold,
        ),
      ),
      // Text after the highlighted word
      TextSpan(
        text: card.context.substring(index + card.front.length),
        style: const TextStyle(
          fontSize: 18.0,
          color: Color(0xFF99909B),
          fontFamily: "Varela Round",
        ),
      ),
    ];
  }
}