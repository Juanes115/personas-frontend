import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/persona_model.dart';
import '../../data/repositories/persona_repository.dart';

final personaRepositoryProvider = Provider((ref) => PersonaRepository());

final personasProvider =
    AsyncNotifierProvider<PersonasNotifier, List<Persona>>(PersonasNotifier.new);

class PersonasNotifier extends AsyncNotifier<List<Persona>> {
  @override
  Future<List<Persona>> build() async {
    final repo = ref.read(personaRepositoryProvider);
    return repo.fetchPersonas();
  }

  Future<void> agregar(Persona persona) async {
    final repo = ref.read(personaRepositoryProvider);
    await repo.createPersona(persona);
    state = await AsyncValue.guard(() => repo.fetchPersonas());
  }

  Future<void> actualizar(int id, Persona persona) async {
    final repo = ref.read(personaRepositoryProvider);
    await repo.updatePersona(id, persona);
    state = await AsyncValue.guard(() => repo.fetchPersonas());
  }

  Future<void> eliminar(int id) async {
    final repo = ref.read(personaRepositoryProvider);
    await repo.deletePersona(id);
    state = await AsyncValue.guard(() => repo.fetchPersonas());
  }
}