import 'package:flutter/material.dart';
import 'package:lenski/utils/proportions.dart';

class AddBookScreen extends StatelessWidget {
  final VoidCallback onBackPressed;

  const AddBookScreen({super.key, required this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
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
                  padding: EdgeInsets.all(p.standardPadding()*2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Add your own!', style: TextStyle(fontSize: 24, fontFamily: "Unbounded")),

                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(p.standardPadding()),
                          child: const TextField(
                            //TODO: fix style
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Paste the text here',
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                            ),
                            maxLines: null,
                            expands: true,
                          ),
                        ),
                      ),
                      
                      SizedBox(
                        height: p.sidebarButtonWidth(),
                        child: ElevatedButton(
                          onPressed: onBackPressed,
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
                )
                
            ],
          ),
        ),
      ),
    );
  }
}