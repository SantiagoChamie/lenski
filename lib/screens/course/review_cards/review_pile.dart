import 'package:flutter/material.dart';
import 'package:lenski/models/course_model.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/data/card_repository.dart';
import 'dart:math';

/// A widget that displays a pile of review cards for a course.
class ReviewPile extends StatefulWidget {
  final Course course;
  final VoidCallback? onNewPressed;

  /// Creates a ReviewPile widget.
  /// 
  /// [course] is the course for which the review pile is being created.
  const ReviewPile({super.key, required this.course, required this.onNewPressed});

  @override
  _ReviewPileState createState() => _ReviewPileState();
}

class _ReviewPileState extends State<ReviewPile> {
  String? displayText;
  List<String> cardFronts = [];
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _fetchFirstWord();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// Fetches the first word to be displayed from the repository.
  Future<void> _fetchFirstWord() async {
    if (_disposed) return;
    
    final repository = CardRepository();
    final cards = await repository.cards(DateTime.now(), widget.course.code);
    if (!mounted) return;

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

  /// Refreshes the word to be displayed.
  Future<void> _refreshWord() async {
    if (_disposed) return;
    if (cardFronts.isNotEmpty) {
      final repository = CardRepository();
      final cards = await repository.cards(DateTime.now(), widget.course.code);
      if (!mounted) return;

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
      await _fetchFirstWord();
    }
  }

  void _navigateToAddCardScreen() {
    widget.onNewPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);

    return GestureDetector(
      onTap: () {
        final navigatorKey = Navigator.of(context).widget.key as GlobalKey<NavigatorState>;
        navigatorKey.currentState?.pushNamed(
          'Review',
          arguments: widget.course,
        );
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
          Positioned(
            bottom: 60,
            right: 60,
            child: FloatingActionButton(
              onPressed: _navigateToAddCardScreen,
              backgroundColor: const Color(0xFFD9D0DB),
              child: const Icon(Icons.add, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}