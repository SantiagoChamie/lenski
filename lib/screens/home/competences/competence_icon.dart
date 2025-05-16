import 'package:flutter/material.dart';

/// An icon representing a competence
/// Competences include: listening, speaking, reading, writing
class CompetenceIcon extends StatelessWidget {
  final double size;
  final String type;
  final bool gray;

  /// Creates a CompetenceIcon widget.
  /// 
  /// [size] is the size of the icon.
  /// [type] is the type of competence (e.g., listening, speaking, reading, writing).
  const CompetenceIcon({super.key, required this.size, required this.type, this.gray = false});

  @override
  Widget build(BuildContext context) {
    final iconData = _getIconData(type);
    final color = _getColor(gray ? 'null' : type);

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(4),
      child: Icon(iconData, color: Colors.white, size: size * 2 / 3),
    );
  }

  /// Returns the appropriate icon data based on the type of competence.
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

  /// Returns the appropriate color based on the type of competence.
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
        return const Color(0xFF808080);
    }
  }
}