import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/persona_model.dart';
import '../../data/repositories/persona_repository.dart';

/// Comparte una instancia del repositorio con la capa de presentación.
final personaRepositoryProvider = Provider((ref) => PersonaRepository());

/// Expone el estado asíncrono de la lista de personas a las pantallas.
final personasProvider =
    AsyncNotifierProvider<PersonasNotifier, List<Persona>>(PersonasNotifier.new);

/// Coordina las operaciones CRUD y actualiza el estado de la lista.
class PersonasNotifier extends AsyncNotifier<List<Persona>> {
  @override
  Future<List<Persona>> build() async {
    final repo = ref.read(personaRepositoryProvider);
    return repo.fetchPersonas();
  }

  /// Crea una persona y vuelve a cargar la lista.
  Future<void> agregar(Persona persona) async {
    final repo = ref.read(personaRepositoryProvider);
    await repo.createPersona(persona);
    state = await AsyncValue.guard(() => repo.fetchPersonas());
  }

  /// Actualiza una persona y vuelve a cargar la lista.
  Future<void> actualizar(int id, Persona persona) async {
    final repo = ref.read(personaRepositoryProvider);
    await repo.updatePersona(id, persona);
    state = await AsyncValue.guard(() => repo.fetchPersonas());
  }

  /// Elimina una persona y vuelve a cargar la lista.
  Future<void> eliminar(int id) async {
    final repo = ref.read(personaRepositoryProvider);
    await repo.deletePersona(id);
    state = await AsyncValue.guard(() => repo.fetchPersonas());
  }
}