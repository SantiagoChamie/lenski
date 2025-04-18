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
import 'package:lenski/widgets/flag_icon.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/data/card_repository.dart';
import 'package:lenski/data/course_repository.dart'; // Add repository import
import 'package:shared_preferences/shared_preferences.dart';

/// A screen for reviewing flashcards within a course.
class ReviewScreen extends StatefulWidget {
  final Course course;

  /// Creates a ReviewScreen widget.
  /// 
  /// [course] is the course for which the review screen is being created.
  const ReviewScreen({super.key, required this.course});

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  bool isFront = true;
  bool isAudioEnabled = true; // Default value
  bool isTtsAvailable = false; // New state variable
  bool _hasIncrementedStreak = false; // New field to track streak updates
  List<lenski_card.Card> cards = [];
  final CardRepository repository = CardRepository();
  final CourseRepository courseRepository = CourseRepository(); // Add repository

  @override
  void initState() {
    super.initState();
    _loadAudioPreference();
    _loadCards();
    _checkTtsAvailability(); // Add this new method call
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
  }

  /// Handles the difficulty selection and updates streak on first review.
  void handleDifficulty(int quality) async {
    // Update streak only on first card review of the session
    if (!_hasIncrementedStreak) {
      await courseRepository.incrementStreak(widget.course);
      _hasIncrementedStreak = true;
    }

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
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Card deleted'),
          action: SnackBarAction(
            label: 'Undo',
            textColor: const Color(0xFFFFD38D),
            onPressed: () async {
              cards.insert(0, currentCard);
              await repository.insertCard(currentCard);
              setState(() {});
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    final boxPadding = p.standardPadding() * 4;
    const iconSize = 80.0;

    if (cards.isEmpty) {
      return EmptyPile(imageUrl: widget.course.imageUrl,);
    }

    final currentCard = cards.first;

    return Stack(
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
            imageUrl: widget.course.imageUrl,
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
          child: Tooltip(
            message: 
              currentCard.type == 'writing' ? "How do you write this word?"
              : currentCard.type == 'speaking' ? "How do you pronounce this word?" 
              : "What does this word mean?",
            child: CompetenceIcon(
              type: currentCard.type,
              size: iconSize/2,
            ),
          )
        ),
        Positioned(
          bottom: boxPadding + 20,
          right: boxPadding + 20,
          child: FloatingActionButton(
            onPressed: handleDelete,
            backgroundColor: const Color(0xFFFFD38D),
            child: const Icon(Icons.delete, color: Colors.black),
          ),
        ),
      ],
    );
  }
}