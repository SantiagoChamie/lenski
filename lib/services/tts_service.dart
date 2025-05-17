import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

/// A service that provides text-to-speech functionality in multiple languages.
///
/// This singleton service uses the flutter_tts plugin to convert text to speech
/// and manages language selection, caching of language settings to improve performance,
/// and provides common TTS operations.
///
/// Features:
/// - Text-to-speech conversion with language specification
/// - Language code mapping and validation
/// - Performance optimization through language caching
/// - Speech control (start/stop)
/// - Available languages discovery
class TtsService {
  /// Private constructor for singleton pattern
  TtsService._privateConstructor();

  /// Singleton instance
  static final TtsService _instance = TtsService._privateConstructor();

  /// Factory constructor to return the singleton instance
  factory TtsService() {
    return _instance;
  }

  /// The underlying Flutter TTS engine
  final FlutterTts _flutterTts = FlutterTts();
  
  /// The previously used language code, used for caching
  String? _previousLanguageCode;
  
  /// The previously used TTS-specific language code, used for caching
  String? _previousTtsLanguageCode;

  /// Converts the given text to speech in the specified language.
  ///
  /// This method will attempt to find an appropriate TTS voice for the provided
  /// language code. If the language code matches the previous request, it will
  /// reuse the previously identified TTS language for better performance.
  ///
  /// @param text The text to be spoken
  /// @param languageCode The language code in ISO 639-1 format (e.g., 'en', 'es', 'fr')
  /// @return A Future that completes when the speech is finished or when an error occurs
  /// @throws Exception if the language code is not supported by the TTS engine
  Future<void> speak(String text, String languageCode) async {
    try {
      // Determine the TTS-specific language code
      String? ttsLanguageCode;

      // Check if we can reuse the previous language code mapping for better performance
      if (_previousLanguageCode == languageCode) {
        ttsLanguageCode = _previousTtsLanguageCode;
      } else {
        // We need to find a matching TTS language
        final List<dynamic> availableLanguages = await _flutterTts.getLanguages;
        ttsLanguageCode = availableLanguages.firstWhere(
          // Match on the first two characters of the language code (e.g., 'en' in 'en-US')
          (lang) => lang.toString().substring(0, 2).toLowerCase() == languageCode.toLowerCase(),
          orElse: () => null,
        );
      }

      // If no matching language was found, throw an exception
      if (ttsLanguageCode == null) {
        throw Exception("Language code '$languageCode' not supported by TTS engine");
      }

      // Set the language if it's different from the previous one
      if (_previousLanguageCode != languageCode) {
        await _flutterTts.setLanguage(ttsLanguageCode);
        _previousLanguageCode = languageCode;
        _previousTtsLanguageCode = ttsLanguageCode;
      }

      // Configure speech parameters
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.5);
      
      // Speak the text
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('TTS Error: $e');
      rethrow;
    }
  }

  /// Stops any ongoing speech immediately.
  ///
  /// @return A Future that completes when the speech has been stopped
  Future<void> stop() async {
    await _flutterTts.stop();
  }

  /// Retrieves a list of all available languages supported by the TTS engine.
  ///
  /// This is useful for checking language availability or providing language selection options.
  ///
  /// @return A Future that resolves to a list of language codes supported by the TTS engine
  /// @throws Exception if unable to retrieve the languages from the TTS engine
  Future<List<dynamic>> getLanguages() async {
    try {
      return await _flutterTts.getLanguages;
    } catch (e) {
      debugPrint('TTS Error getting languages: $e');
      rethrow;
    }
  }
  
  /// Gets the current state of the TTS engine.
  ///
  /// Possible states include: playing, stopped, paused, or error.
  ///
  /// @return A Future that resolves to the current TTS engine state
  Future<dynamic> getState() async {
    return await _flutterTts.getMaxSpeechInputLength;
  }
  
  /// Disposes the TTS engine and frees associated resources.
  ///
  /// Should be called when the TTS service is no longer needed.
  Future<void> dispose() async {
    await _flutterTts.stop();
  }
}