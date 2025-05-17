// Languages to learn
const List<String> sourceLanguages = [
  'العربية', 'Български', 'Čeština', 'Dansk', 'Deutsch', 'Ελληνικά', 'English', 'Español', 'Eesti', 'Suomi', 'Français', 'Magyar', 'Bahasa Indonesia', 'Italiano', '日本語', '한국어', 'Lietuvių', 'Latviešu', 'Norsk Bokmål', 'Nederlands', 'Polski', 'Português', 'Română', 'Русский', 'Slovenčina', 'Slovenščina', 'Svenska', 'Türkçe', 'Українська', '汉语'
];

// Languages from as the base to learn another language
const List<String> targetLanguages = [
  'العربية', 'Български', 'Čeština', 'Dansk', 'Deutsch', 'Ελληνικά', 'English', 'English (British)', 'English (American)', 'Español', 'Eesti', 'Suomi', 'Français', 'Magyar', 'Bahasa Indonesia', 'Italiano', '日本語', '한국어', 'Lietuvių', 'Latviešu', 'Norsk Bokmål', 'Nederlands', 'Polski', 'Português', 'Português (Brazilian)', 'Português (Portugal)', 'Română', 'Русский', 'Slovenčina', 'Slovenščina', 'Svenska', 'Türkçe', 'Українська', '汉语', '汉语 (Simplified)', '汉语 (Traditional)'
];

// Language codes for each language
const Map<String, String> languageCodes = {
  'العربية': 'AR',
  'Български': 'BG',
  'Čeština': 'CS',
  'Dansk': 'DA',
  'Deutsch': 'DE',
  'Ελληνικά': 'EL',
  'English': 'EN',
  'English (British)': 'EN-GB',
  'English (American)': 'EN-US',
  'Español': 'ES',
  'Eesti': 'ET',
  'Suomi': 'FI',
  'Français': 'FR',
  'Magyar': 'HU',
  'Bahasa Indonesia': 'ID',
  'Italiano': 'IT',
  '日本語': 'JA',
  '한국어': 'KO',
  'Lietuvių': 'LT',
  'Latviešu': 'LV',
  'Norsk Bokmål': 'NB',
  'Nederlands': 'NL',
  'Polski': 'PL',
  'Português': 'PT',
  'Português (Brazilian)': 'PT-BR',
  'Português (Portugal)': 'PT-PT',
  'Română': 'RO',
  'Русский': 'RU',
  'Slovenčina': 'SK',
  'Slovenščina': 'SL',
  'Svenska': 'SV',
  'Türkçe': 'TR',
  'Українська': 'UK',
  '汉语': 'ZH',
  '汉语 (Simplified)': 'ZH-HANS',
  '汉语 (Traditional)': 'ZH-HANT',
};

// Language names for each code (keys and values swapped from original)
const Map<String, String> codeToLanguage = {
  'AR': 'العربية',
  'BG': 'Български',
  'CS': 'Čeština',
  'DA': 'Dansk',
  'DE': 'Deutsch',
  'EL': 'Ελληνικά',
  'EN': 'English',
  'EN-GB': 'English (British)',
  'EN-US': 'English (American)',
  'ES': 'Español',
  'ET': 'Eesti',
  'FI': 'Suomi',
  'FR': 'Français',
  'HU': 'Magyar',
  'ID': 'Bahasa Indonesia',
  'IT': 'Italiano',
  'JA': '日本語',
  'KO': '한국어',
  'LT': 'Lietuvių',
  'LV': 'Latviešu',
  'NB': 'Norsk Bokmål',
  'NL': 'Nederlands',
  'PL': 'Polski',
  'PT': 'Português',
  'PT-BR': 'Português (Brazilian)',
  'PT-PT': 'Português (Portugal)',
  'RO': 'Română',
  'RU': 'Русский',
  'SK': 'Slovenčina',
  'SL': 'Slovenščina',
  'SV': 'Svenska',
  'TR': 'Türkçe',
  'UK': 'Українська',
  'ZH': '汉语',
  'ZH-HANS': '汉语 (Simplified)',
  'ZH-HANT': '汉语 (Traditional)',
};

