import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// A service to translate text using the DeepL API.
/// The service caches the translated text to avoid unnecessary API calls.
class TranslationService {
  TranslationService._privateConstructor();

  static final TranslationService _instance = TranslationService._privateConstructor();

  factory TranslationService() {
    return _instance;
  }

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
      print("using cache");
      return _cache[cacheKey]!;
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
      print("sending data to deepl");
      final data = json.decode(response.body);
      final translatedText = data['translations'][0]['text'];
      _cache[cacheKey] = translatedText;
      return translatedText;
    } else {
      throw Exception('Failed to translate text');
    }
  }
}