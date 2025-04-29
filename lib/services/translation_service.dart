import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lenski/data/card_repository.dart'; // Import the CardRepository

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

    final Map<String, dynamic> requestBody = {
      'text': [text],
      'source_lang': sourceLang,
      'target_lang': targetLang,
    };

    if (text != context) {
      requestBody['context'] = context;
    }

    final response = await http.post(
      Uri.parse('https://api-free.deepl.com/v2/translate'),
      headers: {
        'Authorization': 'DeepL-Auth-Key $apiKey',
        'Content-Type': 'application/json; charset=utf-8',
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
}