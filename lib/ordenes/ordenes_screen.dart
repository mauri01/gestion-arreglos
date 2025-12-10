import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;
import 'package:intl/intl.dart';
import '../../database/database.dart';

class OrdenesScreen extends StatefulWidget {
  const OrdenesScreen({super.key});

  @override
  State<OrdenesScreen> createState() => _OrdenesScreenState();
}

class _OrdenesScreenState extends State<OrdenesScreen> {
  String _filtroEstado = 'Todas';

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<AppDatabase>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Órdenes de Servicio'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButton<String>(
              value: _filtroEstado,
              underline: Container(),
              items: const [
                DropdownMenuItem(value: 'Todas', child: Text('Todas')),
                DropdownMenuItem(value: 'pendiente', child: Text('Pendientes')),
                DropdownMenuItem(value: 'en_proceso', child: Text('En Proceso')),
                DropdownMenuItem(value: 'finalizada', child: Text('Finalizadas')),
                DropdownMenuItem(value: 'entregada', child: Text('Entregadas')),
              ],
              onChanged: (value) {
                setState(() {
                  _filtroEstado = value!;
                });
              },
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<OrdenCompleta>>(
        future: database.obtenerOrdenesCompletas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No hay órdenes registradas',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Presioná el botón + para crear una',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          var ordenes = snapshot.data!;

          if (_filtroEstado != 'Todas') {
            ordenes = ordenes.where((o) => o.orden.estado == _filtroEstado).toList();
          }

          ordenes.sort((a, b) => b.orden.fechaIngreso.compareTo(a.orden.fechaIngreso));

          if (ordenes.isEmpty) {
            return Center(
              child: Text(
                'No hay órdenes con este estado',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ordenes.length,
            itemBuilder: (context, index) {
              final ordenCompleta = ordenes[index];
              final orden = ordenCompleta.orden;
              final equipo = ordenCompleta.equipo;
              final cliente = ordenCompleta.cliente;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    _mostrarDetalleOrden(context, ordenCompleta);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getColorForEstado(orden.estado).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _getColorForEstado(orden.estado),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _getEstadoLabel(orden.estado),
                                style: TextStyle(
                                  color: _getColorForEstado(orden.estado),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Orden #${orden.id}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const Spacer(),
                            Text(
                              '\$${orden.costo.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            const Icon(Icons.person, size: 18, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                cliente.nombre,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.devices, size: 18, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text('${equipo.tipo} ${equipo.marca ?? ""} ${equipo.modelo ?? ""}'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(DateFormat('dd/MM/yyyy HH:mm').format(orden.fechaIngreso)),
                          ],
                        ),
                        if (orden.diagnostico != null && orden.diagnostico!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            orden.diagnostico!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                _mostrarDialogoCambiarEstado(context, orden);
                              },
                              icon: const Icon(Icons.flag, size: 18),
                              label: const Text('Cambiar Estado'),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () {
                                _mostrarDialogoOrden(context, ordenCompleta: ordenCompleta);
                              },
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Editar'),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () {
                                _confirmarEliminar(context, orden, cliente.nombre);
                              },
                              icon: const Icon(Icons.delete, size: 18),
                              label: const Text('Eliminar'),
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _mostrarDialogoOrden(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva Orden'),
      ),
    );
  }

  Color _getColorForEstado(String estado) {
    switch (estado) {
      case 'pendiente':
        return Colors.orange;
      case 'en_proceso':
        return Colors.blue;
      case 'finalizada':
        return Colors.green;
      case 'entregada':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getEstadoLabel(String estado) {
    switch (estado) {
      case 'pendiente':
        return 'PENDIENTE';
      case 'en_proceso':
        return 'EN PROCESO';
      case 'finalizada':
        return 'FINALIZADA';
      case 'entregada':
        return 'ENTREGADA';
      default:
        return estado.toUpperCase();
    }
  }

  void _mostrarDialogoOrden(BuildContext context, {OrdenCompleta? ordenCompleta}) {
    showDialog(
      context: context,
      builder: (context) => OrdenDialog(ordenCompleta: ordenCompleta),
    ).then((_) {
      setState(() {});
    });
  }

  void _mostrarDetalleOrden(BuildContext context, OrdenCompleta ordenCompleta) {
    showDialog(
      context: context,
      builder: (context) => DetalleOrdenDialog(ordenCompleta: ordenCompleta),
    ).then((_) {
      setState(() {});
    });
  }

  void _mostrarDialogoCambiarEstado(BuildContext context, Ordene orden) {
    showDialog(
      context: context,
      builder: (context) => CambiarEstadoDialog(orden: orden),
    ).then((_) {
      setState(() {});
    });
  }

  void _confirmarEliminar(BuildContext context, Ordene orden, String nombreCliente) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de eliminar la Orden #${orden.id}?\nCliente: $nombreCliente'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final database = Provider.of<AppDatabase>(context, listen: false);
              await database.eliminarOrden(orden.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Orden eliminada')),
                );
                setState(() {});
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

// DIÁLOGO PARA AGREGAR/EDITAR ORDEN
class OrdenDialog extends StatefulWidget {
  final OrdenCompleta? ordenCompleta;

  const OrdenDialog({super.key, this.ordenCompleta});

  @override
  State<OrdenDialog> createState() => _OrdenDialogState();
}

class _OrdenDialogState extends State<OrdenDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _diagnosticoController;
  late TextEditingController _solucionController;
  late TextEditingController _costoController;
  late TextEditingController _observacionesController;

  String _estadoSeleccionado = 'pendiente';
  int? _equipoSeleccionado;
  List<Equipo> _equipos = [];
  Map<int, Cliente> _clientesMap = {};

  @override
  void initState() {
    super.initState();
    _diagnosticoController = TextEditingController(text: widget.ordenCompleta?.orden.diagnostico ?? '');
    _solucionController = TextEditingController(text: widget.ordenCompleta?.orden.solucion ?? '');
    _costoController = TextEditingController(text: widget.ordenCompleta?.orden.costo.toString() ?? '0');
    _observacionesController = TextEditingController(text: widget.ordenCompleta?.orden.observaciones ?? '');

    if (widget.ordenCompleta != null) {
      _estadoSeleccionado = widget.ordenCompleta!.orden.estado;
      _equipoSeleccionado = widget.ordenCompleta!.orden.equipoId;
    }

    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final database = Provider.of<AppDatabase>(context, listen: false);
    final equipos = await database.obtenerTodosLosEquipos();
    final clientes = await database.obtenerTodosLosClientes();

    setState(() {
      _equipos = equipos;
      _clientesMap = {for (var c in clientes) c.id: c};
      if (_equipoSeleccionado == null && equipos.isNotEmpty) {
        _equipoSeleccionado = equipos.first.id;
      }
    });
  }

  @override
  void dispose() {
    _diagnosticoController.dispose();
    _solucionController.dispose();
    _costoController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.ordenCompleta != null;

    return AlertDialog(
      title: Text(isEditing ? 'Editar Orden' : 'Nueva Orden'),
      content: SizedBox(
        width: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_equipos.isEmpty)
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
                              'Necesitás crear equipos primero',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  DropdownButtonFormField<int>(
                    value: _equipoSeleccionado,
                    decoration: const InputDecoration(
                      labelText: 'Equipo *',
                      prefixIcon: Icon(Icons.devices),
                    ),
                    items: _equipos.map((equipo) {
                      final cliente = _clientesMap[equipo.clienteId];
                      return DropdownMenuItem(
                        value: equipo.id,
                        child: Text('${equipo.tipo} ${equipo.marca ?? ""} - ${cliente?.nombre ?? ""}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _equipoSeleccionado = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) return 'Selecciona un equipo';
                      return null;
                    },
                  ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _estadoSeleccionado,
                  decoration: const InputDecoration(
                    labelText: 'Estado *',
                    prefixIcon: Icon(Icons.flag),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'pendiente', child: Text('Pendiente')),
                    DropdownMenuItem(value: 'en_proceso', child: Text('En Proceso')),
                    DropdownMenuItem(value: 'finalizada', child: Text('Finalizada')),
                    DropdownMenuItem(value: 'entregada', child: Text('Entregada')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _estadoSeleccionado = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _diagnosticoController,
                  decoration: const InputDecoration(
                    labelText: 'Diagnóstico',
                    prefixIcon: Icon(Icons.search),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _solucionController,
                  decoration: const InputDecoration(
                    labelText: 'Solución',
                    prefixIcon: Icon(Icons.build),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _costoController,
                  decoration: const InputDecoration(
                    labelText: 'Costo',
                    prefixIcon: Icon(Icons.attach_money),
                    prefixText: '\$ ',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Ingresa el costo';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _observacionesController,
                  decoration: const InputDecoration(
                    labelText: 'Observaciones',
                    prefixIcon: Icon(Icons.notes),
                    alignLabelWithHint: true,
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
          onPressed: _equipos.isEmpty ? null : _guardar,
          child: Text(isEditing ? 'Actualizar' : 'Guardar'),
        ),
      ],
    );
  }

  void _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final database = Provider.of<AppDatabase>(context, listen: false);
    final costo = double.tryParse(_costoController.text) ?? 0.0;

    if (widget.ordenCompleta == null) {
      final ordenId = await database.insertarOrden(
        OrdenesCompanion(
          equipoId: drift.Value(_equipoSeleccionado!),
          estado: drift.Value(_estadoSeleccionado),
          diagnostico: drift.Value(_diagnosticoController.text.isEmpty ? null : _diagnosticoController.text),
          solucion: drift.Value(_solucionController.text.isEmpty ? null : _solucionController.text),
          costo: drift.Value(costo),
          observaciones: drift.Value(_observacionesController.text.isEmpty ? null : _observacionesController.text),
          // Si se crea con estado "entregada", registrar fecha de entrega
          fechaEntrega: drift.Value(_estadoSeleccionado == 'entregada' ? DateTime.now() : null),
        ),
      );

      await database.insertarHistorial(
        HistorialCompanion(
          ordenId: drift.Value(ordenId),
          accion: const drift.Value('Orden creada'),
          detalles: drift.Value('Estado inicial: $_estadoSeleccionado'),
        ),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Orden creada exitosamente')),
        );
      }
    } else {
      final ordenAnterior = widget.ordenCompleta!.orden;

      // Si cambia a "entregada" y no tenía fecha, registrarla
      DateTime? fechaEntrega = ordenAnterior.fechaEntrega;
      if (_estadoSeleccionado == 'entregada' && fechaEntrega == null) {
        fechaEntrega = DateTime.now();
      }
      // Si cambia de "entregada" a otro estado, limpiar la fecha
      if (_estadoSeleccionado != 'entregada') {
        fechaEntrega = null;
      }

      await database.actualizarOrden(
        ordenAnterior.copyWith(
          equipoId: _equipoSeleccionado!,
          estado: _estadoSeleccionado,
          diagnostico: drift.Value(_diagnosticoController.text.isEmpty ? null : _diagnosticoController.text),
          solucion: drift.Value(_solucionController.text.isEmpty ? null : _solucionController.text),
          costo: costo,
          observaciones: drift.Value(_observacionesController.text.isEmpty ? null : _observacionesController.text),
          fechaEntrega: drift.Value(fechaEntrega),
        ),
      );

      if (ordenAnterior.estado != _estadoSeleccionado) {
        await database.insertarHistorial(
          HistorialCompanion(
            ordenId: drift.Value(ordenAnterior.id),
            accion: const drift.Value('Cambio de estado'),
            detalles: drift.Value('De ${ordenAnterior.estado} a $_estadoSeleccionado'),
          ),
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Orden actualizada exitosamente')),
        );
      }
    }
  }
}

// DIÁLOGO PARA CAMBIAR ESTADO RÁPIDO
class CambiarEstadoDialog extends StatefulWidget {
  final Ordene orden;

  const CambiarEstadoDialog({super.key, required this.orden});

  @override
  State<CambiarEstadoDialog> createState() => _CambiarEstadoDialogState();
}

class _CambiarEstadoDialogState extends State<CambiarEstadoDialog> {
  late String _estadoSeleccionado;

  @override
  void initState() {
    super.initState();
    _estadoSeleccionado = widget.orden.estado;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Cambiar Estado - Orden #${widget.orden.id}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildEstadoOption('pendiente', 'Pendiente', Icons.pending_actions, Colors.orange),
          const SizedBox(height: 8),
          _buildEstadoOption('en_proceso', 'En Proceso', Icons.build, Colors.blue),
          const SizedBox(height: 8),
          _buildEstadoOption('finalizada', 'Finalizada', Icons.check_circle, Colors.green),
          const SizedBox(height: 8),
          _buildEstadoOption('entregada', 'Entregada', Icons.done_all, Colors.grey),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _guardar,
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  Widget _buildEstadoOption(String estado, String label, IconData icon, Color color) {
    final isSelected = _estadoSeleccionado == estado;
    return InkWell(
      onTap: () {
        setState(() {
          _estadoSeleccionado = estado;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? color.withOpacity(0.1) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            const Spacer(),
            if (isSelected) Icon(Icons.check_circle, color: color),
          ],
        ),
      ),
    );
  }

  void _guardar() async {
    if (_estadoSeleccionado == widget.orden.estado) {
      Navigator.pop(context);
      return;
    }

    final database = Provider.of<AppDatabase>(context, listen: false);
    await database.actualizarOrden(widget.orden.copyWith(estado: _estadoSeleccionado));
    await database.insertarHistorial(
      HistorialCompanion(
        ordenId: drift.Value(widget.orden.id),
        accion: const drift.Value('Cambio de estado'),
        detalles: drift.Value('De ${widget.orden.estado} a $_estadoSeleccionado'),
      ),
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Estado actualizado')));
    }
  }
}

// DIÁLOGO DE DETALLE DE LA ORDEN
class DetalleOrdenDialog extends StatelessWidget {
  final OrdenCompleta ordenCompleta;

  const DetalleOrdenDialog({super.key, required this.ordenCompleta});

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<AppDatabase>(context);
    final orden = ordenCompleta.orden;
    final equipo = ordenCompleta.equipo;
    final cliente = ordenCompleta.cliente;

    return Dialog(
      child: SizedBox(
        width: 700,
        height: 600,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _getColorForEstado(orden.estado).withOpacity(0.1),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: _getColorForEstado(orden.estado),
                    child: const Icon(Icons.assignment, size: 30, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Orden #${orden.id}',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getColorForEstado(orden.estado),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            orden.estado.toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${orden.costo.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Información General', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildInfoCard(Icons.person, 'Cliente', cliente.nombre),
                    _buildInfoCard(Icons.devices, 'Equipo', '${equipo.tipo} ${equipo.marca ?? ""} ${equipo.modelo ?? ""}'),
                    _buildInfoCard(Icons.calendar_today, 'Fecha de Ingreso', DateFormat('dd/MM/yyyy HH:mm').format(orden.fechaIngreso)),
                    if (orden.fechaEntrega != null)
                      _buildInfoCard(Icons.event_available, 'Fecha de Entrega', DateFormat('dd/MM/yyyy HH:mm').format(orden.fechaEntrega!)),
                    const SizedBox(height: 24),
                    Text('Detalles del Servicio', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    if (orden.diagnostico != null && orden.diagnostico!.isNotEmpty)
                      _buildDetailCard('Diagnóstico', Icons.search, orden.diagnostico!),
                    if (orden.solucion != null && orden.solucion!.isNotEmpty)
                      _buildDetailCard('Solución', Icons.build, orden.solucion!),
                    if (orden.observaciones != null && orden.observaciones!.isNotEmpty)
                      _buildDetailCard('Observaciones', Icons.notes, orden.observaciones!),
                    const SizedBox(height: 24),
                    Text('Historial', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    FutureBuilder<List<HistorialData>>(
                      future: database.obtenerHistorialPorOrden(orden.id),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text('No hay historial');
                        }
                        return Column(
                          children: snapshot.data!.map((h) {
                            return Card(
                              child: ListTile(
                                leading: const Icon(Icons.history),
                                title: Text(h.accion),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (h.detalles != null) Text(h.detalles!),
                                    Text(DateFormat('dd/MM/yyyy HH:mm').format(h.fecha), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForEstado(String estado) {
    switch (estado) {
      case 'pendiente': return Colors.orange;
      case 'en_proceso': return Colors.blue;
      case 'finalizada': return Colors.green;
      case 'entregada': return Colors.grey;
      default: return Colors.grey;
    }
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Text('$label: ', style: TextStyle(color: Colors.grey[600])),
            Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, IconData icon, String content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text(content),
          ],
        ),
      ),
    );
  }
}