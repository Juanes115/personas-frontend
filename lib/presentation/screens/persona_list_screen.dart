import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/persona_model.dart';
import '../providers/persona_provider.dart';
import 'persona_form_screen.dart';

/// Pantalla principal del CRUD: lista paginada (limit=10), búsqueda y acciones.
class PersonaListScreen extends ConsumerStatefulWidget {
  const PersonaListScreen({super.key});

  @override
  ConsumerState<PersonaListScreen> createState() => _PersonaListScreenState();
}

class _PersonaListScreenState extends ConsumerState<PersonaListScreen> {
  final _busquedaController = TextEditingController();

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  void _mostrarInformacion(BuildContext context, Persona persona) {
    Widget avatarWidget;
    if (persona.foto != null && persona.foto!.isNotEmpty) {
      try {
        final String fotoStr = persona.foto!;
        if (fotoStr.startsWith('http://') || fotoStr.startsWith('https://')) {
          avatarWidget = CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(fotoStr),
          );
        } else {
          final String cleanBase64 =
              fotoStr.contains(',') ? fotoStr.split(',').last : fotoStr;
          avatarWidget = CircleAvatar(
            radius: 40,
            backgroundImage: MemoryImage(base64Decode(cleanBase64)),
          );
        }
      } catch (_) {
        avatarWidget = CircleAvatar(
          radius: 40,
          backgroundColor: const Color(0xFFD9F3EC),
          child: Text(
            persona.nombre.isEmpty ? '?' : persona.nombre[0].toUpperCase(),
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
          ),
        );
      }
    } else {
      avatarWidget = CircleAvatar(
        radius: 40,
        backgroundColor: const Color(0xFFD9F3EC),
        child: Text(
          persona.nombre.isEmpty ? '?' : persona.nombre[0].toUpperCase(),
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            avatarWidget,
            const SizedBox(height: 16),
            Text(
              persona.nombreCompleto,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF12312F)),
            ),
            const SizedBox(height: 4),
            Text('ID ${persona.identificacion}', style: const TextStyle(color: Color(0xFF0F766E), fontWeight: FontWeight.w700)),
            const Divider(height: 24),
            _infoRow(Icons.email_outlined, 'Email', persona.email),
            const SizedBox(height: 8),
            _infoRow(Icons.phone_outlined, 'Teléfono', persona.telefono ?? 'No registrado'),
            const SizedBox(height: 8),
            _infoRow(Icons.location_on_outlined, 'Dirección', persona.direccion ?? 'No registrada'),
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

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF55706C)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF78938E))),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF12312F))),
            ],
          ),
        ),
      ],
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
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
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
            onPressed: () => ref.read(personasProvider.notifier).recargar(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: personasAsync.when(
        data: (state) {
          final personas = state.personas;
          final busqueda = state.search;
          final total = state.total;
          final page = state.page;
          final totalPages = state.totalPages;

          return Column(
            children: [
              // Barra de búsqueda
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: TextField(
                  controller: _busquedaController,
                  onSubmitted: (val) {
                    ref.read(personasProvider.notifier).setSearch(val.trim());
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre, identificación o email',
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.search_rounded),
                      onPressed: () {
                        ref.read(personasProvider.notifier).setSearch(_busquedaController.text.trim());
                      },
                    ),
                    suffixIcon: busqueda.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Limpiar búsqueda',
                            onPressed: () {
                              _busquedaController.clear();
                              ref.read(personasProvider.notifier).setSearch('');
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                  ),
                ),
              ),

              // Encabezado de información
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'Total: $total ${total == 1 ? 'persona' : 'personas'} (Pág. $page de $totalPages)',
                      style: const TextStyle(
                        color: Color(0xFF55706C),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    if (busqueda.isNotEmpty)
                      Text(
                        'Filtrando...',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Lista o Estado Vacío
              Expanded(
                child: personas.isEmpty
                    ? _EstadoVacio(
                        conBusqueda: busqueda.isNotEmpty,
                        onAgregar: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PersonaFormScreen(),
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                        itemCount: personas.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final persona = personas[index];
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

              // Control de Paginación (limit=10)
              if (totalPages > 1)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Botón Anterior
                      OutlinedButton.icon(
                        onPressed: page > 1
                            ? () {
                                ref.read(personasProvider.notifier).setPage(page - 1);
                              }
                            : null,
                        icon: const Icon(Icons.chevron_left_rounded, size: 20),
                        label: const Text('Anterior'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Botones de Páginas
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(totalPages, (index) {
                              final p = index + 1;
                              final esActual = p == page;
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 3),
                                child: InkWell(
                                  onTap: () {
                                    if (!esActual) {
                                      ref.read(personasProvider.notifier).setPage(p);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: esActual ? const Color(0xFF0F766E) : const Color(0xFFF0F6F5),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '$p',
                                      style: TextStyle(
                                        color: esActual ? Colors.white : const Color(0xFF12312F),
                                        fontWeight: esActual ? FontWeight.bold : FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Botón Siguiente
                      ElevatedButton.icon(
                        onPressed: page < totalPages
                            ? () {
                                ref.read(personasProvider.notifier).setPage(page + 1);
                              }
                            : null,
                        icon: const Icon(Icons.chevron_right_rounded, size: 20),
                        label: const Text('Siguiente'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
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

  Widget _buildAvatar() {
    final inicial = persona.nombre.isEmpty ? '?' : persona.nombre[0].toUpperCase();
    if (persona.foto != null && persona.foto!.isNotEmpty) {
      try {
        final String fotoStr = persona.foto!;
        if (fotoStr.startsWith('http://') || fotoStr.startsWith('https://')) {
          return CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(fotoStr),
          );
        }
        final String cleanBase64 = fotoStr.contains(',') ? fotoStr.split(',').last : fotoStr;
        final bytes = base64Decode(cleanBase64);
        return CircleAvatar(
          radius: 25,
          backgroundImage: MemoryImage(bytes),
        );
      } catch (_) {}
    }
    return CircleAvatar(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _buildAvatar(),
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