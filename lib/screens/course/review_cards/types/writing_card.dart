import 'package:flutter/material.dart';
import 'package:lenski/models/card_model.dart' as lenski_card;

class WritingCard extends StatefulWidget {
  final lenski_card.Card card;
  final String courseCode;
  final VoidCallback onShowAnswer;

  const WritingCard({
    super.key,
    required this.card,
    required this.courseCode,
    required this.onShowAnswer,
  });

  @override
  State<WritingCard> createState() => _WritingCardState();
}

class _WritingCardState extends State<WritingCard> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
                  text: widget.card.context.substring(0, widget.card.context.indexOf(widget.card.front)),
                  style: const TextStyle(
                    fontSize: 24.0,
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontFamily: "Varela Round",
                  ),
                  children: [
                    WidgetSpan(
                      child: SizedBox(
                        width: 120,
                        child: TextField(
                          controller: _controller,
                          cursorColor: const Color(0xFFEDE72D),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 8),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),     
                            ),
                            border: UnderlineInputBorder(),
                            isDense: true,
                          ),
                          style: const TextStyle(
                            fontSize: 24.0,
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontFamily: "Varela Round",
                          ),
                        ),
                      ),
                    ),
                    TextSpan(
                      text: widget.card.context.substring(
                        widget.card.context.indexOf(widget.card.front) + widget.card.front.length
                      ),
                    ),
                  ],
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
              'Check answer',
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