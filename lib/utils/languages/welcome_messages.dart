// Multiple welcome messages per language
const Map<String, List<String>> welcomeMessages = {
  'العربية': [
    'مرحبًا!', 
    'أهلاً وسهلاً!', 
    'طاب يومك!'
  ],
  'Български': [
    'Добре дошли!', 
    'Здравейте!', 
    'Радваме се да ви видим!'
  ],
  'Čeština': [
    'Vítejte!', 
    'Ahoj!', 
    'Srdečně vás vítáme!'
  ],
  'Dansk': [
    'Velkommen!', 
    'Hej med dig!', 
    'Glad for at se dig!'
  ],
  'Deutsch': [
    'Willkommen!', 
    'Hallo!', 
    'Schön, dich zu sehen!'
  ],
  'Ελληνικά': [
    'Καλώς ορίσατε!', 
    'Γειά σου!', 
    'Χαίρομαι που σε βλέπω!'
  ],
  'English': [
    'Welcome!', 
    'Hello!', 
    'Greetings!'
  ],
  'English (British)': [
    'Welcome!', 
    'Hello there!', 
    'Good day!'
  ],
  'English (American)': [
    'Welcome!', 
    'Hey!', 
    'What’s up?'
  ],
  'Español': [
    '¡Bienvenido!', 
    '¡Hola!', 
    '¡Qué gusto verte!'
  ],
  'Eesti': [
    'Tere tulemast!', 
    'Tere!', 
    'Tere päevast!'
  ],
  'Suomi': [
    'Tervetuloa!', 
    'Hei!', 
    'Hauska nähdä sinut!'
  ],
  'Français': [
    'Bienvenue!', 
    'Salut!', 
    'Ravi de vous voir!'
  ],
  'Magyar': [
    'Üdvözöljük!', 
    'Szia!', 
    'Örülünk, hogy itt vagy!'
  ],
  'Bahasa Indonesia': [
    'Selamat datang!', 
    'Halo!', 
    'Senang bertemu denganmu!'
  ],
  'Italiano': [
    'Benvenuto!', 
    'Ciao!', 
    'Felice di vederti!'
  ],
  '日本語': [
    'ようこそ！', 
    'こんにちは！', 
    'いらっしゃいませ！'
  ],
  '한국어': [
    '환영합니다!', 
    '안녕하세요!', 
    '만나서 반가워요!'
  ],
  'Lietuvių': [
    'Sveiki atvykę!', 
    'Labas!', 
    'Džiaugiamės jus matydami!'
  ],
  'Latviešu': [
    'Laipni lūdzam!', 
    'Sveiki!', 
    'Prieks redzēt!'
  ],
  'Norsk Bokmål': [
    'Velkommen!', 
    'Hei!', 
    'Hyggelig å se deg!'
  ],
  'Nederlands': [
    'Welkom!', 
    'Hallo!', 
    'Fijn je te zien!'
  ],
  'Polski': [
    'Witamy!', 
    'Cześć!', 
    'Miło cię widzieć!'
  ],
  'Português': [
    'Bem-vindo!', 
    'Olá!', 
    'Prazer em ver você!'
  ],
  'Português (Brazilian)': [
    'Bem-vindo!', 
    'Oi!', 
    'Que bom te ver!'
  ],
  'Português (Portugal)': [
    'Bem-vindo!', 
    'Olá!', 
    'É um prazer vê-lo!'
  ],
  'Română': [
    'Bine ați venit!', 
    'Salut!', 
    'Încântat să te văd!'
  ],
  'Русский': [
    'Добро пожаловать!', 
    'Привет!', 
    'Рады вас видеть!'
  ],
  'Slovenčina': [
    'Vitajte!', 
    'Ahoj!', 
    'Teší nás vaša návšteva!'
  ],
  'Slovenščina': [
    'Dobrodošli!', 
    'Živjo!', 
    'Veseli nas vaš obisk!'
  ],
  'Svenska': [
    'Välkommen!', 
    'Hallå!', 
    'Roligt att se dig!'
  ],
  'Türkçe': [
    'Hoş geldiniz!', 
    'Merhaba!', 
    'Seni gördüğüme sevindim!'
  ],
  'Українська': [
    'Ласкаво просимо!', 
    'Привіт!', 
    'Радий вас бачити!'
  ],
  '汉语 (Simplified)': [
    '欢迎！', 
    '你好！', 
    '很高兴见到你！'
  ],
  '汉语 (Traditional)': [
    '歡迎！', 
    '你好！', 
    '很高興見到你！'
  ],
};

// Helper that picks a “daily” message
String getWelcomeMessage(String languageKey) {
  final messages = welcomeMessages[languageKey] ??
      ['Welcome!']; // fallback if language not found
  // Use the day-of-year so it cycles once per calendar day:
  final today = DateTime.now();
  final dayOfYear = int.parse(
    DateTime(today.year, today.month, today.day)
        .difference(DateTime(today.year))
        .inDays
        .toString(),
  );
  final index = dayOfYear % messages.length;
  return messages[index];
}