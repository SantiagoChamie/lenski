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
  static const Color darkerGrey = Color(0xFF4B4B4D);
  static const Color darkGrey = Color(0xFF99909B);
  static const Color grey = Color(0xFFD9D0DB);
  static const Color lightGrey = Color(0xFFF5F0F6);
  
  // UI state colors
  static const Color success = Color(0xFF4CAF50);  // Green for success states
  static const Color error = Color(0xFFE53935);    // Red for error states
  static const Color warning = Color(0xFFFF9800);  // Orange for warning states

  // Other colors
  static const Color streak = Color(0xFFFF9800);   // Used for streaks
  static const Color gold = Color(0xFFFFD54F); // Gold color for star achievement

  static const Color lightGreen = Color(0xFF0BAE44); // Light green for low difficulty
  static const Color darkRed = Color(0xFF9B1D1D);     // For Extreme difficulty

  // Competences
  static const Color reading = Color(0xFFEDA42E);
  static const Color writing = Color(0xFFEDE72D);
  static const Color speaking = Color(0xFFDE2C50);
  static const Color listening = Color(0xFFD52CDE);

  static const Color black = Colors.black;
  /// White color (use for foreground on dark backgrounds)
  static const Color white = Color(0xFFFFFFFF);

  // Common semi-transparent blacks used for shadows and overlays
  static const Color black54 = Color(0x8A000000);
  static const Color black38 = Color(0x61000000);
  static const Color black12 = Color(0x1F000000);
  static const Color black26 = Color(0x42000000);
  static const Color black45 = Color(0x73000000);

  // Transparent (useful for overlays and transparent backgrounds)
  static const Color transparent = Color(0x00000000);

  // Common greys from Material palette used across the app
  static const Color grey700 = Color(0xFF616161);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey850 = Color(0xFF212121);
}