import 'package:flutter/material.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/data/book_creator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dotted_border/dotted_border.dart';  // Add this import at the top

class AddBookScreen extends StatefulWidget {
  final VoidCallback onBackPressed;
  final String languageCode;

  const AddBookScreen({
    super.key, 
    required this.onBackPressed, 
    required this.languageCode
  });

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final TextEditingController textController = TextEditingController();
  bool isFileMode = true; // Changed to true to show file section first
  String? selectedFilePath;

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'pdf', 'srt'],
    );

    if (result != null) {
      setState(() {
        selectedFilePath = result.files.single.path;
      });
    }
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            if (!isFileMode) {
              setState(() {
                isFileMode = true;
              });
            }
          },
          child: Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFileMode ? const Color(0xFF2C73DE) : Colors.grey,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            if (isFileMode) {
              setState(() {
                isFileMode = false;
              });
            }
          },
          child: Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: !isFileMode ? const Color(0xFF2C73DE) : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedSection() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        // Determine slide direction based on mode change
        final bool slideLeft = child.key == const ValueKey('file');
        
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(slideLeft ? -1.0 : 1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );
      },
      child: isFileMode
          ? _buildFileSelector().copyWith(key: const ValueKey('file'))
          : _buildTextInput().copyWith(key: const ValueKey('text')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(bottom: p.standardPadding() * 2),
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
                      const Text('Add your own!', 
                        style: TextStyle(fontSize: 24, fontFamily: "Unbounded")),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(p.standardPadding()),
                          child: _buildAnimatedSection(),
                        ),
                      ),
                      Column(
                        children: [
                          _buildPageIndicator(), // Add page indicator
                          SizedBox(height: p.standardPadding()), // Add spacing
                          SizedBox(
                            height: p.sidebarButtonWidth(),
                            child: ElevatedButton(
                              onPressed: () {
                                BookCreator().processBook(
                                  textController.text,
                                  widget.languageCode,
                                );
                                widget.onBackPressed();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2C73DE),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                "Start learning!",
                                style: TextStyle(
                                  fontFamily: "Telex", 
                                  fontSize: 30, 
                                  color: Colors.white
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: IconButton(
                  onPressed: widget.onBackPressed, 
                  icon: const Icon(Icons.close)
                ),
              ),
              Positioned(
                top: p.createCourseHeight() / 3,
                left: isFileMode ? null : 0, // Show on left when in text mode
                right: isFileMode ? 0 : null, // Show on right when in file mode
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      isFileMode = !isFileMode;
                    });
                  },
                  icon: Icon(
                    isFileMode 
                      ? Icons.keyboard_arrow_right  // Changed direction
                      : Icons.keyboard_arrow_left
                  ),
                  iconSize: 40,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextInput() {
    return TextField(
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
    );
  }

  Widget _buildFileSelector() {
    return DottedBorder(
      color: Colors.grey,
      strokeWidth: 2,
      borderType: BorderType.RRect,
      radius: const Radius.circular(10),
      padding: EdgeInsets.zero,
      dashPattern: const [12, 4],
      child: Container(
        width: double.infinity,  // Makes container take full available width
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: pickFile,
            borderRadius: BorderRadius.circular(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.upload_file,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Add files (.txt .pdf .srt)',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                if (selectedFilePath != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      'Selected file: ${selectedFilePath!.split('\\').last}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension WidgetExtension on Widget {
  Widget copyWith({Key? key}) => Container(key: key, child: this);
}