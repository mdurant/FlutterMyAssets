import 'package:dio/dio.dart';
import 'api_response.dart';

/// Base URL de la API (solo prefijo /api/v1; el servidor suele estar en :3000).
/// - Misma máquina (Chrome/desktop): http://localhost:3000/api/v1
/// - Android emulador: http://10.0.2.2:3000/api/v1
/// - iOS Simulator: en el simulador "localhost" no es tu Mac. Usa la IP de tu Mac,
///   ej. http://192.168.1.X:3000/api/v1 (ver en Preferencias → Red o `ipconfig getifaddr en0`).
/// - Flutter Web: el backend debe enviar CORS (Access-Control-Allow-Origin) para tu origen.
const String kBaseUrl = 'http://localhost:3000/api/v1';

class ApiClient {
  ApiClient({String? baseUrl}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? kBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ));
    _dio.interceptors.add(_AuthInterceptor(this));
  }

  late final Dio _dio;
  String? _accessToken;
  String? _refreshToken;

  Dio get dio => _dio;

  void setTokens({String? access, String? refresh}) {
    _accessToken = access;
    _refreshToken = refresh;
  }

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final res = await _dio.post<T>(path, data: data, queryParameters: queryParameters);
    return ApiResponse.fromResponse(res);
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final res = await _dio.get<T>(path, queryParameters: queryParameters);
    return ApiResponse.fromResponse(res);
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
  }) async {
    final res = await _dio.put<T>(path, data: data);
    return ApiResponse.fromResponse(res);
  }

  Future<ApiResponse<T>> delete<T>(String path) async {
    final res = await _dio.delete<T>(path);
    return ApiResponse.fromResponse(res);
  }

  Future<bool> _refreshSession() async {
    if (_refreshToken == null) return false;
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': _refreshToken},
        options: Options(extra: {'skipAuth': true}),
      );
      final body = res.data;
      final inner = body?['data'] as Map<String, dynamic>?;
      if (inner != null &&
          inner['accessToken'] != null &&
          inner['refreshToken'] != null) {
        _accessToken = inner['accessToken'] as String;
        _refreshToken = inner['refreshToken'] as String;
        return true;
      }
    } catch (_) {}
    return false;
  }
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._client);

  final ApiClient _client;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.extra['skipAuth'] == true) {
      return handler.next(options);
    }
    final token = _client.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await _client._refreshSession();
      if (refreshed) {
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer ${_client.accessToken}';
        try {
          final response = await _client.dio.fetch(opts);
          return handler.resolve(response);
        } catch (_) {}
      }
    }
    handler.next(err);
  }
}
