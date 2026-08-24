/// Modelo de una persona tal como la representa la API.
class Persona {
  final int? id;
  final String identificacion;
  final String nombre;
  final String apellido;
  final String email;
  final String? telefono;
  final String? direccion;
  final String? foto;

  Persona({
    this.id,
    required this.identificacion,
    required this.nombre,
    required this.apellido,
    required this.email,
    this.telefono,
    this.direccion,
    this.foto,
  });

  /// Construye una persona a partir de la respuesta JSON del backend.
  factory Persona.fromJson(Map<String, dynamic> json) => Persona(
        id: json['id'] is int
            ? json['id'] as int
            : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
        identificacion: json['identificacion']?.toString() ?? '',
        nombre: json['nombre']?.toString() ?? '',
        apellido: json['apellido']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        telefono: json['telefono']?.toString(),
        direccion: json['direccion']?.toString(),
        foto: json['foto']?.toString(),
      );

  /// Convierte la persona al formato JSON que esperan POST y PUT.
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'identificacion': identificacion,
        'nombre': nombre,
        'apellido': apellido,
        'email': email,
        'telefono': telefono,
        'direccion': direccion,
        'foto': foto,
      };

  /// Nombre listo para mostrar en la interfaz.
  String get nombreCompleto => '$nombre $apellido';
}
