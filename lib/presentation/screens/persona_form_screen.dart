import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/persona_model.dart';
import '../providers/persona_provider.dart';

class PersonaFormScreen extends ConsumerStatefulWidget {
  final Persona? persona; // null = crear, no null = editar

  const PersonaFormScreen({super.key, this.persona});

  @override
  ConsumerState<PersonaFormScreen> createState() => _PersonaFormScreenState();
}

class _PersonaFormScreenState extends ConsumerState<PersonaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _identificacion;
  late final TextEditingController _nombre;
  late final TextEditingController _apellido;
  late final TextEditingController _email;
  late final TextEditingController _telefono;
  late final TextEditingController _direccion;

  bool get esEdicion => widget.persona != null;

  @override
  void initState() {
    super.initState();
    final p = widget.persona;
    _identificacion = TextEditingController(text: p?.identificacion ?? '');
    _nombre = TextEditingController(text: p?.nombre ?? '');
    _apellido = TextEditingController(text: p?.apellido ?? '');
    _email = TextEditingController(text: p?.email ?? '');
    _telefono = TextEditingController(text: p?.telefono ?? '');
    _direccion = TextEditingController(text: p?.direccion ?? '');
  }

  String? _validarIdentificacion(String? v) {
    if (v == null || v.isEmpty) return 'La identificación es obligatoria';
    if (!RegExp(r'^\d{6,13}$').hasMatch(v)) {
      return 'La identificación debe tener entre 6 y 13 números';
    }
    return null;
  }

  String? _validarNombre(String? v) {
    if (v == null || v.isEmpty) return 'El nombre es obligatorio';
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s]+$').hasMatch(v)) {
      return 'El nombre solo puede contener letras y espacios';
    }
    return null;
  }

  String? _validarApellido(String? v) {
    if (v == null || v.isEmpty) return 'El apellido es obligatorio';
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s]+$').hasMatch(v)) {
      return 'El apellido solo puede contener letras y espacios';
    }
    return null;
  }

  String? _validarEmail(String? v) {
    if (v == null || v.isEmpty) return 'Ingrese un email válido';
    if (!RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$').hasMatch(v)) {
      return 'Ingrese un email válido';
    }
    return null;
  }

  String? _validarTelefono(String? v) {
    if (v == null || v.isEmpty) return null; // opcional
    if (!RegExp(r'^\d{10,13}$').hasMatch(v)) {
      return 'El teléfono debe tener entre 10 y 13 números';
    }
    return null;
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final persona = Persona(
      id: widget.persona?.id,
      identificacion: _identificacion.text,
      nombre: _nombre.text,
      apellido: _apellido.text,
      email: _email.text,
      telefono: _telefono.text.isEmpty ? null : _telefono.text,
      direccion: _direccion.text.isEmpty ? null : _direccion.text,
    );

    try {
      if (esEdicion) {
        await ref.read(personasProvider.notifier).actualizar(widget.persona!.id!, persona);
      } else {
        await ref.read(personasProvider.notifier).agregar(persona);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(esEdicion ? 'Persona actualizada' : 'Persona agregada correctamente')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(esEdicion ? 'Editar Persona' : 'Agregar Persona')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            children: [
              TextFormField(
                controller: _identificacion,
                decoration: const InputDecoration(labelText: 'Identificación'),
                validator: _validarIdentificacion,
              ),
              TextFormField(
                controller: _nombre,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: _validarNombre,
              ),
              TextFormField(
                controller: _apellido,
                decoration: const InputDecoration(labelText: 'Apellido'),
                validator: _validarApellido,
              ),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: _validarEmail,
              ),
              TextFormField(
                controller: _telefono,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                validator: _validarTelefono,
              ),
              TextFormField(
                controller: _direccion,
                decoration: const InputDecoration(labelText: 'Dirección'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _guardar,
                child: Text(esEdicion ? 'Actualizar' : 'Agregar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}