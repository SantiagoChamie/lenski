import 'package:flutter/material.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/screens/home/courses/flag_icon.dart';
import 'package:lenski/utils/languages.dart';

class LanguageSelectorButton extends StatefulWidget {
  final Function(String, String, String) onLanguageSelected;
  final String startingLanguage;
  final bool isSource; // New parameter to determine if it's a 'from' language

  const LanguageSelectorButton({
    super.key,
    required this.onLanguageSelected,
    this.startingLanguage = 'English',
    this.isSource = true, // Default to true
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

  void _showLanguageSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // TODO: make this a dropdown menu
        return AlertDialog(
          title: const Text('Select a Language'),
          content: SingleChildScrollView(
            child: ListBody(
              children: (widget.isSource ? sourceLanguages : targetLanguages).map((language) {
                return ListTile(
                  title: Text(language),
                  onTap: () {
                    setState(() {
                      _selectedLanguage = language;
                    });
                    widget.onLanguageSelected(language, languageFlags[language]!, languageCodes[language]!);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
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
            imageUrl: languageFlags[_selectedLanguage]!,
          ),
          const SizedBox(width: 8), // Space between flag icon and text
          Text(_selectedLanguage, style: const TextStyle(fontSize: 20, fontFamily: "Varela Round", color: Colors.black)), // Text on the left
          const SizedBox(width: 8), // Space between text and icon
          const Spacer(),
          const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black), // Icon on the right
        ],
      ),
    );
  }
}