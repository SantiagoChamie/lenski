import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:lenski/data/book_repository.dart';
import 'package:lenski/models/book_model.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class BookCreator {
  final BookRepository _bookRepository = BookRepository();

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
    final contents = await file.readAsLines();
    final List<String> sentences = [];
    
    for (int i = 0; i < contents.length; i++) {
      final line = contents[i].trim();
      // Skip timestamp lines and subtitle numbers
      if (line.contains('-->') || RegExp(r'^\d+$').hasMatch(line)) {
        continue;
      }
      if (line.isNotEmpty) {
        sentences.add(line);
      }
    }
    return sentences;
  }

  Future<List<String>> _processPdfFile(String filePath) async {
    final List<String> sentences = [];
    final File file = File(filePath);
    final PdfDocument document = PdfDocument(inputBytes: await file.readAsBytes());

    try {
      for (int pageIndex = 0; pageIndex < document.pages.count; pageIndex++) {
        // Add an empty line between pages (except for the first page)
        if (pageIndex > 0) {
          sentences.add('');
        }

        final PdfTextExtractor extractor = PdfTextExtractor(document);
        final List<TextLine> textLines = extractor.extractTextLines(startPageIndex: pageIndex);

        // Group text elements by their vertical position (y-coordinate)
        final Map<double, List<TextWord>> lineGroups = {};
        const double yThreshold = 2.0; // Tolerance for considering words on the same line

        for (var line in textLines) {
          for (var word in line.wordCollection) {
            // Find the closest existing y-coordinate within the threshold
            final double matchingY = lineGroups.keys.firstWhere(
              (y) => (y - word.bounds.top).abs() <= yThreshold,
              orElse: () => word.bounds.top,
            );

            if (!lineGroups.containsKey(matchingY)) {
              lineGroups[matchingY] = [];
            }
            lineGroups[matchingY]!.add(word);
          }
        }

        // Sort words horizontally within each line and combine them
        for (var words in lineGroups.values) {
          words.sort((a, b) => a.bounds.left.compareTo(b.bounds.left));
          // Join words and normalize spaces
          final String lineText = words
              .map((word) => word.text)
              .join(' ')
              .trim()
              .replaceAll(RegExp(r'\s+'), ' '); // Replace multiple spaces with single space
          
          if (lineText.isNotEmpty) {
            sentences.add(lineText);
          }
        }
      }
    } finally {
      document.dispose();
    }

    return sentences;
  }

  Future<void> _createBook(List<String> content, String code) async {
    if (content.isEmpty) return;

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
    final insertedBook = await _bookRepository.booksByLanguage(code)
        .then((books) => books.last);
    await _bookRepository.createBookDatabase(insertedBook.id!, content);
  }
}