import 'api_client.dart';
import 'api_response.dart';
import '../../models/term.dart';

class TermsApi {
  TermsApi(this._client);

  final ApiClient _client;

  /// GET /terms/active — Términos activos. 403 TERMS_NOT_ACCEPTED si el usuario no los ha aceptado.
  Future<ApiResponse<Term>> getActive() async {
    final res = await _client.get<Map<String, dynamic>>('/terms/active');
    if (!res.success || res.data == null) {
      return ApiResponse<Term>(success: false, message: res.message, errorCode: res.errorCode);
    }
    final term = Term.fromJson(res.data as Map<String, dynamic>);
    return ApiResponse<Term>(success: true, data: term);
  }

  /// POST /terms/accept — Aceptar términos (body: termId o version).
  Future<ApiResponse<void>> accept({String? termId, String? version}) async {
    final data = <String, dynamic>{};
    if (termId != null && termId.isNotEmpty) data['termId'] = termId;
    if (version != null && version.isNotEmpty) data['version'] = version;
    return _client.post<void>('/terms/accept', data: data.isNotEmpty ? data : null);
  }
}
