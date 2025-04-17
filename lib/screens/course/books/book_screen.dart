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
class BookScreen extends StatefulWidget {
  final Book book;
  final Course course;

  /// Creates a BookScreen widget.
  /// 
  /// [book] is the book to be displayed.
  /// [course] is the course to which the book belongs.
  const BookScreen({super.key, required this.book, required this.course});

  @override
  _BookScreenState createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
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
      if (event.logicalKey == LogicalKeyboardKey.arrowRight || event.logicalKey == LogicalKeyboardKey.keyD) {
        _nextSentence();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft || event.logicalKey == LogicalKeyboardKey.keyA) {
        _previousSentence();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    final boxPadding = p.standardPadding() * 4;
    const iconSize = 80.0;

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
                  child: Center(
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
                            final currentSentence = sentences[_currentLine - 1].sentence;
                            return Column(
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.arrow_back_ios_rounded),
                                          onPressed: _previousSentence,
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: p.standardPadding() * 2),
                                            child: Center( // Center horizontally
                                              child: LText(
                                                text: currentSentence,
                                                position: 'below',
                                                fromLanguage: widget.course.fromCode,
                                                toLanguage: widget.course.code,
                                                style: const TextStyle(
                                                  fontSize: 30.0,
                                                  color: Color.fromARGB(255, 0, 0, 0),
                                                  fontFamily: "Varela Round",
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.arrow_forward_ios_rounded),
                                          onPressed: _nextSentence,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: LinearProgressIndicator(
                                    value: _currentLine / widget.book.totalLines,
                                    backgroundColor: const Color(0xFFD9D0DB),
                                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2C73DE)),
                                    borderRadius: BorderRadius.circular(5.0),
                                    minHeight: 10,
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
            ),
            Positioned(
              top: boxPadding - iconSize / 3,
              left: boxPadding - iconSize / 3,
              child: FlagIcon(
                size: iconSize,
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
                  Navigator.of(context).pop(widget.book); // Return the updated book
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