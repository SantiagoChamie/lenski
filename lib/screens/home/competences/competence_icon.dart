import 'package:flutter/material.dart';
import 'package:lenski/utils/colors.dart';

/// A widget that displays an icon representing a language learning competence.
///
/// CompetenceIcon visually represents one of the four core language learning competences:
/// - Listening (headphones icon with purple background)
/// - Speaking (microphone icon with red background)
/// - Reading (book icon with orange background)
/// - Writing (pen icon with yellow background)
///
/// The icon can also be displayed in a gray state to indicate an inactive or disabled competence.
/// Each competence has a distinctive color and icon for quick visual identification.
class CompetenceIcon extends StatelessWidget {
  /// The size of the icon container in logical pixels
  final double size;
  
  /// The type of competence (must be one of: 'listening', 'speaking', 'reading', 'writing')
  final String type;
  
  /// Whether to display the icon in grayscale (inactive) mode
  final bool gray;

  /// Creates a CompetenceIcon widget.
  /// 
  /// [size] determines the width and height of the icon container.
  /// [type] specifies which competence icon to display ('listening', 'speaking', 'reading', or 'writing').
  /// [gray] when true, displays the icon in grayscale to indicate an inactive state.
  const CompetenceIcon({
    super.key, 
    required this.size, 
    required this.type, 
    this.gray = false
  });

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
  ///
  /// @param type The competence type string
  /// @return The IconData to display for the competence
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
  ///
  /// @param type The competence type string
  /// @return The color to use for the competence background
  Color _getColor(String type) {
    switch (type) {
      case 'listening':
        return AppColors.listening;
      case 'speaking':
        return AppColors.speaking;
      case 'reading':
        return AppColors.reading;
      case 'writing':
        return AppColors.writing;
      default:
        return const Color(0xFF808080);
    }
  }
}