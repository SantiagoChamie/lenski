import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lenski/utils/languages/language_flags.dart';
import 'package:lenski/utils/proportions.dart';
import 'package:lenski/widgets/flag_icon.dart';
import 'package:lenski/utils/languages/languages.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lenski/utils/colors.dart';
import 'package:lenski/utils/fonts.dart';

/// A button widget for selecting a language.
///
/// This component displays a button with a flag icon and language name that opens
/// a dialog of available languages when pressed.
///
/// Features:
/// - Visual indication of the currently selected language with flag
/// - Source/target language distinction with appropriate tooltips
/// - Persistent storage of user's flag selection preferences
/// - Customizable appearance with support for different language lists
class LanguageSelectorButton extends StatefulWidget {
  /// Callback function triggered when a language is selected
  final Function(String, String, String) onLanguageSelected;
  
  /// The initial language to display on the button
  final String startingLanguage;
  
  /// Whether this is a source language (what you know) or target language (what you're learning)
  final bool isSource;
  
  /// The title displayed at the top of the language selector dialog
  final String selectorTitle;
  
  /// Whether to hide the explanatory tooltip
  final bool hideTooltip;

  /// Creates a LanguageSelectorButton widget.
  /// 
  /// [onLanguageSelected] is the callback function to be called when a language is selected.
  /// It receives the language name, flag URL, and language code.
  /// 
  /// [startingLanguage] is the initial language to be displayed.
  /// 
  /// [isSource] determines if it's a 'from' language (what you know) or target language (what you're learning).
  /// Defaults to true.
  /// 
  /// [selectorTitle] is the title of the language selector dialog.
  /// 
  /// [hideTooltip] determines if the tooltip should be hidden. Defaults to false.
  const LanguageSelectorButton({
    super.key,
    required this.onLanguageSelected,
    this.startingLanguage = 'English',
    this.isSource = true,
    this.selectorTitle = 'Select a Language',
    this.hideTooltip = false,
  });

  @override
  _LanguageSelectorButtonState createState() => _LanguageSelectorButtonState();
}

/// Contains the state for the language selector button
class _LanguageSelectorButtonState extends State<LanguageSelectorButton> {
  /// The currently selected language
  late String _selectedLanguage;
  
  /// Index of the selected flag variant for the current language
  int _selectedFlagIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.startingLanguage;
    _loadSavedFlagIndex();
  }

  /// Loads the user's preferred flag variant for the selected language.
  ///
  /// This retrieves the saved flag index from SharedPreferences,
  /// falling back to 0 if none is saved.
  Future<void> _loadSavedFlagIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {  // Check if widget is still mounted
      setState(() {
        _selectedFlagIndex = prefs.getInt('flag_$_selectedLanguage') ?? 0;
      });
    }
  }

  /// Displays a dialog for selecting a language.
  ///
  /// The dialog shows a list of available languages based on whether
  /// this is a source or target language selector.
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
                      fontFamily: appFonts['Subtitle'],
                      color: AppColors.black,
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
                          color: isSelected ? AppColors.lightGrey : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () async {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              var currentIndex = prefs.getInt('flag_$language') ?? 0;
                              setState(() { 
                                _selectedLanguage = language;
                                _selectedFlagIndex = currentIndex;  // Update the flag index
                              });
                              widget.onLanguageSelected(
                                language,
                                languageFlags[language]![currentIndex],
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
                                      fontFamily: appFonts['Paragraph'],
                                      color: AppColors.black,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  if (isSelected) ...[
                                    const Spacer(),
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: AppColors.blue,
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
    final localizations = AppLocalizations.of(context)!;
    
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), 
        ),
        fixedSize: Size(p.createCourseButtonWidth(), p.createCourseButtonHeight()),
        backgroundColor: Colors.white, // Keep as is (UI element color)
        overlayColor: Colors.transparent // Keep as is (UI element color)
      ),
      onPressed: () => _showLanguageSelector(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FlagIcon(
            size: 30,
            borderWidth: 0,
            language: _selectedLanguage,
            key: ValueKey('$_selectedLanguage-$_selectedFlagIndex'),  // Add a key to force rebuild
          ),
          const SizedBox(width: 8), // Space between flag icon and text
          Text(
            _selectedLanguage, 
            style: TextStyle(
              fontSize: 20, 
              fontFamily: appFonts['Paragraph'], 
              color: AppColors.black
            )
          ), 
          const SizedBox(width: 8), // Space between text and icon
          if (!widget.isSource && !widget.hideTooltip) // Show tooltip only if not a source language
            Tooltip(
              message: localizations.languageYouKnowTooltip,
              child: const Icon(Icons.help_outline, color: AppColors.darkGrey),
            ),
          if (widget.isSource && !widget.hideTooltip) // Show tooltip only if it's a source language
            Tooltip(
              message: localizations.languageToLearnTooltip,
              child: const Icon(Icons.help_outline, color: AppColors.darkGrey),
            ),
          const Spacer(),
          const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.black), // Icon on the right
        ],
      ),
    );
  }
}