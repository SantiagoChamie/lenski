import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'book_repository.dart';
import 'card_repository.dart';
import 'course_repository.dart';
import 'session_repository.dart';
import 'archive_repository.dart';

/// Result of a migration operation containing status and optional error message
class MigrationResult {
  final bool success;
  final String? message;
  final String? filePath;
  
  MigrationResult({required this.success, this.message, this.filePath});
}

/// Handler for exporting and importing app data between devices or app versions.
/// 
/// This class provides functionality to:
/// - Export all app data to a file for backup or transfer
/// - Import app data from a previously exported file
class MigrationHandler {
  final CourseRepository _courseRepository = CourseRepository();
  final CardRepository _cardRepository = CardRepository();
  final BookRepository _bookRepository = BookRepository();
  final SessionRepository _sessionRepository = SessionRepository();
  final ArchiveRepository _archiveRepository = ArchiveRepository();

  /// Exports all app data to a JSON file that can be imported in another device.
  /// 
  /// Returns a [MigrationResult] indicating success or failure and the export file path.
  Future<MigrationResult> exportData() async {
    try {
      // Get direct database access for bulk operations
      final db = await openDatabase(await getDatabasePath());
      
      // 1. Create data structure with metadata
      final Map<String, dynamic> exportData = {
        "metadata": {
          "version": "1.0",
          "exportDate": DateTime.now().toIso8601String(),
          "appVersion": "1.0.0", // You might want to get this dynamically
        },
        "data": {
          "courses": [],
          "cards": [],
          "books": [],
          "bookSentences": {},
          "archivedBooks": [],
          "sessions": []
        }
      };

      // 2. Export courses data
      final coursesList = await db.query('courses');
      exportData["data"]["courses"] = coursesList;

      // 3. Export cards data
      final cardsList = await db.query('cards');
      exportData["data"]["cards"] = cardsList;

      // 4. Export books data
      final booksList = await db.query('books');
      exportData["data"]["books"] = booksList;
      
      // 5. Export book sentences (query each book's sentences table)
      for (final book in booksList) {
        final int bookId = book['id'] as int;
        // Check if the table exists
        final tables = await db.query('sqlite_master',
            where: 'type = ? AND name = ?',
            whereArgs: ['table', 'b$bookId']);
            
        if (tables.isNotEmpty) {
          final sentences = await db.query('b$bookId');
          exportData["data"]["bookSentences"]["$bookId"] = sentences;
        }
      }

      // 6. Export archived books
      final archivedBooksList = await db.query('archived_books');
      exportData["data"]["archivedBooks"] = archivedBooksList;

      // 7. Export sessions
      final sessionsList = await db.query('sessions');
      exportData["data"]["sessions"] = sessionsList;

      // 9. Create a JSON string from the data
      final jsonString = jsonEncode(exportData);

      // 10. Get the documents directory and create a file
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().day.toString() +
          DateTime.now().month.toString() +
          DateTime.now().year.toString();
      final exportFilePath = join(directory.path, 'lenski_export_$timestamp.json');
      
      // 11. Write the JSON to the file
      final file = File(exportFilePath);
      await file.writeAsString(jsonString);

      // 12. Return success result with the file path
      return MigrationResult(
        success: true,
        message: "Data exported successfully",
        filePath: exportFilePath,
      );
    } catch (e) {
      return MigrationResult(
        success: false,
        message: "Error during export: ${e.toString()}",
      );
    }
  }

  /// Imports app data from a previously exported file.
  /// 
  /// [filePath] is the path to the exported JSON file.
  /// 
  /// Returns a [MigrationResult] indicating success or failure.
  Future<MigrationResult> importData(String filePath) async {
    try {
      // TODO: Implement the import logic
      // 1. Read and validate the exported JSON file
      // 2. Create tables if they don't exist
      // 3. Import data for each table in the correct order (respecting foreign keys)
      //    - Courses
      //    - Books and book sentences
      //    - Archived books
      //    - Cards
      //    - Sessions
      // 4. Handle conflicts with existing data
      
      return MigrationResult(
        success: false,
        message: "Import functionality not implemented yet",
      );
    } catch (e) {
      return MigrationResult(
        success: false,
        message: "Error during import: ${e.toString()}",
      );
    }
  }

  /// Validates an exported file format to ensure it's compatible with this version.
  /// 
  /// [data] is the decoded JSON object from the exported file.
  /// 
  /// Returns true if the format is valid and compatible.
  bool _validateExportFormat(Map<String, dynamic> data) {
    // TODO: Implement validation logic
    // - Check for required fields
    // - Verify data format version
    // - Validate structure of each table's data
    
    return false;
  }
  
  /// Gets the path to the unified database file.
  Future<String> getDatabasePath() async {
    return join(await getDatabasesPath(), 'lenski.db');
  }

  /// Creates a backup of the current database before import operations.
  Future<String?> _backupCurrentDatabase() async {
    try {
      final dbPath = await getDatabasePath();
      final backupPath = '${dbPath}_backup_${DateTime.now().millisecondsSinceEpoch}';
      
      // TODO: Implement backup logic
      // - Copy the database file to the backup path
      
      return backupPath;
    } catch (e) {
      print('Error creating database backup: $e');
      return null;
    }
  }
}