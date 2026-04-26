import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';

class ApiService {
  final ApiClient _apiClient;

  ApiService(this._apiClient);

  Future<Map<String, dynamic>> get(String endpoint, {Map<String, dynamic>? params}) async {
    try {
      final response = await _apiClient.get(
        endpoint,
        queryParameters: params,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw ApiException(
        message: e.error?.toString() ?? 'خطأ في الاتصال',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    } catch (e) {
      throw ApiException(message: 'خطأ في الاتصال: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await _apiClient.post(
        endpoint,
        data: body,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw ApiException(
        message: e.error?.toString() ?? 'خطأ في الاتصال',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    } catch (e) {
      throw ApiException(message: 'خطأ في الاتصال: ${e.toString()}');
    }
  }

  Future<void> deleteAccount(int userId) async {
    await post('/delete-account.php', {'user_id': userId});
  }

  Map<String, dynamic> _handleResponse(Response response) {
    final data = response.data;
    
    // Handle non-JSON responses
    if (data is! Map<String, dynamic>) {
      throw ApiException(
        message: 'استجابة غير صالحة من الخادم',
        statusCode: response.statusCode,
      );
    }
    
    // Check if response indicates success
    if (data['success'] == true) {
      return data;
    }
    
    // Handle error responses
    final errorMessage = data['message'] ?? 'حدث خطأ';
    final statusCode = response.statusCode ?? 0;
    
    // For specific error cases, throw with the exact message
    if (statusCode >= 200 && statusCode < 300) {
      // Backend returned 200 but success: false
      throw ApiException(
        message: errorMessage,
        statusCode: statusCode,
        data: data,
      );
    } else if (statusCode >= 400 && statusCode < 500) {
      // Client errors (400, 409, etc.)
      throw ApiException(
        message: errorMessage,
        statusCode: statusCode,
        data: data,
      );
    } else if (statusCode >= 500) {
      // Server errors
      throw ApiException(
        message: 'خطأ في الخادم: $errorMessage',
        statusCode: statusCode,
        data: data,
      );
    }
    
    throw ApiException(
      message: errorMessage,
      statusCode: statusCode,
      data: data,
    );
  }
}
