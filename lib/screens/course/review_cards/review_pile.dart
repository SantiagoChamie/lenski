import 'package:flutter/material.dart';
import 'package:lenski/models/course_model.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/data/card_repository.dart';

class ReviewPile extends StatefulWidget {
  final Course course;

  const ReviewPile({super.key, required this.course});

  @override
  _ReviewPileState createState() => _ReviewPileState();
}

class _ReviewPileState extends State<ReviewPile> {
  String? displayText;

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
        displayText = cards.first.front;
      } else {
        displayText = 'No new cards remaining';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('Review', arguments: widget.course);
      },
      child: SizedBox(
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
    );
  }
}