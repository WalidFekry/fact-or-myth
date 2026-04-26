import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';

class ApiService {
  final String baseUrl = AppConstants.baseUrl;

  Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? params}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: params);
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('خطأ في الاتصال: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('خطأ في الاتصال: ${e.toString()}');
    }
  }

  Future<void> deleteAccount(int userId) async {
    await post('/delete-account.php', {'user_id': userId});
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);
    
    // Check if response indicates success
    if (data['success'] == true) {
      return data;
    }
    
    // Handle error responses
    final errorMessage = data['message'] ?? 'حدث خطأ';
    
    // For specific error cases, throw with the exact message
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Backend returned 200 but success: false
      throw Exception(errorMessage);
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      // Client errors (400, 409, etc.)
      throw Exception(errorMessage);
    } else if (response.statusCode >= 500) {
      // Server errors
      throw Exception('خطأ في الخادم: $errorMessage');
    }
    
    throw Exception(errorMessage);
  }
}
