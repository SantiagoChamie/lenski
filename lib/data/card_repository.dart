import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../../models/card_model.dart';

class CardRepository {
  static final CardRepository _instance = CardRepository._internal();
  Database? _database;

  factory CardRepository() {
    return _instance;
  }

  CardRepository._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'cards.db');
    return openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE cards(id INTEGER PRIMARY KEY, front TEXT, back TEXT, context TEXT, dueDate TEXT, language TEXT)', // Store dueDate as TEXT
        );
      },
      version: 1,
    );
  }

  Future<void> insertCard(Card card) async {
    final db = await database;
    await db.insert(
      'cards',
      card.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Card>> cards(DateTime dueDate, String language) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cards',
      where: 'dueDate = ? AND language = ?',
      whereArgs: [dueDate.toIso8601String(), language], // Convert DateTime to ISO 8601 string
    );
    return List.generate(maps.length, (i) {
      return Card.fromMap(maps[i]);
    });
  }

  Future<void> updateCard(Card card) async {
    final db = await database;
    await db.update(
      'cards',
      card.toMap(),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  Future<void> deleteCard(int? id) async {
    final db = await database;
    await db.delete(
      'cards',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<String?> getCardByInfo(String front, String context) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cards',
      columns: ['back'],
      where: 'front = ? AND context = ?',
      whereArgs: [front, context],
    );

    if (maps.isNotEmpty) {
      return maps.first['back'] as String?;
    } else {
      return null;
    }
  }
}