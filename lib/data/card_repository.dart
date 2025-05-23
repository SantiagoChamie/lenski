import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import '../../models/card_model.dart';

/// A repository class for managing flashcards in the database.
class CardRepository {
  final int startingInterval = 6; // New parameter
  
  static final CardRepository _instance = CardRepository._internal();
  Database? _database;

  /// Factory constructor to return the singleton instance of CardRepository.
  factory CardRepository() {
    return _instance;
  }
  /// Internal constructor for singleton pattern.
  CardRepository._internal();

  /// Converts a DateTime object to an integer representing the number of days since Unix epoch.
  static int _dateTimeToInt(DateTime date) {
    return _startOfDay(date).toUtc().difference(DateTime.utc(1970, 1, 1)).inDays;
  }

  /// Returns the start of the day for a given DateTime object.
  static DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Getter for the database. Initializes the database if it is not already initialized.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the database and creates the cards table if it does not exist.
  Future<Database> _initDatabase() async {
    // Path for the unified database
    String path = join(await getDatabasesPath(), 'lenski.db');
    
    // Ensure directory exists
    Directory dbDirectory = Directory(dirname(path));
    if (!await dbDirectory.exists()) {
      await dbDirectory.create(recursive: true);
    }
    
    // Open the database without depending on callbacks
    Database db = await openDatabase(path, version: 5);
    
    // Always explicitly check if cards table exists
    final tables = await db.query('sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', 'cards']);
        
    if (tables.isEmpty) {
      // Create the cards table if it doesn't exist
      await db.execute(
        'CREATE TABLE cards('
        'id INTEGER PRIMARY KEY, '
        'front TEXT, '
        'back TEXT, '
        'context TEXT, '
        'dueDate INTEGER, '
        'language TEXT, '
        'prevInterval INTEGER, '
        'eFactor REAL, '
        'repetition INTEGER, '
        'type TEXT'
        ')',
      );
    }
    
    return db;
  }

  /// Inserts a new card into the database.
  /// 
  /// [card] is the card to be inserted.
  Future<void> insertCard(Card card) async {
    final db = await database;
    await db.insert(
      'cards',
      card.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves all cards that are due for review from the database.
  /// 
  /// [dueDate] is the date by which the cards are due.
  /// [language] is the language code of the cards.
  /// Returns a list of cards.
  Future<List<Card>> cards(DateTime dueDate, String language) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cards',
      where: 'dueDate <= ? AND language = ?', // Use <= operator to include cards with dueDate less than or equal to the input date
      whereArgs: [_dateTimeToInt(dueDate), language], // Convert DateTime to integer
    );
    return List.generate(maps.length, (i) {
      return Card.fromMap(maps[i]);
    });
  }

  /// Counts the total number of cards for a specific language.
  /// 
  /// [language] is the language code of the cards.
  /// Returns the count of cards.
  Future<int> getCardCount(String language) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM cards WHERE language = ?',
      [language]
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Updates an existing card in the database.
  /// 
  /// [card] is the card to be updated.
  Future<void> updateCard(Card card) async {
    final db = await database;
    await db.update(
      'cards',
      card.toMap(),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  /// Updates the easiness factor, repetition count, and interval of a card based on the quality of the review.
  /// 
  /// [card] is the card to be updated.
  /// [quality] is the quality of the review.
  /// Returns the new interval in days.
  Future<int> updateCardEFactor(Card card, int quality) async {
    int newRepetition;
    int newInterval;
    double newEFactor;

    if (quality >= 3) {
      if (card.repetition == 0) {
        newInterval = 1;
      } else if (card.repetition == 1) {
        newInterval = startingInterval;
      } else {
        newInterval = (card.prevInterval * card.eFactor).round();
      }
      newRepetition = card.repetition + 1;
      newEFactor = card.eFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
      if (newEFactor < 1.3) newEFactor = 1.3;
    } else {
      newRepetition = 0;
      newInterval = 0;
      newEFactor = card.eFactor;
    }

    final newDueDate = _startOfDay(DateTime.now().add(Duration(days: newInterval)));
    final updatedCard = Card(
      id: card.id,
      front: card.front,
      back: card.back,
      type: card.type,
      context: card.context,
      dueDate: newDueDate,
      language: card.language,
      prevInterval: newInterval,
      eFactor: newEFactor,
      repetition: newRepetition,
    );
    await updateCard(updatedCard);
    return newInterval;
  }

  /// Deletes a card from the database.
  /// 
  /// [id] is the unique identifier of the card to be deleted.
  Future<void> deleteCard(int? id) async {
    final db = await database;
    await db.delete(
      'cards',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Retrieves the back text of a card based on the front text and context.
  /// 
  /// [front] is the front text of the card.
  /// [context] is the context in which the card is used.
  /// Returns the back text of the card if found, otherwise returns null.
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