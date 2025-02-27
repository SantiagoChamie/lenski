import 'package:flutter/material.dart';
import 'package:lenski/utils/proportions.dart';

class CompetenceIcon extends StatelessWidget {
  final double size;
  final String type;

  const CompetenceIcon({super.key, required this.size, required this.type});

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    final iconData = _getIconData(type);
    final color = _getColor(type);

    return Padding(
      padding: EdgeInsets.only(top: p.standardPadding() / 2),
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(4),
        child: Icon(iconData, color: Colors.white, size: size*2/3,),
      ),
    );
  }

  IconData _getIconData(String type) {
    switch (type) {
      case 'listening':
        return Icons.hearing;
      case 'speaking':
        return Icons.mic;
      case 'reading':
        return Icons.menu_book_sharp;
      case 'writing':
        return Icons.edit_outlined;
      default:
        return Icons.help_outline;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'listening':
        return const Color(0xFFD52CDE);
      case 'speaking':
        return const Color(0xFFDE2C50);
      case 'reading':
        return const Color(0xFFEDA42E);
      case 'writing':
        return const Color(0xFFEDE72D);
      default:
        return Colors.grey;
    }
  }
}