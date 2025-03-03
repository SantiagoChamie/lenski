import 'package:flutter/material.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/screens/home/courses/flag_icon.dart';

class LanguageSelectorButton extends StatefulWidget {
  const LanguageSelectorButton({super.key});

  @override
  _LanguageSelectorButtonState createState() => _LanguageSelectorButtonState();
}

class _LanguageSelectorButtonState extends State<LanguageSelectorButton> {
  String _selectedLanguage = 'English';
  //TODO: download fonts for non latin characters
  final List<String> _languages = ['English', 'Español', 'Français', 'Deutsche', '漢語'];
  final Map<String, String> _languageFlags = {
    'English': 'https://upload.wikimedia.org/wikipedia/en/thumb/a/ae/Flag_of_the_United_Kingdom.svg/640px-Flag_of_the_United_Kingdom.svg.png',
    'Español': 'https://upload.wikimedia.org/wikipedia/en/thumb/9/9a/Flag_of_Spain.svg/1920px-Flag_of_Spain.svg.png',
    'Français': 'https://upload.wikimedia.org/wikipedia/en/thumb/c/c3/Flag_of_France.svg/1920px-Flag_of_France.svg.png',
    'Deutsche': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/ba/Flag_of_Germany.svg/1200px-Flag_of_Germany.svg.png', 
    '漢語': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Flag_of_the_People%27s_Republic_of_China.svg/1200px-Flag_of_the_People%27s_Republic_of_China.svg.png',
  };

  void _showLanguageSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // TODO: make this a dropdown menu
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
            imageUrl: _languageFlags[_selectedLanguage]!,
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