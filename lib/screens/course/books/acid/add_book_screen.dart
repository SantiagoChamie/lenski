import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lenski/screens/course/books/acid/loading_overlay.dart';
import 'package:lenski/screens/course/books/acid/help_section_screen.dart';
import 'package:lenski/utils/fonts.dart';
import 'package:lenski/utils/languages.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/data/book_creator.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool isLoading = false;
  String? selectedFilePath;
  final BookCreator _bookCreator = BookCreator();
  bool? isFileMode;
  bool isHelpVisible = false;

  static const String _prefKey = 'last_used_file_mode';
  static const int animationDuration = 300;

  @override
  void initState() {
    super.initState();
    // For Arabic, always set to text mode
    if (widget.languageCode == 'AR') {
      isFileMode = false;
    } else {
      _loadLastUsedMode();
    }
  }

  Future<void> _loadLastUsedMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isFileMode = prefs.getBool(_prefKey) ?? true;
    });
  }

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
    // For Arabic, don't show the indicators
    if (widget.languageCode == 'AR') {
      return const SizedBox.shrink();
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => _switchMode(true),
          child: Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFileMode == true ? const Color(0xFF2C73DE) : Colors.grey,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _switchMode(false),
          child: Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFileMode == false ? const Color(0xFF2C73DE) : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedSection() {
    
    }

    // For Arabic, directly return text input
    if (widget.languageCode == 'AR') {
      return _buildTextInput();
    }


    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: animationDuration),
        transitionBuilder: (Widget child, Animation<double> animation) {
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
        child: isFileMode == true
            ? _buildFileSelector().copyWith(key: const ValueKey('file'))
            : _buildTextInput().copyWith(key: const ValueKey('text')),
      ),
    );
  }

  bool _hasText() {
    return isFileMode == true 
        ? selectedFilePath != null 
        : textController.text.trim().isNotEmpty;
  }

  void _toggleHelpSection() {
    setState(() {
      isHelpVisible = !isHelpVisible;
  void _switchMode(bool toFileMode) async {
    // For Arabic, don't allow mode switching
    if (widget.languageCode == 'AR') return;

    // If help section is visible, hide it when switching modes
    if (isHelpVisible) {
      setState(() {
        isHelpVisible = false;
      });
    }

    if (isFileMode != toFileMode) {
      setState(() {
        if (toFileMode) {
          textController.clear();
        } else {
          selectedFilePath = null;
        }
        isFileMode = toFileMode;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, toFileMode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);

    // Add null check for isFileMode
    if (isFileMode == null && widget.languageCode != 'AR') {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2C73DE)),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Center(
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Add your own texts!', 
                                style: TextStyle(fontSize: 24, fontFamily: "Unbounded")),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: IconButton(
                                  icon: Icon(
                                    isHelpVisible ? Icons.close : Icons.help_outline, 
                                    size: 20, 
                                    color: Colors.grey[600]
                                  ),
                                  onPressed: _toggleHelpSection,
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(p.standardPadding()),
                              child: _buildAnimatedSection(),
                            ),
                          ),
                          Column(
                            children: [
                              if (!isHelpVisible) _buildPageIndicator(),
                              SizedBox(height: p.standardPadding()),
                              SizedBox(
                                height: p.sidebarButtonWidth(),
                                child: ElevatedButton(
                                  onPressed: isLoading || isHelpVisible ? null : () async {
                                    if (!_hasText()) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Please add some text or file before creating a book'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                      return;
                                    }
                                    setState(() => isLoading = true);
                                    try {
                                      bool success;
                                      if (isFileMode == true) {
                                        success = await _bookCreator.processFile(
                                          selectedFilePath!, 
                                          widget.languageCode
                                        );
                                      } else {
                                        success = await _bookCreator.processBook(
                                          textController.text, 
                                          widget.languageCode
                                        );
                                      }
                                      
                                      if (!_bookCreator.isCancelled) {
                                        if (success) {
                                          widget.onBackPressed();
                                        } else {
                                          // Show dialog instead of SnackBar
                                          _showLanguageMismatchDialog(
                                            isFileMode == true ? selectedFilePath! : textController.text,
                                            isFileMode == true
                                          );
                                        }
                                      }
                                    } finally {
                                      if (!_bookCreator.isCancelled) {
                                        setState(() => isLoading = false);
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2C73DE),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    disabledBackgroundColor: Colors.grey[300],
                                    disabledForegroundColor: Colors.grey[600],
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
                    right: 10,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: isLoading ? null : () {
                        widget.onBackPressed();
                      },
                    ),
                  ),
                  if (!isHelpVisible && widget.languageCode != 'AR')
                    Positioned(
                      top: p.createCourseHeight() / 3,
                      left: isFileMode == true ? null : 0,
                      right: isFileMode == true ? 0 : null,
                      child: IconButton(
                        onPressed: () => _switchMode(!(isFileMode == true)),
                        icon: Icon(
                          isFileMode == true 
                            ? Icons.keyboard_arrow_right
                            : Icons.keyboard_arrow_left
                        ),
                        iconSize: 40,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isLoading)
            LoadingOverlay(
              onCancel: () {
                _bookCreator.cancelProcessing();
                setState(() => isLoading = false);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTextInput() {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: const TextSelectionThemeData(
          selectionColor: Color(0xFF71BDE0), // Light blue highlight
          cursorColor: Color(0xFF2C73DE),    // Blue cursor
        ),
      ),
      child: TextField(
        controller: textController,
        enabled: !isLoading,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Place the text here',
          floatingLabelBehavior: FloatingLabelBehavior.always,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF2C73DE), width: 2.0),
          ),
        ),
        maxLines: null,
        expands: true,
      ),
    );
  }

  // File selector widget
  Widget _buildFileSelector() {
    return Tooltip(
      message: 'Poor quality PDFs will not work properly.${(['JA', 'ZH', 'KO'].contains(widget.languageCode)) 
          ? '\n\nPDFs with vertical text (top to bottom) are not supported'
          : ''}',
      verticalOffset: 70,
      waitDuration: const Duration(milliseconds: 500),
      child: DottedBorder(
        color: Colors.grey,
        strokeWidth: 2,
        borderType: BorderType.RRect,
        radius: const Radius.circular(10),
        padding: EdgeInsets.zero,
        dashPattern: const [12, 4],
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isLoading ? null : pickFile,
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
      ),
    );
  }

  Future<void> _showLanguageMismatchDialog(String content, bool isFile) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Language Mismatch'),
          content: Text(
            'The text\'s language doesn\'t match the course\'s language: ${codeToLanguage[widget.languageCode]}'
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF71BDE0)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add Anyway',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() => isLoading = true);
                try {
                  // Force add the book by bypassing language check
                  if (isFile) {
                    await _bookCreator.forceAddFile(content, widget.languageCode);
                  } else {
                    await _bookCreator.forceAddBook(content, widget.languageCode);
                  }
                  if (!_bookCreator.isCancelled) {
                    widget.onBackPressed();
                  }
                } finally {
                  if (!_bookCreator.isCancelled) {
                    setState(() => isLoading = false);
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}

extension WidgetExtension on Widget {
  Widget copyWith({Key? key}) => Container(key: key, child: this);
}