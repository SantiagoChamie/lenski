# LenSki

LenSki is an autonomous language learning desktop application designed to help users practice and improve foreign language skills through translation, pronunciation, and interactive exercises. It is built with Flutter and currently supported only on Windows systems.

---

## Features

- **Text Translation**: Seamless translation powered by DeepL API.
- **Text-to-Speech (TTS)**: Utilizes the computer's native TTS service for pronunciation practice.
- **Interactive Exercises**: Flashcards, listening comprehension, and writing prompts.
- **Settings Screen**: Configure API keys, select target language, and manage TTS voices.

---

## Installation

1. Download the latest Windows installer (`LenSki-Setup.exe`).
2. Run the `.exe` file and follow the on-screen instructions.

---

## Configuration

### DeepL API Key

1. Obtain your API key from [DeepL](https://www.deepl.com/pro).
2. Open LenSki and navigate to **Settings** → **API Key**.
3. Paste your DeepL key into the input field.

### Text-to-Speech Setup

1. Ensure your Windows system has the appropriate language voices installed.
2. Go to **Settings** → **Time & Language** → **Speech**.
3. Add or manage speech voices for the language you want to learn.

---

## Usage

1. Launch LenSki.
2. Choose the language you want to learn.
3. Enter text or select from exercises.
4. Click **Translate** to view the translation.
5. Click **Play** to hear the pronunciation via the system’s TTS.

---

## Building from Source

### Requirements

- Flutter SDK with Windows desktop support
- Git

### Steps

```bash
git clone https://github.com/yourusername/LenSki.git
cd LenSki

flutter channel stable
flutter upgrade
flutter config --enable-windows-desktop

flutter pub get
flutter run -d windows

flutter build windows
```

---

## Contributing

Contributions are welcome!

1. Fork the repository.
2. Create a new branch:

   ```bash
   git checkout -b feature-name
   ```
3. Commit your changes:
    ```bash
   git commit -m "Add new feature"
   ```
4. Push to your fork:
    ```bash
   git push origin feature-name
   ```
5. Open a Pull Request.

Please ensure your code follows the existing style and includes documentation where necessary.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Contact

For questions, suggestions, or support, please open an issue on the GitHub repository or contact:
santiagochamie@gmail.com