import 'package:dio/dio.dart';
import '../models/persona_model.dart';

/// Encapsula todas las peticiones HTTP relacionadas con personas.
class PersonaRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000/api'));

  /// Obtiene todos los registros desde la API.
  Future<List<Persona>> fetchPersonas() async {
    try {
      final response = await _dio.get('/personas');
      return (response.data as List)
          .map((json) => Persona.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error cargando personas: $e');
    }
  }

  /// Envía una persona nueva al backend.
  Future<Persona> createPersona(Persona persona) async {
    try {
      final response = await _dio.post('/personas', data: persona.toJson());
      return Persona.fromJson(response.data);
    } on DioException catch (e) {
      final msg = e.response?.data['error'] ?? 'Error creando persona';
      throw Exception(msg);
    }
  }

  /// Actualiza el registro identificado por [id].
  Future<Persona> updatePersona(int id, Persona persona) async {
    try {
      final response = await _dio.put('/personas/$id', data: persona.toJson());
      return Persona.fromJson(response.data);
    } on DioException catch (e) {
      final msg = e.response?.data['error'] ?? 'Error actualizando persona';
      throw Exception(msg);
    }
  }

  /// Elimina el registro identificado por [id].
  Future<void> deletePersona(int id) async {
    try {
      await _dio.delete('/personas/$id');
    } on DioException catch (e) {
      final msg = e.response?.data['error'] ?? 'Error eliminando persona';
      throw Exception(msg);
    }
  }
}
