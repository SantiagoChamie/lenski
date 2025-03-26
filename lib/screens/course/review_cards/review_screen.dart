import 'package:flutter/material.dart';
import 'package:lenski/models/card_model.dart' as lenski_card;
import 'package:lenski/models/course_model.dart';
import 'package:lenski/services/tts_service.dart';
import 'package:lenski/widgets/flag_icon.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/data/card_repository.dart';
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
  List<lenski_card.Card> cards = [];
  final CardRepository repository = CardRepository();

  @override
  void initState() {
    super.initState();
    _loadAudioPreference();
    _loadCards();
  }

  /// Loads the audio preference from SharedPreferences.
  Future<void> _loadAudioPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isAudioEnabled = prefs.getBool('isAudioEnabled') ?? true;
    });
  }

  /// Toggles the audio preference and saves it to SharedPreferences.
  Future<void> _toggleAudioPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isAudioEnabled = !isAudioEnabled;
    });
    await prefs.setBool('isAudioEnabled', isAudioEnabled);
  }

  /// Loads the cards to be reviewed from the repository.
  Future<void> _loadCards() async {
    final today = DateTime.now();
    final fetchedCards = await repository.cards(today, widget.course.code);
    setState(() {
      cards = fetchedCards;
    });
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

  /// Handles the difficulty selection.
  void handleDifficulty(int quality) async {
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

    //TODO: make this conditional into the text widget
    if (cards.isEmpty) {
      return Stack(
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
                    child: const Text(
                      'No more cards to review!',
                      style: TextStyle(
                        fontSize: 24.0,
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontFamily: "Varela Round",
                      ),
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
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.close_rounded),
            ),
          ),
        ],
      );
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
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(p.standardPadding()),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isFront ? '${widget.course.code.toLowerCase()}.' : '${widget.course.fromCode.toLowerCase()}.',
                        style: const TextStyle(
                          fontSize: 18.0,
                          color: Color(0xFF99909B),
                          fontFamily: "Varela Round",
                        ),
                      ),
                      Column(
                        children: [
                          Text(cards.isEmpty ? '???' :isFront ? currentCard.front : currentCard.back,
                            style: const TextStyle(
                              fontSize: 24.0,
                              color: Color.fromARGB(255, 0, 0, 0),
                              fontFamily: "Varela Round",
                            ),
                          ),
                          if (isFront && currentCard.context != currentCard.front) Text.rich(
                            TextSpan(
                              text: currentCard.context.substring(0, currentCard.context.indexOf(currentCard.front)),
                              style: const TextStyle(
                                fontSize: 18.0,
                                color: Color(0xFF99909B),
                                fontFamily: "Varela Round",
                              ),
                              children: [
                                TextSpan(
                                  text: currentCard.front,
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    color: Color(0xFF99909B),
                                    fontFamily: "Varela Round",
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: currentCard.context.substring(currentCard.context.indexOf(currentCard.front) + currentCard.front.length),
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    color: Color(0xFF99909B),
                                    fontFamily: "Varela Round",
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isFront)
                          Text(currentCard.front,
                            style: const TextStyle(
                              fontSize: 18.0,
                              color: Color(0xFF99909B),
                              fontFamily: "Varela Round",
                            ),
                          ),
                        ],
                      ),
                      isFront ? ElevatedButton(
                        onPressed: toggleCard,
                        child: const Text('Show answer',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Color(0xFF000000),
                            fontFamily: "Sansation",
                          ),
                        ),
                      ) :
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () => handleDifficulty(1),
                            child: const Text('Again',
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Color(0xFF000000),
                                fontFamily: "Sansation",
                              ),
                            ),
                          ),
                          SizedBox(width: p.standardPadding()),
                          ElevatedButton(
                            onPressed: () => handleDifficulty(2),
                            child: const Text('Hard',
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Color(0xFF000000),
                                fontFamily: "Sansation",
                              ),
                            ),
                          ),
                          SizedBox(width: p.standardPadding()),
                          ElevatedButton(
                            onPressed: () => handleDifficulty(3),
                            child: const Text('Medium',
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Color(0xFF000000),
                                fontFamily: "Sansation",
                              ),
                            ),
                          ),
                          SizedBox(width: p.standardPadding()),
                          ElevatedButton(
                            onPressed: () => handleDifficulty(4),
                            child: const Text('Easy',
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Color(0xFF000000),
                                fontFamily: "Sansation",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.close_rounded),
          ),
        ),
        Positioned(
          bottom: boxPadding + 10,
          left: boxPadding + 10,
          child: IconButton(
            onPressed: _toggleAudioPreference,
            icon: Icon(
              isAudioEnabled ? Icons.volume_up : Icons.volume_off,
              color: Colors.black,
            ),
          ),
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