import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
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

  Future<void> deleteBook(int id) async {
    final db = await database;
    await db.delete(
      'books',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}