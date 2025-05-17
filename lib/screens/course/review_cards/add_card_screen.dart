import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lenski/models/course_model.dart';
import 'package:lenski/screens/home/competences/competence_icon.dart';
import 'package:lenski/utils/fonts.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/data/card_repository.dart';
import 'package:lenski/data/session_repository.dart';
import 'package:lenski/models/card_model.dart' as card_model;
import 'package:lenski/services/translation_service.dart';

/// A screen for adding a new card to the course.
class AddCardScreen extends StatefulWidget {
  final VoidCallback onBackPressed;
  final Course course;
  final VoidCallback? onCardAdded;

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
  final TextEditingController frontController = TextEditingController();
  final TextEditingController backController = TextEditingController();
  final TextEditingController contextController = TextEditingController();
  
  // Add focus node for keyboard events
  final FocusNode _keyboardFocusNode = FocusNode();
  
  // Use late initialization for the competences map
  late final Map<String, bool> selectedCompetences;
  
  // Helper method to get tooltip text for competences
  String _getCompetenceTooltip(String type) {
    switch (type) {
      case 'reading':
        return 'Reading';
      case 'listening':
        return 'Listening';
      case 'writing':
        return 'Writing';
      case 'speaking':
        return 'Speaking';
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

    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      onKeyEvent: (KeyEvent event) {
        // Only process KeyDownEvent
        if (event is KeyDownEvent) {
          // Check for Escape key
          if (event.logicalKey == LogicalKeyboardKey.escape || event.logicalKey == LogicalKeyboardKey.space) {
            widget.onBackPressed();
          }
        }
      },
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: p.standardPadding() * 2, left: p.standardPadding() * 2, right: p.standardPadding() * 2),
            width: p.mainScreenWidth() / 2 - p.standardPadding() * 4,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F0F6),
              borderRadius: BorderRadius.circular(5.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
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
                          textSelectionTheme: const TextSelectionThemeData(
                            selectionColor: Color(0xFF71BDE0),
                            cursorColor: Colors.black54,   
                          ),
                        ),
                        child: Column(
                          children: [
                            TextField(
                              controller: frontController,
                              style: TextStyle(fontFamily: appFonts['Detail']),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Front (word to learn)',
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
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
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: 'Back (translation)',
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                                      ),
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                                Tooltip(
                                  message: 'Translate front text',
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
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Context (optional)',
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
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
                            const SnackBar(content: Text('Fill in the front and back fields to create a card')),
                          );
                          return;
                        } else if (contextController.text != '' && !contextController.text.toLowerCase().contains(frontController.text.toLowerCase())) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('The context must include the front text')),
                          );
                          return;
                        } else if (!selectedCompetences.values.contains(true)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Select at least one competence for your card')),
                          );
                          return;
                        }

                        //if case doesn't match, make it match
                        if (contextController.text != '' && !contextController.text.contains(frontController.text)){
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
                        backgroundColor: const Color(0xFF2C73DE),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Add card!",
                        style: TextStyle(fontFamily: appFonts['Subtitle'], fontSize: 30, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: p.standardPadding()*2,
            child: Tooltip(
              message: 'Close',
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onBackPressed,
              ),
            ),
          ),
        ]
      ),
    );
  }
}