/// Términos y condiciones activos (GET /terms/active).
class Term {
  final String id;
  final String? version;
  final String? title;
  final String? content;

  Term({
    required this.id,
    this.version,
    this.title,
    this.content,
  });

  factory Term.fromJson(Map<String, dynamic> json) {
    return Term(
      id: json['id']?.toString() ?? '',
      version: json['version']?.toString(),
      title: json['title']?.toString(),
      content: json['content']?.toString(),
    );
  }
}
