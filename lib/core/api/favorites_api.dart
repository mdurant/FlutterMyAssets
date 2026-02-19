import 'api_client.dart';
import 'api_response.dart';
import '../../models/property.dart';

class FavoritesApi {
  FavoritesApi(this._client);

  final ApiClient _client;

  /// GET /favorites — Lista de propiedades favoritas.
  Future<ApiResponse<List<Property>>> list() async {
    final res = await _client.get<dynamic>('/favorites');
    if (!res.success) {
      return ApiResponse<List<Property>>(success: false, message: res.message, errorCode: res.errorCode);
    }
    final data = res.data;
    if (data is! List) return ApiResponse<List<Property>>(success: true, data: []);
    final list = <Property>[];
    for (final e in data) {
      if (e is Map<String, dynamic>) list.add(Property.fromJson(e));
    }
    return ApiResponse<List<Property>>(success: true, data: list);
  }

  /// POST /favorites/:propertyId — Añadir a favoritos.
  Future<ApiResponse<void>> add(String propertyId) async {
    return _client.post<void>('/favorites/$propertyId');
  }

  /// DELETE /favorites/:propertyId — Quitar de favoritos.
  Future<ApiResponse<void>> remove(String propertyId) async {
    return _client.delete<void>('/favorites/$propertyId');
  }
}
