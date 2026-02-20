/// Perfil del usuario (GET/PATCH /auth/me: nombres, apellidos, domicilio, regionId, comunaId, avatarUrl, email solo lectura).
class UserProfile {
  final String id;
  final String? email;
  final String? nombres;
  final String? apellidos;
  final String? domicilio;
  final String? regionId;
  final String? comunaId;
  final String? avatarUrl;

  UserProfile({
    required this.id,
    this.email,
    this.nombres,
    this.apellidos,
    this.domicilio,
    this.regionId,
    this.comunaId,
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
      domicilio: json['domicilio']?.toString(),
      regionId: json['regionId']?.toString(),
      comunaId: json['comunaId']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'nombres': nombres,
        'apellidos': apellidos,
        'domicilio': domicilio,
        'regionId': regionId,
        'comunaId': comunaId,
        'avatarUrl': avatarUrl,
      };
}
