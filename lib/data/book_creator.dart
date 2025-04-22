import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:lenski/data/book_repository.dart';
import 'package:lenski/models/book_model.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:math' as math;

class BookCreator {
  final BookRepository _bookRepository = BookRepository();
  bool _isCancelled = false;
  Book? _currentBook;

  // Add this getter
  bool get isCancelled => _isCancelled;

  /// Processes text directly pasted into the app
  void processBook(String text, String code) async {
    final sentences = text.split('\n').toList();
    if (sentences.isEmpty) return;
    await _createBook(sentences, code);
  }

  /// Processes a file and creates a book based on its contents
  Future<void> processFile(String filePath, String code) async {

    if (filePath.isEmpty) return;

    final extension = path.extension(filePath).toLowerCase();
    List<String> content = [];
    try {
      switch (extension) {
        case '.txt':
          content = await _processTxtFile(filePath);
          break;
        case '.srt':
          content = await _processSrtFile(filePath);
          break;
        case '.pdf':
          content = await _processPdfFile(filePath);
          break;
        default:
          throw Exception('Unsupported file format');
      }

      if (content.isNotEmpty) {
        await _createBook(content, code);
      }
    } catch (e) {
      // Handle errors appropriately in your UI
      print('Error processing file: $e');
    }
  }

  Future<List<String>> _processTxtFile(String filePath) async {
    final file = File(filePath);
    final contents = await file.readAsLines();
    return contents.where((line) => line.trim().isNotEmpty).toList();
  }

  Future<List<String>> _processSrtFile(String filePath) async {
    final file = File(filePath);
    final lines = await file.readAsLines();

    return lines.where((line) {
      final trimmed = line.trim();
      // Skip empty lines, lines that are just numbers, and timestamp lines
      if (trimmed.isEmpty) return false;
      if (RegExp(r'^\d+$').hasMatch(trimmed)) return false;
      if (RegExp(r'^\d{2}:\d{2}:\d{2},\d{3}').hasMatch(trimmed)) return false;
      return true;
    }).map((line) => 
      // Remove HTML-style tags if present and normalize spaces
      line.replaceAll(RegExp(r'<[^>]*>'), '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim()
    ).toList();
  }

  Future<List<String>> _processPdfFile(String filePath) async {
    final List<String> sentences = [];
    final File file = File(filePath);
    final PdfDocument document = PdfDocument(inputBytes: await file.readAsBytes());

    try {
      for (int pageIndex = 0; pageIndex < document.pages.count; pageIndex++) {
        if (pageIndex > 0) {
          sentences.add('');
        }

        final PdfTextExtractor extractor = PdfTextExtractor(document);
        List<TextLine> textLines;
        
        try {
          // First get the raw text
          final String pageText = extractor.extractText(startPageIndex: pageIndex);
          
          try {
            textLines = extractor.extractTextLines(
              startPageIndex: pageIndex,
              endPageIndex: pageIndex,
            );
            
            // Group text elements by their vertical position
            final Map<double, List<TextWord>> lineGroups = {};
            const double yThreshold = 2.0;

            for (var line in textLines) {
              for (var word in line.wordCollection) {
                final double matchingY = lineGroups.keys.firstWhere(
                  (y) => (y - word.bounds.top).abs() <= yThreshold,
                  orElse: () => word.bounds.top,
                );

                lineGroups.putIfAbsent(matchingY, () => []).add(word);
              }
            }

            // Process each line group
            final sortedYPositions = lineGroups.keys.toList()..sort();
            for (var y in sortedYPositions) {
              var words = lineGroups[y]!;
              words.sort((a, b) => a.bounds.left.compareTo(b.bounds.left));
              
              final String lineText = words
                  .map((word) => word.text)
                  .join(' ')
                  .trim()
                  .replaceAll(RegExp(r'\s+'), ' ');
              
              if (lineText.isNotEmpty) {
                sentences.add(lineText);
              }
            }
          } catch (e) {
            // Fallback: Process the raw text instead
            final List<String> rawLines = pageText
                .split('\n')
                .where((line) => line.trim().isNotEmpty)
                .toList();
            
            for (var line in rawLines) {
              sentences.add(line.trim());
            }
            continue;
          }
          
        } catch (e) {
          print('Error extracting text from page $pageIndex: $e');
          continue; // Skip problematic pages
        }
      }
    } finally {
      document.dispose();
    }

    return sentences;
  }

  void cancelProcessing() {
    _isCancelled = true;
    if (_currentBook != null) {
      _bookRepository.deleteBook(_currentBook!.id!);
      _currentBook = null;
    }
  }

  Future<void> _createBook(List<String> content, String code) async {
    if (content.isEmpty) return;
    _isCancelled = false;

    final bookTitle = content.first;
    final book = Book(
      id: null,
      name: bookTitle,
      imageUrl: null,
      totalLines: content.length,
      currentLine: 1,
      language: code,
    );

    await _bookRepository.insertBook(book);
    if (_isCancelled) return;

    final insertedBook = await _bookRepository.booksByLanguage(code)
        .then((books) => books.last);
    _currentBook = insertedBook;
    
    if (_isCancelled) {
      await _bookRepository.deleteBook(insertedBook.id!);
      _currentBook = null;
      return;
    }

    await _bookRepository.createBookDatabase(insertedBook.id!, content);
    _currentBook = null;
  }
}