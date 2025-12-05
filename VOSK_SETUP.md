# Vosk Offline Speech Recognition Setup

This guide explains how to set up Vosk for offline speech recognition supporting Amharic, Tigrinya, and Oromo.

## Step 1: Download Language Models

Vosk requires language models to work. You need to download models for each language:

### Download Links:
1. **Amharic Model**: Check [Vosk Models](https://alphacephei.com/vosk/models) for Amharic
2. **Tigrinya Model**: Check [Vosk Models](https://alphacephei.com/vosk/models) for Tigrinya  
3. **Oromo Model**: Check [Vosk Models](https://alphacephei.com/vosk/models) for Oromo
4. **English Model** (fallback): [vosk-model-small-en-us-0.15](https://alphacephei.com/vosk/models/vosk-model-small-en-us-0.15.zip)

**Note**: If Ethiopian language models aren't available on the official Vosk site, you may need to:
- Train custom models
- Use community-contributed models
- Contact Vosk developers for Ethiopian language support

## Step 2: Extract and Place Models

1. Download the model ZIP files
2. Extract each model to a folder
3. Place them in your Flutter project:

```
assets/
  models/
    vosk-model-amharic/
      (model files here)
    vosk-model-tigrinya/
      (model files here)
    vosk-model-oromo/
      (model files here)
    vosk-model-small-en-us-0.15/
      (model files here)
```

## Step 3: Update pubspec.yaml

Add the models to your assets:

```yaml
flutter:
  assets:
    - .env
    - assets/models/vosk-model-amharic/
    - assets/models/vosk-model-tigrinya/
    - assets/models/vosk-model-oromo/
    - assets/models/vosk-model-small-en-us-0.15/
```

## Step 4: Verify Package Installation

The app uses `vosk_flutter_2` package. If it's not available, you may need to:

1. Check if the package exists: https://pub.dev/packages/vosk_flutter_2
2. If not available, consider alternatives:
   - `speech_to_text` (online, limited language support)
   - Custom native implementation
   - Other offline STT solutions

## Step 5: Test the Implementation

1. Run `flutter pub get`
2. Build and run the app
3. Select Amharic/Tigrinya/Oromo from the language dropdown
4. Press and hold the mic button
5. Speak in the selected language
6. The text should appear in Amharic/Tigrinya/Oromo script

## Troubleshooting

### Model Not Found Error
- Verify model paths in `lib/core/vosk_speech_service.dart`
- Check that models are in the correct `assets/models/` directory
- Ensure `pubspec.yaml` includes all model directories

### Package Not Found
- Check if `vosk_flutter_2` is available on pub.dev
- If not, you may need to use a fork or alternative package
- Consider using native Android/iOS implementations

### Permission Issues
- Ensure `RECORD_AUDIO` permission is in `AndroidManifest.xml`
- Request microphone permission at runtime

## Alternative: Use Online Speech Recognition

If Vosk models aren't available for Ethiopian languages, you can:
1. Use Google Cloud Speech-to-Text API (supports Amharic)
2. Use Azure Speech Services (supports multiple languages)
3. Use AWS Transcribe (check language support)

These require internet connection but provide better accuracy.

