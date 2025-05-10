import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A screen that allows the user to configure settings for the app.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _contextualTranslationEnabled = false;
  bool _premiumApiEnabled = false;  // New state variable

  @override
  void initState() {
    super.initState();
    _loadApiKey();
    _loadContextualTranslationSetting();
    _loadPremiumApiSetting();  // New method call
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
            ],
          ),
        ),
      ),
    );
  }
}