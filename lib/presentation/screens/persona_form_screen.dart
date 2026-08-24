import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
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

  String? _fotoBase64;
  final ImagePicker _picker = ImagePicker();

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
    _fotoBase64 = p?.foto;
  }

  @override
  void dispose() {
    _identificacion.dispose();
    _nombre.dispose();
    _apellido.dispose();
    _email.dispose();
    _telefono.dispose();
    _direccion.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 80,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64Str = base64Encode(bytes);
        setState(() {
          _fotoBase64 = 'data:image/png;base64,$base64Str';
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error seleccionando imagen: $e')),
      );
    }
  }

  void _mostrarOpcionesImagen() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Seleccionar Foto de Perfil',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF12312F)),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFD9F3EC),
                  child: Icon(Icons.camera_alt_rounded, color: Color(0xFF0F766E)),
                ),
                title: const Text('Tomar foto con la Cámara', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Captura una foto directamente con la cámara del dispositivo'),
                onTap: () {
                  Navigator.pop(context);
                  _seleccionarImagen(ImageSource.camera);
                },
              ),
              const Divider(),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFD9F3EC),
                  child: Icon(Icons.photo_library_rounded, color: Color(0xFF0F766E)),
                ),
                title: const Text('Galería / Archivos locales', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Selecciona una imagen guardada en tu dispositivo'),
                onTap: () {
                  Navigator.pop(context);
                  _seleccionarImagen(ImageSource.gallery);
                },
              ),
              if (_fotoBase64 != null && _fotoBase64!.isNotEmpty) ...[
                const Divider(),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFEBEB),
                    child: Icon(Icons.delete_outline_rounded, color: Colors.red),
                  ),
                  title: const Text('Eliminar foto', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _fotoBase64 = null);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
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
      foto: _fotoBase64,
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

  Widget _buildImagePreview() {
    ImageProvider? imageProvider;
    if (_fotoBase64 != null && _fotoBase64!.isNotEmpty) {
      try {
        final str = _fotoBase64!;
        if (str.startsWith('http://') || str.startsWith('https://')) {
          imageProvider = NetworkImage(str);
        } else {
          final cleanBase64 = str.contains(',') ? str.split(',').last : str;
          imageProvider = MemoryImage(base64Decode(cleanBase64));
        }
      } catch (_) {}
    }

    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFD9F3EC),
              border: Border.all(color: const Color(0xFF0F766E), width: 3),
              image: imageProvider != null
                  ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
                  : null,
            ),
            child: imageProvider == null
                ? const Icon(Icons.person_rounded, size: 60, color: Color(0xFF0F766E))
                : null,
          ),
          Material(
            elevation: 4,
            shape: const CircleBorder(),
            color: const Color(0xFF0F766E),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _mostrarOpcionesImagen,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
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
              const SizedBox(height: 8),
              _buildImagePreview(),
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: _mostrarOpcionesImagen,
                  icon: const Icon(Icons.image_search_rounded, size: 18),
                  label: Text(
                    _fotoBase64 != null ? 'Cambiar Foto / Cargar' : 'Cargar Foto de Perfil',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _identificacion,
                decoration: const InputDecoration(labelText: 'Identificación'),
                validator: _validarIdentificacion,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nombre,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: _validarNombre,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _apellido,
                decoration: const InputDecoration(labelText: 'Apellido'),
                validator: _validarApellido,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: _validarEmail,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _telefono,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                validator: _validarTelefono,
              ),
              const SizedBox(height: 12),
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