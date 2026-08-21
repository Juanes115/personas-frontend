import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/persona_model.dart';
import '../providers/persona_provider.dart';
import 'persona_form_screen.dart';

/// Pantalla principal del CRUD: lista, búsqueda y acciones de cada persona.
class PersonaListScreen extends ConsumerStatefulWidget {
  const PersonaListScreen({super.key});

  @override
  ConsumerState<PersonaListScreen> createState() => _PersonaListScreenState();
}

class _PersonaListScreenState extends ConsumerState<PersonaListScreen> {
  // El texto se conserva en el estado para filtrar sin volver a consultar la API.
  final _busquedaController = TextEditingController();
  String _busqueda = '';

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  void _mostrarInformacion(BuildContext context, Persona persona) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(persona.nombreCompleto),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Identificación: ${persona.identificacion}'),
            Text('Nombre: ${persona.nombre}'),
            Text('Apellido: ${persona.apellido}'),
            Text('Email: ${persona.email}'),
            Text('Teléfono: ${persona.telefono ?? 'No registrado'}'),
            Text('Dirección: ${persona.direccion ?? 'No registrada'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, WidgetRef ref, int id, String nombre) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar Persona'),
        content: Text('¿Estás seguro de eliminar a $nombre?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ref.read(personasProvider.notifier).eliminar(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Persona eliminada correctamente')),
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final personasAsync = ref.watch(personasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Personas',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar lista',
            onPressed: () => ref.invalidate(personasProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: personasAsync.when(
        data: (personas) {
          final personasFiltradas = personas.where((persona) {
            final texto = _busqueda.toLowerCase();
            return persona.nombreCompleto.toLowerCase().contains(texto) ||
                persona.identificacion.contains(texto) ||
                persona.email.toLowerCase().contains(texto);
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: TextField(
                  controller: _busquedaController,
                  onChanged: (value) => setState(() => _busqueda = value),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre, identificación o email',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _busqueda.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Limpiar búsqueda',
                            onPressed: () {
                              _busquedaController.clear();
                              setState(() => _busqueda = '');
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      '${personasFiltradas.length} ${personasFiltradas.length == 1 ? 'persona' : 'personas'}',
                      style: const TextStyle(
                        color: Color(0xFF55706C),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    if (_busqueda.isNotEmpty)
                      Text(
                        'Filtrando resultados',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: personasFiltradas.isEmpty
                    ? _EstadoVacio(
                        conBusqueda: _busqueda.isNotEmpty,
                        onAgregar: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PersonaFormScreen(),
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                        itemCount: personasFiltradas.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final persona = personasFiltradas[index];
                          return _PersonaCard(
                            persona: persona,
                            onInfo: () => _mostrarInformacion(context, persona),
                            onEdit: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PersonaFormScreen(persona: persona),
                              ),
                            ),
                            onDelete: () => _confirmarEliminar(
                              context,
                              ref,
                              persona.id!,
                              persona.nombreCompleto,
                            ),
                          );
                        },
                      ),
                  ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Agregar persona',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PersonaFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _PersonaCard extends StatelessWidget {
  final Persona persona;
  final VoidCallback onInfo;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PersonaCard({
    required this.persona,
    required this.onInfo,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final inicial = persona.nombre.isEmpty ? '?' : persona.nombre[0].toUpperCase();
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFFD9F3EC),
              child: Text(
                inicial,
                style: const TextStyle(
                  color: Color(0xFF0F766E),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    persona.nombreCompleto,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF12312F),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    persona.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFF6A8580), fontSize: 13),
                  ),
                  Text(
                    'ID ${persona.identificacion}',
                    style: const TextStyle(
                      color: Color(0xFF0F766E),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Acciones',
              onSelected: (value) {
                if (value == 'info') onInfo();
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'info', child: Text('Ver información')),
                PopupMenuItem(value: 'edit', child: Text('Editar')),
                PopupMenuItem(value: 'delete', child: Text('Eliminar')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EstadoVacio extends StatelessWidget {
  final bool conBusqueda;
  final VoidCallback onAgregar;

  const _EstadoVacio({required this.conBusqueda, required this.onAgregar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              conBusqueda ? Icons.search_off_rounded : Icons.person_add_alt_1_rounded,
              size: 54,
              color: const Color(0xFF75A8A0),
            ),
            const SizedBox(height: 16),
            Text(
              conBusqueda ? 'No encontramos resultados' : 'Aún no hay personas',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF12312F),
              ),
            ),
            if (!conBusqueda) ...[
              const SizedBox(height: 8),
              const Text(
                'Agrega el primer registro para comenzar.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF6A8580)),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onAgregar,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Agregar persona'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}