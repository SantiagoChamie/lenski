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

  @override
  void initState() {
    super.initState();
    _loadApiKey();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontFamily: 'Unbounded')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
          ],
        ),
      ),
    );
  }
}