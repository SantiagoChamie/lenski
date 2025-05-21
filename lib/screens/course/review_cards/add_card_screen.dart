import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lenski/models/course_model.dart';
import 'package:lenski/screens/home/competences/competence_icon.dart';
import 'package:lenski/utils/fonts.dart';
import 'package:lenski/utils/colors.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/data/card_repository.dart';
import 'package:lenski/data/session_repository.dart';
import 'package:lenski/models/card_model.dart' as card_model;
import 'package:lenski/services/translation_service.dart';

/// A screen for adding a new card to the course.
///
/// This component provides an interface for creating new flashcards with:
/// - Front text (the word or phrase to learn)
/// - Back text (the translation)
/// - Context (an example sentence containing the word)
/// - Selection of competence types (reading, writing, listening, speaking)
///
/// The screen includes a translation button to automatically translate
/// from target language to source language, and validates input before
/// allowing card creation.
class AddCardScreen extends StatefulWidget {
  /// Callback function to return to previous screen
  final VoidCallback onBackPressed;
  
  /// The course for which cards are being added
  final Course course;
  
  /// Optional callback when a card is successfully added
  final VoidCallback? onCardAdded;

  /// Creates an AddCardScreen widget.
  /// 
  /// [onBackPressed] is called when user wants to exit the add card screen.
  /// [course] is the course for which cards are being added.
  /// [onCardAdded] is called when a card is successfully added.
  const AddCardScreen({
    super.key, 
    required this.onBackPressed, 
    required this.course,
    this.onCardAdded,
  });

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  /// Controller for the front (word to learn) text field
  final TextEditingController frontController = TextEditingController();
  
  /// Controller for the back (translation) text field
  final TextEditingController backController = TextEditingController();
  
  /// Controller for the context (example sentence) text field
  final TextEditingController contextController = TextEditingController();
  
  /// Focus node for keyboard events
  final FocusNode _keyboardFocusNode = FocusNode();
  
  /// Map of selected competences for the card
  late final Map<String, bool> selectedCompetences;
  
  /// Gets the localized tooltip text for a specific competence.
  ///
  /// @param type The competence type identifier ('reading', 'writing', etc)
  /// @return A localized string describing the competence
  String _getCompetenceTooltip(String type) {
    final localizations = AppLocalizations.of(context)!;
    
    switch (type) {
      case 'reading':
        return localizations.readingCompetence;
      case 'listening':
        return localizations.listeningCompetence;
      case 'writing':
        return localizations.writingCompetence;
      case 'speaking':
        return localizations.speakingCompetence;
      default:
        return type;
    }
  }
  
  @override
  void initState() {
    super.initState();
    
    // Initialize competences from the course model
    selectedCompetences = {
      'reading': widget.course.reading,
      'writing': widget.course.writing, 
      'listening': widget.course.listening,
      'speaking': widget.course.speaking,
    };
    
    // Ensure at least one competence is selected
    if (!selectedCompetences.values.contains(true)) {
      selectedCompetences['reading'] = true; // Default to reading if nothing is enabled
    }
    
    // Request focus when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _keyboardFocusNode.requestFocus();
    });
  }
  
  @override
  void dispose() {
    frontController.dispose();
    backController.dispose();
    contextController.dispose();
    _keyboardFocusNode.dispose(); // Dispose the focus node
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    final localizations = AppLocalizations.of(context)!;

    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      onKeyEvent: (KeyEvent event) {
        // Only process KeyDownEvent
        if (event is KeyDownEvent) {
          // Check for Escape key or Space key
          if (event.logicalKey == LogicalKeyboardKey.escape || 
              event.logicalKey == LogicalKeyboardKey.space) {
            widget.onBackPressed();
          }
        }
      },
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(
              bottom: p.standardPadding() * 2, 
              left: p.standardPadding() * 2, 
              right: p.standardPadding() * 2
            ),
            width: p.mainScreenWidth() / 2 - p.standardPadding() * 4,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(5.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38, // Keep as is for shadow
                  blurRadius: 4.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(p.standardPadding() * 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(p.standardPadding()),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          textSelectionTheme: TextSelectionThemeData(
                            selectionColor: AppColors.lightBlue,
                            cursorColor: Colors.black54, // Keep as is for cursor color
                          ),
                        ),
                        child: Column(
                          children: [
                            TextField(
                              controller: frontController,
                              style: TextStyle(fontFamily: appFonts['Detail']),
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                hintText: localizations.frontCardLabel,
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: AppColors.blue, width: 2.0),
                                ),
                              ),
                              maxLines: 1,
                            ),
                            SizedBox(height: p.standardPadding()),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: backController,
                                    style: TextStyle(fontFamily: appFonts['Detail']),
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      hintText: localizations.backCardLabel,
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: AppColors.blue, width: 2.0),
                                      ),
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                                Tooltip(
                                  message: localizations.translateTextTooltip,
                                  child: IconButton(
                                    icon: const Icon(Icons.translate),
                                    onPressed: () async {
                                      final translatedText = await TranslationService().translate(
                                        text: frontController.text,
                                        sourceLang: widget.course.code,
                                        targetLang: widget.course.fromCode,
                                        context: contextController.text,
                                      );
                                      backController.text = translatedText;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: p.standardPadding()),
                            Expanded(
                              child: TextField(
                                controller: contextController,
                                style: TextStyle(fontFamily: appFonts['Detail']),
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  hintText: localizations.contextOptional,
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: AppColors.blue, width: 2.0),
                                  ),
                                ),
                                maxLines: null,
                                expands: true,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: p.standardPadding()),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  for (final type in ['reading', 'writing', 'listening', 'speaking'])
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          // Allow toggling regardless of current selection
                                          selectedCompetences[type] = !selectedCompetences[type]!;
                                        });
                                      },
                                      child: Tooltip(
                                        message: _getCompetenceTooltip(type),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Opacity(
                                            opacity: selectedCompetences[type]! ? 1.0 : 0.3,
                                            child: CompetenceIcon(
                                              size: 40,
                                              type: type,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: p.sidebarButtonWidth(),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (frontController.text.isEmpty || backController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(localizations.fillFieldsMessage)),
                          );
                          return;
                        } else if (contextController.text != '' && 
                                 !contextController.text.toLowerCase().contains(frontController.text.toLowerCase())) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(localizations.contextMustIncludeFrontText)),
                          );
                          return;
                        } else if (!selectedCompetences.values.contains(true)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(localizations.noCompetenceError)),
                          );
                          return;
                        }

                        // If case doesn't match, make it match
                        if (contextController.text != '' && !contextController.text.contains(frontController.text)) {
                          frontController.text = frontController.text.toLowerCase();
                        }

                        // Define the order of card types
                        const typeOrder = ['reading', 'listening', 'writing', 'speaking'];
                        
                        // Get selected types and sort them according to the defined order
                        final selectedTypes = selectedCompetences.entries
                            .where((e) => e.value)
                            .map((e) => e.key)
                            .toList()
                          ..sort((a, b) => typeOrder.indexOf(a).compareTo(typeOrder.indexOf(b)));

                        // Create cards in sequence with different due dates
                        for (int i = 0; i < selectedTypes.length; i++) {
                          final dueDate = DateTime.now().add(Duration(days: i));
                          final card = card_model.Card(
                            front: frontController.text,
                            back: backController.text,
                            context: contextController.text == '' ? frontController.text : contextController.text,
                            dueDate: DateTime(dueDate.year, dueDate.month, dueDate.day),
                            type: selectedTypes[i],
                            language: widget.course.code,
                          );
                          await CardRepository().insertCard(card);
                        }
                        
                        // Update the session statistics - increment words added
                        await SessionRepository().updateSessionStats(
                          courseCode: widget.course.code,
                          wordsAdded: 1,
                        );

                        // Call the onCardAdded callback if provided
                        if (widget.onCardAdded != null) {
                          widget.onCardAdded!();
                        }

                        widget.onBackPressed();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        localizations.addCardButton,
                        style: TextStyle(
                          fontFamily: appFonts['Subtitle'], 
                          fontSize: 30, 
                          color: Colors.white // Keep as is for text color
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: p.standardPadding() * 2,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: widget.onBackPressed,
            ),
          ),
        ],
      ),
    );
  }
}