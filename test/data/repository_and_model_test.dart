import 'package:test/test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:lenski/data/database_helper.dart';
import 'package:lenski/data/card_repository.dart';
import 'package:lenski/data/book_repository.dart';
import 'package:lenski/data/course_repository.dart';
import 'package:lenski/data/archive_repository.dart';

import 'package:lenski/models/book_model.dart';
import 'package:lenski/models/card_model.dart';
import 'package:lenski/models/archived_book_model.dart';

void main() {
  setUpAll(() {
    // Initialize ffi for sqflite on desktop tests
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Model parsing resilience', () {
    test('Book.fromMap tolerates missing fields', () {
      final map = {'name': 'Sample Book'};
      final book = Book.fromMap(map);
      expect(book.name, equals('Sample Book'));
      expect(book.totalLines, equals(0));
      expect(book.currentLine, equals(1));
      expect(book.language, equals(''));
    });

    test('Card.fromMap tolerates missing fields', () {
      final map = {'front': 'Q', 'back': 'A'};
      final card = Card.fromMap(map);
      expect(card.front, equals('Q'));
      expect(card.back, equals('A'));
      expect(card.language, isNotNull);
      expect(card.type, isNotEmpty);
    });

    test('ArchivedBook.fromMap tolerates missing fields', () {
      final map = {'name': 'Archived'};
      final archived = ArchivedBook.fromMap(map);
      expect(archived.name, equals('Archived'));
      expect(archived.category, isNotNull);
    });
  });

  group('Repository integration (smoke)', () {
    final dbHelper = DatabaseHelper();

    test('CardRepository insert and count', () async {
      final cardRepo = CardRepository();
      final db = await dbHelper.database;

      // clean cards for test language
      await db.delete('cards', where: 'language = ?', whereArgs: ['TT']);

      final card = Card(
        front: 'front',
        back: 'back',
        context: '',
        dueDate: DateTime.now(),
        language: 'TT',
        type: 'test',
      );

      await cardRepo.insertCard(card);
      final count = await cardRepo.getCardCount('TT');
      expect(count, greaterThanOrEqualTo(1));

      // cleanup
      await db.delete('cards', where: 'language = ?', whereArgs: ['TT']);
    });

    test('BookRepository create book and sentences', () async {
      final bookRepo = BookRepository();
      final db = await dbHelper.database;

      // clean books for language
      await db.delete('books', where: 'language = ?', whereArgs: ['ZZ']);

      final book = Book(
        id: null,
        name: 'Test Book',
        imageUrl: null,
        totalLines: 0,
        currentLine: 1,
        language: 'ZZ',
      );

      await bookRepo.insertBook(book);

      final books = await bookRepo.booksByLanguage('ZZ');
      expect(books, isNotEmpty);

      final inserted = books.last;
      // create sentences table and insert
      await bookRepo.createBookDatabase(inserted.id!, ['one', 'two', 'three']);
      final sentences = await bookRepo.getSentences(inserted.id!);
      expect(sentences.length, equals(3));

      // cleanup: drop book sentences table and delete book
      try {
        await db.execute('DROP TABLE IF EXISTS b${inserted.id}');
      } catch (_) {}
      await db.delete('books', where: 'id = ?', whereArgs: [inserted.id]);
    });

    test('ArchiveRepository archive and retrieve', () async {
      final bookRepo = BookRepository();
      final archiveRepo = ArchiveRepository();
      final db = await dbHelper.database;

      // create a temp book
      final book = Book(
        id: null,
        name: 'To Archive',
        imageUrl: null,
        totalLines: 1,
        currentLine: 1,
        language: 'AA',
      );

      await bookRepo.insertBook(book);
      final books = await bookRepo.booksByLanguage('AA');
      final inserted = books.last;

      // archive it
      await archiveRepo.archiveBook(inserted);

      final archived = await archiveRepo.getArchivedBooks('AA');
      expect(archived.any((a) => a.name == 'To Archive'), isTrue);

      // cleanup
      await db.delete('archived_books', where: 'language = ?', whereArgs: ['AA']);
    });
  });
}
