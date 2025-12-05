# Ethiopia AI Assistant - Flutter App

A multilingual AI Assistant mobile app built with Flutter that supports Amharic, Tigrinya, Afaan Oromo, and English. Users can speak or type questions and receive AI-generated answers in their preferred language.

## Features

- 🎤 **Speech-to-Text**: Press and hold the microphone button to speak your question
- ⌨️ **Text Input**: Type your questions manually
- 🌍 **Multilingual Support**: Choose from Amharic, Tigrinya, Afaan Oromo, or English
- 🤖 **AI Responses**: Get intelligent answers from the backend AI service
- 🔊 **Text-to-Speech**: Listen to responses in your selected language
- 🎨 **Modern UI**: Clean, beautiful interface with Google Fonts

## Prerequisites

- Flutter SDK (3.10.1 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Backend NestJS server running (see backend setup)

## Installation

1. **Clone or navigate to the project directory**
   ```bash
   cd ai_assistant_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**
   
   Create a `.env` file in the root directory (already created):
   ```env
   API_URL=http://localhost:3000
   ```
   
   **Important Notes:**
   - For **Android Emulator**: Use `http://10.0.2.2:3000`
   - For **iOS Simulator**: Use `http://localhost:3000`
   - For **Physical Device**: Use your computer's IP address (e.g., `http://192.168.1.100:3000`)

4. **Update Android permissions** (if needed)
   
   The `speech_to_text` package should automatically add required permissions, but verify in:
   `android/app/src/main/AndroidManifest.xml`
   
   Should include:
   ```xml
   <uses-permission android:name="android.permission.RECORD_AUDIO"/>
   <uses-permission android:name="android.permission.INTERNET"/>
   ```

5. **Update iOS permissions** (if needed)
   
   Add to `ios/Runner/Info.plist`:
   ```xml
   <key>NSSpeechRecognitionUsageDescription</key>
   <string>This app needs speech recognition to convert your voice to text.</string>
   <key>NSMicrophoneUsageDescription</key>
   <string>This app needs microphone access to record your voice.</string>
   ```

## Running the App

1. **Start the backend server first** (NestJS)
   ```bash
   # In the backend directory
   npm run start:dev
   ```

2. **Run the Flutter app**
   ```bash
   flutter run
   ```

   Or run on a specific device:
   ```bash
   flutter run -d <device-id>
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── core/
│   ├── api_service.dart      # Backend API communication
│   └── speech_service.dart   # Speech-to-text functionality
├── providers/
│   └── ai_provider.dart      # State management with Provider
├── screens/
│   └── home_screen.dart      # Main UI screen
└── widgets/
    ├── mic_button.dart       # Microphone button widget
    └── response_box.dart     # AI response display widget
```

## Usage

1. **Select Language**: Choose your preferred response language from the dropdown (Amharic, Tigrinya, Afaan Oromo, or English)

2. **Input Question**:
   - **Voice**: Press and hold the microphone button, speak your question, then release
   - **Text**: Type your question in the text field

3. **Send**: Tap the "Send" button to submit your question

4. **View Response**: The AI response will appear in the response box

5. **Listen**: Tap the speaker icon to hear the response read aloud

## Testing Without Backend

If the backend is not running, the app will automatically show mock responses for testing purposes. This allows you to test the UI and speech recognition features independently.

## Troubleshooting

### Speech Recognition Not Working
- Check device permissions (microphone access)
- Ensure you're testing on a physical device or emulator with microphone support
- Some emulators may not support speech recognition

### Cannot Connect to Backend
- Verify the backend server is running
- Check the `API_URL` in `.env` matches your setup
- For Android emulator, use `10.0.2.2` instead of `localhost`
- For physical device, ensure both devices are on the same network

### Text-to-Speech Not Working
- Some languages may not be fully supported on all devices
- Check device language settings
- Try switching to English to test TTS functionality

## Dependencies

- `speech_to_text: ^6.6.0` - Speech recognition
- `flutter_tts: ^3.8.3` - Text-to-speech
- `provider: ^6.1.2` - State management
- `http: ^1.2.0` - HTTP requests
- `flutter_dotenv: ^5.1.0` - Environment variables
- `google_fonts: ^6.1.0` - Custom fonts

## Example API Request

The app sends POST requests to the backend:

```bash
POST http://localhost:3000/ai/ask
Content-Type: application/json

{
  "text": "How can I help you?",
  "targetLanguage": "am"
}
```

Expected response:
```json
{
  "translatedInput": "...",
  "aiReply": "...",
  "translatedReply": "..."
}
```

## License

This project is part of the Ethiopia AI Assistant application.

## Support

For issues or questions, please check:
- Flutter documentation: https://flutter.dev/docs
- Backend repository for API documentation
