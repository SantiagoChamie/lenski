import 'package:lenski/models/archived_book_model.dart';
import 'package:lenski/models/sentence_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io';
import '../../models/book_model.dart';

/// A repository class for managing books in the database.
class BookRepository {
  static final BookRepository _instance = BookRepository._internal();
  Database? _database;
  Database? _archiveDatabase;

  /// Factory constructor to return the singleton instance of BookRepository.
  factory BookRepository() {
    return _instance;
  }

  /// Internal constructor for singleton pattern.
  BookRepository._internal();

  /// Getter for the database. Initializes the database if it is not already initialized.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the database and creates the books table if it does not exist.
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'books.db');
    return openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE books(id INTEGER PRIMARY KEY, name TEXT, imageUrl TEXT, totalLines INTEGER, currentLine INTEGER, language TEXT, finished INTEGER DEFAULT 0)',
        );
      },
      version: 2,  // Increment version number
    );
  }

  Future<Database> get archiveDatabase async {
    if (_archiveDatabase != null) return _archiveDatabase!;
    _archiveDatabase = await _initArchiveDatabase();
    return _archiveDatabase!;
  }

  Future<Database> _initArchiveDatabase() async {
    String path = join(await getDatabasesPath(), 'archive.db');
    return openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE archived_books(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, language TEXT, category TEXT, subcategory TEXT, imageUrl TEXT, finishedDate INTEGER)',
        );
      },
      version: 3,  // Increment version number
    );
  }

  /// Inserts a new book into the database.
  /// 
  /// [book] is the book to be inserted.
  Future<void> insertBook(Book book) async {
    final db = await database;
    await db.insert(
      'books',
      book.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Creates a new database for a book and inserts its sentences.
  /// 
  /// [bookId] is the ID of the book.
  /// [sentences] is the list of sentences to be inserted.
  Future<void> createBookDatabase(int bookId, List<String> sentences) async {
    String dbName = '$bookId.db';
    String path = join(await getDatabasesPath(), dbName);
    Database bookDb = await openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE sentences(id INTEGER PRIMARY KEY, sentence TEXT)',
        );
      },
      version: 1,
    );

    for (int i = 0; i < sentences.length; i++) {
      await bookDb.insert(
        'sentences',
        {'id': i + 1, 'sentence': sentences[i]},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  /// Retrieves the sentences for a book from its database.
  /// 
  /// [bookId] is the ID of the book.
  /// Returns a list of sentences.
  Future<List<Sentence>> getSentences(int bookId) async {
    String dbName = '$bookId.db';
    String path = join(await getDatabasesPath(), dbName);
    Database bookDb = await openDatabase(path);
    final List<Map<String, dynamic>> maps = await bookDb.query('sentences');
    return List.generate(maps.length, (i) {
      return Sentence.fromMap(maps[i]);
    });
  }

  /// Retrieves all books for a specific language from the database.
  /// 
  /// [language] is the language code of the books.
  /// Returns a list of books.
  Future<List<Book>> booksByLanguage(String language) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = 
      await db.query(
        'books', 
        where: 'language = ?', 
        whereArgs: [language]);
    return List.generate(maps.length, (i) {
      return Book.fromMap(maps[i]);
    });
  }

  /// Updates an existing book in the database.
  /// 
  /// [book] is the book to be updated.
  Future<void> updateBook(Book book) async {
    final db = await database;
    await db.update(
      'books',
      book.toMap(),
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  /// Deletes a book and its associated database.
  /// 
  /// [id] is the ID of the book to be deleted.
  Future<void> deleteBook(int id) async {
    final db = await database;
    final book = await db.query(
      'books',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (book.isNotEmpty) {
      final bookId = book.first['id'];
      String dbName = '$bookId.db';
      String path = join(await getDatabasesPath(), dbName);

      // Close the book-related database connection if it is open
      Database? bookDb;
      try {
        bookDb = await openDatabase(path);
        await bookDb.close();
      } catch (e) {
        // Handle any errors that occur while closing the database
        print('Error closing book database: $e');
      }

      // Delete the book-related database file
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }

    await db.delete(
      'books',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> archiveBook(Book book) async {
    final archiveDb = await archiveDatabase;

    // Create archived book from the book
    final archivedBook = ArchivedBook.fromBook(book);

    // Insert into archive database without specifying ID
    await archiveDb.insert(
      'archived_books',
      archivedBook.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Use existing deleteBook method to remove the book and its database
    await deleteBook(book.id!);
  }

  Future<List<ArchivedBook>> getArchivedBooks(String language) async {
    final db = await archiveDatabase;
    final List<Map<String, dynamic>> maps = await db.query(
      'archived_books',
      where: 'language = ?',
      whereArgs: [language],
    );
    return List.generate(maps.length, (i) {
      return ArchivedBook.fromMap(maps[i]);
    });
  }

  Future<void> updateArchivedBook(ArchivedBook book) async {
    final db = await archiveDatabase;
    await db.update(
      'archived_books',
      book.toMap(),
      where: 'id = ?',
      whereArgs: [book.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteArchivedBook(int id) async {
    final db = await archiveDatabase;
    await db.delete(
      'archived_books',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}