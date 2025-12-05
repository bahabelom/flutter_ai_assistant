import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service for handling API calls to the NestJS backend
class ApiService {
  // Base URL from .env file, defaults to localhost:3000
  String get baseUrl {
    try {
      return dotenv.env['API_URL'] ?? 'http://localhost:3000';
    } catch (e) {
      // If dotenv is not initialized, use default
      return 'http://localhost:3000';
    }
  }

  /// Send a question to the backend and get AI response
  /// 
  /// [text] - The user's input text
  /// [targetLanguage] - Language code (am, ti, om, en)
  /// 
  /// Returns a map with translatedInput, aiReply, and translatedReply
  Future<Map<String, dynamic>> askQuestion({
    required String text,
    required String targetLanguage,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/ai/ask');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'text': text,
          'targetLanguage': targetLanguage,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout. Please check your connection.');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } else if (response.statusCode == 404) {
        // Backend not running - return mock response for testing
        return _getMockResponse(text, targetLanguage);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      // If connection fails, return mock response for testing
      if (e.toString().contains('Failed host lookup') ||
          e.toString().contains('Connection refused')) {
        return _getMockResponse(text, targetLanguage);
      }
      rethrow;
    }
  }

  /// Mock response for testing when backend is not available
  Map<String, dynamic> _getMockResponse(String text, String targetLanguage) {
    final mockReplies = {
      'am': 'እባክዎን የእኔን የኋላ መጨረሻ አገልግሎት ይመልከቱ።',
      'ti': 'እባክኹም ናይ እኔ ወደን ኣገልግሎት ርኣዩ።',
      'om': 'Maaloo naaf hordofaa seerwisi koo ilaali.',
      'en': 'How can I help you?',
    };

    return {
      'translatedInput': text,
      'aiReply': 'This is a mock response. Please start the backend server.',
      'translatedReply': mockReplies[targetLanguage] ?? mockReplies['en']!,
    };
  }
}

