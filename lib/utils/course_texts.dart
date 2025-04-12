// Welcome 
const Map<String, String> welcomeMessages = {
  'AR': 'مرحبًا بكم!', // More accurate for "Welcome!" (less casual than مرحبًا)
  'BG': 'Добре дошли!', // ✅ Correct
  'CS': 'Vítejte!', // ✅ Correct (plural/general use)
  'DA': 'Velkommen!', // ✅ Correct
  'DE': 'Willkommen!', // ✅ Correct
  'EL': 'Καλώς ορίσατε!', // ✅ Correct (formal)
  'EN': 'Welcome!', // ✅ Base language
  'ES': '¡Bienvenidos!', // Use plural for mixed/general audiences
  'ET': 'Tere tulemast!', // ✅ Correct
  'FI': 'Tervetuloa!', // ✅ Correct
  'FR': 'Bienvenue!', // ✅ Correct (gender-neutral in this context)
  'HU': 'Üdvözöljük!', // ✅ Correct (formal/plural)
  'ID': 'Selamat datang!', // ✅ Correct
  'IT': 'Benvenuti!', // Plural for general audiences
  'JA': 'ようこそ！', // ✅ Correct
  'KO': '환영합니다!', // ✅ Correct
  'LT': 'Sveiki atvykę!', // ✅ Correct
  'LV': 'Laipni lūdzam!', // ✅ Correct
  'NB': 'Velkommen!', // ✅ Correct (Norwegian Bokmål)
  'NL': 'Welkom!', // ✅ Correct
  'PL': 'Witamy!', // ✅ Correct (plural/general)
  'PT': 'Bem-vindos!', // Plural for mixed/general audiences
  'RO': 'Bine ați venit!', // ✅ Correct
  'RU': 'Добро пожаловать!', // ✅ Correct
  'SK': 'Vitajte!', // ✅ Correct (plural/general)
  'SL': 'Dobrodošli!', // ✅ Correct (plural/general)
  'SV': 'Välkommen!', // ✅ Correct
  'TR': 'Hoş geldiniz!', // ✅ Correct (plural/polite)
  'UK': 'Ласкаво просимо!', // ✅ Correct
  'ZH': '欢迎！', // ✅ Simplified Chinese
  'ZH-HANS': '欢迎！', // ✅ Simplified Chinese
  'ZH-HANT': '歡迎！', // ✅ Traditional Chinese
};

// no new cards remaining
const Map<String, String> noNewCardsRemainingMessages = {
  'AR': 'لا توجد بطاقات جديدة متبقية', // "No new cards remaining"
  'BG': 'Няма останали нови карти', // Neutral plural
  'CS': 'Žádné nové karty nezbývají', // "No new cards left"
  'DA': 'Ingen nye kort tilbage', // "No new cards left"
  'DE': 'Keine neuen Karten übrig', // Neutral/formal
  'EL': 'Δεν υπάρχουν νέες κάρτες', // "No new cards exist"
  'EN': 'No new cards remaining', // Base language
  'ES': 'No quedan tarjetas nuevas', // Neutral plural
  'ET': 'Uusi kaarte pole jäänud', // "No new cards left"
  'FI': 'Ei uusia kortteja jäljellä', // "No new cards left"
  'FR': 'Aucune nouvelle carte restante', // Singular (gender-neutral)
  'HU': 'Nincsenek új kártyák', // "No new cards"
  'ID': 'Tidak ada kartu baru tersisa',
  'IT': 'Nessuna nuova carta rimasta', // Singular (neutral)
  'JA': '新しいカードが残っていません', // Polite form ("No new cards remain")
  'KO': '남은 새 카드가 없습니다', // Formal/polite
  'LT': 'Nėra likusių naujų kortelių',
  'LV': 'Nav palikušu jaunu karšu',
  'NB': 'Ingen nye kort igjen', // Norwegian Bokmål
  'NL': 'Geen nieuwe kaarten over', // Neutral
  'PL': 'Brak nowych kart', // "No new cards"
  'PT': 'Nenhum cartão novo restante', // Singular (neutral)
  'RO': 'Nu mai sunt cărți noi rămase',
  'RU': 'Нет оставшихся новых карточек', // "No remaining new cards"
  'SK': 'Nezostali žiadne nové karty',
  'SL': 'Ni novih kartic preostalih',
  'SV': 'Inga nya kort kvar', // "No new cards left"
  'TR': 'Kalan yeni kart yok', // "No remaining new cards"
  'UK': 'Немає нових карток, що залишилися',
  'ZH': '没有新卡片剩余了', // Simplified Chinese
  'ZH-HANS': '没有新卡片剩余了', // Simplified
  'ZH-HANT': '沒有新卡片剩餘了', // Traditional
};

//loading...
const Map<String, String> loadingMessages = {
  'AR': 'جاري التحميل...', // Formal "Loading in progress..."
  'BG': 'Зареждане...', // Neutral
  'CS': 'Načítání...', // Standard
  'DA': 'Indlæser...', // "Loading..."
  'DE': 'Wird geladen...', // Passive form (natural)
  'EL': 'Φόρτωση...', // Neutral (common in apps)
  'EN': 'Loading...', // Base
  'ES': 'Cargando...', // Present participle
  'ET': 'Laadimine...', // Neutral
  'FI': 'Ladataan...', // Passive "Being loaded"
  'FR': 'Chargement...', // Gender-neutral noun
  'HU': 'Betöltés...', // Neutral
  'ID': 'Memuat...', // Present continuous
  'IT': 'Caricamento...', // Noun form
  'JA': '読み込み中...', // "Loading in progress" (polite)
  'KO': '로드 중...', // "Load in progress" (common loanword)
  'LT': 'Įkeliama...', // Passive "Being loaded"
  'LV': 'Ielādē...', // Neutral
  'NB': 'Laster...', // Norwegian Bokmål
  'NL': 'Laden...', // Concise
  'PL': 'Ładowanie...', // Standard
  'PT': 'Carregando...', // Present participle
  'RO': 'Se încarcă...', // Reflexive "Is loading"
  'RU': 'Загрузка...', // Standard
  'SK': 'Načítava sa...', // "Is loading"
  'SL': 'Nalaganje...', // Noun form
  'SV': 'Laddar...', // Present tense
  'TR': 'Yükleniyor...', // Present continuous
  'UK': 'Завантаження...', // Standard
  'ZH': '加载中...', // Simplified (加载中 = "loading in progress")
  'ZH-HANS': '加载中...', // Simplified
  'ZH-HANT': '載入中...', // Traditional
};

// no more cards to review
const Map<String, String> noMoreCardsToReviewMessages = {
  'AR': 'لا مزيد من البطاقات لمراجعتها!', // "No more cards to review"
  'BG': 'Няма повече карти за преглед!', // Neutral plural
  'CS': 'Žádné karty k opakování!', // "No cards to review"
  'DA': 'Ingen flere kort at gennemgå!', // "No more cards to go through"
  'DE': 'Keine Karten mehr zum Wiederholen!', // Natural phrasing
  'EL': 'Δεν υπάρχουν άλλες κάρτες για επανάληψη!', // "No more cards for review"
  'EN': 'No more cards to review!', // Base
  'ES': '¡No hay más tarjetas para repasar!', // Neutral plural
  'ET': 'Rohkem pole ülevaatamiseks kaarte!', // "No more cards for review"
  'FI': 'Ei enää kortteja kerrattavaksi!', // "No more cards to repeat"
  'FR': 'Plus de cartes à réviser !', // Common shorthand (plural)
  'HU': 'Nincs több kártya az áttekintéshez!', // "No more cards for review"
  'ID': 'Tidak ada kartu lagi untuk ditinjau!',
  'IT': 'Nessuna carta da ripassare!', // Singular (neutral)
  'JA': '復習するカードがありません！', // "No cards to review" (polite)
  'KO': '복습할 카드가 없습니다!', // Formal/polite
  'LT': 'Nėra daugiau kortelių peržiūrėti!', // "No more cards to view"
  'LV': 'Vairs nav karšu pārskatīšanai!', // "No cards left to review"
  'NB': 'Ingen flere kort å gå gjennom!', // Norwegian Bokmål ("to go through")
  'NL': 'Geen kaarten meer om te herhalen!', // Neutral
  'PL': 'Brak kart do powtórki!', // "No cards for repetition"
  'PT': 'Nenhum cartão para revisar!', // Singular (neutral)
  'RO': 'Nu mai sunt cărți de recenzat!', // "No more cards to review"
  'RU': 'Нет больше карточек для повторения!', // Diminutive "карточек" (study cards)
  'SK': 'Žiadne karty na opakovanie!', // "No cards for repetition"
  'SL': 'Ni več kartic za pregled!', // "No more cards to check"
  'SV': 'Inga fler kort att granska!', // "No more cards to inspect"
  'TR': 'Gözden geçirecek kart kalmadı!', // "No cards left to review"
  'UK': 'Більше немає карток для перегляду!', // Standard
  'ZH': '没有更多卡片需要复习了！', // Simplified
  'ZH-HANS': '没有更多卡片需要复习了！', // Simplified
  'ZH-HANT': '沒有更多卡片需要複習了！', // Traditional
};

// show answer
const Map<String, String> showAnswerMessages = {
  'AR': 'عرض الإجابة',
  'BG': 'Покажи отговора',
  'CS': 'Zobrazit odpověď',
  'DA': 'Vis svar',
  'DE': 'Antwort zeigen',
  'EL': 'Εμφάνιση απάντησης',
  'EN': 'Show Answer',
  'ES': 'Mostrar respuesta',
  'ET': 'Näita vastust',
  'FI': 'Näytä vastaus',
  'FR': 'Afficher la réponse',
  'HU': 'Megoldás mutatása',
  'ID': 'Tampilkan Jawaban',
  'IT': 'Mostra risposta',
  'JA': '答えを表示',
  'KO': '정답 보기',
  'LT': 'Rodyti atsakymą',
  'LV': 'Parādīt atbildi',
  'NB': 'Vis svar',
  'NL': 'Toon antwoord',
  'PL': 'Pokaż odpowiedź',
  'PT': 'Mostrar resposta',
  'RO': 'Afișează răspunsul',
  'RU': 'Показать ответ',
  'SK': 'Zobraziť odpoveď',
  'SL': 'Pokaži odgovor',
  'SV': 'Visa svar',
  'TR': 'Cevabı Göster',
  'UK': 'Показати відповідь',
  'ZH': '显示答案',
  'ZH-HANS': '显示答案',
  'ZH-HANT': '顯示答案',
};

//easy
const Map<String, String> easyDifficulty = {
  'AR': 'سهل', // "Easy"
  'BG': 'Лесно',
  'CS': 'Snadné',
  'DA': 'Let',
  'DE': 'Einfach',
  'EL': 'Εύκολο',
  'EN': 'Easy',
  'ES': 'Fácil',
  'ET': 'Lihtne',
  'FI': 'Helppo',
  'FR': 'Facile',
  'HU': 'Könnyű',
  'ID': 'Mudah',
  'IT': 'Facile',
  'JA': '簡単',
  'KO': '쉬움',
  'LT': 'Lengva',
  'LV': 'Viegli',
  'NB': 'Lett',
  'NL': 'Makkelijk',
  'PL': 'Łatwe',
  'PT': 'Fácil',
  'RO': 'Ușor',
  'RU': 'Легко',
  'SK': 'Ľahké',
  'SL': 'Enostavno',
  'SV': 'Lätt',
  'TR': 'Kolay',
  'UK': 'Легко',
  'ZH': '简单',
  'ZH-HANS': '简单',
  'ZH-HANT': '簡單',
};

//hard
const Map<String, String> hardDifficulty = {
  'AR': 'صعب', // "Hard"
  'BG': 'Трудно',
  'CS': 'Těžké',
  'DA': 'Svær',
  'DE': 'Schwer',
  'EL': 'Δύσκολο',
  'EN': 'Hard',
  'ES': 'Difícil',
  'ET': 'Raske',
  'FI': 'Vaikea',
  'FR': 'Difficile',
  'HU': 'Nehéz',
  'ID': 'Sulit',
  'IT': 'Difficile',
  'JA': '難しい',
  'KO': '어려움',
  'LT': 'Sunku',
  'LV': 'Grūti',
  'NB': 'Vanskelig',
  'NL': 'Moeilijk',
  'PL': 'Trudne',
  'PT': 'Difícil',
  'RO': 'Greu',
  'RU': 'Сложно',
  'SK': 'Ťažké',
  'SL': 'Težko',
  'SV': 'Svårt',
  'TR': 'Zor',
  'UK': 'Важко',
  'ZH': '困难',
  'ZH-HANS': '困难',
  'ZH-HANT': '困難',
};

// card deleted
const Map<String, String> cardDeletedMessages = {
  'AR': 'تم حذف البطاقة.', // "The card was deleted"
  'BG': 'Картата бе изтрита.',
  'CS': 'Karta smazána.',
  'DA': 'Kort slettet.',
  'DE': 'Karte gelöscht.',
  'EL': 'Η κάρτα διαγράφηκε.',
  'EN': 'Card deleted.',
  'ES': 'Tarjeta eliminada.',
  'ET': 'Kaart kustutatud.',
  'FI': 'Kortti poistettu.',
  'FR': 'Carte supprimée.',
  'HU': 'Kártya törölve.',
  'ID': 'Kartu dihapus.',
  'IT': 'Carta eliminata.',
  'JA': 'カードを削除しました。', // "Card has been deleted"
  'KO': '카드가 삭제되었습니다.', // Formal/past tense
  'LT': 'Kortelė ištrinta.',
  'LV': 'Karte izdzēsta.',
  'NB': 'Kort slettet.',
  'NL': 'Kaart verwijderd.',
  'PL': 'Karta usunięta.',
  'PT': 'Cartão excluído.',
  'RO': 'Card șters.',
  'RU': 'Карточка удалена.',
  'SK': 'Karta odstránená.',
  'SL': 'Kartica izbrisana.',
  'SV': 'Kort borttaget.',
  'TR': 'Kart silindi.',
  'UK': 'Картку видалено.',
  'ZH': '卡片已删除。',
  'ZH-HANS': '卡片已删除。',
  'ZH-HANT': '卡片已刪除。',
};

// undo
const Map<String, String> undoMessages = {
  'AR': 'تراجع', // Common for "Undo"
  'BG': 'Отмени',
  'CS': 'Zpět',
  'DA': 'Fortryd',
  'DE': 'Rückgängig',
  'EL': 'Αναίρεση',
  'EN': 'Undo',
  'ES': 'Deshacer',
  'ET': 'Võta tagasi',
  'FI': 'Kumoa',
  'FR': 'Annuler',
  'HU': 'Visszavonás',
  'ID': 'Batalkan',
  'IT': 'Annulla',
  'JA': '元に戻す',
  'KO': '실행 취소',
  'LT': 'Atšaukti',
  'LV': 'Atsaukt',
  'NB': 'Angre',
  'NL': 'Ongedaan maken',
  'PL': 'Cofnij',
  'PT': 'Desfazer',
  'RO': 'Anulează',
  'RU': 'Отменить',
  'SK': 'Späť',
  'SL': 'Razveljavi',
  'SV': 'Ångra',
  'TR': 'Geri Al',
  'UK': 'Скасувати',
  'ZH': '撤销',
  'ZH-HANS': '撤销',
  'ZH-HANT': '復原',
};

// streak
const Map<String, String> dayStreakMessages = {
  'AR': 'يوم متتالية', // "Consecutive days" (singular form for flexibility)
  'BG': 'последователни дни', // "Consecutive days"
  'CS': 'dní v řadě', // "Days in a row"
  'DA': 'dage i træk', // "Days in a row"
  'DE': 'Tage in Folge', // "Days in a row"
  'EL': 'συνεχόμενες μέρες', // "Consecutive days"
  'EN': 'Day Streak',
  'ES': 'días seguidos', // "Days in a row"
  'ET': 'päeva järjest', // "Days in a row"
  'FI': 'päivää putkeen', // "Days in a row"
  'FR': 'jours consécutifs', // "Consecutive days"
  'HU': 'napos sorozat', // "Day streak"
  'ID': 'Hari Berturut-turut',
  'IT': 'giorni consecutivi', // "Consecutive days"
  'JA': '日連続', // "Days consecutive"
  'KO': '일 연속', // "Days in a row"
  'LT': 'dienų iš eilės', // "Days in a row"
  'LV': 'dienas pēc kārtas', // "Days in a row"
  'NB': 'dager på rad', // "Days in a row"
  'NL': 'dagen op rij', // "Days in a row"
  'PL': 'dni z rzędu', // "Days in a row"
  'PT': 'dias consecutivos', // "Consecutive days"
  'RO': 'zile consecutive',
  'RU': 'дней подряд', // "Days in a row"
  'SK': 'dní po sebe', // "Days in a row"
  'SL': 'dni zapored', // "Consecutive days"
  'SV': 'dagar i rad', // "Days in a row"
  'TR': 'Gün Üst Üste', // "Days in a row"
  'UK': 'днів поспіль', // "Days in a row"
  'ZH': '天连续', // "Days consecutive"
  'ZH-HANS': '天连续',
  'ZH-HANT': '天連續',
};

// books finished
const Map<String, String> booksFinishedMessages = {
  'AR': 'كتاب منتهي', // "Finished book" (singular for number flexibility)
  'BG': 'завършени книги', // "Finished books"
  'CS': 'dokončených knih', // "Completed books"
  'DA': 'færdige bøger', // "Finished books"
  'DE': 'Bücher abgeschlossen', // "Books completed"
  'EL': 'ολοκληρωμένα βιβλία', // "Completed books"
  'EN': 'Books Finished',
  'ES': 'libros terminados', // "Finished books"
  'ET': 'lõpetatud raamatud', // "Finished books"
  'FI': 'luettua kirjaa', // "Books read"
  'FR': 'livres terminés', // "Finished books"
  'HU': 'elolvasott könyv', // "Books read"
  'ID': 'Buku Selesai',
  'IT': 'libri completati', // "Completed books"
  'JA': '読了書籍', // "Finished books"
  'KO': '완독한 책', // "Books finished reading"
  'LT': 'užbaigtų knygų', // "Completed books"
  'LV': 'pabeigtas grāmata', // "Finished book"
  'NB': 'bøker fullført', // "Books completed"
  'NL': 'boeken voltooid', // "Books completed"
  'PL': 'ukończone książki', // "Finished books"
  'PT': 'livros concluídos', // "Completed books"
  'RO': 'cărți terminate',
  'RU': 'завершённых книг', // "Completed books"
  'SK': 'dokončených kníh', // "Completed books"
  'SL': 'končane knjige', // "Finished books"
  'SV': 'avslutade böcker', // "Finished books"
  'TR': 'Tamamlanan Kitap', // "Completed book"
  'UK': 'завершених книг', // "Completed books"
  'ZH': '完成的书籍', // "Finished books"
  'ZH-HANS': '完成的书籍',
  'ZH-HANT': '完成的書籍',
};

// words learned
const Map<String, String> wordsLearnedMessages = {
  'AR': 'كلمة مكتسبة', // "Learned word" (singular for flexibility)
  'BG': 'научени думи', // "Learned words"
  'CS': 'naučených slov', // "Learned words"
  'DA': 'lærte ord', // "Learned words"
  'DE': 'gelernte Wörter', // "Learned words"
  'EL': 'μαθημένες λέξεις', // "Learned words"
  'EN': 'Words Learned',
  'ES': 'palabras aprendidas', // "Learned words"
  'ET': 'õpitud sõnu', // "Learned words"
  'FI': 'oppittua sanaa', // "Learned word"
  'FR': 'mots appris', // "Learned words"
  'HU': 'megtanult szó', // "Learned word"
  'ID': 'Kata Dipelajari',
  'IT': 'parole imparate', // "Learned words"
  'JA': '習得単語', // "Learned words"
  'KO': '학습한 단어', // "Learned words"
  'LT': 'išmoktų žodžių', // "Learned words"
  'LV': 'apgūts vārds', // "Learned word"
  'NB': 'lærte ord', // "Learned words"
  'NL': 'geleerde woorden', // "Learned words"
  'PL': 'nauczone słowa', // "Learned words"
  'PT': 'palavras aprendidas', // "Learned words"
  'RO': 'cuvinte învățate',
  'RU': 'изученных слов', // "Learned words"
  'SK': 'naučených slov', // "Learned words"
  'SL': 'naučene besede', // "Learned words"
  'SV': 'inlärda ord', // "Learned words"
  'TR': 'Öğrenilen Kelime', // "Learned word"
  'UK': 'вивчених слів', // "Learned words"
  'ZH': '学会的单词', // "Learned words"
  'ZH-HANS': '学会的单词',
  'ZH-HANT': '學會的單詞',
};