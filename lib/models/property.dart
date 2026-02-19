/// Propiedad inmobiliaria (listado y detalle).
class Property {
  final String id;
  final String? title;
  final String? description;
  final String? address;
  final String? regionId;
  final String? comunaId;
  final double? lat;
  final double? lng;
  final String? type;
  final double? price;
  final int? bedrooms;
  final int? bathrooms;
  final List<String>? facilities;
  final double? riskScore;
  final String? status;
  final List<String>? imageUrls;
  final String? agentId;
  final Map<String, dynamic>? agent;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Property({
    required this.id,
    this.title,
    this.description,
    this.address,
    this.regionId,
    this.comunaId,
    this.lat,
    this.lng,
    this.type,
    this.price,
    this.bedrooms,
    this.bathrooms,
    this.facilities,
    this.riskScore,
    this.status,
    this.imageUrls,
    this.agentId,
    this.agent,
    this.createdAt,
    this.updatedAt,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    List<String>? facilities;
    if (json['facilities'] != null) {
      if (json['facilities'] is List) {
        facilities = (json['facilities'] as List)
            .map((e) => e.toString())
            .where((s) => s.isNotEmpty)
            .toList();
      }
    }
    List<String>? imageUrls;
    if (json['imageUrls'] != null && json['imageUrls'] is List) {
      imageUrls = (json['imageUrls'] as List).map((e) => e.toString()).toList();
    }
    return Property(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      address: json['address']?.toString(),
      regionId: json['regionId']?.toString(),
      comunaId: json['comunaId']?.toString(),
      lat: (json['lat'] is num) ? (json['lat'] as num).toDouble() : null,
      lng: (json['lng'] is num) ? (json['lng'] as num).toDouble() : null,
      type: json['type']?.toString(),
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : null,
      bedrooms: json['bedrooms'] is int ? json['bedrooms'] as int : null,
      bathrooms: json['bathrooms'] is int ? json['bathrooms'] as int : null,
      facilities: facilities,
      riskScore: (json['riskScore'] is num) ? (json['riskScore'] as num).toDouble() : null,
      status: json['status']?.toString(),
      imageUrls: imageUrls,
      agentId: json['agentId']?.toString(),
      agent: json['agent'] is Map<String, dynamic> ? json['agent'] as Map<String, dynamic> : null,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  static DateTime? _parseDateTime(dynamic v) {
    if (v == null) return null;
    if (v is String) return DateTime.tryParse(v);
    return null;
  }
}
