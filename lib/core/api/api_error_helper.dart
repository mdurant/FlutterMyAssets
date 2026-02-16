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
