/// Conversación (chat) con propiedad/agente.
class Conversation {
  final String id;
  final String? propertyId;
  final Map<String, dynamic>? property;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Conversation({
    required this.id,
    this.propertyId,
    this.property,
    this.createdAt,
    this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id']?.toString() ?? '',
      propertyId: json['propertyId']?.toString(),
      property: json['property'] is Map<String, dynamic> ? json['property'] as Map<String, dynamic> : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }
}
