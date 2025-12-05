# Quick Setup Guide

## Step 1: Install Dependencies

```bash
flutter pub get
```

## Step 2: Configure Environment

The `.env` file is already created. Update it based on your setup:

- **Android Emulator**: `API_URL=http://10.0.2.2:3000`
- **iOS Simulator**: `API_URL=http://localhost:3000`
- **Physical Device**: `API_URL=http://YOUR_COMPUTER_IP:3000`

## Step 3: Run the App

```bash
flutter run
```

## Testing Without Backend

The app includes mock responses when the backend is unavailable, so you can test:
- ✅ UI layout and navigation
- ✅ Speech recognition (on physical device or emulator with mic)
- ✅ Text input
- ✅ Language selection
- ✅ Text-to-speech

## File Structure Created

```
lib/
├── main.dart                    ✅ App entry point
├── core/
│   ├── api_service.dart        ✅ Backend API calls
│   └── speech_service.dart     ✅ Speech-to-text
├── providers/
│   └── ai_provider.dart        ✅ State management
├── screens/
│   └── home_screen.dart         ✅ Main UI
└── widgets/
    ├── mic_button.dart         ✅ Microphone button
    └── response_box.dart       ✅ Response display
```

## Permissions Added

- ✅ Android: RECORD_AUDIO, INTERNET
- ✅ iOS: NSSpeechRecognitionUsageDescription, NSMicrophoneUsageDescription

## Next Steps

1. Start your NestJS backend server
2. Update `.env` with correct API_URL
3. Run `flutter run`
4. Test speech recognition and API calls

## Troubleshooting

**Speech not working?**
- Check device permissions
- Test on physical device (emulators may not support mic)

**Can't connect to backend?**
- Verify backend is running
- Check API_URL in `.env`
- For Android emulator, use `10.0.2.2` instead of `localhost`


