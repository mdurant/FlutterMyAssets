/// Perfil del usuario (datos mostrados en Cuenta y para avatar).
class UserProfile {
  final String id;
  final String? email;
  final String? nombres;
  final String? apellidos;
  final String? avatarUrl;

  UserProfile({
    required this.id,
    this.email,
    this.nombres,
    this.apellidos,
    this.avatarUrl,
  });

  String get fullName {
    final n = (nombres ?? '').trim();
    final a = (apellidos ?? '').trim();
    if (n.isEmpty && a.isEmpty) return 'Usuario';
    return [n, a].where((s) => s.isNotEmpty).join(' ');
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString(),
      nombres: json['nombres']?.toString(),
      apellidos: json['apellidos']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'nombres': nombres,
        'apellidos': apellidos,
        'avatarUrl': avatarUrl,
      };
}
