import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Add localization
import 'package:lenski/models/course_model.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/data/card_repository.dart';
import 'package:lenski/utils/colors.dart'; // Add colors
import 'package:lenski/utils/fonts.dart'; // Add fonts
import 'dart:math';

/// A widget that displays a pile of review cards for a course.
///
/// Displays a preview of card fronts that are due for review and allows users to:
/// - See the number of cards to review
/// - Navigate to the review screen by tapping on the card
/// - Refresh to see a different card with keyboard shortcut 's'
/// - Start reviewing cards with keyboard shortcut 'r'
/// - Add new cards with a click or using the spacebar
class ReviewPile extends StatefulWidget {
  /// The course for which the review pile is being displayed
  final Course course;
  
  /// Callback function that is called when the "Add new card" button is pressed
  final VoidCallback? onNewPressed;

  /// Creates a ReviewPile widget.
  /// 
  /// [course] is the course for which the review pile is being created.
  /// [onNewPressed] is the callback function for adding new cards.
  const ReviewPile({super.key, required this.course, required this.onNewPressed});

  @override
  _ReviewPileState createState() => _ReviewPileState();
}

class _ReviewPileState extends State<ReviewPile> {
  String? displayText;
  List<String> cardFronts = [];
  bool _disposed = false;
  bool _isHovered = false;

  // Add focus node for keyboard events
  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fetchFirstWord();
    
    // Request focus when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _keyboardFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _keyboardFocusNode.dispose(); // Dispose the focus node
    super.dispose();
  }

  /// Fetches the first word to be displayed from the repository.
  ///
  /// Retrieves all cards due for review and randomly selects one to display.
  /// If no cards are available, displays a message indicating no cards remain.
  Future<void> _fetchFirstWord() async {
    if (_disposed) return;
    
    final repository = CardRepository();
    final cards = await repository.cards(DateTime.now(), widget.course.code);
    if (!mounted) return;

    setState(() {
      if (cards.isNotEmpty) {
        cardFronts = cards.map((card) => card.front).toList();
        cardFronts.shuffle(Random());
        displayText = cardFronts.first;
      } else {
        displayText = null; // Will show localized text in the build method
      }
    });
  }

  /// Refreshes the word being displayed to show a different card.
  ///
  /// Retrieves all cards and randomly selects a different one than
  /// the currently displayed card, if available.
  Future<void> _refreshWord() async {
    if (_disposed) return;
    if (cardFronts.isNotEmpty) {
      final repository = CardRepository();
      final cards = await repository.cards(DateTime.now(), widget.course.code);
      if (!mounted) return;

      setState(() {
        if (cards.isNotEmpty) {
          final newCardFronts = cards.map((card) => card.front).toList();
          final remainingCards = newCardFronts.where((card) => card != displayText).toList();
          if (remainingCards.isNotEmpty) {
            remainingCards.shuffle(Random());
            displayText = remainingCards.first;
          }
        }
      });
    } else {
      await _fetchFirstWord();
    }
  }

  /// Navigates to the screen for adding new cards.
  ///
  /// Calls the provided onNewPressed callback to trigger navigation.
  void _navigateToAddCardScreen() {
    widget.onNewPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    final localizations = AppLocalizations.of(context)!;

    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      onKeyEvent: (KeyEvent event) {
        // Only handle KeyDownEvent
        if (event is KeyDownEvent) {
          // 's' key for refreshing the word
          if (event.logicalKey == LogicalKeyboardKey.keyS) {
            _refreshWord();
          } else if (event.logicalKey == LogicalKeyboardKey.keyR) {
            final navigatorKey = Navigator.of(context).widget.key as GlobalKey<NavigatorState>;
            navigatorKey.currentState?.pushNamed(
              'Review',
              arguments: {
                'course': widget.course,
                'firstWord': displayText, // Pass the currently displayed word
              },
            );
          }
          // Space key for adding a new card
          else if (event.logicalKey == LogicalKeyboardKey.space) {
            if (widget.onNewPressed != null) {
              _navigateToAddCardScreen();
            }
          }
        }
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: () {
            final navigatorKey = Navigator.of(context).widget.key as GlobalKey<NavigatorState>;
            navigatorKey.currentState?.pushNamed(
              'Review',
              arguments: {
                'course': widget.course,
                'firstWord': displayText, // Pass the currently displayed word
              },
            );
          },
          child: Stack(
            children: [
              SizedBox(
                width: p.mainScreenWidth() / 2,
                height: double.infinity,
                child: Container(
                  margin: EdgeInsets.only(
                    bottom: p.standardPadding() * 2,
                    left: p.standardPadding() * 2,
                    right: p.standardPadding() * 2
                  ),
                  width: p.mainScreenWidth() / 2 - 40,
                  decoration: BoxDecoration(
                    color: _isHovered ? const Color(0xFFF8F4F9) : const Color(0xFFF5F0F6),
                    borderRadius: BorderRadius.circular(5.0),
                    boxShadow: [
                      BoxShadow(
                        color: _isHovered ? Colors.black45 : Colors.black38, // Kept as is for shadow effect
                        blurRadius: _isHovered ? 6.0 : 4.0,
                        offset: Offset(0, _isHovered ? 3 : 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              displayText ?? localizations.noNewCardsRemaining, // Localized text
                              style: TextStyle(
                                fontSize: 24, 
                                fontFamily: appFonts['Subtitle'],
                              ),
                            ),                      
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Text(
                            cardFronts.isEmpty 
                                ? '' 
                                : localizations.cardsToReview(cardFronts.length), // Localized with plural support
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: appFonts['Subtitle'],
                              color: AppColors.darkGrey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if(cardFronts.length > 1)
                Positioned(
                  top: 0,
                  left: 40,
                  child: IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _refreshWord,
                  ),
                ),
              Positioned(
                bottom: 60,
                right: 60,
                child: FloatingActionButton(
                  onPressed: _navigateToAddCardScreen,
                  hoverElevation: 0,
                  elevation: 0,
                  backgroundColor: AppColors.grey,
                  child: const Icon(Icons.add, color: AppColors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}