import 'package:dio/dio.dart';
import 'api_client.dart';
import 'api_response.dart';
import '../../models/user_profile.dart';

/// API de perfil: GET/PATCH /auth/me, cambio de correo vía POST /auth/me/request-email-change.
/// Backend: GET/PATCH /api/v1/auth/me; POST /api/v1/auth/me/request-email-change.
class ProfileApi {
  ProfileApi(this._client);

  final ApiClient _client;

  static const _me = '/auth/me';

  /// GET /auth/me — datos del usuario autenticado.
  Future<ApiResponse<UserProfile>> getMe() async {
    final res = await _client.get<Map<String, dynamic>>(_me);
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

  /// PATCH /auth/me — actualizar datos personales (no incluye email).
  /// Campos opcionales: nombres, apellidos, domicilio, regionId, comunaId, avatarUrl.
  Future<ApiResponse<UserProfile>> updateProfile({
    String? nombres,
    String? apellidos,
    String? domicilio,
    String? regionId,
    String? comunaId,
    String? avatarUrl,
  }) async {
    final data = <String, dynamic>{};
    if (nombres != null) data['nombres'] = nombres;
    if (apellidos != null) data['apellidos'] = apellidos;
    if (domicilio != null) data['domicilio'] = domicilio;
    if (regionId != null) data['regionId'] = regionId;
    if (comunaId != null) data['comunaId'] = comunaId;
    if (avatarUrl != null) data['avatarUrl'] = avatarUrl;
    final res = await _client.patch<Map<String, dynamic>>(_me, data: data);
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

  /// POST /auth/me/request-email-change — solicitar cambio de correo.
  /// El backend envía token al nuevo email; tras verificar (verify-new-email)
  /// el usuario debe cerrar sesión e iniciar sesión con el nuevo correo.
  /// Errores posibles: SAME_EMAIL, EMAIL_IN_USE, EMAIL_SEND_FAILED.
  Future<ApiResponse<void>> requestEmailChange(String newEmail) async {
    try {
      final res = await _client.post<Map<String, dynamic>>(
        '$_me/request-email-change',
        data: {'newEmail': newEmail.trim()},
      );
      if (res.success) return ApiResponse(success: true);
      return ApiResponse(
        success: false,
        message: res.message ?? 'No se pudo solicitar el cambio de correo.',
        errorCode: res.errorCode,
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      final map = data is Map<String, dynamic> ? data : null;
      return ApiResponse(
        success: false,
        message: map?['message']?.toString() ?? 'No se pudo solicitar el cambio de correo.',
        errorCode: map?['error']?.toString(),
      );
    }
  }

  /// POST /auth/me/avatar — subir foto de perfil (multipart).
  Future<ApiResponse<String>> uploadAvatar(String path) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(path),
    });
    final res = await _client.postMultipart<Map<String, dynamic>>('$_me/avatar', data: formData);
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
