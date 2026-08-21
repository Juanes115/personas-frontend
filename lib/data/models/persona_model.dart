class Persona {
  final int? id;
  final String identificacion;
  final String nombre;
  final String apellido;
  final String email;
  final String? telefono;
  final String? direccion;

  Persona({
    this.id,
    required this.identificacion,
    required this.nombre,
    required this.apellido,
    required this.email,
    this.telefono,
    this.direccion,
  });

  factory Persona.fromJson(Map<String, dynamic> json) => Persona(
        id: json['id'] as int?,
        identificacion: json['identificacion'] as String,
        nombre: json['nombre'] as String,
        apellido: json['apellido'] as String,
        email: json['email'] as String,
        telefono: json['telefono'] as String?,
        direccion: json['direccion'] as String?,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'identificacion': identificacion,
        'nombre': nombre,
        'apellido': apellido,
        'email': email,
        'telefono': telefono,
        'direccion': direccion,
      };

  String get nombreCompleto => '$nombre $apellido';
}
