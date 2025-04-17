import 'package:flutter/material.dart';
import 'package:lenski/models/course_model.dart';
import 'package:lenski/screens/home/competences/competence_icon.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/data/card_repository.dart';
import 'package:lenski/models/card_model.dart' as card_model;
import 'package:lenski/services/translation_service.dart';

/// A screen for adding a new card to the course.
class AddCardScreen extends StatefulWidget {
  final VoidCallback onBackPressed;
  final Course course;

  const AddCardScreen({
    super.key, 
    required this.onBackPressed, 
    required this.course
  });

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final TextEditingController frontController = TextEditingController();
  final TextEditingController backController = TextEditingController();
  final TextEditingController contextController = TextEditingController();
  
  // Track selected competences
  final Map<String, bool> selectedCompetences = {
    'reading': true,
    'writing': false,
    'listening': false,
    'speaking': false,
  };

  @override
  Widget build(BuildContext context) {
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
                          style: const TextStyle(fontFamily: "Sansation"),
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
                                style: const TextStyle(fontFamily: "Sansation"),
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
                                  sourceLang: widget.course.code,
                                  targetLang: widget.course.fromCode,
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
                            style: const TextStyle(fontFamily: "Sansation"),
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
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              for (final type in ['reading', 'writing', 'listening', 'speaking'])
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      // Only toggle if it's not the last selected competence
                                      if (selectedCompetences[type] == false || 
                                          selectedCompetences.values.where((e) => e).length > 1) {
                                        selectedCompetences[type] = !selectedCompetences[type]!;
                                      }
                                    });
                                  },
                                  child: Opacity(
                                    opacity: selectedCompetences[type]! ? 1.0 : 0.3,
                                    child: CompetenceIcon(
                                      size: 40,
                                      type: type,
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
                      }

                      //if case doesn't match, make it match
                      if (contextController.text != '' && !contextController.text.contains(frontController.text)){
                        frontController.text = frontController.text.toLowerCase();
                      }

                      // Create a card for each selected competence
                      for (final type in selectedCompetences.entries.where((e) => e.value)) {
                        final card = card_model.Card(
                          front: frontController.text,
                          back: backController.text,
                          context: contextController.text == '' ? frontController.text : contextController.text,
                          dueDate: DateTime.now(),
                          type: type.key,
                          language: widget.course.code,
                        );
                        await CardRepository().insertCard(card);
                      }
                      widget.onBackPressed();
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
            onPressed: widget.onBackPressed,
          ),
        ),
      ]
    );
  }
}