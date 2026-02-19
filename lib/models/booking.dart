/// Solicitud de arriendo (booking).
class Booking {
  final String id;
  final String propertyId;
  final String userId;
  final DateTime dateFrom;
  final DateTime dateTo;
  final String? note;
  final String status;
  final DateTime? createdAt;

  Booking({
    required this.id,
    required this.propertyId,
    required this.userId,
    required this.dateFrom,
    required this.dateTo,
    this.note,
    required this.status,
    this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id']?.toString() ?? '',
      propertyId: json['propertyId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      dateFrom: DateTime.tryParse(json['dateFrom']?.toString() ?? '') ?? DateTime.now(),
      dateTo: DateTime.tryParse(json['dateTo']?.toString() ?? '') ?? DateTime.now(),
      note: json['note']?.toString(),
      status: json['status']?.toString() ?? 'PENDING',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }
}
