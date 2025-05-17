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
  static const Color darkGrey = Color(0xFF99909B);
  static const Color grey = Color(0xFFD9D0DB);
  static const Color lightGrey = Color(0xFFF5F0F6);
  
  // UI state colors
  static const Color success = Color(0xFF4CAF50);  // Green for success states
  static const Color error = Color(0xFFE53935);    // Red for error states
  static const Color warning = Color(0xFFFF9800);  // Orange for warning states

  // Competences
  static const Color reading = Color(0xFFEDA42E);
  static const Color writing = Color(0xFFEDE72D);
  static const Color speaking = Color(0xFFDE2C50);
  static const Color listening = Color(0xFFD52CDE);

  /// A map of color names to Color objects.
  /// Use this to maintain consistent colors throughout the app.
  static final Map<String, Color> colorMap = {
    'blue': blue,
    'lightBlue': lightBlue,
    'lightYellow': lightYellow,
    'yellow': yellow,
    'grey': grey,
    'lightGrey': lightGrey,
    'darkGrey': darkGrey,
    'reading': reading,
    'writing': writing,
    'speaking': speaking,
    'listening': listening,
    'success': success,
    'error': error,
    'warning': warning,
  };
}