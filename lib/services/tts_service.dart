import 'package:flutter_tts/flutter_tts.dart';

/// A service to convert text to speech using the flutter_tts plugin.
class TtsService {
  TtsService._privateConstructor();

  static final TtsService _instance = TtsService._privateConstructor();

  factory TtsService() {
    return _instance;
  }

  final FlutterTts _flutterTts = FlutterTts();
  String? _previousLanguageCode;
  String? _previousTtsLanguageCode;

  /// Converts the given text to speech in the specified language.
  /// Returns a Future that completes when the speech is finished.
  Future<void> speak(String text, String languageCode) async {
  String? ttsLanguageCode;

  // Ensure plugin calls happen on the platform thread
  await Future(() async {
    if (_previousLanguageCode == languageCode) {
      ttsLanguageCode = _previousTtsLanguageCode;
    } else {
      final List<dynamic> availableLanguages = await _flutterTts.getLanguages;
      ttsLanguageCode = availableLanguages.firstWhere(
        (lang) => lang.toString().substring(0, 2).toLowerCase() == languageCode.toLowerCase(),
        orElse: () => null,
      );
    }

    if (ttsLanguageCode == null) {
      throw Exception("Language code not supported");
    }

    if (_previousLanguageCode != languageCode) {
      await _flutterTts.setLanguage(ttsLanguageCode!);
      _previousLanguageCode = languageCode;
      _previousTtsLanguageCode = ttsLanguageCode;
    }

    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.speak(text);
  });
}

  /// Stops the current speech.
  Future<void> stop() async {
    await _flutterTts.stop();
  }

  /// Get languages
  Future<List> getLanguages() async {
    return await _flutterTts.getLanguages;
  }
}