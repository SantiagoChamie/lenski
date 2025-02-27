import 'package:flutter/material.dart';

class LanguageSelectorButton extends StatefulWidget {
  const LanguageSelectorButton({super.key});

  @override
  _LanguageSelectorButtonState createState() => _LanguageSelectorButtonState();
}

class _LanguageSelectorButtonState extends State<LanguageSelectorButton> {
  String _selectedLanguage = 'Select Language';
  final List<String> _languages = ['English', 'Spanish', 'French', 'German', 'Chinese'];

  void _showLanguageSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select a Language'),
          content: SingleChildScrollView(
            child: ListBody(
              children: _languages.map((language) {
                return ListTile(
                  title: Text(language),
                  onTap: () {
                    setState(() {
                      _selectedLanguage = language;
                    });
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
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Rounded corners
        ),
      ),
      onPressed: () => _showLanguageSelector(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_selectedLanguage, style: const TextStyle(fontSize: 20, fontFamily: "Varela Round", color: Colors.black)), // Text on the left
          const SizedBox(width: 8), // Space between text and icon
          const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black), // Icon on the right
        ],
      ),
    );
  }
}