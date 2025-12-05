import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service for handling API calls to the NestJS backend
class ApiService {
  // Base URL - detects Android emulator and uses appropriate URL
  String get baseUrl {
    try {
      final envUrl = dotenv.env['API_URL'];
      if (envUrl != null && envUrl.isNotEmpty) {
        return envUrl;
      }
    } catch (e) {
      // If dotenv is not initialized, continue with default logic
    }
    
    // Default: Use 10.0.2.2 for Android emulator, localhost for others
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3003';
    }
    return 'http://localhost:3003';
  }


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
          'language': targetLanguage,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout. Please check your connection and ensure the backend is running on port 3003.');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Validate response structure
        if (data.containsKey('aiReply')) {
          return {
            'aiReply': data['aiReply'],
            'inputText': data['inputText'] ?? text,
          };
        } else {
          throw Exception('Invalid response format: missing aiReply field');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Endpoint not found. Please check if the backend is running on port 3003.');
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        // Client error (400-499)
        final errorBody = response.body.isNotEmpty 
            ? jsonDecode(response.body) as Map<String, dynamic>? 
            : null;
        final errorMessage = errorBody?['message'] ?? errorBody?['error'] ?? 'Client error';
        throw Exception('Client error (${response.statusCode}): $errorMessage');
      } else if (response.statusCode >= 500) {
        // Server error (500+)
        throw Exception('Server error (${response.statusCode}). Please try again later.');
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      // Network/connection errors
      throw Exception('Cannot connect to backend at $baseUrl. Please ensure the server is running. Error: ${e.message}');
    } on FormatException catch (e) {
      // JSON parsing errors
      throw Exception('Invalid response from server. Error: ${e.message}');
    } on http.ClientException catch (e) {
      // HTTP client errors
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      // Re-throw if it's already an Exception with a message
      if (e is Exception) {
        rethrow;
      }
      // Wrap other errors
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

}

