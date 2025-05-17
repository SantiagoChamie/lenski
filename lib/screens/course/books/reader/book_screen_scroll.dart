import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import this for KeyEvent
import 'package:flutter/gestures.dart'; // Import this for PointerSignalEvent
import 'package:lenski/models/book_model.dart';
import 'package:lenski/models/course_model.dart';
import 'package:lenski/models/sentence_model.dart';
import 'package:lenski/utils/fonts.dart';
import 'package:lenski/widgets/flag_icon.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/data/book_repository.dart';
import 'package:lenski/data/session_repository.dart'; // Add this import
import 'package:lenski/widgets/ltext.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import this for SharedPreferences

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
  // Add these constants at the top of the class
  static const String _fontSizeKey = 'book_font_size';
  static const String _lineHeightKey = 'book_line_height';
  static const String _visibleLinesKey = 'book_visible_lines';
  
  // Add tracking variables
  late DateTime _startTime;
  late int _startLine;
  final SessionRepository _sessionRepository = SessionRepository();

  // Add these methods to handle preferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSize = prefs.getDouble(_fontSizeKey) ?? 30.0;
      _lineHeight = prefs.getDouble(_lineHeightKey) ?? 1.2;
      _visibleLines = prefs.getInt(_visibleLinesKey) ?? 11;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, _fontSize);
    await prefs.setDouble(_lineHeightKey, _lineHeight);
    await prefs.setInt(_visibleLinesKey, _visibleLines);
  }

  late Future<List<Sentence>> _sentencesFuture;
  late int _currentLine;
  final FocusNode _focusNode = FocusNode();
  double _fontSize = 30.0;
  bool _showFontSizeSlider = false;
  double _lineHeight = 1.2;
  bool _showLineHeightSlider = false;
  int _visibleLines = 11;
  bool _showLineCountSlider = false;

  @override
  void initState() {
    super.initState();
    _currentLine = widget.book.currentLine;
    _sentencesFuture = _fetchSentences();
    _loadSettings();
    
    // Initialize tracking variables
    _startTime = DateTime.now();
    _startLine = _currentLine;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    // Save reading stats when leaving the screen
    _saveReadingStats();
    super.dispose();
  }

  /// Saves reading statistics to the session repository
  Future<void> _saveReadingStats() async {
    // Calculate minutes studied
    final now = DateTime.now();
    final minutesStudied = now.difference(_startTime).inMinutes;
    
    // Calculate lines read (only count positive progress)
    final linesRead = _currentLine - _startLine > 0 ? _currentLine - _startLine : 0;
    
    // Only update if there's something to track
    if (minutesStudied > 0 || linesRead > 0) {
      await _sessionRepository.updateSessionStats(
        courseCode: widget.course.code,
        minutesStudied: minutesStudied > 0 ? minutesStudied : null,
        linesRead: linesRead > 0 ? linesRead : null,
      );
    }
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

  /// Checks if the book should be marked as finished based on current position
  Future<void> _checkAndMarkAsFinished(List<Sentence> sentences) async {
    if (widget.book.finished) return;  // Skip if already finished

    // Calculate if last line is visible
    final lastVisibleLine = _currentLine + (_visibleLines ~/ 2);
    if (lastVisibleLine+1 >= sentences.length) {
      // Mark book as finished
      final updatedBook = widget.book.copyWith(finished: true);
      final bookRepository = BookRepository();
      await bookRepository.updateBook(updatedBook);
      
      if (mounted) {
        widget.book.finished = true;
      }
    }
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
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        Navigator.of(context).pop();
      }
    }
  }

  /// Handles scroll events
  void _handleScrollEvent(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      // Using smaller threshold for better touchpad sensitivity
      if (event.scrollDelta.dy > 10) {
        _nextSentence();
      } else if (event.scrollDelta.dy < -10) {
        _previousSentence();
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    final boxPadding = p.standardPadding() * 4;

    return Scaffold(
      body: PopScope<Object?>(
        canPop: true,  
        onPopInvokedWithResult: (bool didPop, Object? result) async {
          await _saveReadingStats();
          return;
        },
        child: GestureDetector(
          onVerticalDragUpdate: (details) {
            if (details.delta.dy > 5) {
              _previousSentence();
            } else if (details.delta.dy < -5) {
              _nextSentence();
            }
          },
          child: Listener(
            onPointerSignal: _handleScrollEvent,
            child: KeyboardListener(
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
                                
                                // Move the check outside setState
                                _checkAndMarkAsFinished(sentences);  // Remove the result display

                                // Concatenate all sentences into a single string
                                final textContent = List.generate(_visibleLines, (index) {
                                  final int sentenceIndex = _currentLine - (_visibleLines ~/ 2) + index;
                                  
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
                                      child: Center(
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            minWidth: p.textWidth(),
                                            maxWidth: p.textWidth(), 
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                                            child: LText(
                                              text: textContent,
                                              position: 'above',
                                              fromLanguage: widget.course.fromCode,
                                              toLanguage: widget.course.code,
                                              style: TextStyle(
                                                fontSize: _fontSize,
                                                height: _lineHeight,
                                                color: const Color.fromARGB(255, 0, 0, 0),
                                                fontFamily: "Varela Round",
                                              ),
                                              textAlign: widget.course.code != 'AR' ? TextAlign.justify : TextAlign.end,
                                              cardTypes: [
                                                if (widget.course.reading) 'reading',
                                                if (widget.course.writing) 'writing',
                                                if (widget.course.listening) 'listening',
                                                if (widget.course.speaking) 'speaking',
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 40.0, right: 4.5),
                                      child: GestureDetector(
                                        onTapDown: (TapDownDetails details) {
                                          final RenderBox box = context.findRenderObject() as RenderBox;
                                          final localPosition = box.globalToLocal(details.globalPosition);
                                          
                                          // Since the progress bar is rotated, we use the x coordinate
                                          // to calculate the progress percentage
                                          final progressBarWidth = box.size.height; // Due to rotation
                                          final tapPosition = localPosition.dy;
                                          final paddingCorrection = 40*2 * (tapPosition / progressBarWidth) - 50;
                                          
                                          // Calculate new line number
                                          final percentage = (tapPosition + paddingCorrection) / progressBarWidth;
                                          final newLine = (percentage * widget.book.totalLines).round();
                                          
                                          // Ensure the new line is within bounds
                                          final boundedLine = newLine.clamp(1, widget.book.totalLines);
                                          
                                          setState(() {
                                            _currentLine = boundedLine;
                                            _updateCurrentLine(boundedLine);
                                          });
                                        },
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
                      language: widget.course.name,
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
                  Positioned(
                    left: boxPadding + 10,
                    bottom: boxPadding + 10,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_showFontSizeSlider) ...[
                          SizedBox(
                            height: 200,
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: Slider(
                                value: _fontSize,
                                activeColor: const Color(0xFF71BDE0),
                                min: 16.0,
                                max: 48.0,
                                divisions: 16,
                                label: _fontSize.round().toString(),
                                onChanged: (value) {
                                  setState(() {
                                    _fontSize = value;
                                    _saveSettings();
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                        IconButton(
                          icon: const Icon(Icons.text_fields_rounded),
                          onPressed: () {
                            setState(() {
                              _showFontSizeSlider = !_showFontSizeSlider;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: boxPadding + 10,
                    bottom: boxPadding + 10,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_showLineCountSlider) ...[
                          SizedBox(
                            height: 200,
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: Slider(
                                value: _visibleLines.toDouble(),
                                activeColor: const Color(0xFF71BDE0),
                                min: 1,
                                max: 21,
                                divisions: 9,
                                label: _visibleLines.toString(),
                                onChanged: (value) {
                                  setState(() {
                                    _visibleLines = value.round();
                                    _saveSettings();
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                        IconButton(
                          icon: const Icon(Icons.view_headline_rounded),
                          onPressed: () {
                            setState(() {
                              _showLineCountSlider = !_showLineCountSlider;
                              _showLineHeightSlider = false;
                              _showFontSizeSlider = false;
                            });
                          },
                        ),
                        if (_showLineHeightSlider) ...[
                          SizedBox(
                            height: 200,
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: Slider(
                                value: _lineHeight,
                                activeColor: const Color(0xFF71BDE0),
                                min: 1.0,
                                max: 3.0,
                                divisions: 20,
                                label: _lineHeight.toStringAsFixed(1),
                                onChanged: (value) {
                                  setState(() {
                                    _lineHeight = value;
                                    _saveSettings();
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                        IconButton(
                          icon: const Icon(Icons.format_line_spacing_rounded),
                          onPressed: () {
                            setState(() {
                              _showLineHeightSlider = !_showLineHeightSlider;
                              _showLineCountSlider = false;
                              _showFontSizeSlider = false;
                            });
                          },
                        ),
                        if (_showFontSizeSlider) ...[
                          SizedBox(
                            height: 200,
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: Slider(
                                value: _fontSize,
                                activeColor: const Color(0xFF71BDE0),
                                min: 16.0,
                                max: 48.0,
                                divisions: 16,
                                label: _fontSize.round().toString(),
                                onChanged: (value) {
                                  setState(() {
                                    _fontSize = value;
                                    _saveSettings();
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                        IconButton(
                          icon: const Icon(Icons.text_fields_rounded),
                          onPressed: () {
                            setState(() {
                              _showFontSizeSlider = !_showFontSizeSlider;
                              _showLineCountSlider = false;
                              _showLineHeightSlider = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}