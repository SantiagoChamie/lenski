import 'package:flutter/material.dart';
import 'package:lenski/models/course_model.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/data/card_repository.dart';
import 'dart:math'; // Add this import for randomization

class ReviewPile extends StatefulWidget {
  final Course course;

  const ReviewPile({super.key, required this.course});

  @override
  _ReviewPileState createState() => _ReviewPileState();
}

class _ReviewPileState extends State<ReviewPile> {
  String? displayText;
  List<String> cardFronts = [];

  @override
  void initState() {
    super.initState();
    _fetchFirstWord();
  }

  Future<void> _fetchFirstWord() async {
    final repository = CardRepository();
    final cards = await repository.cards(DateTime.now(), widget.course.code);
    setState(() {
      if (cards.isNotEmpty) {
        cardFronts = cards.map((card) => card.front).toList();
        cardFronts.shuffle(Random());
        displayText = cardFronts.first;
      } else {
        displayText = 'No new cards remaining';
      }
    });
  }

  Future<void> _refreshWord() async {
    if (cardFronts.isNotEmpty) {
      final repository = CardRepository();
      final cards = await repository.cards(DateTime.now(), widget.course.code);
      setState(() {
        if (cards.isNotEmpty) {
          final newCardFronts = cards.map((card) => card.front).toList();
          final remainingCards = newCardFronts.where((card) => card != displayText).toList();
          if (remainingCards.isNotEmpty) {
            remainingCards.shuffle(Random());
            displayText = remainingCards.first;
          }
        }
      });
    } else {
      _fetchFirstWord();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('Review', arguments: widget.course);
      },
      child: Stack(
        children: [
          SizedBox(
            width: p.mainScreenWidth() / 2,
            height: double.infinity,
            child: Container(
              margin: EdgeInsets.only(bottom: p.standardPadding() * 2, left: p.standardPadding() * 2, right: p.standardPadding() * 2),
              width: p.mainScreenWidth() / 2 - 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F0F6),
                borderRadius: BorderRadius.circular(5.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 4.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  displayText ?? 'Loading...',
                  style: const TextStyle(fontSize: 24, fontFamily: 'Telex'),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 40,
            child: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshWord,
            ),
          ),
        ],
      ),
    );
  }
}