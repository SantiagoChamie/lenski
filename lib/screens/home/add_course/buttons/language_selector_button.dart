import 'package:flutter/material.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/widgets/flag_icon.dart';
import 'package:lenski/utils/languages.dart';

/// A button widget for selecting a language.
class LanguageSelectorButton extends StatefulWidget {
  final Function(String, String, String) onLanguageSelected;
  final String startingLanguage;
  final bool isSource; // New parameter to determine if it's a 'from' language
  final String selectorTitle; // Add this new parameter

  /// Creates a LanguageSelectorButton widget.
  /// 
  /// [onLanguageSelected] is the callback function to be called when a language is selected.
  /// [startingLanguage] is the initial language to be displayed.
  /// [isSource] determines if it's a 'from' language. Defaults to true.
  /// [selectorTitle] is the title of the language selector dialog. Defaults to 'Select a Language'.
  const LanguageSelectorButton({
    super.key,
    required this.onLanguageSelected,
    this.startingLanguage = 'English',
    this.isSource = true, // Default to true
    this.selectorTitle = 'Select a Language', // Default value
  });

  @override
  _LanguageSelectorButtonState createState() => _LanguageSelectorButtonState();
}

/// Contains the information to create the course
class _LanguageSelectorButtonState extends State<LanguageSelectorButton> {
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.startingLanguage;
  }

  /// Displays a dialog for selecting a language.
  void _showLanguageSelector(BuildContext context) {
    final p = Proportions(context);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            width: p.createCourseButtonWidth() * 1.2,
            height: 400,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    widget.selectorTitle,
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: "Telex",
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: (widget.isSource ? sourceLanguages : targetLanguages).length,
                    itemBuilder: (context, index) {
                      final language = (widget.isSource ? sourceLanguages : targetLanguages)[index];
                      final isSelected = language == _selectedLanguage;
                      
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Material(
                          color: isSelected ? const Color(0xFFF5F0F6) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              setState(() {
                                _selectedLanguage = language;
                              });
                              widget.onLanguageSelected(
                                language,
                                languageFlags[language]!,
                                languageCodes[language]!
                              );
                              Navigator.of(context).pop();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  FlagIcon(
                                    size: 30,
                                    borderWidth: 0,
                                    language: language,
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    language,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: "Varela Round",
                                      color: Colors.black,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  if (isSelected) ...[
                                    const Spacer(),
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: Color(0xFF2C73DE),
                                      size: 24,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = Proportions(context);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), 
        ),
        fixedSize: Size(p.createCourseButtonWidth(), p.createCourseButtonHeight())
      ),
      onPressed: () => _showLanguageSelector(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FlagIcon(
            size: 30,
            borderWidth: 0,
            language: _selectedLanguage,
          ),
          const SizedBox(width: 8), // Space between flag icon and text
          Text(_selectedLanguage, style: const TextStyle(fontSize: 20, fontFamily: "Varela Round", color: Colors.black)), // Text on the left
          const SizedBox(width: 8), // Space between text and icon
          if (!widget.isSource) 
            Tooltip(
              message: "A language you already know.",
              child: Icon(Icons.help_outline, color: Colors.grey[600]),
            ),
          if (widget.isSource)
            Tooltip(
              message: "A language you want to learn.",
              child: Icon(Icons.help_outline, color: Colors.grey[600]),
            ),
          const Spacer(),
          const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black), // Icon on the right
        ],
      ),
    );
  }
}