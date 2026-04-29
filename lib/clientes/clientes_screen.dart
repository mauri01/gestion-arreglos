import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;
import '../../database/database.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  String _searchQuery = '';

  // Controla qué clientes tienen los equipos expandidos
  final Set<int> _expandidos = {};

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<AppDatabase>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
          SizedBox(
            width: 300,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar cliente...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    // Limpiar expandidos al buscar para que no queden
                    // estados "colgados" de otra búsqueda
                    _expandidos.clear();
                  });
                },
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Cliente>>(
        future: _searchQuery.isEmpty
            ? database.obtenerTodosLosClientes()
            : database.buscarClientesPorNombre(_searchQuery),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty
                        ? 'No hay clientes registrados'
                        : 'No se encontraron clientes',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _searchQuery.isEmpty
                        ? 'Presioná el botón + para agregar uno'
                        : 'Intenta con otro término de búsqueda',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          final clientes = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: clientes.length,
            itemBuilder: (context, index) {
              final cliente = clientes[index];
              final estaExpandido = _expandidos.contains(cliente.id);

              return _ClienteCard(
                cliente: cliente,
                estaExpandido: estaExpandido,
                onToggleExpand: () {
                  setState(() {
                    if (estaExpandido) {
                      _expandidos.remove(cliente.id);
                    } else {
                      _expandidos.add(cliente.id);
                    }
                  });
                },
                onEditar: () => _mostrarDialogoCliente(context, cliente: cliente),
                onEliminar: () => _confirmarEliminar(context, cliente),
                onDetalle: () => _mostrarDetalleCliente(context, cliente),
                onRefresh: () => setState(() {}),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarDialogoCliente(context),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Cliente'),
      ),
    );
  }

  void _mostrarDialogoCliente(BuildContext context, {Cliente? cliente}) {
    showDialog(
      context: context,
      builder: (context) => ClienteDialog(cliente: cliente),
    ).then((_) => setState(() {}));
  }

  void _mostrarDetalleCliente(BuildContext context, Cliente cliente) {
    showDialog(
      context: context,
      builder: (context) => DetalleClienteDialog(cliente: cliente),
    ).then((_) => setState(() {}));
  }

  void _confirmarEliminar(BuildContext context, Cliente cliente) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de eliminar a ${cliente.nombre}?\n\nEsto también eliminará todos sus equipos y órdenes asociadas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final database = Provider.of<AppDatabase>(context, listen: false);
              await database.eliminarCliente(cliente.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${cliente.nombre} eliminado')),
                );
                setState(() {
                  _expandidos.remove(cliente.id);
                });
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════
// CARD DEL CLIENTE CON EQUIPOS EXPANDIBLES
// ════════════════════════════════════════════
class _ClienteCard extends StatelessWidget {
  final Cliente cliente;
  final bool estaExpandido;
  final VoidCallback onToggleExpand;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;
  final VoidCallback onDetalle;
  final VoidCallback onRefresh;

  const _ClienteCard({
    required this.cliente,
    required this.estaExpandido,
    required this.onToggleExpand,
    required this.onEditar,
    required this.onEliminar,
    required this.onDetalle,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<AppDatabase>(context, listen: false);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── FILA PRINCIPAL DEL CLIENTE ────────────────────────────────────
          InkWell(
            onTap: onDetalle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Avatar con inicial
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      cliente.nombre[0].toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Datos del cliente
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cliente.nombre,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        if (cliente.telefono != null) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.phone,
                                  size: 13, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(cliente.telefono!,
                                  style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                        ],
                        if (cliente.email != null) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.email,
                                  size: 13, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(cliente.email!,
                                  style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Acciones
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    tooltip: 'Editar',
                    onPressed: onEditar,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Eliminar',
                    onPressed: onEliminar,
                  ),

                  // Botón expandir/colapsar equipos
                  _BotonEquipos(
                    clienteId: cliente.id,
                    estaExpandido: estaExpandido,
                    onTap: onToggleExpand,
                  ),
                ],
              ),
            ),
          ),

          // ── SECCIÓN EXPANDIBLE: EQUIPOS ───────────────────────────────────
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: estaExpandido
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: estaExpandido
                ? _EquiposExpandidos(
              cliente: cliente,
              onRefresh: onRefresh,
            )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ── BOTÓN QUE MUESTRA CANTIDAD DE EQUIPOS Y FLECHA ─────────────────────────
class _BotonEquipos extends StatelessWidget {
  final int clienteId;
  final bool estaExpandido;
  final VoidCallback onTap;

  const _BotonEquipos({
    required this.clienteId,
    required this.estaExpandido,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<AppDatabase>(context, listen: false);

    return FutureBuilder<List<Equipo>>(
      future: database.obtenerEquiposPorCliente(clienteId),
      builder: (context, snapshot) {
        final cantidad = snapshot.data?.length ?? 0;

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: cantidad > 0
                        ? Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.devices,
                        size: 14,
                        color: cantidad > 0
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$cantidad equipo${cantidad == 1 ? '' : 's'}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: cantidad > 0
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: estaExpandido ? 0.5 : 0,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 20,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── LISTA EXPANDIDA DE EQUIPOS ───────────────────────────────────────────────
class _EquiposExpandidos extends StatelessWidget {
  final Cliente cliente;
  final VoidCallback onRefresh;

  const _EquiposExpandidos({
    required this.cliente,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<AppDatabase>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: FutureBuilder<List<Equipo>>(
        future: database.obtenerEquiposPorCliente(cliente.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }

          final equipos = snapshot.data ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado de la sección
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 16, 6),
                child: Row(
                  children: [
                    Text(
                      'Equipos de ${cliente.nombre}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const Spacer(),
                    // Botón agregar equipo directo desde aquí
                    TextButton.icon(
                      onPressed: () =>
                          _mostrarDialogoNuevoEquipo(context, cliente, onRefresh),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Agregar equipo', style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ),

              if (equipos.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.grey[400]),
                      const SizedBox(width: 8),
                      Text(
                        'Sin equipos registrados',
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                    ],
                  ),
                )
              else
                ...equipos.map((equipo) => _FilaEquipo(
                  equipo: equipo,
                  cliente: cliente,
                  onRefresh: onRefresh,
                )),

              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }

  void _mostrarDialogoNuevoEquipo(
      BuildContext context, Cliente cliente, VoidCallback onRefresh) {
    showDialog(
      context: context,
      builder: (context) => EquipoDialog(clientePreseleccionado: cliente),
    ).then((_) => onRefresh());
  }
}

// ── FILA DE CADA EQUIPO DENTRO DEL CLIENTE ──────────────────────────────────
class _FilaEquipo extends StatelessWidget {
  final Equipo equipo;
  final Cliente cliente;
  final VoidCallback onRefresh;

  const _FilaEquipo({
    required this.equipo,
    required this.cliente,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: ListTile(
          dense: true,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          leading: CircleAvatar(
            radius: 16,
            backgroundColor: _colorParaTipo(equipo.tipo).withOpacity(0.15),
            child: Icon(
              _iconoParaTipo(equipo.tipo),
              size: 16,
              color: _colorParaTipo(equipo.tipo),
            ),
          ),
          title: Text(
            '${equipo.tipo}${equipo.marca != null ? ' · ${equipo.marca}' : ''}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          subtitle: equipo.modelo != null
              ? Text(equipo.modelo!,
              style: const TextStyle(fontSize: 12))
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ver órdenes del equipo
              IconButton(
                icon: Icon(Icons.assignment_outlined,
                    size: 18, color: Colors.grey[600]),
                tooltip: 'Ver órdenes',
                onPressed: () =>
                    _mostrarOrdenesDeEquipo(context, equipo, cliente),
                visualDensity: VisualDensity.compact,
              ),
              // Editar equipo
              IconButton(
                icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                tooltip: 'Editar',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => EquipoDialog(
                      equipo: equipo,
                      clientePreseleccionado: cliente,
                    ),
                  ).then((_) => onRefresh());
                },
                visualDensity: VisualDensity.compact,
              ),
              // Eliminar equipo
              IconButton(
                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                tooltip: 'Eliminar',
                onPressed: () =>
                    _confirmarEliminarEquipo(context, equipo),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarOrdenesDeEquipo(
      BuildContext context, Equipo equipo, Cliente cliente) {
    showDialog(
      context: context,
      builder: (context) => DetalleEquipoDialog(equipo: equipo, cliente: cliente),
    );
  }

  void _confirmarEliminarEquipo(BuildContext context, Equipo equipo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Eliminar este equipo?\n\n${equipo.tipo} ${equipo.marca ?? ""}\n\nSe eliminarán también sus órdenes asociadas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final database = Provider.of<AppDatabase>(context, listen: false);
              await database.eliminarEquipo(equipo.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Equipo eliminado')),
                );
                onRefresh();
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Color _colorParaTipo(String tipo) {
    switch (tipo) {
      case 'Impresora': return Colors.blue;
      case 'PC':        return Colors.green;
      case 'Laptop':    return Colors.orange;
      case 'Monitor':   return Colors.purple;
      default:          return Colors.grey;
    }
  }

  IconData _iconoParaTipo(String tipo) {
    switch (tipo) {
      case 'Impresora': return Icons.print;
      case 'PC':        return Icons.computer;
      case 'Laptop':    return Icons.laptop;
      case 'Monitor':   return Icons.monitor;
      default:          return Icons.devices;
    }
  }
}

// ════════════════════════════════════════════
// DIÁLOGO PARA AGREGAR/EDITAR CLIENTE
// ════════════════════════════════════════════
class ClienteDialog extends StatefulWidget {
  final Cliente? cliente;

  const ClienteDialog({super.key, this.cliente});

  @override
  State<ClienteDialog> createState() => _ClienteDialogState();
}

class _ClienteDialogState extends State<ClienteDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _telefonoController;
  late TextEditingController _emailController;
  late TextEditingController _direccionController;

  @override
  void initState() {
    super.initState();
    _nombreController =
        TextEditingController(text: widget.cliente?.nombre ?? '');
    _telefonoController =
        TextEditingController(text: widget.cliente?.telefono ?? '');
    _emailController =
        TextEditingController(text: widget.cliente?.email ?? '');
    _direccionController =
        TextEditingController(text: widget.cliente?.direccion ?? '');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.cliente != null;

    return AlertDialog(
      title: Text(isEditing ? 'Editar Cliente' : 'Nuevo Cliente'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre *',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _telefonoController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _direccionController,
                  decoration: const InputDecoration(
                    labelText: 'Dirección',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _guardar,
          child: Text(isEditing ? 'Actualizar' : 'Guardar'),
        ),
      ],
    );
  }

  void _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final database = Provider.of<AppDatabase>(context, listen: false);

    if (widget.cliente == null) {
      await database.insertarCliente(
        ClientesCompanion(
          nombre: drift.Value(_nombreController.text),
          telefono: drift.Value(
              _telefonoController.text.isEmpty ? null : _telefonoController.text),
          email: drift.Value(
              _emailController.text.isEmpty ? null : _emailController.text),
          direccion: drift.Value(
              _direccionController.text.isEmpty ? null : _direccionController.text),
        ),
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente creado exitosamente')),
        );
      }
    } else {
      await database.actualizarCliente(
        widget.cliente!.copyWith(
          nombre: _nombreController.text,
          telefono:
          drift.Value(_telefonoController.text.isEmpty ? null : _telefonoController.text),
          email: drift.Value(
              _emailController.text.isEmpty ? null : _emailController.text),
          direccion: drift.Value(
              _direccionController.text.isEmpty ? null : _direccionController.text),
        ),
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente actualizado exitosamente')),
        );
      }
    }
  }
}

// ════════════════════════════════════════════
// DIÁLOGO DE DETALLE DEL CLIENTE
// ════════════════════════════════════════════
class DetalleClienteDialog extends StatelessWidget {
  final Cliente cliente;

  const DetalleClienteDialog({super.key, required this.cliente});

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<AppDatabase>(context);

    return Dialog(
      child: SizedBox(
        width: 600,
        height: 500,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      cliente.nombre[0].toUpperCase(),
                      style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cliente.nombre,
                          style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Cliente',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información de Contacto',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (cliente.telefono != null)
                    _InfoRow(
                        icon: Icons.phone,
                        label: 'Teléfono',
                        value: cliente.telefono!),
                  if (cliente.email != null)
                    _InfoRow(
                        icon: Icons.email,
                        label: 'Email',
                        value: cliente.email!),
                  if (cliente.direccion != null)
                    _InfoRow(
                        icon: Icons.location_on,
                        label: 'Dirección',
                        value: cliente.direccion!),
                  const SizedBox(height: 24),
                  Text(
                    'Equipos Registrados',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Equipo>>(
                future: database.obtenerEquiposPorCliente(cliente.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No hay equipos registrados',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    );
                  }

                  final equipos = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: equipos.length,
                    itemBuilder: (context, index) {
                      final equipo = equipos[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.devices),
                          title: Text(
                              '${equipo.tipo} ${equipo.marca ?? ""}'),
                          subtitle: Text(equipo.modelo ?? 'Sin modelo'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════
// DIÁLOGO PARA AGREGAR/EDITAR EQUIPO
// (con clientePreseleccionado opcional)
// ════════════════════════════════════════════
class EquipoDialog extends StatefulWidget {
  final Equipo? equipo;
  final Cliente? clientePreseleccionado;

  const EquipoDialog({
    super.key,
    this.equipo,
    this.clientePreseleccionado,
  });

  @override
  State<EquipoDialog> createState() => _EquipoDialogState();
}

class _EquipoDialogState extends State<EquipoDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _marcaController;
  late TextEditingController _modeloController;
  late TextEditingController _numeroSerieController;
  late TextEditingController _observacionesController;

  String _tipoSeleccionado = 'Impresora';
  int? _clienteSeleccionado;
  List<Cliente> _clientes = [];

  @override
  void initState() {
    super.initState();
    _marcaController =
        TextEditingController(text: widget.equipo?.marca ?? '');
    _modeloController =
        TextEditingController(text: widget.equipo?.modelo ?? '');
    _numeroSerieController =
        TextEditingController(text: widget.equipo?.numeroSerie ?? '');
    _observacionesController =
        TextEditingController(text: widget.equipo?.observaciones ?? '');

    if (widget.equipo != null) {
      _tipoSeleccionado = widget.equipo!.tipo;
      _clienteSeleccionado = widget.equipo!.clienteId;
    } else if (widget.clientePreseleccionado != null) {
      _clienteSeleccionado = widget.clientePreseleccionado!.id;
    }

    _cargarClientes();
  }

  Future<void> _cargarClientes() async {
    final database = Provider.of<AppDatabase>(context, listen: false);
    final clientes = await database.obtenerTodosLosClientes();
    setState(() {
      _clientes = clientes;
      if (_clienteSeleccionado == null && clientes.isNotEmpty) {
        _clienteSeleccionado = clientes.first.id;
      }
    });
  }

  @override
  void dispose() {
    _marcaController.dispose();
    _modeloController.dispose();
    _numeroSerieController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.equipo != null;

    return AlertDialog(
      title: Text(isEditing ? 'Editar Equipo' : 'Nuevo Equipo'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_clientes.isEmpty)
                  Card(
                    color: Colors.orange[50],
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Necesitás crear un cliente primero',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  DropdownButtonFormField<int>(
                    value: _clienteSeleccionado,
                    decoration: const InputDecoration(
                      labelText: 'Cliente *',
                      prefixIcon: Icon(Icons.person),
                    ),
                    items: _clientes.map((cliente) {
                      return DropdownMenuItem(
                        value: cliente.id,
                        child: Text(cliente.nombre),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _clienteSeleccionado = value),
                    validator: (value) {
                      if (value == null) return 'Selecciona un cliente';
                      return null;
                    },
                  ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _tipoSeleccionado,
                  decoration: const InputDecoration(
                    labelText: 'Tipo *',
                    prefixIcon: Icon(Icons.devices),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Impresora', child: Text('Impresora')),
                    DropdownMenuItem(value: 'PC', child: Text('PC')),
                    DropdownMenuItem(value: 'Laptop', child: Text('Laptop')),
                    DropdownMenuItem(value: 'Monitor', child: Text('Monitor')),
                    DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                  ],
                  onChanged: (value) =>
                      setState(() => _tipoSeleccionado = value!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _marcaController,
                  decoration: const InputDecoration(
                    labelText: 'Marca',
                    prefixIcon: Icon(Icons.branding_watermark),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _modeloController,
                  decoration: const InputDecoration(
                    labelText: 'Modelo',
                    prefixIcon: Icon(Icons.model_training),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _numeroSerieController,
                  decoration: const InputDecoration(
                    labelText: 'Número de Serie',
                    prefixIcon: Icon(Icons.numbers),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _observacionesController,
                  decoration: const InputDecoration(
                    labelText: 'Observaciones',
                    prefixIcon: Icon(Icons.notes),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _clientes.isEmpty ? null : _guardar,
          child: Text(isEditing ? 'Actualizar' : 'Guardar'),
        ),
      ],
    );
  }

  void _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final database = Provider.of<AppDatabase>(context, listen: false);

    if (widget.equipo == null) {
      await database.insertarEquipo(
        EquiposCompanion(
          clienteId: drift.Value(_clienteSeleccionado!),
          tipo: drift.Value(_tipoSeleccionado),
          marca: drift.Value(
              _marcaController.text.isEmpty ? null : _marcaController.text),
          modelo: drift.Value(
              _modeloController.text.isEmpty ? null : _modeloController.text),
          numeroSerie: drift.Value(_numeroSerieController.text.isEmpty
              ? null
              : _numeroSerieController.text),
          observaciones: drift.Value(_observacionesController.text.isEmpty
              ? null
              : _observacionesController.text),
        ),
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Equipo creado exitosamente')),
        );
      }
    } else {
      await database.actualizarEquipo(
        widget.equipo!.copyWith(
          clienteId: _clienteSeleccionado!,
          tipo: _tipoSeleccionado,
          marca: drift.Value(
              _marcaController.text.isEmpty ? null : _marcaController.text),
          modelo: drift.Value(
              _modeloController.text.isEmpty ? null : _modeloController.text),
          numeroSerie: drift.Value(_numeroSerieController.text.isEmpty
              ? null
              : _numeroSerieController.text),
          observaciones: drift.Value(_observacionesController.text.isEmpty
              ? null
              : _observacionesController.text),
        ),
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Equipo actualizado exitosamente')),
        );
      }
    }
  }
}

// ════════════════════════════════════════════
// DIÁLOGO DE DETALLE DEL EQUIPO
// ════════════════════════════════════════════
class DetalleEquipoDialog extends StatelessWidget {
  final Equipo equipo;
  final Cliente? cliente;

  const DetalleEquipoDialog({
    super.key,
    required this.equipo,
    this.cliente,
  });

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<AppDatabase>(context);

    return Dialog(
      child: SizedBox(
        width: 600,
        height: 500,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: const Icon(Icons.devices, size: 30, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${equipo.tipo} ${equipo.marca ?? ""}',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (cliente != null)
                          Text(
                            cliente!.nombre,
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información del Equipo',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(icon: Icons.devices, label: 'Tipo', value: equipo.tipo),
                  if (equipo.marca != null)
                    _InfoRow(
                        icon: Icons.branding_watermark,
                        label: 'Marca',
                        value: equipo.marca!),
                  if (equipo.modelo != null)
                    _InfoRow(
                        icon: Icons.model_training,
                        label: 'Modelo',
                        value: equipo.modelo!),
                  if (equipo.numeroSerie != null)
                    _InfoRow(
                        icon: Icons.numbers,
                        label: 'Número de Serie',
                        value: equipo.numeroSerie!),
                  if (equipo.observaciones != null)
                    _InfoRow(
                        icon: Icons.notes,
                        label: 'Observaciones',
                        value: equipo.observaciones!),
                  const SizedBox(height: 24),
                  Text(
                    'Órdenes de Servicio',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Ordene>>(
                future: database.obtenerOrdenesPorEquipo(equipo.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No hay órdenes registradas',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    );
                  }

                  final ordenes = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: ordenes.length,
                    itemBuilder: (context, index) {
                      final orden = ordenes[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.assignment),
                          title: Text('Orden #${orden.id}'),
                          subtitle: Text(orden.estado.toUpperCase()),
                          trailing: Text('\$${orden.costo.toStringAsFixed(2)}'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════
// WIDGET AUXILIAR: FILA DE INFO
// ════════════════════════════════════════════
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(color: Colors.grey[600]),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}