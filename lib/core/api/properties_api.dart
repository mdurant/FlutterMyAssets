import 'package:dio/dio.dart';
import 'api_client.dart';
import 'api_response.dart';
import '../../models/property.dart';

class PropertiesApi {
  PropertiesApi(this._client);

  final ApiClient _client;

  /// Parámetros de listado (query).
  Map<String, dynamic> listQuery({
    String? q,
    String? regionId,
    String? comunaId,
    double? lat,
    double? lng,
    double? radiusKm,
    String? type,
    double? priceMin,
    double? priceMax,
    List<String>? facilities,
    int? bedrooms,
    int? bathrooms,
    String? sort,
    int? page,
    int? limit,
  }) {
    final map = <String, dynamic>{};
    if (q != null && q.isNotEmpty) map['q'] = q;
    if (regionId != null && regionId.isNotEmpty) map['regionId'] = regionId;
    if (comunaId != null && comunaId.isNotEmpty) map['comunaId'] = comunaId;
    if (lat != null) map['lat'] = lat;
    if (lng != null) map['lng'] = lng;
    if (radiusKm != null) map['radiusKm'] = radiusKm;
    if (type != null && type.isNotEmpty) map['type'] = type;
    if (priceMin != null) map['priceMin'] = priceMin;
    if (priceMax != null) map['priceMax'] = priceMax;
    if (facilities != null && facilities.isNotEmpty) map['facilities'] = facilities.join(',');
    if (bedrooms != null) map['bedrooms'] = bedrooms;
    if (bathrooms != null) map['bathrooms'] = bathrooms;
    if (sort != null && sort.isNotEmpty) map['sort'] = sort;
    if (page != null) map['page'] = page;
    if (limit != null) map['limit'] = limit;
    return map;
  }

  /// GET /properties — Listado con filtros.
  Future<ApiResponse<List<Property>>> list({Map<String, dynamic>? query}) async {
    final res = await _client.get<dynamic>('/properties', queryParameters: query);
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

  /// GET /properties/:id — Detalle.
  Future<ApiResponse<Property>> get(String id) async {
    final res = await _client.get<Map<String, dynamic>>('/properties/$id');
    if (!res.success || res.data == null) {
      return ApiResponse<Property>(success: false, message: res.message, errorCode: res.errorCode);
    }
    return ApiResponse<Property>(success: true, data: Property.fromJson(res.data as Map<String, dynamic>));
  }

  /// POST /properties — Crear (body según backend).
  Future<ApiResponse<Property>> create(Map<String, dynamic> body) async {
    final res = await _client.post<Map<String, dynamic>>('/properties', data: body);
    if (!res.success || res.data == null) {
      return ApiResponse<Property>(success: false, message: res.message, errorCode: res.errorCode);
    }
    return ApiResponse<Property>(success: true, data: Property.fromJson(res.data as Map<String, dynamic>));
  }

  /// PUT /properties/:id — Actualizar.
  Future<ApiResponse<Property>> update(String id, Map<String, dynamic> body) async {
    final res = await _client.put<Map<String, dynamic>>('/properties/$id', data: body);
    if (!res.success || res.data == null) {
      return ApiResponse<Property>(success: false, message: res.message, errorCode: res.errorCode);
    }
    return ApiResponse<Property>(success: true, data: Property.fromJson(res.data as Map<String, dynamic>));
  }

  /// DELETE /properties/:id — Eliminar.
  Future<ApiResponse<void>> delete(String id) async {
    return _client.delete<void>('/properties/$id');
  }

  /// POST /properties/:id/images — Subir imagen(es) (multipart).
  Future<ApiResponse<dynamic>> uploadImages(String propertyId, List<MultipartFile> files) async {
    final formData = FormData.fromMap({
      'images': files.length == 1 ? files.single : files,
    });
    return _client.postMultipart<dynamic>('/properties/$propertyId/images', data: formData);
  }
}
