import 'package:flutter/material.dart';
import 'package:lenski/utils/proportions.dart';

class CompetenceIcon extends StatelessWidget {
  final Color color;
  final IconData icon;

  const CompetenceIcon({super.key, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    return Padding(
      padding: EdgeInsets.only(top: p.standardPadding() / 2),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(4),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}