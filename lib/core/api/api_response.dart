import 'package:dio/dio.dart';

class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.errorCode,
  });

  factory ApiResponse.fromResponse(Response<dynamic> res) {
    final body = res.data;
    if (body is! Map<String, dynamic>) {
      return ApiResponse<T>(success: (res.statusCode ?? 0) >= 200 && (res.statusCode ?? 0) < 300);
    }
    return ApiResponse<T>(
      success: body['success'] as bool? ?? false,
      data: body['data'] as T?,
      message: body['message'] as String?,
      errorCode: body['error'] as String?,
    );
  }

  final bool success;
  final T? data;
  final String? message;
  final String? errorCode;
}
