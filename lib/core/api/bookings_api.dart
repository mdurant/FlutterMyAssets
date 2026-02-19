import 'api_client.dart';
import 'api_response.dart';
import '../../models/booking.dart';

class BookingsApi {
  BookingsApi(this._client);

  final ApiClient _client;

  /// POST /bookings — Crear solicitud de arriendo (propertyId, dateFrom, dateTo, note?).
  Future<ApiResponse<Booking>> create({
    required String propertyId,
    required DateTime dateFrom,
    required DateTime dateTo,
    String? note,
  }) async {
    final body = <String, dynamic>{
      'propertyId': propertyId,
      'dateFrom': dateFrom.toIso8601String(),
      'dateTo': dateTo.toIso8601String(),
    };
    if (note != null && note.isNotEmpty) body['note'] = note;
    final res = await _client.post<Map<String, dynamic>>('/bookings', data: body);
    if (!res.success || res.data == null) {
      return ApiResponse<Booking>(success: false, message: res.message, errorCode: res.errorCode);
    }
    return ApiResponse<Booking>(success: true, data: Booking.fromJson(res.data as Map<String, dynamic>));
  }

  /// GET /bookings — Lista con filtro opcional por status.
  Future<ApiResponse<List<Booking>>> list({String? status}) async {
    final query = status != null && status.isNotEmpty ? {'status': status} : null;
    final res = await _client.get<dynamic>('/bookings', queryParameters: query);
    if (!res.success) {
      return ApiResponse<List<Booking>>(success: false, message: res.message, errorCode: res.errorCode);
    }
    final data = res.data;
    if (data is! List) return ApiResponse<List<Booking>>(success: true, data: []);
    final list = <Booking>[];
    for (final e in data) {
      if (e is Map<String, dynamic>) list.add(Booking.fromJson(e));
    }
    return ApiResponse<List<Booking>>(success: true, data: list);
  }
}
