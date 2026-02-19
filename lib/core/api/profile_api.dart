import 'package:dio/dio.dart';
import 'api_client.dart';
import 'api_response.dart';
import '../../models/user_profile.dart';

/// API de perfil de usuario: obtener datos, actualizar y subir avatar.
/// Backend esperado: GET/PATCH /users/me, POST /users/me/avatar (ver PROFILE-BACKEND.md).
class ProfileApi {
  ProfileApi(this._client);

  final ApiClient _client;

  /// GET /users/me — datos del usuario autenticado.
  Future<ApiResponse<UserProfile>> getMe() async {
    final res = await _client.get<Map<String, dynamic>>('/users/me');
    if (!res.success || res.data == null) {
      return ApiResponse(success: false, message: res.message, errorCode: res.errorCode);
    }
    try {
      final profile = UserProfile.fromJson(res.data!);
      return ApiResponse(success: true, data: profile);
    } catch (_) {
      return ApiResponse(success: false, message: 'Formato de perfil inválido');
    }
  }

  /// PATCH /users/me — actualizar nombres, apellidos, etc.
  Future<ApiResponse<UserProfile>> updateProfile({
    String? nombres,
    String? apellidos,
  }) async {
    final data = <String, dynamic>{};
    if (nombres != null) data['nombres'] = nombres;
    if (apellidos != null) data['apellidos'] = apellidos;
    final res = await _client.patch<Map<String, dynamic>>('/users/me', data: data);
    if (!res.success || res.data == null) {
      return ApiResponse(success: false, message: res.message, errorCode: res.errorCode);
    }
    try {
      final profile = UserProfile.fromJson(res.data!);
      return ApiResponse(success: true, data: profile);
    } catch (_) {
      return ApiResponse(success: false, message: 'Formato de perfil inválido');
    }
  }

  /// POST /users/me/avatar — subir foto de perfil (multipart).
  /// [path] ruta local del archivo (ej. desde image_picker).
  /// Backend: multipart campo "file" o "avatar"; respuesta { data: { avatarUrl: "..." } }.
  Future<ApiResponse<String>> uploadAvatar(String path) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(path),
    });
    final res = await _client.postMultipart<Map<String, dynamic>>('/users/me/avatar', data: formData);
    if (!res.success) {
      return ApiResponse(success: false, message: res.message, errorCode: res.errorCode);
    }
    final data = res.data;
    final url = data?['avatarUrl']?.toString() ?? data?['data']?['avatarUrl']?.toString();
    if (url == null || url.isEmpty) {
      return ApiResponse(success: false, message: 'El servidor no devolvió la URL del avatar');
    }
    return ApiResponse(success: true, data: url);
  }
}
