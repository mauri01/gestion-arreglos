import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database/database.dart';
import 'screens/home_screen.dart';
import 'services/update_service.dart';
import 'widgets/update_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Precalentar shared_preferences ANTES de mostrar la ventana
  // Esto evita la pantalla en blanco al iniciar
  await SharedPreferences.getInstance();

  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1280, 720),
    minimumSize: Size(1280, 720),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.maximize();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<AppDatabase>(
      create: (_) => AppDatabase(),
      dispose: (_, db) => db.close(),
      child: MaterialApp(
        title: 'Gestión de Arreglos',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
          ),
        ),
        home: const AppWrapper(),
      ),
    );
  }
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> with WindowListener {
  bool _listo = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _inicializar();
  }

  Future<void> _inicializar() async {
    // shared_preferences ya fue precalentado en main(),
    // esta llamada es instantánea — sin espera real.
    await SharedPreferences.getInstance();

    if (mounted) {
      setState(() => _listo = true);

      // Verificar actualizaciones DESPUÉS de que la UI ya es visible
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _verificarActualizaciones();
      });
    }
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowResize() async {
    final size = await windowManager.getSize();
    if (size.width < 1280 || size.height < 720) {
      await windowManager.setSize(const Size(1280, 720));
    }
  }

  Future<void> _verificarActualizaciones() async {
    try {
      final updateInfo = await UpdateService.verificarActualizacion();
      if (updateInfo != null && mounted) {
        showDialog(
          context: context,
          barrierDismissible: !updateInfo.required,
          builder: (context) => UpdateDialog(updateInfo: updateInfo),
        );
      }
    } catch (_) {
      // Si falla la verificación (sin internet, URL no existe, etc.)
      // simplemente se ignora — no debe afectar el inicio de la app
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_listo) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Iniciando...',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return const HomeScreen();
  }
}