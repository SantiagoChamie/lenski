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
  /// A book is considered completed when currentLine equals totalLines.
  Future<int> getCompletedBooksCount(Course course) async {
    final db = await _bookRepository.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM books WHERE language = ? AND currentLine = totalLines',
      [course.code]
    );
    return result.first['count'] as int;
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
