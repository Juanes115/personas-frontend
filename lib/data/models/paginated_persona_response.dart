import 'persona_model.dart';

/// Respuesta paginada entregada por la API del backend.
class PaginatedPersonaResponse {
  final List<Persona> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  PaginatedPersonaResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginatedPersonaResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List? ?? [];
    return PaginatedPersonaResponse(
      data: list
          .map((item) => Persona.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 10,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }
}
