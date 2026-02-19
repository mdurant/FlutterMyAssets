/// Notificación del usuario.
class NotificationItem {
  final String id;
  final String? title;
  final String? body;
  final bool read;
  final DateTime? createdAt;

  NotificationItem({
    required this.id,
    this.title,
    this.body,
    this.read = false,
    this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString(),
      body: json['body']?.toString(),
      read: json['read'] == true,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }
}
