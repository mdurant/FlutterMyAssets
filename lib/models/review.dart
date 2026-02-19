/// Reseña de una propiedad.
class Review {
  final String id;
  final String propertyId;
  final String userId;
  final int rating;
  final String? comment;
  final String? mediaUrl;
  final DateTime? createdAt;

  Review({
    required this.id,
    required this.propertyId,
    required this.userId,
    required this.rating,
    this.comment,
    this.mediaUrl,
    this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id']?.toString() ?? '',
      propertyId: json['propertyId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      rating: json['rating'] is int ? json['rating'] as int : 0,
      comment: json['comment']?.toString(),
      mediaUrl: json['mediaUrl']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }
}
