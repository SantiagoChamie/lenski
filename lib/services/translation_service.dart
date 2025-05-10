import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lenski/data/card_repository.dart';

/// A service to translate text using the DeepL API.
/// The service caches the translated text to avoid unnecessary API calls.
class TranslationService {
  TranslationService._privateConstructor();

  static final TranslationService _instance = TranslationService._privateConstructor();

  factory TranslationService() {
    return _instance;
  }

  final Map<String, String> _cache = {};

  /// Translates the given text from the source language to the target language.
  /// Caches the translated text to avoid unnecessary API calls.
  /// Checks the CardRepository for an existing card before making an API call.
  /// Throws an exception if the API key is not set or the translation fails.
  Future<String> translate({
    required String text,
    required String sourceLang,
    required String targetLang,
    required String context,
  }) async {
    final cacheKey = '$text-$sourceLang-$targetLang-$context';
    
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    // Check the CardRepository for an existing card
    final existingCardBack = await _checkCardRepository(text, context);
    if (existingCardBack != null) {
      _cache[cacheKey] = existingCardBack;
      return existingCardBack;
    }

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

    final Map<String, dynamic> requestBody = {
      'text': [text],
      'source_lang': sourceLang,
      'target_lang': targetLang,
    };

    if (text != context) {
      requestBody['context'] = context;
    }

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
      final translatedText = data['translations'][0]['text'];
      _cache[cacheKey] = translatedText;
      return translatedText;
    } else {
      throw Exception('Failed to translate text');
    }
  }

  /// Checks if premium API is enabled
  Future<bool> _isPremiumApiEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('premium_api_enabled') ?? false;
  }

  /// Checks the CardRepository for an existing card with the given front and context.
  Future<String?> _checkCardRepository(String front, String context) async {
    return await CardRepository().getCardByInfo(front, context);
  }

  /// Determines if a card with the given front and context exists in the CardRepository.
  Future<bool> cardExists(String front, String context) async {
    return await CardRepository().getCardByInfo(front, context) != null;
  }

  /// Retrieves the DeepL API key from shared preferences.
  Future<String> _getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('deepl_api_key') ?? '';
  }

  /// Checks if the language of the given text matches the provided language code.
  /// Returns true if the detected language matches the expected language code.
  /// The language code should match DeepL's supported language codes (e.g., 'EN', 'DE', 'ES').
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
      throw Exception('Failed to check language');
    }
  }
}