import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class UpdateService {
  // Cambia esto por tu URL de GitHub
  static const String versionUrl =
      'https://github.com/mauri01/gestion-arreglos/releases/download/v1.0.0/version.json';

  static Future<UpdateInfo?> verificarActualizacion() async {
    try {
      // Obtener versión actual de la app
      final packageInfo = await PackageInfo.fromPlatform();
      final versionActual = packageInfo.version;

      // Descargar información de la última versión
      final response = await http.get(Uri.parse(versionUrl)).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode != 200) {
        return null;
      }

      final data = json.decode(response.body);
      final versionDisponible = data['version'] as String;

      // Comparar versiones
      if (_esVersionNueva(versionActual, versionDisponible)) {
        return UpdateInfo(
          version: versionDisponible,
          downloadUrl: data['download_url'] as String,
          changelog: data['changelog'] as String,
          releaseDate: data['release_date'] as String,
          required: data['required'] as bool? ?? false,
        );
      }

      return null;
    } catch (e) {
      print('Error al verificar actualización: $e');
      return null;
    }
  }

  static bool _esVersionNueva(String actual, String disponible) {
    final partesActual = actual.split('.').map(int.parse).toList();
    final partesDisponible = disponible.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      if (partesDisponible[i] > partesActual[i]) {
        return true;
      } else if (partesDisponible[i] < partesActual[i]) {
        return false;
      }
    }

    return false;
  }
}

class UpdateInfo {
  final String version;
  final String downloadUrl;
  final String changelog;
  final String releaseDate;
  final bool required;

  UpdateInfo({
    required this.version,
    required this.downloadUrl,
    required this.changelog,
    required this.releaseDate,
    required this.required,
  });
}