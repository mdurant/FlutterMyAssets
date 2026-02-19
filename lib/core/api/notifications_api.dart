import 'api_client.dart';
import 'api_response.dart';
import '../../models/notification_item.dart';

class NotificationsApi {
  NotificationsApi(this._client);

  final ApiClient _client;

  /// GET /notifications — Lista de notificaciones.
  Future<ApiResponse<List<NotificationItem>>> list() async {
    final res = await _client.get<dynamic>('/notifications');
    if (!res.success) {
      return ApiResponse<List<NotificationItem>>(success: false, message: res.message, errorCode: res.errorCode);
    }
    final data = res.data;
    if (data is! List) return ApiResponse<List<NotificationItem>>(success: true, data: []);
    final list = <NotificationItem>[];
    for (final e in data) {
      if (e is Map<String, dynamic>) list.add(NotificationItem.fromJson(e));
    }
    return ApiResponse<List<NotificationItem>>(success: true, data: list);
  }

  /// POST /notifications/:id/read — Marcar como leída.
  Future<ApiResponse<void>> markRead(String id) async {
    return _client.post<void>('/notifications/$id/read');
  }
}
