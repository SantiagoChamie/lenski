import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:lenski/data/book_repository.dart';
import 'package:lenski/models/book_model.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class _TrackedLine {
  String text;
  int unusedCount;

  _TrackedLine(this.text) : unusedCount = 0;
}

class BookCreator {
  final BookRepository _bookRepository = BookRepository();
  bool _isCancelled = false;
  Book? _currentBook;

  final List<_TrackedLine> _trackedHeaders = [];
  final List<_TrackedLine> _trackedFooters = [];
  static const int _headerFooterLines = 3; // Number of lines to check at top/bottom
  static const int _maxUnusedPages = 2;

  // Add this getter
  bool get isCancelled => _isCancelled;

  /// Processes text directly pasted into the app
  void processBook(String text, String code) async {
    // Split initial text by newlines and process each line
    final List<String> processedLines = [];
    final List<String> initialSentences = text.split('\n');

    for (String sentence in initialSentences) {
      if (sentence.trim().isEmpty) {
        processedLines.add('');
        continue;
      }

      // Split long sentences by word count
      List<String> words = sentence.split(' ');
      StringBuffer currentLine = StringBuffer();
      int wordCount = 0;

      for (String word in words) {
        if (wordCount >= 15) {
          processedLines.add(currentLine.toString().trim());
          currentLine.clear();
          wordCount = 0;
        }
        currentLine.write('$word ');
        wordCount++;
      }

      // Add remaining words if any
      if (currentLine.isNotEmpty) {
        processedLines.add(currentLine.toString().trim());
      }
    }

    if (processedLines.isEmpty) return;
    await _createBook(processedLines, code);
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
          content = await _processPdfFile(filePath, code);
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

  Future<List<String>> _processPdfFile(String filePath, String languageCode) async {
    final List<String> sentences = [];
    final File file = File(filePath);
    final PdfDocument document = PdfDocument(inputBytes: await file.readAsBytes());

    try {
      
      for (int pageIndex = 0; pageIndex < document.pages.count; pageIndex++) {
        // Increment unused count for all tracked lines
        for (var header in _trackedHeaders) {
          header.unusedCount++;
        }
        for (var footer in _trackedFooters) {
          footer.unusedCount++;
        }

        // Remove headers/footers that haven't been used for more than 2 pages
        _trackedHeaders.removeWhere((header) => header.unusedCount > _maxUnusedPages);
        _trackedFooters.removeWhere((footer) => footer.unusedCount > _maxUnusedPages);

        if (pageIndex > 0) {
          sentences.add('');
        }

        final PdfTextExtractor extractor = PdfTextExtractor(document);
        
        try {
          if(languageCode != 'EL'){
          // Primary method: Structured text extraction
          final textLines = extractor.extractTextLines(
            startPageIndex: pageIndex,
            endPageIndex: pageIndex,
          );
          
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

          final sortedYPositions = lineGroups.keys.toList()..sort();
          final List<String> pageLines = [];

          for (var y in sortedYPositions) {
            var words = lineGroups[y]!;
            words.sort((a, b) => a.bounds.left.compareTo(b.bounds.left));
            
            final String lineText = words
                .map((word) => word.text)
                .join(' ')
                .trim()
                .replaceAll(RegExp(r'\s+'), ' ');
            
            if (lineText.isNotEmpty) {
              pageLines.add(lineText);
            }
          }

          if (pageLines.isNotEmpty) {
            final currentHeaders = pageLines.take(_headerFooterLines).toList();
            final currentFooters = pageLines.reversed.take(_headerFooterLines).toList();

            final filteredLines = pageLines.where((line) {
              final normalizedLine = _normalizeText(line);
              
              bool isRepeatingHeader = _trackedHeaders.any((header) {
                if (_normalizeText(header.text) == normalizedLine) {
                  header.unusedCount = 0;
                  return true;
                }
                return false;
              });

              bool isRepeatingFooter = _trackedFooters.any((footer) {
                if (_normalizeText(footer.text) == normalizedLine) {
                  footer.unusedCount = 0;
                  return true;
                }
                return false;
              });

              return !isRepeatingHeader && !isRepeatingFooter;
            }).toList();

            // Add new potential headers/footers
            for (var header in currentHeaders) {
              if (!_trackedHeaders.any((h) => _normalizeText(h.text) == _normalizeText(header))) {
                _trackedHeaders.add(_TrackedLine(header));
              }
            }
            
            for (var footer in currentFooters) {
              if (!_trackedFooters.any((f) => _normalizeText(f.text) == _normalizeText(footer))) {
                _trackedFooters.add(_TrackedLine(footer));
              }
            }

            sentences.addAll(filteredLines);
            continue;
          }}

          // Fallback: Raw text extraction
          final String pageText = extractor.extractText(startPageIndex: pageIndex);
          List<String> rawLines = [];
          
          // Split text into lines and handle line length
          for (String line in pageText.split('\n')) {
            line = line.trim();
            if (line.isEmpty) continue;
            
            // Split long lines
            while (line.length > 100) {
              int splitIndex = line.lastIndexOf(' ', 100);
              if (splitIndex == -1) splitIndex = 100;
              
              rawLines.add(line.substring(0, splitIndex).trim());
              line = line.substring(splitIndex).trim();
            }
            if (line.isNotEmpty) {
              rawLines.add(line);
            }
          }
          
          if (rawLines.isNotEmpty) {

            final filteredLines = rawLines.where((line) {
              final normalizedLine = _normalizeText(line);
              
              bool isRepeatingHeader = _trackedHeaders.any((header) {
                if (_normalizeText(header.text) == normalizedLine) {
                  header.unusedCount = 0;
                  return true;
                }
                return false;
              });

              bool isRepeatingFooter = _trackedFooters.any((footer) {
                if (_normalizeText(footer.text) == normalizedLine) {
                  footer.unusedCount = 0;
                  return true;
                }
                return false;
              });

              return !isRepeatingHeader && !isRepeatingFooter;
            }).toList();

            sentences.addAll(filteredLines);
          }
        } catch (e) {
          continue;
        }
      }
    } finally {
      document.dispose();
    }

    return sentences;
  }

  // Add this helper method to normalize text for comparison
  String _normalizeText(String text) {
    // Remove page numbers and normalize whitespace
    return text
        .replaceAll(RegExp(r'\b\d+\b'), '') // Remove standalone numbers (page numbers)
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .toLowerCase();
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