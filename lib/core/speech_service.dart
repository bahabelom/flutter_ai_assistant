import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'vosk_speech_service.dart';

/// Service for handling speech-to-text functionality
/// Uses Vosk for Ethiopian languages (Amharic, Tigrinya, Oromo)
/// Falls back to speech_to_text for English
class SpeechService {
  final VoskSpeechService _voskService = VoskSpeechService();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isAvailable = false;

  /// Initialize speech recognition
  Future<bool> initialize() async {
    try {
      _isAvailable = await _speech.initialize(
        onError: (error) {
          print('Speech recognition error: $error');
        },
        onStatus: (status) {
          print('Speech recognition status: $status');
        },
      );
      return _isAvailable;
    } catch (e) {
      print('Failed to initialize speech recognition: $e');
      return false;
    }
  }

  /// Check if speech recognition is available
  bool get isAvailable => _isAvailable;

  /// Check if currently listening
  bool get isListening => _isListening;

  /// Get available locales for speech recognition
  Future<List<stt.LocaleName>> getAvailableLocales() async {
    return await _speech.locales();
  }

  /// Get speech recognition locale ID from language code
  /// Returns the locale ID if available, null otherwise
  Future<String?> getLocaleIdForLanguage(String languageCode) async {
    final availableLocales = await getAvailableLocales();
    
    // Map language codes to exact locale IDs we're looking for
    final localeMap = {
      'en': ['en_US', 'en-US', 'en_GB', 'en-GB', 'en_AU', 'en-AU', 'en_CA', 'en-CA', 'en_IN', 'en-IN'],
      'am': ['am_ET', 'am-ET'],  // Amharic - Ethiopia only
      'ti': ['ti_ET', 'ti-ET'],  // Tigrinya - Ethiopia only
      'om': ['om_ET', 'om-ET'],  // Afaan Oromo - Ethiopia only
    };

    final possibleLocales = localeMap[languageCode] ?? [];
    
    // First, try exact matches (most reliable)
    for (final possibleLocale in possibleLocales) {
      try {
        final found = availableLocales.firstWhere(
          (locale) => locale.localeId.toLowerCase() == possibleLocale.toLowerCase(),
        );
        if (found.localeId.isNotEmpty) {
          print('✓ Exact match found for $languageCode: ${found.localeId} (${found.name})');
          return found.localeId;
        }
      } catch (e) {
        // Continue searching
        continue;
      }
    }
    
    // Then try prefix matches (e.g., "am_ET" matches "am_ET_xxx")
    for (final possibleLocale in possibleLocales) {
      try {
        final localePrefix = possibleLocale.toLowerCase().split('_')[0]; // Get "am" from "am_ET"
        final found = availableLocales.firstWhere(
          (locale) {
            final localeParts = locale.localeId.toLowerCase().split('_');
            return localeParts.isNotEmpty && localeParts[0] == localePrefix;
          },
        );
        if (found.localeId.isNotEmpty) {
          print('✓ Prefix match found for $languageCode: ${found.localeId} (${found.name})');
          return found.localeId;
        }
      } catch (e) {
        // Continue searching
        continue;
      }
    }

    // Log available locales for debugging
    print('✗ No match found for $languageCode. Available locales:');
    for (final locale in availableLocales.take(20)) {
      print('  - ${locale.localeId}: ${locale.name}');
    }

    // Return null - don't fallback to wrong language
    return null;
  }
  
  /// Check if a specific language is supported
  Future<bool> isLanguageSupported(String languageCode) async {
    final localeId = await getLocaleIdForLanguage(languageCode);
    return localeId != null;
  }

  /// Start listening for speech input
  /// 
  /// [onResult] - Callback function that receives the recognized text
  /// [onError] - Optional callback for error handling
  /// [languageCode] - Language code (en, am, ti, om) to use for recognition
  Future<void> startListening({
    required Function(String text) onResult,
    Function(String error)? onError,
    String? languageCode,
  }) async {
    if (_isListening) {
      return;
    }

    // Use Vosk for Ethiopian languages (am, ti, om) - offline support
    if (languageCode != null && ['am', 'ti', 'om'].contains(languageCode)) {
      try {
        // Try Vosk first
        await _voskService.startListening(
          onResult: (text) {
            if (text.isNotEmpty) {
              _isListening = true;
              onResult(text);
            }
          },
          onError: (error) {
            // Vosk failed - show helpful message but don't block
            print('Vosk error: $error');
            _isListening = false;
            onError?.call('Vosk models not found. Please download language models from https://alphacephei.com/vosk/models and place them in assets/models/. For now, you can type your question manually.');
          },
          languageCode: languageCode,
        );
        _isListening = true;
        return;
      } catch (e) {
        // Vosk failed - show message but allow user to continue with text input
        print('Vosk initialization failed: $e');
        _isListening = false;
        onError?.call('Offline speech recognition not available. Vosk models need to be downloaded. You can still type your question manually in ${languageCode.toUpperCase()}.');
        return;
      }
    }

    // Use speech_to_text for English or fallback
    if (!_isAvailable) {
      onError?.call('Speech recognition is not available');
      return;
    }

    try {
      _isListening = true;
      
      // Get locale ID for the selected language
      String? localeId;
      if (languageCode != null) {
        localeId = await getLocaleIdForLanguage(languageCode);
        if (localeId == null && languageCode != 'en') {
          // Language not supported - warn user but don't proceed
          final availableLocales = await getAvailableLocales();
          final localeList = availableLocales.map((l) => l.localeId).join(', ');
          onError?.call('${languageCode.toUpperCase()} speech recognition is not available on this device. Available: $localeList');
          _isListening = false;
          return;
        } else if (localeId != null) {
          print('✓ Using locale: $localeId for language: $languageCode');
        }
      }
      
      await _speech.listen(
        onResult: (result) {
          print('Speech result: "${result.recognizedWords}" (final: ${result.finalResult}, locale: $localeId)');
          if (result.finalResult) {
            _isListening = false;
            onResult(result.recognizedWords);
          } else {
            // Update UI with partial results if needed
            onResult(result.recognizedWords);
          }
        },
        localeId: localeId, // Use selected language locale
      );
    } catch (e) {
      _isListening = false;
      onError?.call('Failed to start listening: $e');
    }
  }

  /// Stop listening for speech input
  Future<void> stopListening() async {
    if (_isListening) {
      // Stop Vosk if it's running
      if (_voskService.isListening) {
        await _voskService.stopListening();
      }
      // Stop speech_to_text if it's running
      await _speech.stop();
      _isListening = false;
    }
  }

  /// Cancel speech recognition
  Future<void> cancel() async {
    if (_isListening) {
      // Cancel Vosk if it's running
      if (_voskService.isListening) {
        await _voskService.cancel();
      }
      // Cancel speech_to_text if it's running
      await _speech.cancel();
      _isListening = false;
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _voskService.dispose();
    _speech.cancel();
  }
}


