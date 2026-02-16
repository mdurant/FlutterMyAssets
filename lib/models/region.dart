class Region {
  final String id;
  final String nombre;

  Region({required this.id, required this.nombre});

  factory Region.fromJson(Map<String, dynamic> json) {
    final id = (json['id']?.toString() ?? '').trim();
    final nombre = (json['nombre']?.toString() ?? '').trim();
    return Region(id: id, nombre: nombre);
  }
}
