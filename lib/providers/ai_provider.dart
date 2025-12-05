import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../core/api_service.dart';
import '../core/speech_service.dart';

/// Provider for managing AI Assistant state and operations
class AiProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final SpeechService _speechService = SpeechService();
  final FlutterTts _tts = FlutterTts();

  // State variables
  String _inputText = '';
  String _responseText = '';
  String _selectedLanguage = 'en';
  bool _isLoading = false;
  bool _isListening = false;
  String _listeningText = '';
  bool _speechAvailable = false;
  bool _shouldFocusTextField = false;

  // Getters
  String get inputText => _inputText;
  String get responseText => _responseText;
  String get selectedLanguage => _selectedLanguage;
  bool get isLoading => _isLoading;
  bool get isListening => _isListening;
  String get listeningText => _listeningText;
  bool get speechAvailable => _speechAvailable;
  bool get shouldFocusTextField => _shouldFocusTextField;
  
  /// Clear the focus flag after it's been used
  void clearFocusFlag() {
    _shouldFocusTextField = false;
    notifyListeners();
  }

  // Language options
  final Map<String, String> languages = {
    'en': 'English',
    'am': 'Amharic',
    'ti': 'Tigrinya',
    'om': 'Afaan Oromo',
  };

  AiProvider() {
    _initializeServices();
  }

  /// Initialize speech recognition and TTS
  Future<void> _initializeServices() async {
    // Initialize speech recognition
    _speechAvailable = await _speechService.initialize();
    notifyListeners();

    // Configure TTS
    await _tts.setLanguage(_getTtsLanguageCode(_selectedLanguage));
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  /// Get TTS language code from language code
  String _getTtsLanguageCode(String langCode) {
    switch (langCode) {
      case 'am':
        return 'am-ET'; // Amharic
      case 'ti':
        return 'ti-ET'; // Tigrinya
      case 'om':
        return 'om-ET'; // Afaan Oromo
      case 'en':
      default:
        return 'en-US'; // English
    }
  }

  /// Update input text
  void updateInputText(String text) {
    _inputText = text;
    notifyListeners();
  }

  /// Update selected language
  void updateSelectedLanguage(String languageCode) {
    _selectedLanguage = languageCode;
    _tts.setLanguage(_getTtsLanguageCode(languageCode));
    notifyListeners();
  }

  /// Start listening for speech input
  Future<void> startListening() async {
    if (!_speechAvailable && _selectedLanguage == 'en') {
      // Focus text field instead of showing error
      _shouldFocusTextField = true;
      _isListening = false;
      notifyListeners();
      return;
    }

    _isListening = true;
    _listeningText = '';
    notifyListeners();

    await _speechService.startListening(
      onResult: (text) {
        _listeningText = text;
        _inputText = text;
        notifyListeners();
      },
      onError: (error) {
        _isListening = false;
        // Instead of showing error, redirect to text input
        _shouldFocusTextField = true;
        notifyListeners();
      },
      languageCode: _selectedLanguage, // Pass selected language for recognition
    );
  }

  /// Stop listening for speech input
  Future<void> stopListening() async {
    await _speechService.stopListening();
    _isListening = false;
    notifyListeners();
  }

  /// Send question to backend and get AI response
  Future<void> sendQuestion() async {
    if (_inputText.trim().isEmpty) {
      _responseText = 'Please enter or speak a question.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _responseText = '';
    notifyListeners();

    try {
      final result = await _apiService.askQuestion(
        text: _inputText.trim(),
        targetLanguage: _selectedLanguage,
      );

      _responseText = result['translatedReply'] ?? 
                     result['aiReply'] ?? 
                     'No response received.';
      
      // Clear input after successful send
      _inputText = '';
      _listeningText = '';
    } catch (e) {
      _responseText = 'Error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Speak the response using text-to-speech
  Future<void> speakResponse() async {
    if (_responseText.isEmpty) {
      return;
    }

    try {
      await _tts.setLanguage(_getTtsLanguageCode(_selectedLanguage));
      await _tts.speak(_responseText);
    } catch (e) {
      _responseText = 'TTS Error: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Stop speaking
  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  @override
  void dispose() {
    _speechService.dispose();
    _tts.stop();
    super.dispose();
  }
}


