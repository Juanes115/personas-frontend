import 'package:dio/dio.dart';
import '../models/persona_model.dart';
import '../models/paginated_persona_response.dart';

/// Encapsula todas las peticiones HTTP relacionadas con personas.
class PersonaRepository {
  static const String _defaultUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://localhost:3000/api',
  );

  final Dio _dio;

  PersonaRepository({String? baseUrl})
      : _dio = Dio(BaseOptions(baseUrl: baseUrl ?? _defaultUrl));

  /// Obtiene la lista paginada de personas desde la API.
  Future<PaginatedPersonaResponse> fetchPersonas({
    int page = 1,
    int limit = 10,
    String search = '',
  }) async {
    try {
      final response = await _dio.get(
        '/personas',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search.isNotEmpty) 'search': search,
        },
      );
      if (response.data is Map<String, dynamic>) {
        return PaginatedPersonaResponse.fromJson(response.data);
      } else if (response.data is List) {
        final list = (response.data as List)
            .map((json) => Persona.fromJson(json))
            .toList();
        return PaginatedPersonaResponse(
          data: list,
          total: list.length,
          page: 1,
          limit: limit,
          totalPages: 1,
        );
      }
      throw Exception('Formato de respuesta desconocido');
    } catch (e) {
      throw Exception('Error cargando personas: $e');
    }
  }

  /// Envía una persona nueva al backend.
  Future<Persona> createPersona(Persona persona) async {
    try {
      final response = await _dio.post('/personas', data: persona.toJson());
      return Persona.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = (data is Map && data['error'] != null)
          ? data['error'].toString()
          : 'Error creando persona (${e.response?.statusCode ?? 'red'})';
      throw Exception(msg);
    }
  }

  /// Actualiza el registro identificado por [id].
  Future<Persona> updatePersona(int id, Persona persona) async {
    try {
      final response = await _dio.put('/personas/$id', data: persona.toJson());
      return Persona.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = (data is Map && data['error'] != null)
          ? data['error'].toString()
          : 'Error actualizando persona (${e.response?.statusCode ?? 'red'})';
      throw Exception(msg);
    }
  }

  /// Elimina el registro identificado por [id].
  Future<void> deletePersona(int id) async {
    try {
      await _dio.delete('/personas/$id');
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = (data is Map && data['error'] != null)
          ? data['error'].toString()
          : 'Error eliminando persona (${e.response?.statusCode ?? 'red'})';
      throw Exception(msg);
    }
  }
}
