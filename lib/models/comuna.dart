class Comuna {
  final String id;
  final String nombre;

  Comuna({required this.id, required this.nombre});

  factory Comuna.fromJson(Map<String, dynamic> json) {
    final id = (json['id']?.toString() ?? '').trim();
    final nombre = (json['nombre']?.toString() ?? '').trim();
    return Comuna(id: id, nombre: nombre);
  }
}
