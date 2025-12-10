import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;
import '../../database/database.dart';

class EquiposScreen extends StatefulWidget {
  const EquiposScreen({super.key});

  @override
  State<EquiposScreen> createState() => _EquiposScreenState();
}

class _EquiposScreenState extends State<EquiposScreen> {
  String _searchQuery = '';
  String _filtroTipo = 'Todos';

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<AppDatabase>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipos'),
        actions: [
          // Filtro por tipo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<String>(
              value: _filtroTipo,
              underline: Container(),
              items: const [
                DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                DropdownMenuItem(value: 'Impresora', child: Text('Impresoras')),
                DropdownMenuItem(value: 'PC', child: Text('PCs')),
                DropdownMenuItem(value: 'Laptop', child: Text('Laptops')),
                DropdownMenuItem(value: 'Monitor', child: Text('Monitores')),
                DropdownMenuItem(value: 'Otro', child: Text('Otros')),
              ],
              onChanged: (value) {
                setState(() {
                  _filtroTipo = value!;
                });
              },
            ),
          ),
          // Barra de búsqueda
          SizedBox(
            width: 300,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar equipo...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Equipo>>(
        future: database.obtenerTodosLosEquipos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.devices_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No hay equipos registrados',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Presioná el botón + para agregar uno',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          var equipos = snapshot.data!;

          // Aplicar filtros
          if (_filtroTipo != 'Todos') {
            equipos = equipos.where((e) => e.tipo == _filtroTipo).toList();
          }

          if (_searchQuery.isNotEmpty) {
            equipos = equipos.where((e) {
              final marca = e.marca?.toLowerCase() ?? '';
              final modelo = e.modelo?.toLowerCase() ?? '';
              final tipo = e.tipo.toLowerCase();
              final query = _searchQuery.toLowerCase();
              return marca.contains(query) || modelo.contains(query) || tipo.contains(query);
            }).toList();
          }

          if (equipos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No se encontraron equipos',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return FutureBuilder<List<Cliente>>(
            future: database.obtenerTodosLosClientes(),
            builder: (context, clientesSnapshot) {
              if (!clientesSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final clientesMap = {
                for (var c in clientesSnapshot.data!) c.id: c
              };

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: equipos.length,
                itemBuilder: (context, index) {
                  final equipo = equipos[index];
                  final cliente = clientesMap[equipo.clienteId];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getColorForTipo(equipo.tipo),
                        child: Icon(
                          _getIconForTipo(equipo.tipo),
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        '${equipo.tipo} ${equipo.marca ?? ""}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (equipo.modelo != null)
                            Text('Modelo: ${equipo.modelo}'),
                          if (cliente != null)
                            Row(
                              children: [
                                const Icon(Icons.person, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(cliente.nombre),
                              ],
                            ),
                          if (equipo.numeroSerie != null)
                            Text(
                              'S/N: ${equipo.numeroSerie}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _mostrarDialogoEquipo(context, equipo: equipo);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _confirmarEliminar(context, equipo, cliente?.nombre);
                            },
                          ),
                        ],
                      ),
                      isThreeLine: true,
                      onTap: () {
                        _mostrarDetalleEquipo(context, equipo, cliente);
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _mostrarDialogoEquipo(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Equipo'),
      ),
    );
  }

  Color _getColorForTipo(String tipo) {
    switch (tipo) {
      case 'Impresora':
        return Colors.blue;
      case 'PC':
        return Colors.green;
      case 'Laptop':
        return Colors.orange;
      case 'Monitor':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconForTipo(String tipo) {
    switch (tipo) {
      case 'Impresora':
        return Icons.print;
      case 'PC':
        return Icons.computer;
      case 'Laptop':
        return Icons.laptop;
      case 'Monitor':
        return Icons.monitor;
      default:
        return Icons.devices;
    }
  }

  void _mostrarDialogoEquipo(BuildContext context, {Equipo? equipo}) {
    showDialog(
      context: context,
      builder: (context) => EquipoDialog(equipo: equipo),
    ).then((_) {
      setState(() {});
    });
  }

  void _mostrarDetalleEquipo(BuildContext context, Equipo equipo, Cliente? cliente) {
    showDialog(
      context: context,
      builder: (context) => DetalleEquipoDialog(equipo: equipo, cliente: cliente),
    ).then((_) {
      setState(() {});
    });
  }

  void _confirmarEliminar(BuildContext context, Equipo equipo, String? nombreCliente) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de eliminar este equipo?\n\n${equipo.tipo} ${equipo.marca ?? ""}\nCliente: ${nombreCliente ?? "Desconocido"}\n\nEsto también eliminará todas las órdenes asociadas.',
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

// ==========================================
// DIÁLOGO PARA AGREGAR/EDITAR EQUIPO
// ==========================================
class EquipoDialog extends StatefulWidget {
  final Equipo? equipo;

  const EquipoDialog({super.key, this.equipo});

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
    _marcaController = TextEditingController(text: widget.equipo?.marca ?? '');
    _modeloController = TextEditingController(text: widget.equipo?.modelo ?? '');
    _numeroSerieController = TextEditingController(text: widget.equipo?.numeroSerie ?? '');
    _observacionesController = TextEditingController(text: widget.equipo?.observaciones ?? '');

    if (widget.equipo != null) {
      _tipoSeleccionado = widget.equipo!.tipo;
      _clienteSeleccionado = widget.equipo!.clienteId;
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
                // Seleccionar Cliente
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
                    onChanged: (value) {
                      setState(() {
                        _clienteSeleccionado = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Selecciona un cliente';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 16),

                // Tipo de equipo
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
                  onChanged: (value) {
                    setState(() {
                      _tipoSeleccionado = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Marca
                TextFormField(
                  controller: _marcaController,
                  decoration: const InputDecoration(
                    labelText: 'Marca',
                    prefixIcon: Icon(Icons.branding_watermark),
                  ),
                ),
                const SizedBox(height: 16),

                // Modelo
                TextFormField(
                  controller: _modeloController,
                  decoration: const InputDecoration(
                    labelText: 'Modelo',
                    prefixIcon: Icon(Icons.model_training),
                  ),
                ),
                const SizedBox(height: 16),

                // Número de serie
                TextFormField(
                  controller: _numeroSerieController,
                  decoration: const InputDecoration(
                    labelText: 'Número de Serie',
                    prefixIcon: Icon(Icons.numbers),
                  ),
                ),
                const SizedBox(height: 16),

                // Observaciones
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
      // Crear nuevo equipo
      await database.insertarEquipo(
        EquiposCompanion(
          clienteId: drift.Value(_clienteSeleccionado!),
          tipo: drift.Value(_tipoSeleccionado),
          marca: drift.Value(_marcaController.text.isEmpty ? null : _marcaController.text),
          modelo: drift.Value(_modeloController.text.isEmpty ? null : _modeloController.text),
          numeroSerie: drift.Value(_numeroSerieController.text.isEmpty ? null : _numeroSerieController.text),
          observaciones: drift.Value(_observacionesController.text.isEmpty ? null : _observacionesController.text),
        ),
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Equipo creado exitosamente')),
        );
      }
    } else {
      // Actualizar equipo existente
      await database.actualizarEquipo(
        widget.equipo!.copyWith(
          clienteId: _clienteSeleccionado!,
          tipo: _tipoSeleccionado,
          marca: drift.Value(_marcaController.text.isEmpty ? null : _marcaController.text),
          modelo: drift.Value(_modeloController.text.isEmpty ? null : _modeloController.text),
          numeroSerie: drift.Value(_numeroSerieController.text.isEmpty ? null : _numeroSerieController.text),
          observaciones: drift.Value(_observacionesController.text.isEmpty ? null : _observacionesController.text),
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

// ==========================================
// DIÁLOGO DE DETALLE DEL EQUIPO
// ==========================================
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
            // Header
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
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
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

            // Información del equipo
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
                    _InfoRow(icon: Icons.branding_watermark, label: 'Marca', value: equipo.marca!),
                  if (equipo.modelo != null)
                    _InfoRow(icon: Icons.model_training, label: 'Modelo', value: equipo.modelo!),
                  if (equipo.numeroSerie != null)
                    _InfoRow(icon: Icons.numbers, label: 'Número de Serie', value: equipo.numeroSerie!),
                  if (equipo.observaciones != null)
                    _InfoRow(icon: Icons.notes, label: 'Observaciones', value: equipo.observaciones!),
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

            // Lista de órdenes
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