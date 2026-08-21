import 'package:dio/dio.dart';
import '../models/persona_model.dart';

class PersonaRepository {
  // En emulador Android usa 10.0.2.2 en vez de 127.0.0.1
  // Pídele a Breiro su IP local cuando prueben juntos en dispositivo físico
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:3000/api'));

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

  Future<Persona> createPersona(Persona persona) async {
    try {
      final response = await _dio.post('/personas', data: persona.toJson());
      return Persona.fromJson(response.data);
    } on DioException catch (e) {
      final msg = e.response?.data['error'] ?? 'Error creando persona';
      throw Exception(msg);
    }
  }

  Future<Persona> updatePersona(int id, Persona persona) async {
    try {
      final response = await _dio.put('/personas/$id', data: persona.toJson());
      return Persona.fromJson(response.data);
    } on DioException catch (e) {
      final msg = e.response?.data['error'] ?? 'Error actualizando persona';
      throw Exception(msg);
    }
  }

  Future<void> deletePersona(int id) async {
    try {
      await _dio.delete('/personas/$id');
    } on DioException catch (e) {
      final msg = e.response?.data['error'] ?? 'Error eliminando persona';
      throw Exception(msg);
    }
  }
}
