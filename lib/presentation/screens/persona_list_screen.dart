import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/persona_provider.dart';
import 'persona_form_screen.dart';

class PersonaListScreen extends ConsumerWidget {
  const PersonaListScreen({super.key});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final personasAsync = ref.watch(personasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Personas')),
      body: personasAsync.when(
        data: (personas) => ListView.builder(
          itemCount: personas.length,
          itemBuilder: (context, index) {
            final persona = personas[index];
            return ListTile(
              title: Text(persona.nombreCompleto),
              subtitle: Text(persona.identificacion),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.info_outline), onPressed: () {}),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PersonaFormScreen(persona: persona),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _confirmarEliminar(
                        context, ref, persona.id!, persona.nombreCompleto),
                  ),
                ],
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
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