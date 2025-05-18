import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lenski/screens/course/books/acid/loading_overlay.dart';
import 'package:lenski/screens/course/books/acid/help_section_screen.dart';
import 'package:lenski/utils/fonts.dart';
import 'package:lenski/utils/colors.dart';
import 'package:lenski/utils/languages/languages.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/data/book_creator.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

/// A screen for adding new books to a language course.
///
/// This component allows users to add custom text content as books by:
/// - Directly pasting text
/// - Uploading text files (.txt, .pdf, .srt)
/// - Setting options for content processing (like sentence shuffling)
class AddBookScreen extends StatefulWidget {
  /// Callback function to return to the previous screen
  final VoidCallback onBackPressed;
  
  /// The language code of the course
  final String languageCode;

  /// Creates an AddBookScreen widget.
  /// 
  /// [onBackPressed] is the callback function to be called when the back button is pressed.
  /// [languageCode] is the code of the language for which to create the book.
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
  bool isShuffleEnabled = false; 
  
  // Add a focus node for keyboard events
  final FocusNode _keyboardFocusNode = FocusNode();

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
    
    // Request focus when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _keyboardFocusNode.requestFocus();
    });
  }
  
  @override
  void dispose() {
    _keyboardFocusNode.dispose(); // Dispose the focus node
    super.dispose();
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
              color: isFileMode == true ? AppColors.blue : AppColors.grey,
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
              color: isFileMode == false ? AppColors.blue : AppColors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedSection() {
    
    // If help is visible, show help section instead of input methods
    if (isHelpVisible) {
      return const HelpSectionScreen();
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
    });
  }

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
    final localizations = AppLocalizations.of(context)!;

    // Add null check for isFileMode
    if (isFileMode == null && widget.languageCode != 'AR') {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue),
        ),
      );
    }

    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      onKeyEvent: (KeyEvent event) {
        // Only process KeyDownEvent
        if (event is KeyDownEvent) {
          // Check for Escape key
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            // Don't allow closing if loading is in progress
            if (!isLoading) {
              widget.onBackPressed();
            }
          }
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: p.standardPadding() * 2),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12, // Keep as is for shadow
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
                                Text(
                                  localizations.addYourOwnTexts,
                                  style: TextStyle(
                                    fontSize: 24, 
                                    fontFamily: appFonts['Title']
                                  ),
                                ),
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Main start learning button with proper width constraint
                                    SizedBox(
                                      width: 300,
                                      height: p.sidebarButtonWidth(),
                                      child: ElevatedButton(
                                        onPressed: isLoading || isHelpVisible ? null : () async {
                                          if (!_hasText()) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(localizations.pleaseAddTextOrFile),
                                                duration: const Duration(seconds: 2),
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
                                                widget.languageCode,
                                                shuffleSentences: isShuffleEnabled,
                                              );
                                            } else {
                                              success = await _bookCreator.processBook(
                                                textController.text, 
                                                widget.languageCode,
                                                shuffleSentences: isShuffleEnabled,
                                              );
                                            }
                                            
                                            if (!_bookCreator.isCancelled) {
                                              if (success) {
                                                widget.onBackPressed();
                                              } else {
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
                                          backgroundColor: AppColors.blue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          disabledBackgroundColor: Colors.grey[300],
                                          disabledForegroundColor: Colors.grey[600],
                                        ),
                                        child: Text(
                                          localizations.startLearningButton,
                                          style: TextStyle(
                                            fontFamily: appFonts['Subtitle'], 
                                            fontSize: 30, 
                                            color: Colors.white
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Shuffle toggle button with improved tooltip
                                    Container(
                                      height: p.sidebarButtonWidth(),
                                      margin: const EdgeInsets.only(left: 8),
                                      child: Tooltip(
                                        message: isShuffleEnabled 
                                            ? localizations.randomSentences 
                                            : localizations.realSentences,
                                        verticalOffset: -40,
                                        waitDuration: const Duration(milliseconds: 500),
                                        preferBelow: false,
                                        child: ElevatedButton(
                                          onPressed: isLoading || isHelpVisible ? null : () {
                                            setState(() {
                                              isShuffleEnabled = !isShuffleEnabled;
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isShuffleEnabled 
                                                ? AppColors.lightBlue // Light blue when active
                                                : Colors.grey[300], // Grey when inactive
                                            shape: const CircleBorder(),
                                            padding: const EdgeInsets.all(16),
                                            disabledBackgroundColor: Colors.grey[200],
                                            disabledForegroundColor: Colors.grey[400],
                                          ),
                                          child: Icon(
                                            isShuffleEnabled ? Icons.shuffle : Icons.format_list_numbered,
                                            color: isShuffleEnabled ? Colors.white : Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
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
      ),
    );
  }

  Widget _buildTextInput() {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: AppColors.lightBlue,
          cursorColor: AppColors.blue,
        ),
      ),
      child: TextField(
        controller: textController,
        enabled: !isLoading,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: AppLocalizations.of(context)!.placeTextHere,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.blue, width: 2.0),
          ),
        ),
        maxLines: null,
        expands: true,
      ),
    );
  }

  // File selector widget
  Widget _buildFileSelector() {
    final localizations = AppLocalizations.of(context)!;
    final bool isAsianLanguage = ['JA', 'ZH', 'KO'].contains(widget.languageCode);
    
    return Tooltip(
      message: '${localizations.poorQualityPdfWarning}${isAsianLanguage 
          ? '\n\n${localizations.verticalTextPdfWarning}'
          : ''}',
      verticalOffset: 70,
      waitDuration: const Duration(milliseconds: 500),
      child: DottedBorder(
        color: Colors.grey, // Keep the original Colors.grey instead of AppColors.grey
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
                    color: Colors.grey, // Keep the original Colors.grey
                  ),
                  const SizedBox(height: 16),
                  Text(
                   localizations.addFilesTypes,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey, // Keep the original Colors.grey
                      fontFamily: appFonts['Paragraph'],
                    ),
                  ),
                  if (selectedFilePath != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        '${localizations.selectedFile}: ${selectedFilePath!.split('\\').last}',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: appFonts['Paragraph'],
                        ),
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
    final localizations = AppLocalizations.of(context)!;
    
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            localizations.languageMismatchTitle,
            style: TextStyle(
              fontFamily: appFonts['Subtitle'],
            ),
          ),
          content: Text(
            '${localizations.languageMismatchContent} ${codeToLanguage[widget.languageCode]}',
            style: TextStyle(
              fontFamily: appFonts['Paragraph'],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                localizations.cancel,
                style: TextStyle(
                  color: AppColors.lightBlue,
                  fontFamily: appFonts['Detail'],
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                localizations.addAnyway,
                style: TextStyle(
                  color: AppColors.error,
                  fontFamily: appFonts['Detail'],
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() => isLoading = true);
                try {
                  // Force add the book by bypassing language check
                  if (isFile) {
                    await _bookCreator.forceAddFile(
                      content, 
                      widget.languageCode,
                      shuffleSentences: isShuffleEnabled,
                    );
                  } else {
                    await _bookCreator.forceAddBook(
                      content, 
                      widget.languageCode,
                      shuffleSentences: isShuffleEnabled,
                    );
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