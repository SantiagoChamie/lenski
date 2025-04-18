// Languages to learn
const List<String> sourceLanguages = [
  'العربية', 'Български', 'Čeština', 'Dansk', 'Deutsch', 'Ελληνικά', 'English', 'Español', 'Eesti', 'Suomi', 'Français', 'Magyar', 'Bahasa Indonesia', 'Italiano', '日本語', '한국어', 'Lietuvių', 'Latviešu', 'Norsk Bokmål', 'Nederlands', 'Polski', 'Português', 'Română', 'Русский', 'Slovenčina', 'Slovenščina', 'Svenska', 'Türkçe', 'Українська', '汉语'
];

// Languages from as the base to learn another language
const List<String> targetLanguages = [
  'العربية', 'Български', 'Čeština', 'Dansk', 'Deutsch', 'Ελληνικά', 'English', 'English (British)', 'English (American)', 'Español', 'Eesti', 'Suomi', 'Français', 'Magyar', 'Bahasa Indonesia', 'Italiano', '日本語', '한국어', 'Lietuvių', 'Latviešu', 'Norsk Bokmål', 'Nederlands', 'Polski', 'Português', 'Português (Brazilian)', 'Português (Portugal)', 'Română', 'Русский', 'Slovenčina', 'Slovenščina', 'Svenska', 'Türkçe', 'Українська', '汉语', '汉语 (Simplified)', '汉语 (Traditional)'
];

// Welcome message per language
const Map<String, String> welcomeMessages = {
  'العربية': 'مرحبًا!',
  'Български': 'Добре дошли!',
  'Čeština': 'Vítejte!',
  'Dansk': 'Velkommen!',
  'Deutsch': 'Willkommen!',
  'Ελληνικά': 'Καλώς ορίσατε!',
  'English': 'Welcome!',
  'English (British)': 'Welcome!',
  'English (American)': 'Welcome!',
  'Español': '¡Bienvenido!',
  'Eesti': 'Tere tulemast!',
  'Suomi': 'Tervetuloa!',
  'Français': 'Bienvenue!',
  'Magyar': 'Üdvözöljük!',
  'Bahasa Indonesia': 'Selamat datang!',
  'Italiano': 'Benvenuto!',
  '日本語': 'ようこそ！',
  '한국어': '환영합니다!',
  'Lietuvių': 'Sveiki atvykę!',
  'Latviešu': 'Laipni lūdzam!',
  'Norsk Bokmål': 'Velkommen!',
  'Nederlands': 'Welkom!',
  'Polski': 'Witamy!',
  'Português': 'Bem-vindo!',
  'Português (Brazilian)': 'Bem-vindo!',
  'Português (Portugal)': 'Bem-vindo!',
  'Română': 'Bine ați venit!',
  'Русский': 'Добро пожаловать!',
  'Slovenčina': 'Vitajte!',
  'Slovenščina': 'Dobrodošli!',
  'Svenska': 'Välkommen!',
  'Türkçe': 'Hoş geldiniz!',
  'Українська': 'Ласкаво просимо!',
  '汉语': '欢迎！',
  '汉语 (Simplified)': '欢迎！',
  '汉语 (Traditional)': '歡迎！',
};

// Flags for each language
const Map<String, String> languageFlags = {
  'العربية': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2b/Flag_of_the_Arab_League.svg/1200px-Flag_of_the_Arab_League.svg.png',
  'Български': 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/Flag_of_Bulgaria.svg/1200px-Flag_of_Bulgaria.svg.png',
  'Čeština': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cb/Flag_of_the_Czech_Republic.svg/1200px-Flag_of_the_Czech_Republic.svg.png',
  'Dansk': 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/Flag_of_Denmark.svg/1200px-Flag_of_Denmark.svg.png',
  'Deutsch': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/ba/Flag_of_Germany.svg/1200px-Flag_of_Germany.svg.png',
  'Ελληνικά': 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/Flag_of_Greece.svg/1200px-Flag_of_Greece.svg.png',
  'English': 'https://upload.wikimedia.org/wikipedia/en/thumb/a/ae/Flag_of_the_United_Kingdom.svg/640px-Flag_of_the_United_Kingdom.svg.png',
  'English (British)': 'https://upload.wikimedia.org/wikipedia/en/thumb/a/ae/Flag_of_the_United_Kingdom.svg/640px-Flag_of_the_United_Kingdom.svg.png',
  'English (American)': 'https://upload.wikimedia.org/wikipedia/en/thumb/a/a4/Flag_of_the_United_States.svg/1920px-Flag_of_the_United_States.svg.png',
  'Español': 'https://upload.wikimedia.org/wikipedia/en/thumb/9/9a/Flag_of_Spain.svg/1920px-Flag_of_Spain.svg.png',
  'Eesti': 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8f/Flag_of_Estonia.svg/1200px-Flag_of_Estonia.svg.png',
  'Suomi': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Flag_of_Finland.svg/1200px-Flag_of_Finland.svg.png',
  'Français': 'https://upload.wikimedia.org/wikipedia/en/thumb/c/c3/Flag_of_France.svg/1920px-Flag_of_France.svg.png',
  'Magyar': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Flag_of_Hungary.svg/1200px-Flag_of_Hungary.svg.png',
  'Bahasa Indonesia': 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9f/Flag_of_Indonesia.svg/1200px-Flag_of_Indonesia.svg.png',
  'Italiano': 'https://upload.wikimedia.org/wikipedia/en/thumb/0/03/Flag_of_Italy.svg/1200px-Flag_of_Italy.svg.png',
  '日本語': 'https://upload.wikimedia.org/wikipedia/en/thumb/9/9e/Flag_of_Japan.svg/1200px-Flag_of_Japan.svg.png',
  '한국어': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/09/Flag_of_South_Korea.svg/1200px-Flag_of_South_Korea.svg.png',
  'Lietuvių': 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/11/Flag_of_Lithuania.svg/1200px-Flag_of_Lithuania.svg.png',
  'Latviešu': 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/84/Flag_of_Latvia.svg/1200px-Flag_of_Latvia.svg.png',
  'Norsk Bokmål': 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d9/Flag_of_Norway.svg/1200px-Flag_of_Norway.svg.png',
  'Nederlands': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/Flag_of_the_Netherlands.svg/1200px-Flag_of_the_Netherlands.svg.png',
  'Polski': 'https://upload.wikimedia.org/wikipedia/en/thumb/1/12/Flag_of_Poland.svg/1200px-Flag_of_Poland.svg.png',
  'Português': 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/Flag_of_Portugal.svg/1200px-Flag_of_Portugal.svg.png',
  'Português (Brazilian)': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Flag_of_Brazil.svg/1200px-Flag_of_Brazil.svg.png',
  'Português (Portugal)': 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/Flag_of_Portugal.svg/1200px-Flag_of_Portugal.svg.png',
  'Română': 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/Flag_of_Romania.svg/1200px-Flag_of_Romania.svg.png',
  'Русский': 'https://upload.wikimedia.org/wikipedia/en/thumb/f/f3/Flag_of_Russia.svg/1200px-Flag_of_Russia.svg.png',
  'Slovenčina': 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e6/Flag_of_Slovakia.svg/1200px-Flag_of_Slovakia.svg.png',
  'Slovenščina': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f0/Flag_of_Slovenia.svg/1200px-Flag_of_Slovenia.svg.png',
  'Svenska': 'https://upload.wikimedia.org/wikipedia/en/thumb/4/4c/Flag_of_Sweden.svg/1200px-Flag_of_Sweden.svg.png',
  'Türkçe': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b4/Flag_of_Turkey.svg/1200px-Flag_of_Turkey.svg.png',
  'Українська': 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/49/Flag_of_Ukraine.svg/1200px-Flag_of_Ukraine.svg.png',
  '汉语': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Flag_of_the_People%27s_Republic_of_China.svg/1200px-Flag_of_the_People%27s_Republic_of_China.svg.png',
  '汉语 (Simplified)': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Flag_of_the_People%27s_Republic_of_China.svg/1200px-Flag_of_the_People%27s_Republic_of_China.svg.png',
  '汉语 (Traditional)': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Flag_of_the_People%27s_Republic_of_China.svg/1200px-Flag_of_the_People%27s_Republic_of_China.svg.png',
};

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

// Language attributes for each language
final Map<String, Map<String, dynamic>> languageAttributes = {
  'AR': {
    'languageFamily': 'Afro-Asiatic',
    'alphabet': 'Arabic',
    'grammarComplexity': 0.8,
    'wordOrder': 'VSO',
    'formalityLevels': true,
    'writingDirection': 'RTL',
    'genderedWords': true,
    'pluralWords': true,
  },
  'BG': {
    'languageFamily': 'Slavic',
    'alphabet': 'Cyrillic',
    'grammarComplexity': 0.75,
    'wordOrder': 'SVO',
    'formalityLevels': true,
    'writingDirection': 'LTR',
    'genderedWords': true,
    'pluralWords': true,
  },
  'CS': {
    'languageFamily': 'Slavic',
    'alphabet': 'Latin',
    'grammarComplexity': 0.8,
    'wordOrder': 'SVO',
    'formalityLevels': true,
    'writingDirection': 'LTR',
    'genderedWords': true,
    'pluralWords': true,
  },
  'DA': {
    'languageFamily': 'Germanic',
    'alphabet': 'Latin',
    'grammarComplexity': 0.45,
    'wordOrder': 'SVO',
    'formalityLevels': false,
    'writingDirection': 'LTR',
    'genderedWords': false,
    'pluralWords': true,
  },
  'DE': {
    'languageFamily': 'Germanic',
    'alphabet': 'Latin',
    'grammarComplexity': 0.7,
    'wordOrder': 'SVO/SOV',
    'formalityLevels': true,
    'writingDirection': 'LTR',
    'genderedWords': true,
    'pluralWords': true,
  },
  'EL': {
    'languageFamily': 'Hellenic',
    'alphabet': 'Greek',
    'grammarComplexity': 0.65,
    'wordOrder': 'SVO',
    'formalityLevels': false,
    'writingDirection': 'LTR',
    'genderedWords': true,
    'pluralWords': true,
  },
  'EN': {
    'languageFamily': 'Germanic',
    'alphabet': 'Latin',
    'grammarComplexity': 0.4,
    'wordOrder': 'SVO',
    'formalityLevels': false,
    'writingDirection': 'LTR',
    'genderedWords': false,
    'pluralWords': true,
  },
  'EN-GB': {
    'languageFamily': 'Germanic',
    'alphabet': 'Latin',
    'grammarComplexity': 0.4,
    'wordOrder': 'SVO',
    'formalityLevels': false,
    'writingDirection': 'LTR',
    'genderedWords': false,
    'pluralWords': true,
  },
  'EN-US': {
    'languageFamily': 'Germanic',
    'alphabet': 'Latin',
    'grammarComplexity': 0.4,
    'wordOrder': 'SVO',
    'formalityLevels': false,
    'writingDirection': 'LTR',
    'genderedWords': false,
    'pluralWords': true,
  },
  'ES': {
    'languageFamily': 'Romance',
    'alphabet': 'Latin',
    'grammarComplexity': 0.6,
    'wordOrder': 'SVO',
    'formalityLevels': true,
    'writingDirection': 'LTR',
    'genderedWords': true,
    'pluralWords': true,
  },
  'ET': {
    'languageFamily': 'Uralic',
    'alphabet': 'Latin',
    'grammarComplexity': 0.7,
    'wordOrder': 'SVO',
    'formalityLevels': false,
    'writingDirection': 'LTR',
    'genderedWords': false,
    'pluralWords': true,
  },
  'FI': {
    'languageFamily': 'Uralic',
    'alphabet': 'Latin',
    'grammarComplexity': 0.75,
    'wordOrder': 'SVO',
    'formalityLevels': false,
    'writingDirection': 'LTR',
    'genderedWords': false,
    'pluralWords': true,
  },
  'FR': {
    'languageFamily': 'Romance',
    'alphabet': 'Latin',
    'grammarComplexity': 0.65,
    'wordOrder': 'SVO',
    'formalityLevels': true,
    'writingDirection': 'LTR',
    'genderedWords': true,
    'pluralWords': true,
  },
  'HU': {
    'languageFamily': 'Uralic',
    'alphabet': 'Latin',
    'grammarComplexity': 0.8,
    'wordOrder': 'SVO',
    'formalityLevels': false,
    'writingDirection': 'LTR',
    'genderedWords': false,
    'pluralWords': true,
  },
  'ID': {
    'languageFamily': 'Austronesian',
    'alphabet': 'Latin',
    'grammarComplexity': 0.3,
    'wordOrder': 'SVO',
    'formalityLevels': true,
    'writingDirection': 'LTR',
    'genderedWords': false,
    'pluralWords': false,
  },
  'IT': {
    'languageFamily': 'Romance',
    'alphabet': 'Latin',
    'grammarComplexity': 0.6,
    'wordOrder': 'SVO',
    'formalityLevels': true,
    'writingDirection': 'LTR',
    'genderedWords': true,
    'pluralWords': true,
  },
  'JA': {
    'languageFamily': 'Japonic',
    'alphabet': 'Kanji + Kana',
    'grammarComplexity': 0.9,
    'wordOrder': 'SOV',
    'formalityLevels': true,
    'writingDirection': 'LTR/Top-Down',
    'genderedWords': false,
    'pluralWords': false,
  },
  'KO': {
    'languageFamily': 'Koreanic',
    'alphabet': 'Hangul',
    'grammarComplexity': 0.85,
    'wordOrder': 'SOV',
    'formalityLevels': true,
    'writingDirection': 'LTR',
    'genderedWords': false,
    'pluralWords': false,
  },
  'LT': {
    'languageFamily': 'Baltic',
    'alphabet': 'Latin',
    'grammarComplexity': 0.75,
    'wordOrder': 'SVO',
    'formalityLevels': false,
    'writingDirection': 'LTR',
    'genderedWords': true,
    'pluralWords': true,
  },
  'LV': {
    'languageFamily': 'Baltic',
    'alphabet': 'Latin',
    'grammarComplexity': 0.7,
    'wordOrder': 'SVO',
    'formalityLevels': false,
    'writingDirection': 'LTR',
    'genderedWords': true,
    'pluralWords': true,
  },
  'NB': {
    'languageFamily': 'Germanic',
    'alphabet': 'Latin',
    'grammarComplexity': 0.5,
    'wordOrder': 'SVO',
    'formalityLevels': false,
    'writingDirection': 'LTR',
    'genderedWords': false,
    'pluralWords': true,
  },
  'NL': {
    'languageFamily': 'Germanic',
    'alphabet': 'Latin',
    'grammarComplexity': 0.55,
    'wordOrder': 'SVO',
    'formalityLevels': false,
    'writingDirection': 'LTR',
    'genderedWords': true,
    'pluralWords': true,
  },
  'PL': {
    'languageFamily': 'Slavic',
    'alphabet': 'Latin',
    'grammarComplexity': 0.85,
    'wordOrder': 'SVO',
    'formalityLevels': true,
    'writingDirection': 'LTR',
    'genderedWords': true,
    'pluralWords': true,
  },
  'PT': {
    'languageFamily': 'Romance',
    'alphabet': 'Latin',
    'grammarComplexity': 0.6,
    'wordOrder': 'SVO',
    'formalityLevels': true,
    'writingDirection': 'LTR',
    'genderedWords': true,
    'pluralWords': true,
  },
  'PT-BR': {
    'languageFamily': 'Romance',
    'alphabet': 'Latin',
    'grammarComplexity': 0.6,
    'wordOrder': 'SVO',
    'formalityLevels': true,
    'writingDirection': 'LTR',
    'genderedWords': true,
    'pluralWords': true,
  },
  'PT-PT': {
    'languageFamily': 'Romance',
    'alphabet': 'Latin',
    'grammarComplexity': 0.65,
    'wordOrder': 'SVO',
    'formalityLevels': true,
    'writingDirection': 'LTR',
    'genderedWords': true,
    'pluralWords': true,
  },
  'RO': {
    'languageFamily': 'Romance',
    'alphabet': 'Latin',
    'grammarComplexity': 0.7,
    'wordOrder': 'SVO',
    'formalityLevels': true,
    'writingDirection': 'LTR',
    'genderedWords': true,
    'pluralWords': true,
  },
  'RU': {
    'languageFamily': 'Slavic',
    'alphabet': 'Cyrillic',
    'grammarComplexity': 0.85,
    'wordOrder': 'SVO',
    'formalityLevels': true,
    'writingDirection': 'LTR',
    'genderedWords': true,
    'pluralWords': true,
  },
  'SK': {
    'languageFamily': 'Slavic',
    'alphabet': 'Latin',
    'grammarComplexity': 0.8,
    'wordOrder': 'SVO',
    'formalityLevels': true,
    'writingDirection': 'LTR',
    'genderedWords': true,
    'pluralWords': true,
  },
  'SL': {
    'languageFamily': 'Slavic',
    'alphabet': 'Latin',
    'grammarComplexity': 0.75,
    'wordOrder': 'SVO',
    'formalityLevels': true,
    'writingDirection': 'LTR',
    'genderedWords': true,
    'pluralWords': true,
  },
  'SV': {
    'languageFamily': 'Germanic',
    'alphabet': 'Latin',
    'grammarComplexity': 0.5,
    'wordOrder': 'SVO',
    'formalityLevels': false,
    'writingDirection': 'LTR',
    'genderedWords': false,
    'pluralWords': true,
  },
  'TR': {
    'languageFamily': 'Turkic',
    'alphabet': 'Latin',
    'grammarComplexity': 0.65,
    'wordOrder': 'SOV',
    'formalityLevels': true,
    'writingDirection': 'LTR',
    'genderedWords': false,
    'pluralWords': true,
  },
  'UK': {
    'languageFamily': 'Slavic',
    'alphabet': 'Cyrillic',
    'grammarComplexity': 0.8,
    'wordOrder': 'SVO',
    'formalityLevels': true,
    'writingDirection': 'LTR',
    'genderedWords': true,
    'pluralWords': true,
  },
  'ZH': {
    'languageFamily': 'Sino-Tibetan',
    'alphabet': 'Han characters',
    'grammarComplexity': 0.8,
    'wordOrder': 'SVO',
    'formalityLevels': false,
    'writingDirection': 'LTR/Top-Down',
    'genderedWords': false,
    'pluralWords': false,
  },
  'ZH-HANS': {
    'languageFamily': 'Sino-Tibetan',
    'alphabet': 'Simplified Han',
    'grammarComplexity': 0.75,
    'wordOrder': 'SVO',
    'formalityLevels': false,
    'writingDirection': 'LTR',
    'genderedWords': false,
    'pluralWords': false,
  },
  'ZH-HANT': {
    'languageFamily': 'Sino-Tibetan',
    'alphabet': 'Traditional Han',
    'grammarComplexity': 0.8,
    'wordOrder': 'SVO',
    'formalityLevels': false,
    'writingDirection': 'LTR/Top-Down',
    'genderedWords': false,
    'pluralWords': false,
  },
};
