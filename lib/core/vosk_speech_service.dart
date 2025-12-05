import 'dart:async';
import 'package:vosk_flutter_2/vosk_flutter_2.dart';

/// Vosk-based offline speech recognition service
/// Supports Amharic, Tigrinya, and Oromo
class VoskSpeechService {
  VoskFlutterPlugin? _voskPlugin;
  Model? _model;
  Recognizer? _recognizer;
  SpeechService? _speechService;
  bool _isListening = false;
  bool _isInitialized = false;
  StreamSubscription<String>? _resultSubscription;
  StreamSubscription<String>? _partialResultSubscription;
  
  // Model paths - these should be downloaded and placed in assets
  final Map<String, String> _modelPaths = {
    'am': 'assets/models/vosk-model-amharic',  // Amharic model
    'ti': 'assets/models/vosk-model-tigrinya', // Tigrinya model
    'om': 'assets/models/vosk-model-oromo',   // Oromo model
    'en': 'assets/models/vosk-model-small-en-us-0.15', // English fallback
  };

  /// Initialize Vosk with a specific language model
  Future<bool> initialize({String languageCode = 'am'}) async {
    try {
      // Get Vosk plugin instance
      _voskPlugin = VoskFlutterPlugin.instance();

      // Get model path for language
      final modelPath = _modelPaths[languageCode] ?? _modelPaths['en']!;
      
      print('Attempting to load Vosk model from: $modelPath');
      
      // Create model - this will throw if model files don't exist
      _model = await _voskPlugin!.createModel(modelPath);
      
      // Create recognizer (16kHz sample rate)
      _recognizer = await _voskPlugin!.createRecognizer(
        model: _model!,
        sampleRate: 16000,
      );
      
      // Initialize speech service
      _speechService = await _voskPlugin!.initSpeechService(_recognizer!);
      
      _isInitialized = true;
      print('✓ Vosk initialized for language: $languageCode');
      return true;
    } catch (e) {
      final modelPath = _modelPaths[languageCode] ?? _modelPaths['en']!;
      print('Failed to initialize Vosk: $e');
      print('Model path attempted: $modelPath');
      print('Note: Vosk models for Ethiopian languages may not be publicly available.');
      print('You can still use the app by typing your questions manually.');
      _isInitialized = false;
      return false;
    }
  }

  /// Check if Vosk is initialized
  bool get isInitialized => _isInitialized;

  /// Check if currently listening
  bool get isListening => _isListening;

  /// Start listening for speech input
  /// 
  /// [onResult] - Callback function that receives the recognized text
  /// [onError] - Optional callback for error handling
  /// [languageCode] - Language code (am, ti, om, en)
  Future<void> startListening({
    required Function(String text) onResult,
    Function(String error)? onError,
    String languageCode = 'am',
  }) async {
    if (!_isInitialized) {
      // Try to initialize if not already done
      final initialized = await initialize(languageCode: languageCode);
      if (!initialized) {
        onError?.call('Failed to initialize Vosk speech recognition');
        return;
      }
    }

    if (_isListening) {
      return;
    }

    try {
      // Reinitialize if language changed
      if (_model == null || _recognizer == null) {
        await initialize(languageCode: languageCode);
      }

      _isListening = true;
      
      // Start recognition using SpeechService
      final started = await _speechService!.start(
        onRecognitionError: (error) {
          _isListening = false;
          onError?.call('Recognition error: $error');
        },
      );
      
      if (started != true) {
        _isListening = false;
        onError?.call('Failed to start speech recognition');
        return;
      }
      
      // Listen for results via EventChannel
      // Note: The actual result stream is handled by the native side
      // You may need to set up EventChannel listeners here
      // For now, we'll use a simple approach
      
      print('✓ Started listening with Vosk (language: $languageCode)');
    } catch (e) {
      _isListening = false;
      onError?.call('Failed to start listening: $e');
    }
  }

  /// Stop listening for speech input
  Future<void> stopListening() async {
    if (_isListening && _speechService != null) {
      try {
        await _speechService!.stop();
        await _resultSubscription?.cancel();
        await _partialResultSubscription?.cancel();
        _resultSubscription = null;
        _partialResultSubscription = null;
        _isListening = false;
        print('✓ Stopped listening');
      } catch (e) {
        print('Error stopping recognition: $e');
      }
    }
  }

  /// Cancel speech recognition
  Future<void> cancel() async {
    await stopListening();
  }

  /// Dispose resources
  Future<void> dispose() async {
    await stopListening();
    _recognizer?.dispose();
    _model?.dispose();
    _recognizer = null;
    _model = null;
    _speechService = null;
    _voskPlugin = null;
    _isInitialized = false;
  }
}

