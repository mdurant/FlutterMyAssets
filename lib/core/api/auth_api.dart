import 'api_client.dart';
import 'api_response.dart';

class AuthApi {
  AuthApi(this._client);

  final ApiClient _client;

  Future<ApiResponse<Map<String, dynamic>>> register({
    required String email,
    required String password,
    required String nombres,
    required String apellidos,
    required String sexo,
    required String fechaNacimiento,
    required String domicilio,
    required String regionId,
    required String comunaId,
    required bool acceptTerms,
  }) async {
    return _client.post<Map<String, dynamic>>('/auth/register', data: {
      'email': email,
      'password': password,
      'nombres': nombres,
      'apellidos': apellidos,
      'sexo': sexo,
      'fechaNacimiento': fechaNacimiento,
      'domicilio': domicilio,
      'regionId': regionId,
      'comunaId': comunaId,
      'acceptTerms': acceptTerms,
    });
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyEmail(String token) async {
    return _client.post<Map<String, dynamic>>('/auth/verify-email', data: {'token': token});
  }

  /// Reenviar correo de verificación con un nuevo token. Backend: POST /auth/resend-verify-email.
  Future<ApiResponse<void>> resendVerifyEmail(String email) async {
    return _client.post<void>('/auth/resend-verify-email', data: {'email': email});
  }

  /// Envía código OTP de login al correo. Recomendado para "Iniciar sesión con código" y "Reenviar código".
  /// Backend: POST /auth/send-login-otp. Contrato: FLUTTER-BACKEND-LOGIN-OTP.md.
  Future<ApiResponse<Map<String, dynamic>>> sendLoginOtp(String email) async {
    return _client.post<Map<String, dynamic>>('/auth/send-login-otp', data: {'email': email});
  }

  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    String? password,
  }) async {
    final data = <String, dynamic>{'email': email};
    if (password != null && password.isNotEmpty) data['password'] = password;
    return _client.post<Map<String, dynamic>>('/auth/login', data: data);
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyOtp({
    required String email,
    required String code,
    required String purpose,
  }) async {
    return _client.post<Map<String, dynamic>>('/auth/verify-otp', data: {
      'email': email,
      'code': code,
      'purpose': purpose,
    });
  }

  Future<ApiResponse<Map<String, dynamic>>> refresh(String refreshToken) async {
    return _client.post<Map<String, dynamic>>('/auth/refresh', data: {'refreshToken': refreshToken});
  }

  Future<ApiResponse<void>> logout(String refreshToken) async {
    return _client.post<void>('/auth/logout', data: {'refreshToken': refreshToken});
  }

  Future<ApiResponse<void>> passwordRecovery(String email) async {
    return _client.post<void>('/auth/password-recovery', data: {'email': email});
  }

  Future<ApiResponse<void>> passwordReset({
    required String token,
    required String newPassword,
  }) async {
    return _client.post<void>('/auth/password-reset', data: {
      'token': token,
      'newPassword': newPassword,
    });
  }
}
