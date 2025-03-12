import 'package:flutter/material.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/data/book_creator.dart';

/// A screen for adding a new book to the course.
class AddBookScreen extends StatelessWidget {
  final VoidCallback onBackPressed;
  final String languageCode;

  /// Creates an AddBookScreen widget.
  /// 
  /// [onBackPressed] is the callback function to be called when the back button is pressed.
  /// [languageCode] is the language code for the book being added.
  const AddBookScreen({super.key, required this.onBackPressed, required this.languageCode});

  @override
  Widget build(BuildContext context) {
    final TextEditingController textController = TextEditingController();
    final p = Proportions(context);
    final ValueNotifier<bool> isSong = ValueNotifier<bool>(true);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(bottom: p.standardPadding() * 3),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F0F6),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 2,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                width: p.mainScreenWidth() - p.standardPadding() * 4,
                child: Padding(
                  padding: EdgeInsets.all(p.standardPadding() * 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Add your own!', style: TextStyle(fontSize: 24, fontFamily: "Unbounded")),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(p.standardPadding()),
                          child: TextField(
                            controller: textController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Paste the text here',
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue, width: 2.0),
                              ),
                            ),
                            maxLines: null,
                            expands: true,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: p.sidebarButtonWidth(),
                        child: ElevatedButton(
                          onPressed: () {
                            BookCreator().processBook(
                              textController.text,
                              languageCode,
                              isSong.value,
                            );
                            onBackPressed();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2C73DE),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Start learning!",
                            style: TextStyle(fontFamily: "Telex", fontSize: 30, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: IconButton(
                  onPressed: onBackPressed, 
                  icon: const Icon(Icons.close)),
              ),
              Positioned(
                bottom: 40,
                right: 40,
                child: ValueListenableBuilder<bool>(
                valueListenable: isSong,
                builder: (context, value, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Text'),
                      Switch(
                        value: value,
                        activeColor: const Color(0xFF2C73DE),
                        onChanged: (newValue) {
                          isSong.value = newValue;
                        },
                      ),
                      const Text('Song'),
                    ],
                  );
                },
              ),
              )
            ],
          ),
        ),
      ),
    );
  }
}