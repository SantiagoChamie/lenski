import 'package:lenski/models/sentence_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../../models/book_model.dart';
import 'archive_repository.dart';
import 'dart:io';

/// A repository class for managing books in the database.
class BookRepository {
  static final BookRepository _instance = BookRepository._internal();
  Database? _database;
  late final ArchiveRepository _archiveRepository;

  /// Factory constructor to return the singleton instance of BookRepository.
  factory BookRepository() {
    return _instance;
  }

  /// Internal constructor for singleton pattern.
  BookRepository._internal() {
    // Initialize archive repository lazily to avoid circular dependency
    Future.delayed(Duration.zero, () {
      _archiveRepository = ArchiveRepository();
    });
  }

  /// Getter for the database. Initializes the database if it is not already initialized.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the database and creates the books table if it does not exist.
  Future<Database> _initDatabase() async {
    // Path for the unified database
    String path = join(await getDatabasesPath(), 'lenski.db');
    
    // Ensure directory exists
    Directory dbDirectory = Directory(dirname(path));
    if (!await dbDirectory.exists()) {
      await dbDirectory.create(recursive: true);
    }
    
    // Open database without depending on callbacks
    Database db = await openDatabase(path, version: 4);
    
    // Always check if books table exists
    final tables = await db.query('sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', 'books']);
        
    if (tables.isEmpty) {
      print('Creating books table in unified database');
      // Create the books table if it doesn't exist
      await db.execute(
        'CREATE TABLE books(id INTEGER PRIMARY KEY, name TEXT, imageUrl TEXT, totalLines INTEGER, currentLine INTEGER, language TEXT, finished INTEGER DEFAULT 0)',
      );
    }
    
    return db;
  }

  /// Inserts a new book into the database.
  Future<void> insertBook(Book book) async {
    final db = await database;
    await db.insert(
      'books',
      book.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Creates a table for a book and inserts its sentences.
  Future<void> createBookDatabase(int bookId, List<String> sentences) async {
    final db = await database;
    
    // First check if the table already exists
    final tables = await db.query('sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', 'b$bookId']);
        
    if (tables.isEmpty) {
      // Create the table if it doesn't exist
      await db.execute(
        'CREATE TABLE b$bookId(id INTEGER PRIMARY KEY, sentence TEXT)',
      );
    }

    // Insert sentences
    await db.transaction((txn) async {
      for (int i = 0; i < sentences.length; i++) {
        await txn.insert(
          'b$bookId',
          {'id': i + 1, 'sentence': sentences[i]},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  /// Retrieves the sentences for a book from its table.
  Future<List<Sentence>> getSentences(int bookId) async {
    final db = await database;
    
    // Check if the table exists
    final tables = await db.query('sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', 'b$bookId']);
        
    if (tables.isEmpty) {
      // No table found
      return [];
    }
    
    // Query the sentences
    final List<Map<String, dynamic>> maps = await db.query('b$bookId');
    return List.generate(maps.length, (i) {
      return Sentence.fromMap(maps[i]);
    });
  }

  /// Retrieves all books for a specific language from the database.
  Future<List<Book>> booksByLanguage(String language) async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('books', where: 'language = ?', whereArgs: [language]);
    return List.generate(maps.length, (i) {
      return Book.fromMap(maps[i]);
    });
  }

  /// Updates an existing book in the database.
  Future<void> updateBook(Book book) async {
    final db = await database;
    await db.update(
      'books',
      book.toMap(),
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  /// Deletes a book and its associated table.
  Future<void> deleteBook(int id) async {
    final db = await database;
    
    // Check if the book exists
    final book = await db.query(
      'books',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (book.isNotEmpty) {
      // Drop the book sentences table if it exists
      try {
        final tables = await db.query('sqlite_master',
            where: 'type = ? AND name = ?',
            whereArgs: ['table', 'b$id']);
            
        if (tables.isNotEmpty) {
          await db.execute('DROP TABLE b$id');
        }
      } catch (e) {
        print('Error dropping book table: $e');
      }
    }

    // Delete the book entry
    await db.delete(
      'books',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Archives a book by delegating to ArchiveRepository.
  /// This method is kept for backward compatibility.
  Future<void> archiveBook(Book book) async {
    await _archiveRepository.archiveBook(book);
  }
}