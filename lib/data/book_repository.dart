import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io';
import '../../models/book_model.dart';

class BookRepository {
  static final BookRepository _instance = BookRepository._internal();
  Database? _database;

  factory BookRepository() {
    return _instance;
  }

  BookRepository._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

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

  Future<void> insertBook(Book book) async {
    final db = await database;
    await db.insert(
      'books',
      book.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

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

  Future<void> updateBook(Book book) async {
    final db = await database;
    await db.update(
      'books',
      book.toMap(),
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  // Delete a book and its associated database
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
}