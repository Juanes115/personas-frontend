# Personas App

Aplicación Flutter para administrar personas mediante una API REST. Permite
listar, buscar, consultar, crear, editar y eliminar registros.

## Arquitectura

```text
Pantallas Flutter
	|
	v
Riverpod (estado) --> Repository (Dio) --> API Express --> PostgreSQL
```

La estructura principal está organizada por responsabilidades:

- `lib/data/models`: representa los datos que llegan y salen como JSON.
- `lib/data/repositories`: concentra las peticiones HTTP al backend.
- `lib/presentation/providers`: mantiene el estado de la lista con Riverpod.
- `lib/presentation/screens`: contiene las pantallas y la interacción del usuario.

## Ejecutar el proyecto

```powershell
flutter pub get
flutter analyze
flutter run -d chrome
```

El backend debe responder en `http://localhost:3000` y la API en:

```text
http://localhost:3000/api/personas
```

## URL según el dispositivo

La URL se configura en `lib/data/repositories/persona_repository.dart`.

| Entorno | URL base |
| --- | --- |
| Flutter Web en el mismo computador | `http://localhost:3000/api` |
| Emulador Android con backend local | `http://10.0.2.2:3000/api` |
| Celular físico u otro computador | `http://IP_DEL_SERVIDOR:3000/api` |

## Flujo del CRUD

1. `PersonaListScreen` observa `personasProvider`.
2. `PersonasNotifier` solicita la lista al repositorio.
3. `PersonaRepository` usa Dio para llamar a `/personas`.
4. La respuesta JSON se convierte en objetos `Persona`.
5. Riverpod actualiza la pantalla cuando cambia `state`.

| Acción | Método | Endpoint |
| --- | --- | --- |
| Listar | GET | `/api/personas` |
| Crear | POST | `/api/personas` |
| Editar | PUT | `/api/personas/:id` |
| Eliminar | DELETE | `/api/personas/:id` |

## Interfaz

- Inicio con acceso a la gestión de personas.
- Lista con búsqueda por nombre, identificación o email.
- Tarjetas con avatar, email y acciones agrupadas.
- Diálogo de información completa.
- Formulario con validación en tiempo real.
- Estados de carga, error y lista vacía.
