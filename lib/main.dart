import 'package:flutter/material.dart';
import 'package:lenski/screens/navigation/navigation_handler.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Main function to run the app
void main() async {
  sqfliteFfiInit(); // Initialize FFI
  databaseFactory = databaseFactoryFfi; // Set the database factory to FFI
  runApp(const MyApp()); // Run the Flutter app
}

/// Root widget of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LenSki Beta', // Title of the app
      debugShowCheckedModeBanner: false, // Disable debug banner
      theme: ThemeData(
        primarySwatch: Colors.blue, // Set the primary color theme
      ),
      home: const NavigationHandler(), // Set the home widget
    );
  }
}