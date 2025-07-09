import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;

class AiService {
  // IMPORTANT: This is the address of your local machine.
  // For the Android Emulator, 'localhost' maps to the emulator itself.
  // To connect to your computer's localhost, you MUST use '10.0.2.2'.
  // For the iOS Simulator, 'localhost' works correctly.
  final String _baseUrl = 'http://192.168.0.104:5000';

  /// Sends the user's input text to the Python backend for processing.
  /// Returns a map with 'item', 'amount', and 'category' on success.
  /// Returns null on failure.
  Future<Map<String, dynamic>?> processExpenseText(String text) async {
    // Make sure your Python Flask server is running before calling this!
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/process'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({'text': text}),
      ).timeout(const Duration(seconds: 15)); // Add a timeout for safety

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, then parse the JSON.
        return json.decode(response.body);
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception and log the error.
        print('Failed to process text. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      // This catches network errors, timeouts, etc.
      print('Error connecting to the AI service: $e');
      return null;
    }
  }
}