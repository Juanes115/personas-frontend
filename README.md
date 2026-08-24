# Personas App (Flutter Frontend)

Aplicación Flutter moderna para administrar personas conectada a la API REST. Incluye sistema de paginación (`limit=10`), búsqueda en tiempo real, interfaz responsiva y carga/captura de imágenes (Cámara y Galería/Archivos).

## 📐 Arquitectura del Proyecto

```text
Pantallas Flutter
	|
	v
Riverpod (estado paginado) --> Repository (Dio) --> API Express (Backend) --> PostgreSQL (Neon DB)
```

Estructura modular del código (`lib/`):
- `lib/data/models`: Modelos de datos `Persona` y `PaginatedPersonaResponse`.
- `lib/data/repositories`: `PersonaRepository` con peticiones HTTP usando Dio.
- `lib/presentation/providers`: Gestión de estado paginado con Riverpod (`personasProvider`).
- `lib/presentation/screens`: Pantallas principales (`home_screen`, `persona_list_screen`, `persona_form_screen`).

---

## 🚀 Guía para Ejecutar el Frontend Localmente

### 1. Requisitos Previos
- **Flutter SDK**: v3.13.0 o superior (`flutter doctor`)
- **Navegador Web**: Microsoft Edge, Google Chrome o la plataforma de tu preferencia.
- Backend en ejecución en `http://localhost:3000`.

---

### 2. Descargar Dependencias
Abre una terminal en la carpeta `personas-frontend` y ejecuta:

```bash
flutter pub get
```

---

### 3. Verificar el Estado del Código (Opcional)
```bash
flutter analyze
```

---

### 4. Iniciar la Aplicación Frontend
Asegúrate de que el backend esté corriendo en `http://localhost:3000` y ejecuta alguno de los siguientes comandos:

#### Opción A: En Microsoft Edge (Recomendado)
```bash
flutter run -d edge --web-hostname localhost --web-port 8080
```

#### Opción B: En Google Chrome
```bash
flutter run -d chrome --web-hostname localhost --web-port 8080
```

#### Opción C: Servidor Web Ligero (Web Server)
```bash
flutter run -d web-server --web-hostname localhost --web-port 8080
```

---

### 5. Abrir en el Navegador
Abre tu navegador e ingresa a:
👉 **`http://localhost:8080`**

---

## 📸 Funcionalidades Clave
- **Listado Paginado**: Paginación con límite de 10 elementos por página (`limit=10`) con botones *Anterior* / *Siguiente* e indicador de páginas.
- **Búsqueda Avanzada**: Búsqueda por nombre, identificación o email.
- **Carga de Imágenes**:
  - 📷 **Cámara**: Capturar foto directamente con la cámara del dispositivo.
  - 📁 **Galería / Archivos**: Seleccionar imagen almacenada localmente.
- **Operaciones CRUD**: Creación, consulta detallada, edición y eliminación de registros.
