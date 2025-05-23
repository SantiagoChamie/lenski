import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
import 'package:lenski/utils/colors.dart';
import 'package:lenski/widgets/flag_icon.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/data/card_repository.dart';
import 'package:lenski/data/course_repository.dart';
import 'package:lenski/data/session_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A screen for reviewing flashcards within a course.
///
/// This component displays cards that are due for review using a spaced repetition
/// system and provides an interface for:
/// - Showing the front of flashcards with different competence types
/// - Flipping to show the back of the card with translation
/// - Rating cards as easy or difficult, affecting their next review date
/// - Editing card content or deleting cards from the deck
/// - Tracking study time and updating progress statistics
///
/// Features:
/// - Keyboard shortcuts for efficient reviewing
/// - First-card prioritization for specific words
/// - Different card types based on competence (reading, writing, listening, speaking)
/// - Study time tracking and session statistics
class ReviewScreen extends StatefulWidget {
  /// The course associated with these flashcards
  final Course course;
  
  /// Optional specific word that should be shown first in the review
  final String? firstWord;

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
  /// Whether the card is showing its front (question) or back (answer)
  bool isFront = true;
  
  /// Whether audio should play automatically when showing cards
  bool isAudioEnabled = true;
  
  /// Whether text-to-speech is available for the current language
  bool isTtsAvailable = false;
  
  /// Whether to show colored competence indicators
  bool _showColors = true; 
  
  /// List of cards to be reviewed in this session
  List<lenski_card.Card> cards = [];
  
  /// Repository for card data operations
  final CardRepository repository = CardRepository();
  
  /// Repository for course data operations
  final CourseRepository courseRepository = CourseRepository();
  
  /// Repository for session statistics
  final SessionRepository sessionRepository = SessionRepository();
  
  /// Start time of the review session for tracking study duration
  late DateTime _startTime;
  
  /// Whether an attempt to reload cards has already been made
  bool _attemptedReload = false;

  /// Focus node for keyboard shortcuts
  final FocusNode _focusNode = FocusNode();


  @override
  void initState() {
    super.initState();
    _loadAudioPreference();
    _loadCards();
    _checkTtsAvailability();
    _loadColors();
    
    // Initialize start time for tracking study duration
    _startTime = DateTime.now();
    
    // Request focus when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }
  
  @override
  void dispose() {
    // Save study time when leaving screen
    _saveStudyTime();
    _focusNode.dispose(); // Dispose focus node
    super.dispose();
  }
  
  /// Loads the colored cards preference from SharedPreferences.
  ///
  /// This determines whether competence cards show their type-specific colors
  /// or appear in a neutral gray color.
  Future<void> _loadColors() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showColors = prefs.getBool('colored_competence_cards') ?? true;
    });
  }

  /// Saves the time spent studying to the session repository.
  ///
  /// This calculates the duration between the session start and current time,
  /// then stores it in the session statistics for the course.
  Future<void> _saveStudyTime() async {
    final now = DateTime.now();
    final minutesStudied = now.difference(_startTime).inMinutes; 
    
    // Only update if user spent at least a minute
    if (minutesStudied > 0) {
      await sessionRepository.updateSessionStats(
        courseCode: widget.course.code,
        minutesStudied: minutesStudied,
      );
    }
  }

  /// Loads the audio preference from SharedPreferences.
  ///
  /// This determines whether cards should automatically read their content
  /// aloud when shown.
  Future<void> _loadAudioPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isAudioEnabled = prefs.getBool('isAudioEnabled') ?? true;
    });
  }

  /// Loads the cards to be reviewed from the repository.
  ///
  /// This method:
  /// 1. Fetches all cards due for review today
  /// 2. If firstWord is specified, prioritizes it at the beginning of the deck
  /// 3. Randomizes the order of the remaining cards
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
  ///
  /// This determines whether text-to-speech functionality is available
  /// for the language being learned, and disables audio if not available.
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
  /// 
  /// If the card is on the front and audio is enabled, it reads the front of the card.
  void toggleCard() async {
    if (isFront && isAudioEnabled) {
      // ignore: empty_catches
      try {await TtsService().speak(cards.first.front, widget.course.code);} catch (e) {}
    }
    setState(() {
      isFront = !isFront;
    });
  }

  /// Handles the difficulty selection and updates card scheduling.
  ///
  /// @param quality The difficulty rating (1 for difficult, 4 for easy)
  void handleDifficulty(int quality) async {
    // Track card review in the session stats
    await sessionRepository.updateSessionStats(
      courseCode: widget.course.code,
      wordsReviewed: 1,
    );

    final currentCard = cards.removeAt(0);
    final nextDue = await repository.updateCardEFactor(currentCard, quality);
    
    if (nextDue < 1) {
      // If card should be reviewed again in this session, add it back
      cards.add(currentCard);
    }
    toggleCard();
  }

  /// Handles the deletion of the current card.
  ///
  /// This removes the card from the deck and provides an undo option.
  void handleDelete() async {
    final localizations = AppLocalizations.of(context)!;
    
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
          content: Text(localizations.cardDeleted),
          action: SnackBarAction(
            label: localizations.undoAction,
            textColor: AppColors.lightYellow,
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

  /// Shows a dialog for editing the current card.
  ///
  /// @param card The card to be edited
  void _showEditCardDialog(lenski_card.Card card) async {
    final localizations = AppLocalizations.of(context)!;
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
          SnackBar(content: Text(localizations.cardUpdatedSuccessfully)),
        );
      }
    }
  }

  /// Gets the tooltip text for a specific card type.
  ///
  /// @param cardType The type of card ('writing', 'speaking', or other)
  /// @return A localized string describing the card's prompt
  String _getCardTypeTooltip(String cardType) {
    final localizations = AppLocalizations.of(context)!;
    
    switch (cardType) {
      case 'writing':
        return localizations.writingCardTooltip;
      case 'speaking':
        return localizations.speakingCardTooltip;
      default:
        return localizations.readingCardTooltip;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    final boxPadding = p.standardPadding() * 4;
    const iconSize = 80.0;

    if (cards.isEmpty) {
      // If we haven't tried reloading yet, try to load cards again
      if (!_attemptedReload) {
        _attemptedReload = true;
        // Use Future.microtask to avoid setState during build
        Future.microtask(() async {
          await _loadCards();
          // Reset the flag if we found new cards
          if (cards.isNotEmpty) {
            setState(() {
              _attemptedReload = false;
            });
          }
        });
      }
      
      return EmptyPile(language: widget.course.name);
    }

    // Reset reload flag when we have cards
    _attemptedReload = false;
    
    final currentCard = cards.first;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        await _saveStudyTime();
        return;
      },
      child: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: (KeyEvent event) {
          // Only handle key down events
          if (event is! KeyDownEvent) {
            return;
          }
          
          // Get the logical key
          final logicalKey = event.logicalKey;
          
          // Space key - flip card from front to back only
          if (logicalKey == LogicalKeyboardKey.space && isFront) {
            toggleCard();
          }
          // Number keys (when viewing the back of card)
          else if (!isFront) {
            // '1' key for difficult
            if (logicalKey == LogicalKeyboardKey.digit1 || 
                logicalKey == LogicalKeyboardKey.numpad1) {
              handleDifficulty(1);
            }
            // '2' key for easy
            else if (logicalKey == LogicalKeyboardKey.digit2 || 
                    logicalKey == LogicalKeyboardKey.numpad2) {
              handleDifficulty(4);
            }
          }

          if(logicalKey == LogicalKeyboardKey.keyE) {
            _showEditCardDialog(currentCard);
          }

          if(logicalKey == LogicalKeyboardKey.keyD || 
             logicalKey == LogicalKeyboardKey.delete) {
            handleDelete();
          }

          if(logicalKey == LogicalKeyboardKey.escape) {
            Navigator.of(context).pop();
          }
        },
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(boxPadding),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: isFront ? AppColors.lightGrey : Colors.white,
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
                                showColors: _showColors,
                              )
                            :
                          currentCard.type == 'listening'
                            ? ListeningCard(
                                card: currentCard,
                                courseCode: widget.course.code,
                                onShowAnswer: toggleCard,
                                showColors: _showColors,
                              )
                            :
                          currentCard.type == 'speaking'
                            ? SpeakingCard(
                                card: currentCard,
                                courseCode: widget.course.code,
                                onShowAnswer: toggleCard,
                                showColors: _showColors,
                              )
                            :
                          currentCard.type == 'writing'
                            ? WritingCard(
                                card: currentCard,
                                courseCode: widget.course.code,
                                onShowAnswer: toggleCard,
                                showColors: _showColors,
                              )
                            :
                          ReadingCard(
                            card: currentCard,
                            courseCode: widget.course.code,
                            onShowAnswer: toggleCard,
                            showColors: _showColors,
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
                borderColor: AppColors.grey,
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
                  Text(
                    cards.length.toString(),
                    style: TextStyle(
                      fontFamily: appFonts['Paragraph'], 
                      fontWeight: FontWeight.bold, 
                      color: AppColors.darkGrey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Tooltip(
                    message: _getCardTypeTooltip(currentCard.type),
                    child: CompetenceIcon(
                      type: currentCard.type,
                      size: iconSize/2,
                      gray: !_showColors,
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
                    backgroundColor: AppColors.lightYellow,
                    child: const Icon(Icons.edit, color: AppColors.black, size: 20),
                  ),
                  const SizedBox(height: 16),
                  // Delete button (now smaller)
                  FloatingActionButton.small(
                    onPressed: handleDelete,
                    hoverElevation: 0,
                    elevation: 0,
                    backgroundColor: AppColors.lightYellow,
                    child: const Icon(Icons.delete, color: AppColors.black, size: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog for editing a card's content.
///
/// This component allows users to modify:
/// - The front (word to learn)
/// - The back (translation)
/// - The context (example sentence)
/// - The card type (competence)
class EditCardDialog extends StatefulWidget {
  /// The card being edited
  final lenski_card.Card card;
  
  /// Creates an EditCardDialog widget.
  /// 
  /// [card] is the card to be edited.
  const EditCardDialog({super.key, required this.card});
  
  @override
  _EditCardDialogState createState() => _EditCardDialogState();
}

class _EditCardDialogState extends State<EditCardDialog> {
  /// Controller for the front text field
  late TextEditingController _frontController;
  
  /// Controller for the back text field
  late TextEditingController _backController;
  
  /// Controller for the context text field
  late TextEditingController _contextController;
  
  /// Currently selected card type
  late String _selectedType;
  
  /// Available card types
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
    final localizations = AppLocalizations.of(context)!;
    
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        width: 400,
        child: Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: const TextSelectionThemeData(
              selectionColor: AppColors.lightBlue,
              cursorColor: AppColors.darkGrey,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.editCardTitle,
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: appFonts['Subtitle'],
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _frontController,
                decoration: InputDecoration(
                  labelText: localizations.frontCardLabel,
                  labelStyle: TextStyle(
                    fontFamily: appFonts['Detail'],
                    fontSize: 16,
                    color: AppColors.darkGrey,
                  ),
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.blue, width: 2.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _backController,
                decoration: InputDecoration(
                  labelText: localizations.backCardLabel,
                  labelStyle: TextStyle(
                    fontFamily: appFonts['Detail'],
                    fontSize: 16,
                    color: AppColors.darkGrey,
                  ),
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.blue, width: 2.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contextController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: localizations.contextCardLabel,
                  labelStyle: TextStyle(
                    fontFamily: appFonts['Detail'],
                    fontSize: 16,
                    color: AppColors.darkGrey,
                  ),
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.blue, width: 2.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: localizations.cardTypeLabel,
                  labelStyle: TextStyle(
                    fontFamily: appFonts['Detail'],
                    fontSize: 16,
                    color: AppColors.darkGrey,
                  ),
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.blue, width: 2.0),
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
                          localizations.getCardTypeDisplay(type),
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
                    child: Text(
                      localizations.cancel,
                      style: TextStyle(
                        fontFamily: appFonts['Detail'],
                        fontSize: 14,
                        color: AppColors.error,
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
                      backgroundColor: AppColors.blue,
                    ),
                    child: Text(
                      localizations.save,
                      style: TextStyle(
                        fontFamily: appFonts['Detail'],
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
  ///
  /// @param days Integer number of days since Unix epoch
  /// @return A DateTime object corresponding to that date
  static DateTime _intToDateTime(int days) {
    return DateTime.utc(1970, 1, 1).add(Duration(days: days));
  }
}