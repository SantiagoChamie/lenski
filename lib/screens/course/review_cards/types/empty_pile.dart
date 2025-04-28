import 'package:flutter/material.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/widgets/flag_icon.dart';

class EmptyPile extends StatelessWidget {
  final String language;
  const EmptyPile({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    final boxPadding = p.standardPadding() * 4;
    const iconSize = 80.0;
    
    return Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(boxPadding),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F0F6),
                  borderRadius: BorderRadius.circular(5.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4.0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(p.standardPadding()),
                    child: const Text(
                      'No more cards to review!',
                      style: TextStyle(
                        fontSize: 24.0,
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontFamily: "Varela Round",
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: boxPadding - iconSize / 3,
            left: boxPadding - iconSize / 3,
            child: FlagIcon(
              size: iconSize,
              borderWidth: 5.0,
              borderColor: const Color(0xFFD9D0DB),
              language: language,
            ),
          ),
          Positioned(
            top: boxPadding + 10,
            right: boxPadding + 10,
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.close_rounded),
            ),
          ),
        ],
      );
  }
}