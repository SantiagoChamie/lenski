import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import this for KeyEvent
import 'package:lenski/models/book_model.dart';
import 'package:lenski/models/course_model.dart';
import 'package:lenski/models/sentence_model.dart';
import 'package:lenski/widgets/flag_icon.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/data/book_repository.dart';
import 'package:lenski/widgets/ltext.dart';

/// Screen to display a book
/// Allows the user to read the book sentence by sentence
class BookScreenScroll extends StatefulWidget {
  final Book book;
  final Course course;

  /// Creates a BookScreenScroll widget.
  /// 
  /// [book] is the book to be displayed.
  /// [course] is the course to which the book belongs.
  const BookScreenScroll({super.key, required this.book, required this.course});

  @override
  _BookScreenScrollState createState() => _BookScreenScrollState();
}

class _BookScreenScrollState extends State<BookScreenScroll> {
  late Future<List<Sentence>> _sentencesFuture;
  late int _currentLine;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _currentLine = widget.book.currentLine;
    _sentencesFuture = _fetchSentences();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  /// Fetches the sentences for the book from the repository.
  Future<List<Sentence>> _fetchSentences() async {
    final bookRepository = BookRepository();
    final sentences = await bookRepository.getSentences(widget.book.id!);
    sentences.sort((a, b) => a.id.compareTo(b.id));
    return sentences;
  }

  /// Updates the current line of the book in the repository.
  void _updateCurrentLine(int newLine) async {
    final bookRepository = BookRepository();
    widget.book.currentLine = newLine;
    await bookRepository.updateBook(widget.book);
  }

  /// Moves to the next sentence in the book.
  void _nextSentence() {
    setState(() {
      if (_currentLine < widget.book.totalLines) {
        _currentLine++;
        _updateCurrentLine(_currentLine);
      }
    });
  }

  /// Moves to the previous sentence in the book.
  void _previousSentence() {
    setState(() {
      if (_currentLine > 1) {
        _currentLine--;
        _updateCurrentLine(_currentLine);
      }
    });
  }

  /// Handles key events for navigating through sentences.
  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown || event.logicalKey == LogicalKeyboardKey.keyS) {
        _nextSentence();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp || event.logicalKey == LogicalKeyboardKey.keyW) {
        _previousSentence();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    final boxPadding = p.standardPadding() * 4;

    return Scaffold(
      body: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(boxPadding),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F0F6),
                    borderRadius: BorderRadius.circular(5.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(p.standardPadding()),
                    child: FutureBuilder<List<Sentence>>(
                      future: _sentencesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return const Text('Error loading sentences');
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text('No sentences found');
                        } else {
                          final sentences = snapshot.data!;

                          // Concatenate all sentences into a single string
                          final textContent = List.generate(11, (index) {
                            final int sentenceIndex = _currentLine - 6 + index;

                            // Handle empty lines at the top and bottom
                            if (sentenceIndex < 0 || sentenceIndex >= sentences.length) {
                              return ''; // Empty line
                            }

                            final sentence = sentences[sentenceIndex];
                            return sentence.sentence;
                          }).join('\n'); // Join sentences with a newline

                          return Row(
                            children: [
                              Expanded(
                                child: Center( // Ensures horizontal centering
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: LText(
                                      text: textContent,
                                      position: 'above',
                                      fromLanguage: widget.course.fromCode,
                                      toLanguage: widget.course.code,
                                      style: const TextStyle(
                                        fontSize: 30.0,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                        fontFamily: "Varela Round",
                                      ),
                                      textAlign: TextAlign.justify, // Justified text alignment
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 40.0, right: 4.5),
                                child: RotatedBox(
                                  quarterTurns: 1,
                                  child: LinearProgressIndicator(
                                    value: _currentLine / widget.book.totalLines,
                                    backgroundColor: const Color(0xFFD9D0DB),
                                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2C73DE)),
                                    minHeight: 10,
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: boxPadding - 40,
              left: boxPadding - 40,
              child: FlagIcon(
                size: 80.0,
                borderWidth: 5.0,
                borderColor: const Color(0xFFD9D0DB),
                imageUrl: widget.course.imageUrl,
              ),
            ),
            Positioned(
              top: boxPadding + 10,
              right: boxPadding + 10,
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pop(widget.book);
                },
                icon: const Icon(Icons.close_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}