import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/app_constants.dart';

/// Centralized API client using Dio
/// Singleton pattern with GetIt
class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) {
          // Accept all status codes to handle them manually
          return status != null && status < 600;
        },
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    // Add pretty logger only in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    }

    // Add error handling interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, ErrorInterceptorHandler handler) {
          // Handle different error types
          final errorMessage = _handleDioError(error);
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: errorMessage,
              type: error.type,
              response: error.response,
            ),
          );
        },
      ),
    );
  }

  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى';
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode != null) {
          if (statusCode >= 500) {
            return 'خطأ في الخادم. يرجى المحاولة لاحقاً';
          } else if (statusCode == 401) {
            return 'غير مصرح. يرجى تسجيل الدخول مرة أخرى';
          } else if (statusCode == 404) {
            return 'المورد غير موجود';
          }
        }
        return error.response?.data['message'] ?? 'حدث خطأ في الخادم';
      
      case DioExceptionType.cancel:
        return 'تم إلغاء الطلب';
      
      case DioExceptionType.connectionError:
        return 'خطأ في الاتصال. تحقق من الإنترنت';
      
      case DioExceptionType.badCertificate:
        return 'خطأ في شهادة الأمان';
      
      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') ?? false) {
          return 'لا يوجد اتصال بالإنترنت';
        }
        return 'حدث خطأ غير متوقع';
    }
  }

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException {
      rethrow;
    }
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException {
      rethrow;
    }
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException {
      rethrow;
    }
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException {
      rethrow;
    }
  }

  /// Get Dio instance (for advanced usage)
  Dio get dio => _dio;
}
