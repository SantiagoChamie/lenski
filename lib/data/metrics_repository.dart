import 'package:lenski/models/card_model.dart';
import 'package:lenski/models/book_model.dart';
import 'package:lenski/models/course_metrics_model.dart';
import 'package:lenski/models/course_model.dart';
import 'package:lenski/data/card_repository.dart';
import 'package:lenski/data/book_repository.dart';

class MetricsRepository {
  final CardRepository _cardRepository = CardRepository();
  final BookRepository _bookRepository = BookRepository();

  /// Returns the total number of flashcards created for a specific course.
  Future<int> getCardCount(Course course) async {
    final db = await _cardRepository.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM cards WHERE language = ?',
      [course.code]
    );
    return result.first['count'] as int;
  }

  /// Returns the number of completed books for a specific course.
  /// A book is considered completed when it is either:
  /// 1. In the books database and marked as finished
  /// 2. In the archive database for the given language
  Future<int> getCompletedBooksCount(Course course) async {
    final db = await _bookRepository.database;
    final archiveDb = await _bookRepository.archiveDatabase;

    // Get finished books from active database
    final activeResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM books WHERE language = ? AND finished = 1',
      [course.code]
    );
    final activeCount = activeResult.first['count'] as int;

    // Get books from archive database
    final archivedResult = await archiveDb.rawQuery(
      'SELECT COUNT(*) as count FROM archived_books WHERE language = ?',
      [course.code]
    );
    final archivedCount = archivedResult.first['count'] as int;

    // Return total of finished active books plus archived books
    return activeCount + archivedCount;
  }

  /// Returns a metrics summary for a specific course
  Future<CourseMetrics> getCourseMetrics(Course course) async {
    final cardCount = await getCardCount(course);
    final completedBooks = await getCompletedBooksCount(course);

    return CourseMetrics(
      totalCards: cardCount,
      completedBooks: completedBooks,
    );
  }
}
