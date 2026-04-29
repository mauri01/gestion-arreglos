import 'package:shared_preferences/shared_preferences.dart';

// ==========================================
// CLAVES DE ALMACENAMIENTO
// ==========================================
class _Keys {
  static const nombre    = 'taller_nombre';
  static const direccion = 'taller_direccion';
  static const telefono  = 'taller_telefono';
  static const email     = 'taller_email';
  static const cuit      = 'taller_cuit';
  static const notas     = 'taller_notas';
}

// ==========================================
// MODELO
// ==========================================
class TallerConfig {
  final String nombre;
  final String direccion;
  final String telefono;
  final String email;
  final String cuit;
  final String notas;

  const TallerConfig({
    this.nombre    = '',
    this.direccion = '',
    this.telefono  = '',
    this.email     = '',
    this.cuit      = '',
    this.notas     = '',
  });

  bool get estaConfigurado => nombre.isNotEmpty;

  TallerConfig copyWith({
    String? nombre,
    String? direccion,
    String? telefono,
    String? email,
    String? cuit,
    String? notas,
  }) {
    return TallerConfig(
      nombre:    nombre    ?? this.nombre,
      direccion: direccion ?? this.direccion,
      telefono:  telefono  ?? this.telefono,
      email:     email     ?? this.email,
      cuit:      cuit      ?? this.cuit,
      notas:     notas     ?? this.notas,
    );
  }
}

// ==========================================
// SERVICIO
// ==========================================
class TallerConfigService {
  /// Lee la configuración guardada.
  static Future<TallerConfig> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    return TallerConfig(
      nombre:    prefs.getString(_Keys.nombre)    ?? '',
      direccion: prefs.getString(_Keys.direccion) ?? '',
      telefono:  prefs.getString(_Keys.telefono)  ?? '',
      email:     prefs.getString(_Keys.email)     ?? '',
      cuit:      prefs.getString(_Keys.cuit)      ?? '',
      notas:     prefs.getString(_Keys.notas)     ?? '',
    );
  }

  /// Guarda la configuración.
  static Future<void> guardar(TallerConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_Keys.nombre,    config.nombre);
    await prefs.setString(_Keys.direccion, config.direccion);
    await prefs.setString(_Keys.telefono,  config.telefono);
    await prefs.setString(_Keys.email,     config.email);
    await prefs.setString(_Keys.cuit,      config.cuit);
    await prefs.setString(_Keys.notas,     config.notas);
  }
}