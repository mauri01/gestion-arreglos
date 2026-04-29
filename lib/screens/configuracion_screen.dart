import 'package:flutter/material.dart';
import '../../services/taller_config_service.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreController;
  late TextEditingController _direccionController;
  late TextEditingController _telefonoController;
  late TextEditingController _emailController;
  late TextEditingController _cuitController;
  late TextEditingController _notasController;

  bool _cargando = true;
  bool _guardando = false;
  bool _cambiosSinGuardar = false;

  @override
  void initState() {
    super.initState();
    _nombreController    = TextEditingController();
    _direccionController = TextEditingController();
    _telefonoController  = TextEditingController();
    _emailController     = TextEditingController();
    _cuitController      = TextEditingController();
    _notasController     = TextEditingController();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final config = await TallerConfigService.cargar();
    setState(() {
      _nombreController.text    = config.nombre;
      _direccionController.text = config.direccion;
      _telefonoController.text  = config.telefono;
      _emailController.text     = config.email;
      _cuitController.text      = config.cuit;
      _notasController.text     = config.notas;
      _cargando = false;
    });

    for (final ctrl in [
      _nombreController, _direccionController, _telefonoController,
      _emailController, _cuitController, _notasController,
    ]) {
      ctrl.addListener(() => setState(() => _cambiosSinGuardar = true));
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _cuitController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    await TallerConfigService.guardar(
      TallerConfig(
        nombre:    _nombreController.text.trim(),
        direccion: _direccionController.text.trim(),
        telefono:  _telefonoController.text.trim(),
        email:     _emailController.text.trim(),
        cuit:      _cuitController.text.trim(),
        notas:     _notasController.text.trim(),
      ),
    );

    if (mounted) {
      setState(() {
        _guardando = false;
        _cambiosSinGuardar = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Configuración guardada'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración del Taller'),
        actions: [
          if (_cambiosSinGuardar)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Chip(
                label: const Text('Sin guardar', style: TextStyle(fontSize: 12)),
                backgroundColor: Colors.orange[100],
                side: BorderSide(color: Colors.orange[300]!),
                visualDensity: VisualDensity.compact,
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: FilledButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: _guardando
                  ? const SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : const Icon(Icons.save),
              label: Text(_guardando ? 'Guardando...' : 'Guardar'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── AVISO si falta el nombre ──
                  if (_nombreController.text.isEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Completá los datos del taller para que aparezcan en los comprobantes.',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],

                  // ── SECCIÓN: DATOS PRINCIPALES ──
                  _SectionHeader(
                    icon: Icons.store,
                    title: 'Datos del Taller',
                    subtitle: 'Aparecen en el encabezado del comprobante',
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del taller *',
                      hintText: 'Ej: Taller Técnico García',
                      prefixIcon: Icon(Icons.storefront),
                    ),
                    validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'El nombre es obligatorio' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _direccionController,
                    decoration: const InputDecoration(
                      labelText: 'Dirección',
                      hintText: 'Ej: Av. San Martín 1234, Ciudad',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _telefonoController,
                          decoration: const InputDecoration(
                            labelText: 'Teléfono',
                            hintText: 'Ej: (261) 555-1234',
                            prefixIcon: Icon(Icons.phone),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'Ej: taller@email.com',
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _cuitController,
                    decoration: const InputDecoration(
                      labelText: 'CUIT / Identificación fiscal',
                      hintText: 'Ej: 20-12345678-9',
                      prefixIcon: Icon(Icons.badge),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── SECCIÓN: TEXTO AL PIE ──
                  _SectionHeader(
                    icon: Icons.receipt_long,
                    title: 'Texto al pie del comprobante',
                    subtitle: 'Condiciones, garantía, o cualquier nota adicional',
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _notasController,
                    decoration: const InputDecoration(
                      labelText: 'Notas / Condiciones',
                      hintText:
                      'Ej: Garantía de 90 días en repuestos. No nos hacemos responsables por pérdida de datos.',
                      prefixIcon: Icon(Icons.notes),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 40),

                  // ── PREVIEW ──
                  _SectionHeader(
                    icon: Icons.preview,
                    title: 'Vista previa del encabezado',
                    subtitle: 'Así se verá en el comprobante',
                  ),
                  const SizedBox(height: 16),

                  // Rebuild en tiempo real escuchando los controladores
                  ListenableBuilder(
                    listenable: Listenable.merge([
                      _nombreController, _direccionController,
                      _telefonoController, _emailController, _cuitController,
                    ]),
                    builder: (context, _) => _PreviewEncabezado(
                      nombre:    _nombreController.text,
                      direccion: _direccionController.text,
                      telefono:  _telefonoController.text,
                      email:     _emailController.text,
                      cuit:      _cuitController.text,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── BOTÓN AL PIE ──
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _guardando ? null : _guardar,
                      icon: _guardando
                          ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                          : const Icon(Icons.save),
                      label: Text(
                        _guardando ? 'Guardando...' : 'Guardar configuración',
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// ENCABEZADO DE SECCIÓN
// ══════════════════════════════════════════════
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            Text(subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════
// PREVIEW DEL ENCABEZADO DEL COMPROBANTE
// ══════════════════════════════════════════════
class _PreviewEncabezado extends StatelessWidget {
  final String nombre;
  final String direccion;
  final String telefono;
  final String email;
  final String cuit;

  const _PreviewEncabezado({
    required this.nombre,
    required this.direccion,
    required this.telefono,
    required this.email,
    required this.cuit,
  });

  @override
  Widget build(BuildContext context) {
    final tieneContenido = nombre.isNotEmpty || direccion.isNotEmpty ||
        telefono.isNotEmpty || email.isNotEmpty || cuit.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: !tieneContenido
          ? Center(
        child: Text(
          'Completá los campos para ver la vista previa',
          style: TextStyle(color: Colors.grey[500], fontSize: 13),
        ),
      )
          : Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (nombre.isNotEmpty)
                  Text(
                    nombre,
                    style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                if (direccion.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(direccion,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                ],
                if (telefono.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(children: [
                    Icon(Icons.phone, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(telefono,
                        style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                  ]),
                ],
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(children: [
                    Icon(Icons.email, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(email,
                        style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                  ]),
                ],
                if (cuit.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(children: [
                    Icon(Icons.badge, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('CUIT: $cuit',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                  ]),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'ORDEN #001',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'COPIA CLIENTE',
                style: TextStyle(
                    fontSize: 9, fontWeight: FontWeight.bold,
                    color: Color(0xFF1565C0)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}