import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/persona_model.dart';
import '../../data/repositories/persona_repository.dart';

/// Estado paginado de la lista de personas.
class PersonaState {
  final List<Persona> personas;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final String search;

  PersonaState({
    required this.personas,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.search,
  });

  PersonaState copyWith({
    List<Persona>? personas,
    int? page,
    int? limit,
    int? total,
    int? totalPages,
    String? search,
  }) {
    return PersonaState(
      personas: personas ?? this.personas,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
      search: search ?? this.search,
    );
  }
}

/// Comparte una instancia del repositorio con la capa de presentación.
final personaRepositoryProvider = Provider((ref) => PersonaRepository());

/// Expone el estado asíncrono paginado de la lista de personas a las pantallas.
final personasProvider =
    AsyncNotifierProvider<PersonasNotifier, PersonaState>(PersonasNotifier.new);

/// Coordina las operaciones CRUD y actualiza el estado de la lista paginada.
class PersonasNotifier extends AsyncNotifier<PersonaState> {
  @override
  Future<PersonaState> build() async {
    final repo = ref.read(personaRepositoryProvider);
    final res = await repo.fetchPersonas(page: 1, limit: 10, search: '');
    return PersonaState(
      personas: res.data,
      page: res.page,
      limit: res.limit,
      total: res.total,
      totalPages: res.totalPages,
      search: '',
    );
  }

  /// Cambia a la página indicada.
  Future<void> setPage(int page) async {
    final current = state.valueOrNull;
    final search = current?.search ?? '';
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(personaRepositoryProvider);
      final res = await repo.fetchPersonas(page: page, limit: 10, search: search);
      return PersonaState(
        personas: res.data,
        page: res.page,
        limit: res.limit,
        total: res.total,
        totalPages: res.totalPages,
        search: search,
      );
    });
  }

  /// Actualiza la búsqueda y reinicia a la página 1.
  Future<void> setSearch(String search) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(personaRepositoryProvider);
      final res = await repo.fetchPersonas(page: 1, limit: 10, search: search);
      return PersonaState(
        personas: res.data,
        page: res.page,
        limit: res.limit,
        total: res.total,
        totalPages: res.totalPages,
        search: search,
      );
    });
  }

  /// Recarga la página actual.
  Future<void> recargar() async {
    final current = state.valueOrNull;
    final page = current?.page ?? 1;
    final search = current?.search ?? '';
    state = await AsyncValue.guard(() async {
      final repo = ref.read(personaRepositoryProvider);
      final res = await repo.fetchPersonas(page: page, limit: 10, search: search);
      return PersonaState(
        personas: res.data,
        page: res.page,
        limit: res.limit,
        total: res.total,
        totalPages: res.totalPages,
        search: search,
      );
    });
  }

  /// Crea una persona y vuelve a cargar la lista paginada.
  Future<void> agregar(Persona persona) async {
    final repo = ref.read(personaRepositoryProvider);
    await repo.createPersona(persona);
    await recargar();
  }

  /// Actualiza una persona y vuelve a cargar la lista paginada.
  Future<void> actualizar(int id, Persona persona) async {
    final repo = ref.read(personaRepositoryProvider);
    await repo.updatePersona(id, persona);
    await recargar();
  }

  /// Elimina una persona y vuelve a cargar la lista paginada.
  Future<void> eliminar(int id) async {
    final repo = ref.read(personaRepositoryProvider);
    await repo.deletePersona(id);
    await recargar();
  }
}