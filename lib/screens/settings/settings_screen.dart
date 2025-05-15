import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../data/migration_handler.dart'; // Add this import

/// A screen that allows the user to configure settings for the app.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _contextualTranslationEnabled = false;
  bool _premiumApiEnabled = false;
  bool _streakIndicatorEnabled = true;

  // Create an instance of MigrationHandler
  final MigrationHandler _migrationHandler = MigrationHandler();
  bool _isExporting = false;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
    _loadContextualTranslationSetting();
    _loadPremiumApiSetting();
    _loadStreakIndicatorSetting();
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

  /// Handles file picking and importing data
  Future<void> _importFile() async {
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
                  ? 'Import successful'
                  : 'Import failed: ${migrationResult.message}'),
              backgroundColor: migrationResult.success ? Colors.green : Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during import: $e'),
            backgroundColor: Colors.red,
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

  /// Exports app data to a file at user-selected location
  Future<void> _exportFile() async {
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
            content: Text('Export failed: ${migrationResult.message}'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // Now let the user pick where to save the file
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save your Lenski data file',
        fileName: 'lenski_export_${DateTime.now().day.toString() +
          DateTime.now().month.toString() +
          DateTime.now().year.toString()}.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (outputPath != null) {
        // Copy the generated file to user's chosen location
        final sourceFile = File(migrationResult.filePath!);
        final destinationFile = File(outputPath);
        await sourceFile.copy(outputPath);
        
        // Delete the temporary file
        await sourceFile.delete();

        // Show success message with chosen path
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export successful. File saved to: $outputPath'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // User cancelled, delete the temporary file
        final sourceFile = File(migrationResult.filePath!);
        await sourceFile.delete();
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export cancelled by user'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during export: $e'),
            backgroundColor: Colors.red,
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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: const TextSelectionThemeData(
              selectionColor: Color(0xFFFFD38D),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'API Keys',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Telex'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _apiKeyController,
                            obscureText: true,
                            cursorColor: const Color.fromARGB(255, 0, 0, 0),
                            decoration: const InputDecoration(
                              labelText: 'DeepL API Key',
                              labelStyle: TextStyle(fontFamily: 'Sansation', color: Colors.black),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _saveApiKey,
                          child: const Text(
                            'Save API Key',
                            style: TextStyle(color: Color(0xFF2C73DE)),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Use Premium DeepL API',
                          style: TextStyle(fontFamily: 'Sansation'),
                        ),
                        const SizedBox(width: 10),
                        Switch(
                          value: _premiumApiEnabled,
                          onChanged: _savePremiumApiSetting,
                          activeColor: const Color(0xFF2C73DE),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Translation Settings',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Telex'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Toggle between contextual and non-contextual translation in the overlay',
                          style: TextStyle(fontFamily: 'Sansation'),
                        ),
                        Switch(
                          value: _contextualTranslationEnabled,
                          onChanged: _saveContextualTranslationSetting,
                          activeColor: const Color(0xFF2C73DE),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Display Settings',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Telex'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Show streak indicators on courses',
                          style: TextStyle(fontFamily: 'Sansation'),
                        ),
                        Switch(
                          value: _streakIndicatorEnabled,
                          onChanged: _saveStreakIndicatorSetting,
                          activeColor: const Color(0xFF2C73DE),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _isExporting ? null : _exportFile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8E8E8),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    child: _isExporting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Export',
                            style: TextStyle(fontFamily: 'Sansation'),
                          ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _isImporting ? null : _importFile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C73DE),
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
                        : const Text(
                            'Import',
                            style: TextStyle(fontFamily: 'Sansation'),
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