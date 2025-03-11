import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lenski/data/card_repository.dart'; // Import the CardRepository

/// A service to translate text using the DeepL API.
/// The service caches the translated text to avoid unnecessary API calls.
class TranslationService {
  TranslationService._privateConstructor();

  static final TranslationService _instance = TranslationService._privateConstructor();

  factory TranslationService() {
    return _instance;
  }
  //TODO : fix bug with accidentals in the translation
  final String _apiKey = dotenv.env['DEEPL_KEY'] ?? '';
  final Map<String, String> _cache = {};

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
        'Authorization': 'DeepL-Auth-Key $_apiKey',
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final translatedText = data['translations'][0]['text'];
      _cache[cacheKey] = translatedText;
      return translatedText;
    } else {
      throw Exception('Failed to translate text');
    }
  }

  Future<String?> _checkCardRepository(String front, String context) async {
    return await CardRepository().getCardByInfo(front, context);
  }

  Future<bool> cardExists(String front, String context) async {
    return await CardRepository().getCardByInfo(front, context) != null;
  }
}