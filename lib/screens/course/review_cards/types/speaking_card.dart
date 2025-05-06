import 'package:flutter/material.dart';
import 'package:lenski/models/card_model.dart' as lenski_card;

class SpeakingCard extends StatefulWidget {
  final lenski_card.Card card;
  final String courseCode;
  final VoidCallback onShowAnswer;

  const SpeakingCard({
    super.key,
    required this.card,
    required this.courseCode,
    required this.onShowAnswer,
  });

  @override
  State<SpeakingCard> createState() => _SpeakingCardState();
}

class _SpeakingCardState extends State<SpeakingCard> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '${widget.courseCode.toLowerCase()}.',
            style: const TextStyle(
              fontSize: 18.0,
              color: Color(0xFF99909B),
              fontFamily: "Varela Round",
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text.rich(
                TextSpan(
                  text: widget.card.context.contains(widget.card.front)
                      ? widget.card.context.substring(0, widget.card.context.indexOf(widget.card.front))
                      : widget.card.context,
                  style: const TextStyle(
                    fontSize: 24.0,
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontFamily: "Varela Round",
                  ),
                  children: widget.card.context.contains(widget.card.front)
                      ? [
                          const TextSpan(
                            text: '_______',
                            style: TextStyle(
                              fontSize: 24.0,
                              color: Color(0xFFDE2C50), // Speaking competence color
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: widget.card.context.substring(
                              widget.card.context.indexOf(widget.card.front) + widget.card.front.length,
                            ),
                          ),
                        ]
                      : [],
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                '~${widget.card.back}~',
                style: const TextStyle(
                  fontSize: 18.0,
                  color: Color(0xFF99909B),
                  fontFamily: "Varela Round",
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: widget.onShowAnswer,
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