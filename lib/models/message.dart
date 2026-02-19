/// Mensaje dentro de una conversación.
class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String? text;
  final DateTime? createdAt;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.text,
    this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversationId']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      text: json['text']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }
}
