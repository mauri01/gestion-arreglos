# 🔧 Gestión de Arreglos

Sistema de escritorio para talleres técnicos. Permite gestionar clientes, equipos y órdenes de servicio, con generación de comprobantes en PDF.

Desarrollado con **Flutter** para Windows.

---

## ✨ Funcionalidades

- **Clientes** — alta, edición, búsqueda y eliminación. Los equipos de cada cliente se ven expandibles dentro de su card.
- **Equipos** — registro por tipo (impresora, PC, laptop, monitor, otro) asociado a un cliente.
- **Órdenes de servicio** — seguimiento de estado (pendiente → en proceso → finalizada → entregada), diagnóstico, solución y costo.
- **Comprobantes PDF** — genera una hoja A4 con copia para el cliente y copia para el taller, lista para imprimir.
- **Dashboard** — resumen de órdenes pendientes, en proceso, total de clientes y equipos.
- **Configuración del taller** — nombre, dirección, teléfono, email, CUIT y notas al pie que aparecen en los comprobantes.

---

## 🗂 Estructura del proyecto

```
lib/
├── database/
│   └── database.dart          # Esquema y operaciones con Drift (SQLite)
├── screens/
│   ├── home_screen.dart        # Navegación principal + Dashboard
│   ├── clientes/
│   │   └── clientes_screen.dart
│   ├── equipos/
│   │   └── equipos_screen.dart
│   ├── ordenes/
│   │   └── ordenes_screen.dart
│   └── configuracion/
│       └── configuracion_screen.dart
└── services/
    ├── comprobante_service.dart   # Generación de PDF
    ├── taller_config_service.dart # Persistencia de datos del taller
    └── update_service.dart        # Verificación de actualizaciones
```

---

## 🛠 Requisitos de desarrollo

| Herramienta | Versión mínima |
|---|---|
| Flutter SDK | 3.19+ |
| Dart SDK | 3.3+ |
| Windows | 10 / 11 (64-bit) |
| Inno Setup | 6+ (solo para generar el installer) |

---

## 🚀 Cómo correr el proyecto

```bash
# 1. Clonar el repositorio
git clone https://github.com/mauri01/gestion-arreglos.git
cd gestion-arreglos

# 2. Instalar dependencias
flutter pub get

# 3. Generar código de Drift (base de datos)
dart run build_runner build --delete-conflicting-outputs

# 4. Correr en modo desarrollo
flutter run -d windows
```

---

## 📦 Generar el instalador (.exe)

### Paso 1 — Build de Flutter

```bash
flutter build windows --release
```

Esto compila la app y deja los archivos en:
```
build\windows\x64\runner\Release\
```

### Paso 2 — Compilar el installer con Inno Setup

**Opción A — Interfaz gráfica:**
1. Abrír **Inno Setup Compiler**
2. `File` → `Open` → seleccionar `installer.iss`
3. `Build` → `Compile` (o presionar **F9**)
4. El installer queda en `installer_output\gestion_arreglos_setup_v1.0.0.exe`

**Opción B — Línea de comandos:**
```bash
"C:\Program Files (x86)\Inno Setup 6\ISCC.exe" installer.iss
```

> 💡 El archivo `installer_output\` está en `.gitignore`. El `.exe` generado se distribuye aparte, no se sube al repo.

### Actualizar la versión del installer

Antes de generar una nueva versión, editar estas líneas en `installer.iss`:

```ini
AppVersion=1.0.1
OutputBaseFilename=gestion_arreglos_setup_v1.0.1
```

---

## 📚 Dependencias principales

```yaml
dependencies:
  drift: ^2.x          # Base de datos SQLite con ORM
  drift_flutter: ^x.x
  provider: ^6.x       # Inyección de dependencias
  pdf: ^3.x            # Generación de PDF
  printing: ^5.x       # Impresión y preview de PDF
  shared_preferences: ^2.x  # Persistencia de configuración
  window_manager: ^0.x # Control de ventana de escritorio
  path_provider: ^2.x
  intl: ^0.x
  url_launcher: ^6.x
  package_info_plus: ^x.x
  http: ^1.x
```

---

## 🗃 Base de datos

La app usa **SQLite** a través de Drift. El archivo de base de datos se guarda en:

```
C:\Users\<usuario>\Documents\gestion_arreglos.db
```

Las tablas son:
- `clientes` — datos de contacto
- `equipos` — dispositivos asociados a un cliente
- `ordenes` — órdenes de servicio con estado y costo
- `historial` — log de cambios por orden

> ⚠️ Si se modifica el esquema de la base de datos, incrementar `schemaVersion` en `database.dart` y agregar la migración correspondiente.

---

## 🔄 Actualización de la app

El sistema verifica actualizaciones al iniciar comparando la versión actual con un archivo `version.json` hosteado en GitHub Releases. Para publicar una nueva versión:

1. Generar el installer (ver sección anterior)
2. Crear un nuevo Release en GitHub
3. Subir el `.exe` del installer
4. Actualizar el `version.json` con la nueva versión y URL de descarga

Formato del `version.json`:
```json
{
  "version": "1.0.1",
  "download_url": "https://github.com/mauri01/gestion-arreglos/releases/download/v1.0.1/gestion_arreglos_setup_v1.0.1.exe",
  "changelog": "- Comprobantes PDF\n- Equipos expandibles por cliente\n- Configuración del taller",
  "release_date": "2025-01-15",
  "required": false
}
```

---

## 📝 Licencia

Uso privado.