import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/archived_book_model.dart';
import '../models/book_model.dart';
import 'book_repository.dart';
import 'dart:io';

/// A repository class for managing archived books in the database.
class ArchiveRepository {
  static final ArchiveRepository _instance = ArchiveRepository._internal();
  Database? _database;
  final BookRepository _bookRepository = BookRepository();

  /// Factory constructor to return the singleton instance of ArchiveRepository.
  factory ArchiveRepository() {
    return _instance;
  }

  /// Internal constructor for singleton pattern.
  ArchiveRepository._internal();

  /// Getter for the database. Initializes the database if it is not already initialized.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the database and creates the archived_books table if it does not exist.
  Future<Database> _initDatabase() async {
    // Path for the unified database
    String path = join(await getDatabasesPath(), 'lenski.db');
    
    // Ensure directory exists
    Directory dbDirectory = Directory(dirname(path));
    if (!await dbDirectory.exists()) {
      await dbDirectory.create(recursive: true);
    }
    
    // Open database without depending on callbacks
    Database db = await openDatabase(path, version: 5);
    
    // Always check if archived_books table exists
    final tables = await db.query('sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', 'archived_books']);
        
    if (tables.isEmpty) {
      // Create the archived_books table if it doesn't exist
      await db.execute(
        'CREATE TABLE archived_books(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, language TEXT, category TEXT, subcategory TEXT, imageUrl TEXT, finishedDate INTEGER)',
      );
    }
    
    return db;
  }

  /// Archives a book by adding it to archived_books table and removing from the books table.
  Future<void> archiveBook(Book book) async {
    final db = await database;

    // Create archived book from the book
    final archivedBook = ArchivedBook.fromBook(book);

    // Insert into archive database without specifying ID
    await db.insert(
      'archived_books',
      archivedBook.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Use BookRepository to delete the original book
    await _bookRepository.deleteBook(book.id!);
  }

  /// Retrieves all archived books for a specific language.
  Future<List<ArchivedBook>> getArchivedBooks(String language) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'archived_books',
      where: 'language = ?',
      whereArgs: [language],
    );
    return List.generate(maps.length, (i) {
      return ArchivedBook.fromMap(maps[i]);
    });
  }

  /// Updates an existing archived book in the database.
  Future<void> updateArchivedBook(ArchivedBook book) async {
    final db = await database;
    await db.update(
      'archived_books',
      book.toMap(),
      where: 'id = ?',
      whereArgs: [book.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Deletes an archived book from the database.
  Future<void> deleteArchivedBook(int id) async {
    final db = await database;
    await db.delete(
      'archived_books',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}