import 'package:flutter_tts/flutter_tts.dart';
import 'package:lenski/utils/languages.dart';

/// A service to convert text to speech using the flutter_tts plugin.
class TtsService {
  TtsService._privateConstructor();

  static final TtsService _instance = TtsService._privateConstructor();

  factory TtsService() {
    return _instance;
  }

  final FlutterTts _flutterTts = FlutterTts();
  String? _previousLanguageCode;

  /// Converts the given text to speech in the specified language.
  /// Returns a Future that completes when the speech is finished.
  Future<void> speak(String text, String languageCode) async {
    final ttsLanguageCode = ttsLanguageCodes[languageCode] ?? 'en-US';
    if (_previousLanguageCode != ttsLanguageCode) {
      await _flutterTts.setLanguage(ttsLanguageCode);
      _previousLanguageCode = ttsLanguageCode;
    }
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.speak(text);
  }

  /// Stops the current speech.
  Future<void> stop() async {
    await _flutterTts.stop();
  }
}