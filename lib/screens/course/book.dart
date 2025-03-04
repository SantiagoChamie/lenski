import 'package:flutter/material.dart';
import 'dart:math';

import 'package:lenski/utils/proportions.dart';

class Book extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final int? totalLines;
  final int? currentLine;
  final VoidCallback? onPressed;

  const Book({
    super.key,
    this.imageUrl,
    this.name,
    this.totalLines,
    this.currentLine,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    final randomColor = Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
    final percentage = (totalLines != null && currentLine != null && totalLines! > 0)
        ? (currentLine! / totalLines! * 100).toInt()
        : 100;

    double fontSize;
    if (percentage < 10) {
      fontSize = 16;
    } else if (percentage < 100) {
      fontSize = 14;
    } else {
      fontSize = 12;
    }

    return Column(
      children: [
        InkWell(
          onTap: onPressed,
          child: Stack(
            children: [
              Container(
                width: 100,
                height: 150,
                decoration: BoxDecoration(
                  color: imageUrl == null ? randomColor : null,
                  image: imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Center(
                        child: Text(
                          '$percentage%',
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Sansation',
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        value: percentage / 100,
                        strokeWidth: 5,
                        backgroundColor: Colors.white,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2C73DE)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 100 + p.standardPadding() * 2,
          child: Text(
            name ?? 'unnamed wa',
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Varela Round',
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}