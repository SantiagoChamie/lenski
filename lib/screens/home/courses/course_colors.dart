import 'package:flutter/material.dart';

/// Predefined colors that can be used for course buttons.
class CourseColors {
  /// List of available colors for courses
  static const List<Color> colors = [
    Color.fromARGB(255, 121, 184, 236),  // Blue
    Color.fromARGB(255, 132, 185, 134), // Green
    Color.fromARGB(255, 240, 161, 156), // Red
    Color.fromARGB(255, 171, 120, 180), // Purple
    Color.fromARGB(255, 247, 203, 136), // Light Red/Orange
  ];

  /// Gets a random color from the available colors
  static Color getRandomColor() {
    return colors[DateTime.now().millisecondsSinceEpoch % colors.length];
  }
}