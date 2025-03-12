import 'package:flutter/material.dart';
import 'package:lenski/models/card_model.dart' as lenski_card;
import 'package:lenski/models/course_model.dart';
import 'package:lenski/widgets/flag_icon.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/data/card_repository.dart';

class ReviewScreen extends StatefulWidget {
  final Course course;

  const ReviewScreen({super.key, required this.course});

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  bool isFront = true;
  List<lenski_card.Card> cards = [];
  final CardRepository repository = CardRepository();

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final today = DateTime.now();
    final fetchedCards = await repository.cards(today, widget.course.code);
    setState(() {
      cards = fetchedCards;
    });
  }

  void toggleCard() {
    setState(() {
      isFront = !isFront;
    });
  }

  void handleEasy() async {
    final currentCard = cards.removeAt(0);
    await repository.postponeCard(currentCard);
    toggleCard();
  }

  void handleMedium() async {
    final currentCard = cards.removeAt(0);
    if (currentCard.prevInterval != 0) {
      await repository.postponeCard(currentCard, interval: currentCard.prevInterval);
    }
    cards.add(currentCard);
    toggleCard();
  }

  void handleHard() async {
    final currentCard = cards.removeAt(0);
    if (currentCard.prevInterval != 0) {
      await repository.restartCard(currentCard);
    }
    cards.add(currentCard);
    toggleCard();
  }

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    final boxPadding = p.standardPadding() * 4;
    const iconSize = 80.0;

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
                          Text(isFront ? currentCard.front : currentCard.back,
                            style: const TextStyle(
                              fontSize: 24.0,
                              color: Color.fromARGB(255, 0, 0, 0),
                              fontFamily: "Varela Round",
                            ),
                          ),
                          if (isFront) Text.rich(
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
                            onPressed: handleHard,
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
                            onPressed: handleMedium,
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
                            onPressed: handleEasy,
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
      ],
    );
  }
}