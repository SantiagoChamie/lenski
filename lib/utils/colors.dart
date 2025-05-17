import 'package:flutter/material.dart';

/// App color palette
/// Contains the main colors used throughout the application
class AppColors {
  // Blues
  static const Color blue = Color(0xFF2C73DE);
  static const Color lightBlue = Color(0xFF71BDE0);
  
  // Yellows
  static const Color lightYellow = Color(0xFFFFD38D);
  static const Color yellow = Color(0xFFEE9A1D);
  
  // Greys
  static const Color grey = Color(0xFFD9D0DB);
  static const Color lightGrey = Color(0xFFF5F0F6);
  
  /// A map of color names to Color objects.
  /// Use this to maintain consistent colors throughout the app.
  static final Map<String, Color> colorMap = {
    'blue': blue,
    'lightBlue': lightBlue,
    'lightYellow': lightYellow,
    'yellow': yellow,
    'grey': grey,
    'lightGrey': lightGrey,
  };
}