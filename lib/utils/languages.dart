// Languages to learn
const List<String> sourceLanguages = [
  'العربية', 'Български', 'Čeština', 'Dansk', 'Deutsch', 'Ελληνικά', 'English', 'Español', 'Eesti', 'Suomi', 'Français', 'Magyar', 'Bahasa Indonesia', 'Italiano', '日本語', '한국어', 'Lietuvių', 'Latviešu', 'Norsk Bokmål', 'Nederlands', 'Polski', 'Português', 'Română', 'Русский', 'Slovenčina', 'Slovenščina', 'Svenska', 'Türkçe', 'Українська', '汉语'
];

// Languages from as the base to learn another language
const List<String> targetLanguages = [
  'العربية', 'Български', 'Čeština', 'Dansk', 'Deutsch', 'Ελληνικά', 'English', 'English (British)', 'English (American)', 'Español', 'Eesti', 'Suomi', 'Français', 'Magyar', 'Bahasa Indonesia', 'Italiano', '日本語', '한국어', 'Lietuvių', 'Latviešu', 'Norsk Bokmål', 'Nederlands', 'Polski', 'Português', 'Português (Brazilian)', 'Português (Portugal)', 'Română', 'Русский', 'Slovenčina', 'Slovenščina', 'Svenska', 'Türkçe', 'Українська', '汉语', '汉语 (Simplified)', '汉语 (Traditional)'
];

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

// Flags for each language
const Map<String, List<String>> languageFlags = {
  'العربية': [
    'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2b/Flag_of_the_Arab_League.svg/1200px-Flag_of_the_Arab_League.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fe/Flag_of_Egypt.svg/1920px-Flag_of_Egypt.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/7/77/Flag_of_Algeria.svg/1920px-Flag_of_Algeria.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/0/01/Flag_of_Sudan.svg/1920px-Flag_of_Sudan.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f6/Flag_of_Iraq.svg/1920px-Flag_of_Iraq.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Flag_of_Morocco.svg/1920px-Flag_of_Morocco.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0d/Flag_of_Saudi_Arabia.svg/1920px-Flag_of_Saudi_Arabia.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/8/89/Flag_of_Yemen.svg/1920px-Flag_of_Yemen.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/5/54/Flag_of_Syria_%282025-%29.svg/1920px-Flag_of_Syria_%282025-%29.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/ce/Flag_of_Tunisia.svg/1920px-Flag_of_Tunisia.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cb/Flag_of_the_United_Arab_Emirates.svg/1920px-Flag_of_the_United_Arab_Emirates.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c0/Flag_of_Jordan.svg/1920px-Flag_of_Jordan.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Flag_of_Libya.svg/1920px-Flag_of_Libya.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/5/59/Flag_of_Lebanon.svg/1920px-Flag_of_Lebanon.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/0/00/Flag_of_Palestine.svg/1920px-Flag_of_Palestine.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Flag_of_Oman.svg/1920px-Flag_of_Oman.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/4/43/Flag_of_Mauritania.svg/1920px-Flag_of_Mauritania.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/a/aa/Flag_of_Kuwait.svg/1920px-Flag_of_Kuwait.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/Flag_of_Qatar.svg/1920px-Flag_of_Qatar.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Flag_of_Bahrain.svg/1920px-Flag_of_Bahrain.svg.png',
    ],
  'Български': [
    'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/Flag_of_Bulgaria.svg/1200px-Flag_of_Bulgaria.svg.png'],
  'Čeština': [
    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cb/Flag_of_the_Czech_Republic.svg/1200px-Flag_of_the_Czech_Republic.svg.png'],
  'Dansk': [
    'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/Flag_of_Denmark.svg/1200px-Flag_of_Denmark.svg.png',
  'https://upload.wikimedia.org/wikipedia/commons/thumb/0/09/Flag_of_Greenland.svg/1920px-Flag_of_Greenland.svg.png',
  'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/Flag_of_the_Faroe_Islands.svg/1280px-Flag_of_the_Faroe_Islands.svg.png'],
  'Deutsch': [
    'https://upload.wikimedia.org/wikipedia/commons/thumb/b/ba/Flag_of_Germany.svg/1200px-Flag_of_Germany.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/Flag_of_Belgium.svg/1280px-Flag_of_Belgium.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/4/41/Flag_of_Austria.svg/1920px-Flag_of_Austria.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/0/08/Flag_of_Switzerland_%28Pantone%29.svg/1024px-Flag_of_Switzerland_%28Pantone%29.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/d/da/Flag_of_Luxembourg.svg/1920px-Flag_of_Luxembourg.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/4/47/Flag_of_Liechtenstein.svg/1920px-Flag_of_Liechtenstein.svg.png'],
  'Ελληνικά': [
    'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/Flag_of_Greece.svg/1200px-Flag_of_Greece.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d4/Flag_of_Cyprus.svg/1920px-Flag_of_Cyprus.svg.png'],
  'English': [
    'https://upload.wikimedia.org/wikipedia/en/thumb/a/ae/Flag_of_the_United_Kingdom.svg/640px-Flag_of_the_United_Kingdom.svg.png',
    'https://upload.wikimedia.org/wikipedia/en/thumb/a/a4/Flag_of_the_United_States.svg/1920px-Flag_of_the_United_States.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d9/Flag_of_Canada_%28Pantone%29.svg/1920px-Flag_of_Canada_%28Pantone%29.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/8/88/Flag_of_Australia_%28converted%29.svg/1920px-Flag_of_Australia_%28converted%29.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3e/Flag_of_New_Zealand.svg/1920px-Flag_of_New_Zealand.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/4/45/Flag_of_Ireland.svg/1920px-Flag_of_Ireland.svg.png',
    
    'https://upload.wikimedia.org/wikipedia/en/thumb/b/be/Flag_of_England.svg/1920px-Flag_of_England.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/1/10/Flag_of_Scotland.svg/1920px-Flag_of_Scotland.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/d/dc/Flag_of_Wales.svg/1920px-Flag_of_Wales.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/4/43/Flag_of_Northern_Ireland_%281953%E2%80%931972%29.svg/1920px-Flag_of_Northern_Ireland_%281953%E2%80%931972%29.svg.png'

    'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0a/Flag_of_Jamaica.svg/1920px-Flag_of_Jamaica.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ef/Flag_of_Barbados.svg/1920px-Flag_of_Barbados.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/9/93/Flag_of_the_Bahamas.svg/1920px-Flag_of_the_Bahamas.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e7/Flag_of_Belize.svg/1920px-Flag_of_Belize.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/6/64/Flag_of_Trinidad_and_Tobago.svg/1920px-Flag_of_Trinidad_and_Tobago.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fe/Flag_of_Saint_Kitts_and_Nevis.svg/1920px-Flag_of_Saint_Kitts_and_Nevis.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6d/Flag_of_Saint_Vincent_and_the_Grenadines.svg/1920px-Flag_of_Saint_Vincent_and_the_Grenadines.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Flag_of_Grenada.svg/1920px-Flag_of_Grenada.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/9/99/Flag_of_Guyana.svg/1920px-Flag_of_Guyana.svg.png',
    ],
  'English (British)': [
    'https://upload.wikimedia.org/wikipedia/en/thumb/a/ae/Flag_of_the_United_Kingdom.svg/640px-Flag_of_the_United_Kingdom.svg.png',
    'https://upload.wikimedia.org/wikipedia/en/thumb/b/be/Flag_of_England.svg/1920px-Flag_of_England.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/1/10/Flag_of_Scotland.svg/1920px-Flag_of_Scotland.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/d/dc/Flag_of_Wales.svg/1920px-Flag_of_Wales.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/4/43/Flag_of_Northern_Ireland_%281953%E2%80%931972%29.svg/1920px-Flag_of_Northern_Ireland_%281953%E2%80%931972%29.svg.png'],
  'English (American)': [
    'https://upload.wikimedia.org/wikipedia/en/thumb/a/a4/Flag_of_the_United_States.svg/1920px-Flag_of_the_United_States.svg.png'],
  'Español': [
    'https://upload.wikimedia.org/wikipedia/en/thumb/9/9a/Flag_of_Spain.svg/1920px-Flag_of_Spain.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fc/Flag_of_Mexico.svg/1920px-Flag_of_Mexico.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/2/21/Flag_of_Colombia.svg/1920px-Flag_of_Colombia.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/Flag_of_Argentina.svg/1920px-Flag_of_Argentina.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cf/Flag_of_Peru.svg/1920px-Flag_of_Peru.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/0/06/Flag_of_Venezuela.svg/1920px-Flag_of_Venezuela.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/7/78/Flag_of_Chile.svg/1920px-Flag_of_Chile.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/Flag_of_Guatemala.svg/1920px-Flag_of_Guatemala.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Flag_of_Ecuador.svg/1920px-Flag_of_Ecuador.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b3/Bandera_de_Bolivia_%28Estado%29.svg/1920px-Bandera_de_Bolivia_%28Estado%29.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bd/Flag_of_Cuba.svg/1920px-Flag_of_Cuba.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9f/Flag_of_the_Dominican_Republic.svg/1920px-Flag_of_the_Dominican_Republic.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/8/82/Flag_of_Honduras.svg/1920px-Flag_of_Honduras.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/2/27/Flag_of_Paraguay.svg/1920px-Flag_of_Paraguay.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/3/34/Flag_of_El_Salvador.svg/1920px-Flag_of_El_Salvador.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/1/19/Flag_of_Nicaragua.svg/1920px-Flag_of_Nicaragua.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f2/Flag_of_Costa_Rica.svg/1920px-Flag_of_Costa_Rica.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ab/Flag_of_Panama.svg/1920px-Flag_of_Panama.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fe/Flag_of_Uruguay.svg/1920px-Flag_of_Uruguay.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/2/28/Flag_of_Puerto_Rico.svg/1920px-Flag_of_Puerto_Rico.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/Flag_of_Equatorial_Guinea.svg/1920px-Flag_of_Equatorial_Guinea.svg.png',
    ],
  'Eesti': [
    'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8f/Flag_of_Estonia.svg/1200px-Flag_of_Estonia.svg.png'],
  'Suomi': [
    'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Flag_of_Finland.svg/1200px-Flag_of_Finland.svg.png'],
  'Français': [
    'https://upload.wikimedia.org/wikipedia/en/thumb/c/c3/Flag_of_France.svg/1920px-Flag_of_France.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Flag_of_Monaco.svg/1280px-Flag_of_Monaco.svg.png',
    
    'https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/Flag_of_Belgium.svg/1280px-Flag_of_Belgium.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d9/Flag_of_Canada_%28Pantone%29.svg/1920px-Flag_of_Canada_%28Pantone%29.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/0/08/Flag_of_Switzerland_%28Pantone%29.svg/1024px-Flag_of_Switzerland_%28Pantone%29.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/d/da/Flag_of_Luxembourg.svg/1920px-Flag_of_Luxembourg.svg.png',
    ],
  'Magyar': [
    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Flag_of_Hungary.svg/1200px-Flag_of_Hungary.svg.png'],
  'Bahasa Indonesia': [
    'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9f/Flag_of_Indonesia.svg/1200px-Flag_of_Indonesia.svg.png'],
  'Italiano': [
    'https://upload.wikimedia.org/wikipedia/en/thumb/0/03/Flag_of_Italy.svg/1200px-Flag_of_Italy.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b1/Flag_of_San_Marino.svg/1280px-Flag_of_San_Marino.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b3/Flag_of_Vatican_City_%282023%E2%80%93present%29.svg/1024px-Flag_of_Vatican_City_%282023%E2%80%93present%29.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/0/08/Flag_of_Switzerland_%28Pantone%29.svg/1024px-Flag_of_Switzerland_%28Pantone%29.svg.png',
    ],
  '日本語': [
    'https://upload.wikimedia.org/wikipedia/en/thumb/9/9e/Flag_of_Japan.svg/1200px-Flag_of_Japan.svg.png'],
  '한국어': [
    'https://upload.wikimedia.org/wikipedia/commons/thumb/0/09/Flag_of_South_Korea.svg/1200px-Flag_of_South_Korea.svg.png'],
  'Lietuvių': [
    'https://upload.wikimedia.org/wikipedia/commons/thumb/1/11/Flag_of_Lithuania.svg/1200px-Flag_of_Lithuania.svg.png'],
  'Latviešu': [
    'https://upload.wikimedia.org/wikipedia/commons/thumb/8/84/Flag_of_Latvia.svg/1200px-Flag_of_Latvia.svg.png'],
  'Norsk Bokmål': [
    'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d9/Flag_of_Norway.svg/1200px-Flag_of_Norway.svg.png'],
  'Nederlands': [
    'https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/Flag_of_the_Netherlands.svg/1200px-Flag_of_the_Netherlands.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/Flag_of_Belgium.svg/1280px-Flag_of_Belgium.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/6/60/Flag_of_Suriname.svg/1920px-Flag_of_Suriname.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f6/Flag_of_Aruba.svg/1920px-Flag_of_Aruba.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b1/Flag_of_Cura%C3%A7ao.svg/1920px-Flag_of_Cura%C3%A7ao.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d3/Flag_of_Sint_Maarten.svg/1920px-Flag_of_Sint_Maarten.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1e/Flag_of_Bonaire.svg/1920px-Flag_of_Bonaire.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5a/Flag_of_Saba.svg/1920px-Flag_of_Saba.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/0/08/Flag_of_Sint_Eustatius.svg/1920px-Flag_of_Sint_Eustatius.svg.png',
    ],
  'Polski': ['https://upload.wikimedia.org/wikipedia/en/thumb/1/12/Flag_of_Poland.svg/1200px-Flag_of_Poland.svg.png'],
  'Português': [
    'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/Flag_of_Portugal.svg/1200px-Flag_of_Portugal.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Flag_of_Brazil.svg/1200px-Flag_of_Brazil.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9d/Flag_of_Angola.svg/1920px-Flag_of_Angola.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/Flag_of_Mozambique.svg/1920px-Flag_of_Mozambique.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Flag_of_Cape_Verde.svg/1920px-Flag_of_Cape_Verde.svg.png',
    ],
  'Português (Brazilian)': ['https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Flag_of_Brazil.svg/1200px-Flag_of_Brazil.svg.png'],
  'Português (Portugal)': ['https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/Flag_of_Portugal.svg/1200px-Flag_of_Portugal.svg.png'],
  'Română': [
    'https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/Flag_of_Romania.svg/1200px-Flag_of_Romania.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/2/27/Flag_of_Moldova.svg/1920px-Flag_of_Moldova.svg.png'],
  'Русский': ['https://upload.wikimedia.org/wikipedia/en/thumb/f/f3/Flag_of_Russia.svg/1200px-Flag_of_Russia.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/8/85/Flag_of_Belarus.svg/1920px-Flag_of_Belarus.svg.png',
    ],
  'Slovenčina': ['https://upload.wikimedia.org/wikipedia/commons/thumb/e/e6/Flag_of_Slovakia.svg/1200px-Flag_of_Slovakia.svg.png'],
  'Slovenščina': ['https://upload.wikimedia.org/wikipedia/commons/thumb/f/f0/Flag_of_Slovenia.svg/1200px-Flag_of_Slovenia.svg.png'],
  'Svenska': ['https://upload.wikimedia.org/wikipedia/en/thumb/4/4c/Flag_of_Sweden.svg/1200px-Flag_of_Sweden.svg.png'],
  'Türkçe': [
    'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b4/Flag_of_Turkey.svg/1200px-Flag_of_Turkey.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d4/Flag_of_Cyprus.svg/1920px-Flag_of_Cyprus.svg.png'],
  'Українська': ['https://upload.wikimedia.org/wikipedia/commons/thumb/4/49/Flag_of_Ukraine.svg/1200px-Flag_of_Ukraine.svg.png'],
  '汉语': [
    'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Flag_of_the_People%27s_Republic_of_China.svg/1200px-Flag_of_the_People%27s_Republic_of_China.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/7/72/Flag_of_the_Republic_of_China.svg/1920px-Flag_of_the_Republic_of_China.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5b/Flag_of_Hong_Kong.svg/1920px-Flag_of_Hong_Kong.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/Flag_of_Macau.svg/1920px-Flag_of_Macau.svg.png',
  ],
  '汉语 (Simplified)': ['https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Flag_of_the_People%27s_Republic_of_China.svg/1200px-Flag_of_the_People%27s_Republic_of_China.svg.png'],
  '汉语 (Traditional)': ['https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Flag_of_the_People%27s_Republic_of_China.svg/1200px-Flag_of_the_People%27s_Republic_of_China.svg.png'],
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
