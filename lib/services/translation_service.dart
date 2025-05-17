import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lenski/data/card_repository.dart';

/// A service that provides text translation capabilities using the DeepL API.
///
/// This singleton service handles text translation requests, caching results to minimize
/// API calls, and providing language detection. It supports both free and premium
/// DeepL API access and integrates with the app's card repository to reuse existing translations.
///
/// Features:
/// - Translation with source and target language specification
/// - Context-aware translation for improved accuracy
/// - Result caching to reduce API usage
/// - Language detection
/// - Integration with study card repository
class TranslationService {
  /// Private constructor for singleton pattern
  TranslationService._privateConstructor();

  /// Singleton instance
  static final TranslationService _instance = TranslationService._privateConstructor();

  /// Factory constructor to return the singleton instance
  factory TranslationService() {
    return _instance;
  }

  /// In-memory cache of translations to avoid repeated API calls
  final Map<String, String> _cache = {};

  /// Translates text from the source language to the target language.
  ///
  /// Uses the provided context to improve translation accuracy. This method attempts
  /// to locate an existing translation in the cache or the card repository before
  /// making an API call. If no existing translation is found, it calls the DeepL API.
  ///
  /// @param text The text to translate
  /// @param sourceLang Source language code (e.g., 'EN', 'ES')
  /// @param targetLang Target language code (e.g., 'EN', 'ES')
  /// @param context Additional text to provide context for the translation
  /// @return A Future that resolves to the translated text
  /// @throws Exception if the API key is not set or the translation fails
  Future<String> translate({
    required String text,
    required String sourceLang,
    required String targetLang,
    required String context,
  }) async {
    final cacheKey = '$text-$sourceLang-$targetLang-$context';
    
    // Try to retrieve from cache first
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    // Check the CardRepository for an existing card
    final existingCardBack = await _checkCardRepository(text, context);
    if (existingCardBack != null) {
      _cache[cacheKey] = existingCardBack;
      return existingCardBack;
    }

    // Retrieve API key and check if it's available
    final String apiKey = await _getApiKey();
    if (apiKey.isEmpty) {
      throw Exception('API Key is not set');
    }
    
    // Check if premium API is enabled
    final bool isPremiumApi = await _isPremiumApiEnabled();
    
    // Set the correct API endpoint based on premium status
    final String apiEndpoint = isPremiumApi
        ? 'https://api.deepl.com/v2/translate'
        : 'https://api-free.deepl.com/v2/translate';

    // Prepare the request body
    final Map<String, dynamic> requestBody = {
      'text': [text],
      'source_lang': sourceLang,
      'target_lang': targetLang,
    };

    // Only include context if it's different from the text
    if (text != context) {
      requestBody['context'] = context;
    }

    // Make the API request
    final response = await http.post(
      Uri.parse(apiEndpoint),
      headers: {
        'Authorization': 'DeepL-Auth-Key $apiKey',
        'Content-Type': 'application/json; charset=utf-8',
        'User-Agent': 'LenskiApp/1.0.0',
      },
      body: utf8.encode(json.encode(requestBody)),
    );

    // Process the response
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final translatedText = data['translations'][0]['text'];
      _cache[cacheKey] = translatedText;
      return translatedText;
    } else {
      throw Exception('Failed to translate text: ${response.statusCode}');
    }
  }

  /// Checks if premium DeepL API access is enabled in the app settings.
  ///
  /// @return A Future that resolves to true if premium API is enabled, false otherwise
  Future<bool> _isPremiumApiEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('premium_api_enabled') ?? false;
  }

  /// Checks the CardRepository for an existing card with the given front text and context.
  ///
  /// @param front The front text of the card to search for
  /// @param context The context text of the card to search for
  /// @return A Future that resolves to the card's back text if found, or null if not found
  Future<String?> _checkCardRepository(String front, String context) async {
    return await CardRepository().getCardByInfo(front, context);
  }

  /// Determines if a card with the given front text and context exists in the CardRepository.
  ///
  /// @param front The front text of the card to search for
  /// @param context The context text of the card to search for
  /// @return A Future that resolves to true if a card exists, false otherwise
  Future<bool> cardExists(String front, String context) async {
    return await CardRepository().getCardByInfo(front, context) != null;
  }

  /// Retrieves the DeepL API key from shared preferences.
  ///
  /// @return A Future that resolves to the API key string, or an empty string if not set
  Future<String> _getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('deepl_api_key') ?? '';
  }

  /// Checks if the language of the given text matches the provided language code.
  ///
  /// This uses the DeepL API's language detection feature to determine if the text
  /// is written in the expected language.
  ///
  /// @param text The text to analyze
  /// @param code The expected language code (e.g., 'EN', 'ES')
  /// @return A Future that resolves to true if the detected language matches the expected code
  /// @throws Exception if the API key is not set or the language check fails
  Future<bool> checkLanguage(String text, String code) async {
    final String apiKey = await _getApiKey();
    if (apiKey.isEmpty) {
      throw Exception('API Key is not set');
    }
    
    // Check if premium API is enabled
    final bool isPremiumApi = await _isPremiumApiEnabled();
    
    // Set the correct API endpoint based on premium status
    final String apiEndpoint = isPremiumApi
        ? 'https://api.deepl.com/v2/translate'
        : 'https://api-free.deepl.com/v2/translate';

    // We only need to detect the language, so we'll use any target language
    // The API will still return the detected source language
    final Map<String, dynamic> requestBody = {
      'text': [text],
      'target_lang': 'EN', // Using English as dummy target language
    };

    final response = await http.post(
      Uri.parse(apiEndpoint),
      headers: {
        'Authorization': 'DeepL-Auth-Key $apiKey',
        'Content-Type': 'application/json; charset=utf-8',
        'User-Agent': 'LenskiApp/1.0.0',
      },
      body: utf8.encode(json.encode(requestBody)),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final detectedLanguage = data['translations'][0]['detected_source_language'];
      // Compare language codes (case-insensitive)
      return detectedLanguage.toUpperCase() == code.toUpperCase();
    } else {
      throw Exception('Failed to check language: ${response.statusCode}');
    }
  }
  
  /// Clears the translation cache.
  ///
  /// This can be useful when the API key changes or when you want to force fresh translations.
  void clearCache() {
    _cache.clear();
  }
}