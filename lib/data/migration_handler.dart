import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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
      // 1. Read the exported JSON file
      final file = File(filePath);
      if (!await file.exists()) {
        return MigrationResult(
          success: false,
          message: "Import file not found: $filePath",
        );
      }
      
      // Read and parse the JSON data
      final jsonString = await file.readAsString();
      final Map<String, dynamic> importData = jsonDecode(jsonString);
      
      // 2. Validate the import data format
      if (!_validateExportFormat(importData)) {
        return MigrationResult(
          success: false,
          message: "Invalid or incompatible import file format",
        );
      }
      
      // 3. Create a backup of the current database
      final backupPath = await _backupCurrentDatabase();
      if (backupPath == null) {
        return MigrationResult(
          success: false,
          message: "Failed to create database backup before import",
        );
      }
      
      // 4. Get direct database access for bulk operations
      final db = await openDatabase(await getDatabasePath());
      
      try {
        // Use a transaction for all import operations to ensure atomicity
        await db.transaction((txn) async {
          // Ensure all required tables exist before import
          await _ensureTablesExist(txn, importData);
          
          // 5a. Import courses data
          if (importData["data"]["courses"] != null) {
            // Clear existing courses
            await txn.delete('courses');
            
            // Insert imported courses
            for (final courseData in importData["data"]["courses"]) {
              await txn.insert(
                'courses',
                courseData as Map<String, dynamic>,
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
          }
          
          // 5b. Import books data
          if (importData["data"]["books"] != null) {
            // Clear existing books
            await txn.delete('books');
            
            // Insert imported books
            for (final bookData in importData["data"]["books"]) {
              await txn.insert(
                'books',
                bookData as Map<String, dynamic>,
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
          }
          
          // 5c. Import book sentences
          if (importData["data"]["bookSentences"] != null) {
            final bookSentences = importData["data"]["bookSentences"] as Map<String, dynamic>;
            
            for (final bookId in bookSentences.keys) {
              // Check if the table exists and create if needed
              final tables = await txn.query('sqlite_master',
                  where: 'type = ? AND name = ?',
                  whereArgs: ['table', 'b$bookId']);
                  
              if (tables.isEmpty) {
                await txn.execute(
                  'CREATE TABLE b$bookId(id INTEGER PRIMARY KEY, sentence TEXT)',
                );
              } else {
                // Clear existing sentences for this book
                await txn.delete('b$bookId');
              }
              
              // Insert sentences
              final sentences = bookSentences[bookId] as List<dynamic>;
              for (final sentenceData in sentences) {
                await txn.insert(
                  'b$bookId',
                  sentenceData as Map<String, dynamic>,
                  conflictAlgorithm: ConflictAlgorithm.replace,
                );
              }
            }
          }
          
          // 5d. Import archived books
          if (importData["data"]["archivedBooks"] != null) {
            // Clear existing archived books
            await txn.delete('archived_books');
            
            // Insert imported archived books
            for (final archivedBookData in importData["data"]["archivedBooks"]) {
              await txn.insert(
                'archived_books',
                archivedBookData as Map<String, dynamic>,
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
          }
          
          // 5e. Import cards data
          if (importData["data"]["cards"] != null) {
            // Clear existing cards
            await txn.delete('cards');
            
            // Insert imported cards
            for (final cardData in importData["data"]["cards"]) {
              await txn.insert(
                'cards',
                cardData as Map<String, dynamic>,
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
          }
          
          // 5f. Import sessions data
          if (importData["data"]["sessions"] != null) {
            // Clear existing sessions
            await txn.delete('sessions');
            
            // Insert imported sessions
            for (final sessionData in importData["data"]["sessions"]) {
              await txn.insert(
                'sessions',
                sessionData as Map<String, dynamic>,
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
          }
        });
        
        await db.close();
        
        return MigrationResult(
          success: true,
          message: "Import completed successfully",
        );
      } catch (e) {
        // If any error occurs during import, restore the backup
        await db.close();
        
        // Attempt to restore the database from backup
        await _restoreFromBackup(backupPath);
        
        return MigrationResult(
          success: false,
          message: "Error during import. Database restored from backup. Error: ${e.toString()}",
        );
      }
    } catch (e) {
      return MigrationResult(
        success: false,
        message: "Error during import: ${e.toString()}",
      );
    }
  }

  /// Ensures all required tables exist before attempting to import data
  Future<void> _ensureTablesExist(Transaction txn, Map<String, dynamic> importData) async {
    // Check and create courses table if needed
    await _ensureTableExists(txn, 'courses', '''
      CREATE TABLE courses(
        id INTEGER PRIMARY KEY, 
        name TEXT, 
        level TEXT, 
        code TEXT, 
        fromCode TEXT, 
        listening INTEGER, 
        speaking INTEGER, 
        reading INTEGER, 
        writing INTEGER, 
        color INTEGER, 
        imageUrl TEXT, 
        streak INTEGER DEFAULT 0, 
        lastAccess INTEGER DEFAULT 0, 
        dailyGoal INTEGER DEFAULT 100, 
        totalGoal INTEGER DEFAULT 10000, 
        visible INTEGER DEFAULT 1, 
        goalType TEXT DEFAULT "learn", 
        goalComplete INTEGER DEFAULT 0
      )
    ''');

    // Check and create books table if needed
    await _ensureTableExists(txn, 'books', '''
      CREATE TABLE books(
        id INTEGER PRIMARY KEY, 
        name TEXT, 
        imageUrl TEXT, 
        totalLines INTEGER, 
        currentLine INTEGER, 
        language TEXT, 
        finished INTEGER DEFAULT 0
      )
    ''');

    // Check and create archived_books table if needed
    await _ensureTableExists(txn, 'archived_books', '''
      CREATE TABLE archived_books(
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        name TEXT, 
        language TEXT, 
        category TEXT, 
        subcategory TEXT, 
        imageUrl TEXT, 
        finishedDate INTEGER
      )
    ''');

    // Check and create cards table if needed
    await _ensureTableExists(txn, 'cards', '''
      CREATE TABLE cards(
        id INTEGER PRIMARY KEY, 
        front TEXT, 
        back TEXT, 
        context TEXT, 
        dueDate INTEGER, 
        language TEXT, 
        prevInterval INTEGER, 
        eFactor REAL, 
        repetition INTEGER, 
        type TEXT
      )
    ''');

    // Check and create sessions table if needed
    await _ensureTableExists(txn, 'sessions', '''
      CREATE TABLE sessions(
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        courseCode TEXT NOT NULL, 
        date INTEGER NOT NULL, 
        wordsAdded INTEGER DEFAULT 0, 
        wordsReviewed INTEGER DEFAULT 0, 
        linesRead INTEGER DEFAULT 0, 
        minutesStudied INTEGER DEFAULT 0, 
        cardsDeleted INTEGER DEFAULT 0, 
        streakIncremented INTEGER DEFAULT 0, 
        UNIQUE(courseCode, date)
      )
    ''');

    // Check for book sentence tables that need to be created
    if (importData["data"]["bookSentences"] != null) {
      final bookSentences = importData["data"]["bookSentences"] as Map<String, dynamic>;
      for (final bookId in bookSentences.keys) {
        await _ensureTableExists(txn, 'b$bookId', '''
          CREATE TABLE b$bookId(
            id INTEGER PRIMARY KEY, 
            sentence TEXT
          )
        ''');
      }
    }
  }

  /// Helper method to check if a table exists and create it if it doesn't
  Future<void> _ensureTableExists(Transaction txn, String tableName, String createTableSql) async {
    final tables = await txn.query('sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', tableName]);
        
    if (tables.isEmpty) {
      print('Creating $tableName table for import');
      await txn.execute(createTableSql);
    }
  }

  /// Validates an exported file format to ensure it's compatible with this version.
  bool _validateExportFormat(Map<String, dynamic> data) {
    try {
      // Check for required metadata
      if (!data.containsKey('metadata') || !data.containsKey('data')) {
        print('Missing required top-level keys');
        return false;
      }
      
      // Check metadata format
      final metadata = data['metadata'] as Map<String, dynamic>?;
      if (metadata == null || !metadata.containsKey('version')) {
        print('Invalid or missing metadata');
        return false;
      }
      
      // Check data structure
      final appData = data['data'] as Map<String, dynamic>?;
      if (appData == null) {
        print('Missing data section');
        return false;
      }
      
      // Verify expected data sections
      final expectedSections = ['courses', 'cards', 'books', 'bookSentences', 'archivedBooks', 'sessions'];
      for (final section in expectedSections) {
        if (!appData.containsKey(section)) {
          print('Missing data section: $section');
          return false;
        }
      }
      
      // Validate version compatibility
      final version = metadata['version'];
      if (version != '1.0') {
        print('Incompatible version: $version');
        return false;
      }
      
      return true;
    } catch (e) {
      print('Error validating export format: $e');
      return false;
    }
  }
  
  /// Gets the path to the unified database file.
  Future<String> getDatabasePath() async {
    return join(await getDatabasesPath(), 'lenski.db');
  }

  /// Creates a backup of the current database before import operations.
  Future<String?> _backupCurrentDatabase() async {
    try {
      final dbPath = await getDatabasePath();
      final dbFile = File(dbPath);
      
      // Check if database exists
      if (!await dbFile.exists()) {
        // No database to backup, likely a new installation
        return dbPath + '_empty';
      }
      
      final backupPath = '${dbPath}_backup_${DateTime.now().millisecondsSinceEpoch}';
      
      // Copy the database file to backup location
      await dbFile.copy(backupPath);
      
      print('Database backed up to: $backupPath');
      return backupPath;
    } catch (e) {
      print('Error creating database backup: $e');
      return null;
    }
  }

  /// Restores the database from a backup file.
  Future<bool> _restoreFromBackup(String backupPath) async {
    try {
      final currentDbPath = await getDatabasePath();
      final backupFile = File(backupPath);
      final dbFile = File(currentDbPath);
      
      if (await backupFile.exists()) {
        // Delete the corrupted database
        if (await dbFile.exists()) {
          await dbFile.delete();
        }
        
        // Restore from backup
        await backupFile.copy(currentDbPath);
        print('Database restored from backup: $backupPath');
        return true;
      } else {
        print('Backup file not found: $backupPath');
        return false;
      }
    } catch (e) {
      print('Error restoring database from backup: $e');
      return false;
    }
  }
}