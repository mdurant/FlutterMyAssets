import 'package:dio/dio.dart';

/// Convierte [DioException] en un mensaje corto para mostrar al usuario.
/// En Flutter Web, "connection error" suele ser CORS: el backend debe permitir
/// el origen (p. ej. Access-Control-Allow-Origin: * o tu localhost:PORT).
String messageFromDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionError:
    case DioExceptionType.connectionTimeout:
      return _connectionErrorMessage;
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      return 'El servidor no respondió a tiempo.';
    case DioExceptionType.badResponse:
      final msg = e.response?.data is Map
          ? (e.response!.data as Map)['message'] as String?
          : null;
      return msg ?? 'Error del servidor (${e.response?.statusCode})';
    case DioExceptionType.cancel:
      return 'Petición cancelada.';
    case DioExceptionType.unknown:
    default:
      final msg = e.message ?? '';
      if (msg.isEmpty ||
          msg.toLowerCase().contains('connection') ||
          msg.toLowerCase().contains('socket') ||
          msg.toLowerCase().contains('xmlhttprequest') ||
          msg.toLowerCase().contains('network')) {
        return _connectionErrorMessage;
      }
      return msg;
  }
}

const String _connectionErrorMessage =
    'No se pudo conectar al servidor. '
    'Comprueba que la API esté en marcha (ej. http://localhost:3000). '
    'En web o simulador, el backend debe permitir CORS y estar accesible.';

/// Mensaje para mostrar en UI a partir de cualquier error (p. ej. de un catch).
String apiErrorMessage(Object e) {
  if (e is DioException) return messageFromDioException(e);
  final s = e.toString();
  return s.startsWith('Exception: ') ? s.substring(11) : s;
}

/// Mensajes para la solicitud de OTP (POST /auth/login solo con email). Ver FLUTTER-BACKEND-LOGIN-OTP.md.
String messageForLoginOtpRequest(DioException e) {
  if (e.type != DioExceptionType.badResponse || e.response?.data is! Map) {
    return messageFromDioException(e);
  }
  final data = e.response!.data as Map;
  final code = data['error'] as String?;
  final msg = data['message'] as String?;
  switch (code) {
    case 'USER_NOT_FOUND':
      return msg ?? 'No existe una cuenta con ese correo.';
    case 'EMAIL_SEND_FAILED':
      return msg ?? 'No se pudo enviar el correo. Intenta más tarde o contacta soporte.';
    default:
      return msg ?? messageFromDioException(e);
  }
}

/// Mensajes para verificación OTP (POST /auth/verify-otp). Ver FLUTTER-BACKEND-LOGIN-OTP.md.
String messageForVerifyOtpError(DioException e) {
  if (e.type != DioExceptionType.badResponse || e.response?.data is! Map) {
    return messageFromDioException(e);
  }
  final data = e.response!.data as Map;
  final code = data['error'] as String?;
  final msg = data['message'] as String?;
  switch (code) {
    case 'INVALID_OTP':
      return msg ?? 'Código incorrecto o expirado.';
    case 'OTP_EXPIRED':
      return msg ?? 'El código ha expirado. Solicita uno nuevo.';
    case 'OTP_MAX_ATTEMPTS':
      return msg ?? 'Demasiados intentos. Solicita un nuevo código.';
    default:
      return msg ?? 'Código inválido.';
  }
}
