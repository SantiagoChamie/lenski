import 'package:flutter/material.dart';
import 'package:lenski/utils/proportions.dart';

class TranslationOverlay extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final p = Proportions(context);
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
                '$targetLang.',
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Varela Round',
                ),
              ),
              SizedBox(width: p.standardPadding()),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontFamily: 'Varela Round',
                ),
              ),
            ],
          ),
          SizedBox(height: p.standardPadding()/2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$sourceLang.',
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Varela Round',
                ),
              ),
              SizedBox(width: p.standardPadding()),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontFamily: 'Varela Round',
                ),
              ),
            ],
          ),
          SizedBox(height: p.standardPadding()),
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
                  onPressed: () {
                    // Add your onPressed code here!
                  },
                ),
              ),
              const SizedBox(width: 8.0),
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFD9D0DB),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),

                ),
                child: IconButton(
                  icon: const Icon(Icons.search, color: Colors.black, size: 30.0),
                  onPressed: () {
                    // Add your onPressed code here!
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}