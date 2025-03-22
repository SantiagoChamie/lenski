import 'package:flutter/material.dart';
import 'package:lenski/models/course_model.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/data/card_repository.dart';
import 'package:lenski/models/card_model.dart' as card_model;
import 'package:lenski/services/translation_service.dart';

/// A screen for adding a new card to the course.
class AddCardScreen extends StatelessWidget {
  final VoidCallback onBackPressed;
  final Course course;

  /// Creates an AddCardScreen widget.
  /// 
  /// [onBackPressed] is the callback function to be called when the back button is pressed.
  /// [course] is the course for which the card is being added.
  const AddCardScreen({super.key, required this.onBackPressed, required this.course});

  @override
  Widget build(BuildContext context) {
    final TextEditingController frontController = TextEditingController();
    final TextEditingController backController = TextEditingController();
    final TextEditingController contextController = TextEditingController();
    final p = Proportions(context);

    return Stack(
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
                const Text('Add a new card!', style: TextStyle(fontSize: 24, fontFamily: "Unbounded")),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(p.standardPadding()),
                    child: Column(
                      children: [
                        TextField(
                          controller: frontController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Front text',
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
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Back text',
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                                  ),
                                ),
                                maxLines: 1,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.translate),
                              onPressed: () async {
                                final translatedText = await TranslationService().translate(
                                  text: frontController.text,
                                  sourceLang: course.code,
                                  targetLang: course.fromCode,
                                  context: contextController.text,
                                );
                                backController.text = translatedText;
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: p.standardPadding()),
                        Expanded(
                          child: TextField(
                            controller: contextController,
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
                      ],
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
                      } else if (contextController.text != '' && !contextController.text.contains(frontController.text)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('The context must include the front text')),
                        );
                        return;
                      }

                      final newCard = card_model.Card(
                        front: frontController.text,
                        back: backController.text,
                        context: contextController.text == '' ? frontController.text : contextController.text,
                        dueDate: DateTime.now(),
                        language: course.code,
                      );
        
                      await CardRepository().insertCard(newCard);
                      onBackPressed();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C73DE),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Add card!",
                      style: TextStyle(fontFamily: "Telex", fontSize: 30, color: Colors.white),
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
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: onBackPressed,
          ),
        ),
      ]
    );
  }
}