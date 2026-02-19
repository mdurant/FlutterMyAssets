import 'api_client.dart';
import 'api_response.dart';
import '../../models/review.dart';

class ReviewsApi {
  ReviewsApi(this._client);

  final ApiClient _client;

  /// GET /properties/:id/reviews — Reseñas de una propiedad.
  Future<ApiResponse<List<Review>>> list(String propertyId) async {
    final res = await _client.get<dynamic>('/properties/$propertyId/reviews');
    if (!res.success) {
      return ApiResponse<List<Review>>(success: false, message: res.message, errorCode: res.errorCode);
    }
    final data = res.data;
    if (data is! List) return ApiResponse<List<Review>>(success: true, data: []);
    final list = <Review>[];
    for (final e in data) {
      if (e is Map<String, dynamic>) list.add(Review.fromJson(e));
    }
    return ApiResponse<List<Review>>(success: true, data: list);
  }

  /// POST /properties/:id/reviews — Crear reseña (rating, comment?, mediaUrl?).
  Future<ApiResponse<Review>> create(String propertyId, {required int rating, String? comment, String? mediaUrl}) async {
    final body = <String, dynamic>{'rating': rating};
    if (comment != null && comment.isNotEmpty) body['comment'] = comment;
    if (mediaUrl != null && mediaUrl.isNotEmpty) body['mediaUrl'] = mediaUrl;
    final res = await _client.post<Map<String, dynamic>>('/properties/$propertyId/reviews', data: body);
    if (!res.success || res.data == null) {
      return ApiResponse<Review>(success: false, message: res.message, errorCode: res.errorCode);
    }
    return ApiResponse<Review>(success: true, data: Review.fromJson(res.data as Map<String, dynamic>));
  }
}
