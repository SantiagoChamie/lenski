import 'package:flutter/material.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/data/card_repository.dart';
import 'package:lenski/models/card_model.dart';

class ReviewPile extends StatelessWidget {
  final String languageCode;

  const ReviewPile({super.key, required this.languageCode});

  Future<String?> _fetchFirstWord() async {
    final repository = CardRepository();
    final cards = await repository.cards(DateTime.now(), languageCode);
    if (cards.isNotEmpty) {
      return cards.first.front;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);

    return FutureBuilder<String?>(
      future: _fetchFirstWord(),
      builder: (context, snapshot) {
        String displayText;
        if (snapshot.connectionState == ConnectionState.waiting) {
          displayText = 'Loading...';
        } else if (snapshot.hasError) {
          displayText = 'Error fetching card';
        } else if (!snapshot.hasData || snapshot.data == null) {
          displayText = 'No new cards remaining';
        } else {
          displayText = snapshot.data!;
        }

        return SizedBox(
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
                displayText,
                style: const TextStyle(fontSize: 24, fontFamily: 'Unbounded'),
              ),
            ),
          ),
        );
      },
    );
  }
}