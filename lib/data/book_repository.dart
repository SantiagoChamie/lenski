import 'package:lenski/models/sentence_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io';
import '../../models/book_model.dart';

/// A repository class for managing books in the database.
class BookRepository {
  static final BookRepository _instance = BookRepository._internal();
  Database? _database;

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
          'CREATE TABLE books(id INTEGER PRIMARY KEY, name TEXT, imageUrl TEXT, totalLines INTEGER, currentLine INTEGER, language TEXT)',
        );
      },
      version: 1,
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

  /// Deletes a sentence from a book and updates the total lines count
  Future<void> deleteSentence(int bookId, int sentenceId) async {
    String dbName = '$bookId.db';
    String path = join(await getDatabasesPath(), dbName);
    Database bookDb = await openDatabase(path);

    await bookDb.delete(
      'sentences',
      where: 'id = ?',
      whereArgs: [sentenceId],
    );

    // Update the book's total lines count
    final db = await database;
    final book = (await db.query(
      'books',
      where: 'id = ?',
      whereArgs: [bookId],
    )).first;

    final updatedBook = Book.fromMap(book);
    updatedBook.totalLines--;
    await updateBook(updatedBook);
  }

  /// Restores a deleted sentence
  Future<void> restoreSentence(int bookId, Sentence sentence) async {
    String dbName = '$bookId.db';
    String path = join(await getDatabasesPath(), dbName);
    Database bookDb = await openDatabase(path);

    await bookDb.insert(
      'sentences',
      sentence.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Update the book's total lines count
    final db = await database;
    final book = (await db.query(
      'books',
      where: 'id = ?',
      whereArgs: [bookId],
    )).first;

    final updatedBook = Book.fromMap(book);
    updatedBook.totalLines++;
    await updateBook(updatedBook);
  }
}