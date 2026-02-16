import 'package:dio/dio.dart';

import '../../models/region.dart';
import '../../models/comuna.dart';
import 'api_client.dart';
import 'api_error_helper.dart';

class RegionsApi {
  RegionsApi(this._client);

  final ApiClient _client;

  Future<List<Region>> getRegions() async {
    try {
      final res = await _client.get<dynamic>('/regions');
      if (!res.success) {
        throw Exception(res.message ?? 'No se pudieron cargar las regiones');
      }
      final data = res.data;
      if (data is! List || data.isEmpty) {
        return [];
      }
      final list = <Region>[];
      for (final e in data) {
        if (e is! Map<String, dynamic>) continue;
        try {
          final r = Region.fromJson(e);
          if (r.id.isNotEmpty) list.add(r);
        } catch (_) {}
      }
      return list;
    } on DioException catch (e) {
      throw Exception(
        'No se pudieron cargar las regiones. ${apiErrorMessage(e)}',
      );
    }
  }

  Future<List<Comuna>> getComunas(String regionId) async {
    if (regionId.isEmpty) return [];
    try {
      final res = await _client.get<dynamic>(
        '/comunas',
        queryParameters: {'regionId': regionId},
      );
      if (!res.success) {
        throw Exception(res.message ?? 'No se pudieron cargar las comunas');
      }
      final data = res.data;
      if (data is! List || data.isEmpty) {
        return [];
      }
      final list = <Comuna>[];
      for (final e in data) {
        if (e is! Map<String, dynamic>) continue;
        try {
          final c = Comuna.fromJson(e);
          if (c.id.isNotEmpty) list.add(c);
        } catch (_) {}
      }
      return list;
    } on DioException catch (e) {
      throw Exception(
        'No se pudieron cargar las comunas. ${apiErrorMessage(e)}',
      );
    }
  }
}
