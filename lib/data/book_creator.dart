import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:lenski/data/book_repository.dart';
import 'package:lenski/models/book_model.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:lenski/services/translation_service.dart'; // Add this import

class _TrackedLine {
  String text;
  int unusedCount;

  _TrackedLine(this.text) : unusedCount = 0;
}

class BookCreator {
  final BookRepository _bookRepository = BookRepository();
  bool _isCancelled = false;
  Book? _currentBook;

  // Add these cached content variables
  List<String>? _lastProcessedContent;
  String? _lastLanguageCode;

  final List<_TrackedLine> _trackedHeaders = [];
  final List<_TrackedLine> _trackedFooters = [];
  static const int _headerFooterLines = 3; // Number of lines to check at top/bottom
  static const int _maxUnusedPages = 2;

  bool get isCancelled => _isCancelled;

  /// Processes text directly pasted into the app
  /// Returns true if book was created successfully, false if language doesn't match
  Future<bool> processBook(String text, String code, {bool shuffleSentences = false}) async {
    // Process the text into lines
    final List<String> processedLines = _processTextContent(text);

    if (processedLines.isEmpty) return false;

    // Store processed content for potential force add later
    _lastProcessedContent = processedLines;
    _lastLanguageCode = code;

    // Check language before creating the book
    if (!await _verifyLanguage(processedLines, code)) {
      return false; // Language doesn't match
    }

    // Create the book with either original or shuffled lines
    if (shuffleSentences) {
      final shuffledLines = _shuffleLines(processedLines);
      await _createBook(shuffledLines, code);
    } else {
      await _createBook(processedLines, code);
    }
    
    return true;
  }

  /// Processes text content into lines for book creation
  List<String> _processTextContent(String text) {
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
        if (wordCount >= 10) {
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

    return processedLines;
  }

  /// Processes a file and creates a book based on its contents
  /// Returns true if book was created successfully, false if language doesn't match
  Future<bool> processFile(String filePath, String code, {bool shuffleSentences = false}) async {
    if (filePath.isEmpty) return false;

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

      if (content.isEmpty) return false;

      // Store processed content for potential force add later
      _lastProcessedContent = content;
      _lastLanguageCode = code;

      // Check language before creating the book
      if (!await _verifyLanguage(content, code)) {
        return false; // Language doesn't match
      }

      // Create the book with either original or shuffled lines
      if (shuffleSentences) {
        final shuffledLines = _shuffleLines(content);
        await _createBook(shuffledLines, code);
      } else {
        await _createBook(content, code);
      }
      
      return true;
    } catch (e) {
      // Handle errors appropriately in your UI
      print('Error processing file: $e');
      return false;
    }
  }

  /// Forces adding the book using already processed content
  /// If no processed content is available, processes the text again
  Future<void> forceAddBook(String text, String code, {bool shuffleSentences = false}) async {
    if (_lastProcessedContent != null && _lastLanguageCode == code) {
      // Use the cached content if available
      if (shuffleSentences) {
        final shuffledLines = _shuffleLines(_lastProcessedContent!);
        await _createBook(shuffledLines, code);
      } else {
        await _createBook(_lastProcessedContent!, code);
      }
    } else {
      // Otherwise process the text again
      final processedLines = _processTextContent(text);
      if (processedLines.isNotEmpty) {
        if (shuffleSentences) {
          final shuffledLines = _shuffleLines(processedLines);
          await _createBook(shuffledLines, code);
        } else {
          await _createBook(processedLines, code);
        }
      }
    }

    // Clear the cache after use
    _lastProcessedContent = null;
    _lastLanguageCode = null;
  }

  /// Forces adding a file using already processed content
  /// If no processed content is available, processes the file again
  Future<void> forceAddFile(String filePath, String code, {bool shuffleSentences = false}) async {
    if (_lastProcessedContent != null && _lastLanguageCode == code) {
      // Use the cached content if available
      if (shuffleSentences) {
        final shuffledLines = _shuffleLines(_lastProcessedContent!);
        await _createBook(shuffledLines, code);
      } else {
        await _createBook(_lastProcessedContent!, code);
      }
    } else {
      // Otherwise process the file again
      if (filePath.isEmpty) return;

      final extension = path.extension(filePath).toLowerCase();
      List<String> content = [];

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
        if (shuffleSentences) {
          final shuffledLines = _shuffleLines(content);
          await _createBook(shuffledLines, code);
        } else {
          await _createBook(content, code);
        }
      }
    }

    // Clear the cache after use
    _lastProcessedContent = null;
    _lastLanguageCode = null;
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
        line
            .replaceAll(RegExp(r'<[^>]*>'), '')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim()).toList();
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
          if (languageCode != 'EL') {
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
            }
          }

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

  /// Verifies if the content matches the expected language code
  /// Takes a sample from the middle of the text for language checking
  Future<bool> _verifyLanguage(List<String> content, String code) async {
    // Get non-empty lines
    final nonEmptyLines = content.where((line) => line.trim().isNotEmpty).toList();
    if (nonEmptyLines.isEmpty) return false;

    // Get a representative line from the middle of the text
    final middleIndex = nonEmptyLines.length ~/ 2;
    String sampleLine = nonEmptyLines[middleIndex];

    // If the line is too short, try to find a longer one nearby
    if (sampleLine.split(' ').length < 5) {
      // Look for a longer line in the vicinity
      for (int i = 1; i < 10; i++) {
        final forwardIndex = middleIndex + i;
        final backwardIndex = middleIndex - i;

        if (forwardIndex < nonEmptyLines.length &&
            nonEmptyLines[forwardIndex].split(' ').length >= 5) {
          sampleLine = nonEmptyLines[forwardIndex];
          break;
        }

        if (backwardIndex >= 0 &&
            nonEmptyLines[backwardIndex].split(' ').length >= 5) {
          sampleLine = nonEmptyLines[backwardIndex];
          break;
        }
      }
    }

    try {
      // Use TranslationService to check if the language matches
      return await TranslationService().checkLanguage(sampleLine, code);
    } catch (e) {
      print('Error checking language: $e');
      // In case of API error, assume language is correct to not block the user
      return true;
    }
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

    final insertedBook = await _bookRepository.booksByLanguage(code).then((books) => books.last);
    _currentBook = insertedBook;

    if (_isCancelled) {
      await _bookRepository.deleteBook(insertedBook.id!);
      _currentBook = null;
      return;
    }

    await _bookRepository.createBookDatabase(insertedBook.id!, content);
    _currentBook = null;
  }

  /// Shuffles content by extracting sentences based on punctuation, then shuffling them
  /// 
  /// This method:
  /// 1. Preserves the title (first line)
  /// 2. Extracts proper sentences divided by punctuation
  /// 3. Shuffles all sentences together regardless of paragraph structure
  /// 4. Removes empty lines
  List<String> _shuffleLines(List<String> lines) {
    if (lines.length <= 1) return List.from(lines); // Nothing to shuffle
    
    // Always keep the title (first line) in place
    final title = lines.isNotEmpty ? lines.first : "";
    final result = [title];
    
    // If we only have a title, return early
    if (lines.length <= 1) return result;
    
    // Skip the title for processing
    final remainingLines = lines.sublist(1);
    
    // Join all lines with spaces and extract sentences
    final allText = remainingLines
        .where((line) => line.trim().isNotEmpty) // Remove empty lines
        .join(' ');
        
    // Extract sentences from the joined text
    final sentences = _extractSentences(allText);
    
    // Shuffle all sentences together
    if (sentences.isNotEmpty) {
      sentences.shuffle();
    }
    
    // Add the shuffled sentences to the result
    result.addAll(sentences);
    
    return result;
  }

  /// Extracts sentences from text based on punctuation
  List<String> _extractSentences(String text) {
    // Define regex pattern for sentence boundaries
    // This looks for punctuation followed by a space or end of string
    final sentencePattern = RegExp(r'(?<=[.!?,;:()\[\]{}<>\。！？，；：（）【】［］｛｝「」『』、،؛¿¡])\s*');
    
    // Split the text into sentences
    final sentences = <String>[];
    int startIndex = 0;
    
    // Find all sentence boundaries
    for (final match in sentencePattern.allMatches(text)) {
      final endIndex = match.end;
      // Extract and clean the sentence
      String sentence = text.substring(startIndex, endIndex).trim();
      
      // Clean the sentence while preserving balanced punctuation
      sentence = _cleanTrailingPunctuation(sentence);
      
      // Skip sentences that are only numbers
      if (sentence.isNotEmpty && !_isOnlyNumbers(sentence)) {
        sentences.add(sentence);
      }
      startIndex = endIndex;
    }
    
    // Add any remaining text as the last sentence (also clean it)
    String remainingText = text.substring(startIndex).trim();
    remainingText = _cleanTrailingPunctuation(remainingText);
    
    if (remainingText.isNotEmpty && !_isOnlyNumbers(remainingText)) {
      sentences.add(remainingText);
    }
    
    return sentences;
  }

  /// Cleans trailing punctuation while preserving balanced pairs
  String _cleanTrailingPunctuation(String text) {
    if (text.isEmpty) return text;
    
    // Define paired punctuation to check for balance
    final punctuationPairs = {
      '(': ')',
      '[': ']',
      '{': '}',
      '<': '>',
      '「': '」',
      '『': '』',
      '（': '）',
      '【': '】',
      '［': '］',
      '｛': '｝',
      '¿': '?',
      '¡': '!'
    };
    
    // Check if the text ends with any punctuation
    final regex = RegExp(r'[.!?,;:()\[\]{}<>\。！？，；：（）【】［］｛｝「」『』、،؛¿¡]+$');
    final match = regex.firstMatch(text);
    
    if (match == null) return text; // No trailing punctuation
    
    final trailingPunctuation = match.group(0)!;
    final textWithoutTrailing = text.substring(0, text.length - trailingPunctuation.length);
    
    // Check for balanced pairs in the trailing punctuation
    for (int i = 0; i < trailingPunctuation.length; i++) {
      final char = trailingPunctuation[i];
      
      // If it's a closing punctuation, check if it has a matching opening
      if (punctuationPairs.containsValue(char)) {
        final openingChar = punctuationPairs.entries
            .firstWhere((entry) => entry.value == char, orElse: () => const MapEntry('', ''))
            .key;
        
        if (openingChar.isNotEmpty && textWithoutTrailing.contains(openingChar)) {
          // This is a balanced pair, so keep it
          return text;
        }
      }
      
      // If it's an opening punctuation that should have a closing match
      if (punctuationPairs.containsKey(char)) {
        final closingChar = punctuationPairs[char]!;
        if (trailingPunctuation.contains(closingChar)) {
          // This is a balanced pair, so keep it
          return text;
        }
      }
    }
    
    // If we get here, the trailing punctuation isn't balanced, so remove it
    return textWithoutTrailing;
  }

  /// Checks if a string contains only numbers, spaces, and number-related characters
  bool _isOnlyNumbers(String text) {
    // This regex checks if the string consists only of:
    // - digits (0-9)
    // - spaces
    // - commas and periods (common in numbers)
    // - percent, plus, minus signs (for percentages, positive/negative numbers)
    return RegExp(r'^[\d\s.,+\-%]+$').hasMatch(text);
  }
}