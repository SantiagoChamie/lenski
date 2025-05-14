import 'package:flutter/material.dart';
import 'package:lenski/models/card_model.dart' as lenski_card;
import 'package:lenski/models/course_model.dart';
import 'package:lenski/screens/course/review_cards/back_card.dart';
import 'package:lenski/screens/course/review_cards/types/empty_pile.dart';
import 'package:lenski/screens/course/review_cards/types/listening_card.dart';
import 'package:lenski/screens/course/review_cards/types/reading_card.dart';
import 'package:lenski/screens/course/review_cards/types/speaking_card.dart';
import 'package:lenski/screens/course/review_cards/types/writing_card.dart';
import 'package:lenski/screens/home/competences/competence_icon.dart';
import 'package:lenski/services/tts_service.dart';
import 'package:lenski/utils/fonts.dart';
import 'package:lenski/widgets/flag_icon.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/data/card_repository.dart';
import 'package:lenski/data/course_repository.dart';
import 'package:lenski/data/session_repository.dart'; // Add this import
import 'package:shared_preferences/shared_preferences.dart';

/// A screen for reviewing flashcards within a course.
class ReviewScreen extends StatefulWidget {
  final Course course;
  final String? firstWord; // Add this field

  /// Creates a ReviewScreen widget.
  /// 
  /// [course] is the course for which the review screen is being created.
  /// [firstWord] is the word that should be displayed first (optional)
  const ReviewScreen({
    super.key, 
    required this.course,
    this.firstWord,
  });

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  bool isFront = true;
  bool isAudioEnabled = true; // Default value
  bool isTtsAvailable = false; // New state variable
  List<lenski_card.Card> cards = [];
  final CardRepository repository = CardRepository();
  final CourseRepository courseRepository = CourseRepository();
  final SessionRepository sessionRepository = SessionRepository(); // Add session repository
  
  // Add tracking variable for study time
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _loadAudioPreference();
    _loadCards();
    _checkTtsAvailability();
    
    // Initialize start time for tracking study duration
    _startTime = DateTime.now();
  }
  
  @override
  void dispose() {
    // Save study time when leaving screen
    _saveStudyTime();
    super.dispose();
  }
  
  /// Saves the time spent studying to session repository
  Future<void> _saveStudyTime() async {
    final now = DateTime.now();
    final minutesStudied = now.difference(_startTime).inMinutes-1; 
    
    // Only update if user spent at least a minute
    if (minutesStudied > 0) {
      await sessionRepository.updateSessionStats(
        courseCode: widget.course.code,
        minutesStudied: minutesStudied,
      );
    }
  }

  /// Loads the audio preference from SharedPreferences.
  Future<void> _loadAudioPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isAudioEnabled = prefs.getBool('isAudioEnabled') ?? true;
    });
  }

  /// Loads the cards to be reviewed from the repository.
  Future<void> _loadCards() async {
    final today = DateTime.now();
    final fetchedCards = await repository.cards(today, widget.course.code);
    
    setState(() {
      if (fetchedCards.isEmpty) {
        cards = [];
        return;
      }

      // Check if we have a specific first word to show
      if (widget.firstWord != null) {
        // Find the card with matching front text to show first
        final firstCardIndex = fetchedCards.indexWhere((card) => card.front == widget.firstWord);
        
        if (firstCardIndex != -1) {
          // Remove the first card from its position
          final firstCard = fetchedCards.removeAt(firstCardIndex);
          
          // Randomize the remaining cards
          fetchedCards.shuffle();
          
          // Add the first card back at the beginning
          fetchedCards.insert(0, firstCard);
        } else {
          // If the firstWord isn't found (unusual case), just shuffle all cards
          fetchedCards.shuffle();
        }
      } else {
        // No specific first word, so shuffle all cards
        fetchedCards.shuffle();
      }
      
      cards = fetchedCards;
    });
  }

  /// Checks the availability of TTS for the current course language.
  Future<void> _checkTtsAvailability() async {
    try {
      final List<dynamic> availableLanguages = await TtsService().getLanguages();
      final bool available = availableLanguages.any(
        (lang) => lang.toString().substring(0, 2).toLowerCase() == widget.course.code.toLowerCase()
      );
      setState(() {
        isTtsAvailable = available;
        // If TTS is not available, disable audio
        if (!available) {
          isAudioEnabled = false;
        }
      });
    } catch (e) {
      setState(() {
        isTtsAvailable = false;
        isAudioEnabled = false;
      });
    }
  }
  
  /// Toggles the visibility of the card (front/back).
  /// If the card is on the front and audio is enabled, it reads the front of the card.
  void toggleCard() async {
    if (isFront && isAudioEnabled) {
      // ignore: empty_catches
      try {await TtsService().speak(cards.first.front, widget.course.code);} catch (e) {}
    }
    setState(() {
      isFront = !isFront;
    });
    /**for (var card in cards) {
      print('Due date for card ${card.id}: ${_intToDateTime(card.dueDate)}');
    }
    */
  }

  /// Handles the difficulty selection and updates streak on first review.
  void handleDifficulty(int quality) async {
    // Track card review in the session stats
    await sessionRepository.updateSessionStats(
      courseCode: widget.course.code,
      wordsReviewed: 1,
    );

    final currentCard = cards.removeAt(0);
    final nextDue = await repository.updateCardEFactor(currentCard, quality);
    if (nextDue < 1) {
      cards.add(currentCard);
    }
    toggleCard();
  }

  /// Handles the deletion of the current card.
  void handleDelete() async {
    if (cards.isNotEmpty) {
      final currentCard = cards.removeAt(0);
      await repository.deleteCard(currentCard.id);
      await sessionRepository.updateSessionStats(
        courseCode: widget.course.code,
        cardsDeleted: 1,
      );
      setState(() {
        isFront = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Card deleted'),
          action: SnackBarAction(
            label: 'Undo',
            textColor: const Color(0xFFFFD38D),
            onPressed: () async {
              cards.insert(0, currentCard);
              await repository.insertCard(currentCard);
              await sessionRepository.updateSessionStats(
                courseCode: widget.course.code,
                cardsDeleted: -1,
              );
              setState(() {});
            },
          ),
        ),
      );
    }
  }

  /// Shows a dialog for editing the current card
  void _showEditCardDialog(lenski_card.Card card) async {
    final result = await showDialog<lenski_card.Card>(
      context: context,
      builder: (context) => EditCardDialog(card: card),
    );
    
    if (result != null) {
      // Update the card in the repository
      await repository.updateCard(result);
      
      // Update the card in the current list
      setState(() {
        cards[0] = result;
      });
      
      // Show confirmation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card updated successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    final boxPadding = p.standardPadding() * 4;
    const iconSize = 80.0;

    if (cards.isEmpty) {
      return EmptyPile(language: widget.course.name);
    }

    final currentCard = cards.first;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        await _saveStudyTime();
        return;
      },
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(boxPadding),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: isFront ? const Color(0xFFF5F0F6) : const Color(0xFFFFFFFF),
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
                  child: isFront
                      ? currentCard.type == 'reading' 
                          ? ReadingCard(
                              card: currentCard,
                              courseCode: widget.course.code,
                              onShowAnswer: toggleCard,
                            )
                          :
                        currentCard.type == 'listening'
                          ? ListeningCard(
                              card: currentCard,
                              courseCode: widget.course.code,
                              onShowAnswer: toggleCard,
                            )
                          :
                        currentCard.type == 'speaking'
                          ? SpeakingCard(
                              card: currentCard,
                              courseCode: widget.course.code,
                              onShowAnswer: toggleCard,
                            )
                          :
                        currentCard.type == 'writing'
                          ? WritingCard(
                              card: currentCard,
                              courseCode: widget.course.code,
                              onShowAnswer: toggleCard,
                            )
                          :
                        ReadingCard(
                          card: currentCard,
                          courseCode: widget.course.code,
                          onShowAnswer: toggleCard,
                        )
                      : BackCard(
                          card: currentCard,
                          courseFromCode: widget.course.fromCode,
                          onDifficultySelected: handleDifficulty,
                        ),
                ),
              ),
            ),
          ),

          /// Icons and decor
          Positioned(
            top: boxPadding - iconSize / 3,
            left: boxPadding - iconSize / 3,
            child: FlagIcon(
              size: iconSize,
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
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.close_rounded),
            ),
          ),
          
          Positioned(
            bottom: boxPadding + 10,
            left: boxPadding + 10,
            child: Column(
              children: [
                Text(cards.length.toString(),
                  style: TextStyle(
                    fontFamily: appFonts['Paragraph'], 
                    fontWeight: FontWeight.bold, 
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),
                Tooltip(
                  message: 
                    currentCard.type == 'writing' ? "How do you write this word?"
                    : currentCard.type == 'speaking' ? "How do you pronounce this word?" 
                    : "What does this word mean?",
                  child: CompetenceIcon(
                    type: currentCard.type,
                    size: iconSize/2,
                  ),
                ),
              ],
            )
          ),
          Positioned(
            bottom: boxPadding + 20,
            right: boxPadding + 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Edit button
                FloatingActionButton.small(
                  onPressed: () => _showEditCardDialog(currentCard),
                  hoverElevation: 0,
                  elevation: 0,
                  backgroundColor: const Color(0xFFFFD38D),
                  child: const Icon(Icons.edit, color: Colors.black, size: 20),
                ),
                const SizedBox(height: 16),
                // Delete button (now smaller)
                FloatingActionButton.small(
                  onPressed: handleDelete,
                  hoverElevation: 0,
                  elevation: 0,
                  backgroundColor: const Color(0xFFFFD38D),
                  child: const Icon(Icons.delete, color: Colors.black, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog for editing a card
class EditCardDialog extends StatefulWidget {
  final lenski_card.Card card;
  
  const EditCardDialog({super.key, required this.card});
  
  @override
  _EditCardDialogState createState() => _EditCardDialogState();
}

class _EditCardDialogState extends State<EditCardDialog> {
  late TextEditingController _frontController;
  late TextEditingController _backController;
  late TextEditingController _contextController;
  late String _selectedType;
  final List<String> _cardTypes = ['reading', 'writing', 'speaking', 'listening'];
  
  @override
  void initState() {
    super.initState();
    _frontController = TextEditingController(text: widget.card.front);
    _backController = TextEditingController(text: widget.card.back);
    _contextController = TextEditingController(text: widget.card.context);
    _selectedType = widget.card.type;
  }
  
  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    _contextController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        width: 400,
        child: Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: const TextSelectionThemeData(
              selectionColor: Color(0xFF71BDE0),
              cursorColor: Colors.black54,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Card',
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: appFonts['Subtitle'],
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _frontController,
                decoration: InputDecoration(
                  labelText: 'Front (word to learn)',
                  labelStyle: TextStyle(
                    fontFamily: appFonts['Detail'],
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF2C73DE), width: 2.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _backController,
                decoration: InputDecoration(
                  labelText: 'Back (translation)',
                  labelStyle: TextStyle(
                    fontFamily: appFonts['Detail'],
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF2C73DE), width: 2.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contextController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Context (example sentence)',
                  labelStyle: TextStyle(
                    fontFamily: appFonts['Detail'],
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF2C73DE), width: 2.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Card Type',
                  labelStyle: TextStyle(
                    fontFamily: appFonts['Detail'],
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF2C73DE), width: 2.0),
                  ),
                ),
                items: _cardTypes.map((type) {
                  IconData icon;
                  switch (type) {
                    case 'reading':
                      icon = Icons.menu_book;
                      break;
                    case 'writing':
                      icon = Icons.edit_note;
                      break;
                    case 'speaking':
                      icon = Icons.record_voice_over;
                      break;
                    case 'listening':
                      icon = Icons.headphones;
                      break;
                    default:
                      icon = Icons.question_mark;
                  }
                  
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Row(
                      children: [
                        Icon(icon, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          type.substring(0, 1).toUpperCase() + type.substring(1),
                          style: TextStyle(
                            fontFamily: appFonts['Detail'],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel',
                      style: TextStyle(
                        fontFamily: 'Sansation',
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      final updatedCard = lenski_card.Card(
                        id: widget.card.id,
                        front: _frontController.text.trim(),
                        back: _backController.text.trim(),
                        context: _contextController.text.trim(),
                        dueDate: _intToDateTime(widget.card.dueDate),
                        language: widget.card.language,
                        type: _selectedType,
                        prevInterval: widget.card.prevInterval,
                        eFactor: widget.card.eFactor,
                        repetition: widget.card.repetition,
                      );
                      Navigator.pop(context, updatedCard);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C73DE),
                    ),
                    child: const Text('Save',
                      style: TextStyle(
                        fontFamily: 'Sansation',
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Converts an integer representing the number of days since Unix epoch to a DateTime object.
  static DateTime _intToDateTime(int days) {
    return DateTime.utc(1970, 1, 1).add(Duration(days: days));
  }

}