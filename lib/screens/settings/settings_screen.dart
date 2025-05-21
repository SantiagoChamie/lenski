import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../data/migration_handler.dart';
import '../../utils/colors.dart';
import '../../utils/fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A screen that allows the user to configure settings for the app.
///
/// This screen provides controls for:
/// - API configuration (DeepL API key, premium API toggle)
/// - Translation settings (contextual translation toggle)
/// - Display preferences (streak indicators, colored competence cards)
/// - Data management (import and export functionality)
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  /// Controller for the API key text field
  final TextEditingController _apiKeyController = TextEditingController();
  
  /// Whether contextual translation is enabled
  bool _contextualTranslationEnabled = false;
  
  /// Whether premium DeepL API is enabled
  bool _premiumApiEnabled = false;
  
  /// Whether streak indicators are shown on courses
  bool _streakIndicatorEnabled = true;
  
  /// Whether competence cards are colored
  bool _coloredCompetenceCards = true;

  /// Handler for importing and exporting app data
  final MigrationHandler _migrationHandler = MigrationHandler();
  
  /// Whether data is currently being exported
  bool _isExporting = false;
  
  /// Whether data is currently being imported
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
    _loadContextualTranslationSetting();
    _loadPremiumApiSetting();
    _loadStreakIndicatorSetting();
    _loadColoredCompetenceCardsSetting();
  }

  /// Loads the saved API key from shared preferences and sets it in the text controller.
  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiKeyController.text = prefs.getString('deepl_api_key') ?? '';
    });
  }

  /// Saves the API key entered by the user to shared preferences.
  Future<void> _saveApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('deepl_api_key', _apiKeyController.text);
  }

  /// Loads the contextual translation setting from shared preferences
  Future<void> _loadContextualTranslationSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _contextualTranslationEnabled = prefs.getBool('contextual_translation_enabled') ?? false;
    });
  }

  /// Saves the contextual translation setting to shared preferences
  Future<void> _saveContextualTranslationSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('contextual_translation_enabled', value);
    setState(() {
      _contextualTranslationEnabled = value;
    });
  }

  /// Loads the premium API setting from shared preferences
  Future<void> _loadPremiumApiSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _premiumApiEnabled = prefs.getBool('premium_api_enabled') ?? false;
    });
  }

  /// Saves the premium API setting to shared preferences
  Future<void> _savePremiumApiSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('premium_api_enabled', value);
    setState(() {
      _premiumApiEnabled = value;
    });
  }

  /// Loads the streak indicator setting from shared preferences
  Future<void> _loadStreakIndicatorSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _streakIndicatorEnabled = prefs.getBool('streak_indicator_enabled') ?? true;
    });
  }

  /// Saves the streak indicator setting to shared preferences
  Future<void> _saveStreakIndicatorSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('streak_indicator_enabled', value);
    setState(() {
      _streakIndicatorEnabled = value;
    });
  }

  /// Loads the colored competence cards setting from shared preferences
  Future<void> _loadColoredCompetenceCardsSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _coloredCompetenceCards = prefs.getBool('colored_competence_cards') ?? true;
    });
  }

  /// Saves the colored competence cards setting to shared preferences
  Future<void> _saveColoredCompetenceCardsSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('colored_competence_cards', value);
    setState(() {
      _coloredCompetenceCards = value;
    });
  }

  /// Handles file picking and importing data.
  ///
  /// Shows a confirmation dialog before importing, then lets the user select a file.
  /// After importing, shows a success or error message.
  Future<void> _importFile() async {
    // Show confirmation dialog first
    final localizations = AppLocalizations.of(context)!;
    final String? confirmation = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            localizations.warningTitle,
            style: TextStyle(
              fontSize: 24,
              fontFamily: appFonts['Title'],
            ),
          ),
          content: Text(
            localizations.warningMessage,
            style: TextStyle(
              fontSize: 16,
              fontFamily: appFonts['Paragraph'],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop('cancel'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.blue,
                textStyle: TextStyle(
                  fontSize: 14,
                  fontFamily: appFonts['Detail'],
                ),
              ),
              child: Text(localizations.cancel),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
                textStyle: TextStyle(
                  fontSize: 14,
                  fontFamily: appFonts['Detail'],
                ),
              ),
              onPressed: () => Navigator.of(context).pop('import'),
              child: Text(localizations.importAndReplace),
            ),
          ],
        );
      },
    );

    // If user didn't confirm, exit early
    if (confirmation != 'import') {
      return;
    }

    try {
      setState(() {
        _isImporting = true; // Show loading indicator
      });

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final path = result.files.single.path;
        if (path != null) {
          // Call the importData method from MigrationHandler
          final migrationResult = await _migrationHandler.importData(path);

          // Show result to the user
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(migrationResult.success
                  ? localizations.importSuccess
                  : localizations.importFailed(migrationResult.message!)),
              backgroundColor: migrationResult.success ? 
                (AppColors.success) : 
                (AppColors.error),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.importFailed(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false; // Hide loading indicator
        });
      }
    }
  }

  /// Exports app data to a file at user-selected location.
  ///
  /// Generates export data, then lets the user choose where to save it.
  /// Shows success or error messages after export completes.
  Future<void> _exportFile() async {
    final localizations = AppLocalizations.of(context)!;
    try {
      setState(() {
        _isExporting = true; // Show loading indicator
      });

      // First generate the export data
      final migrationResult = await _migrationHandler.exportData();

      if (!migrationResult.success || migrationResult.filePath == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.importFailed(migrationResult.message!)),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      
      // Now let the user pick where to save the file
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save your Lenski data file',
        fileName: 'lenski_export_${DateTime.now().day}_${DateTime.now().month}_${DateTime.now().year}.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (outputPath != null) {
        // Copy the generated file to user's chosen location
        final sourceFile = File(migrationResult.filePath!);
        await sourceFile.copy(outputPath);
        
        // Delete the temporary file
        await sourceFile.delete();

        // Show success message with chosen path
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${localizations.exportSuccess} $outputPath"),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        // User cancelled, delete the temporary file
        final sourceFile = File(migrationResult.filePath!);
        await sourceFile.delete();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.importFailed(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false; // Hide loading indicator
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: const TextSelectionThemeData(
              selectionColor: AppColors.lightYellow,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.apiKeys,
                        style: TextStyle(
                          fontSize: 24, 
                          fontWeight: FontWeight.bold, 
                          fontFamily: appFonts['Subtitle']
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _apiKeyController,
                              obscureText: true,
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                labelText: localizations.deeplApiKey,
                                labelStyle: TextStyle(
                                  fontFamily: appFonts['Detail'], 
                                  color: Colors.black
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _saveApiKey,
                            child: Text(
                              localizations.saveApiKey,
                              style: TextStyle(
                                color: AppColors.blue,
                                fontFamily: appFonts['Detail'],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            localizations.usePremiumApi,
                            style: TextStyle(fontFamily: appFonts['Detail']),
                          ),
                          const SizedBox(width: 10),
                          Switch(
                            value: _premiumApiEnabled,
                            onChanged: _savePremiumApiSetting,
                            activeColor: AppColors.blue,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        localizations.translationSettings,
                        style: TextStyle(
                          fontSize: 24, 
                          fontWeight: FontWeight.bold, 
                          fontFamily: appFonts['Subtitle']
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              localizations.toggleContextual,
                              style: TextStyle(fontFamily: appFonts['Detail']),
                            ),
                          ),
                          Switch(
                            value: _contextualTranslationEnabled,
                            onChanged: _saveContextualTranslationSetting,
                            activeColor: AppColors.blue,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        localizations.displaySettings,
                        style: TextStyle(
                          fontSize: 24, 
                          fontWeight: FontWeight.bold, 
                          fontFamily: appFonts['Subtitle']
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            localizations.showStreakIndicators,
                            style: TextStyle(fontFamily: appFonts['Detail']),
                          ),
                          Switch(
                            value: _streakIndicatorEnabled,
                            onChanged: _saveStreakIndicatorSetting,
                            activeColor: AppColors.blue,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            localizations.useColoredCards,
                            style: TextStyle(fontFamily: appFonts['Detail']),
                          ),
                          Switch(
                            value: _coloredCompetenceCards,
                            onChanged: _saveColoredCompetenceCardsSetting,
                            activeColor: AppColors.blue,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _isExporting ? null : _exportFile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightGrey,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    child: _isExporting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            localizations.export,
                            style: TextStyle(fontFamily: appFonts['Detail']),
                          ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _isImporting ? null : _importFile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    child: _isImporting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            localizations.import,
                            style: TextStyle(fontFamily: appFonts['Detail']),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}