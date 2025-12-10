import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../database/database.dart';
import '../clientes/clientes_screen.dart';
import '../equipos/equipos_screen.dart';
import '../ordenes/ordenes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardTab(),
    const OrdenesScreen(),
    const ClientesScreen(),
    const EquiposScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Barra lateral de navegación
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.assignment_outlined),
                selectedIcon: Icon(Icons.assignment),
                label: Text('Órdenes'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('Clientes'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.devices_outlined),
                selectedIcon: Icon(Icons.devices),
                label: Text('Equipos'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Contenido principal
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// TAB DEL DASHBOARD
// ==========================================
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<AppDatabase>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              'Resumen General',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Tarjetas de estadísticas
            GridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.5,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Órdenes Pendientes
                FutureBuilder<List<Ordene>>(
                  future: database.obtenerOrdenesPorEstado('pendiente'),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.length ?? 0;
                    return _StatCard(
                      title: 'Órdenes Pendientes',
                      value: count.toString(),
                      icon: Icons.pending_actions,
                      color: Colors.orange,
                    );
                  },
                ),

                // Órdenes En Proceso
                FutureBuilder<List<Ordene>>(
                  future: database.obtenerOrdenesPorEstado('en_proceso'),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.length ?? 0;
                    return _StatCard(
                      title: 'En Proceso',
                      value: count.toString(),
                      icon: Icons.build,
                      color: Colors.blue,
                    );
                  },
                ),

                // Total Clientes
                FutureBuilder<List<Cliente>>(
                  future: database.obtenerTodosLosClientes(),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.length ?? 0;
                    return _StatCard(
                      title: 'Total Clientes',
                      value: count.toString(),
                      icon: Icons.people,
                      color: Colors.green,
                    );
                  },
                ),

                // Total Equipos
                FutureBuilder<List<Equipo>>(
                  future: database.obtenerTodosLosEquipos(),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.length ?? 0;
                    return _StatCard(
                      title: 'Total Equipos',
                      value: count.toString(),
                      icon: Icons.devices,
                      color: Colors.purple,
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Órdenes recientes
            Text(
              'Órdenes Recientes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: FutureBuilder<List<OrdenCompleta>>(
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
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay órdenes registradas',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final ordenes = snapshot.data!.take(5).toList();

                  return ListView.builder(
                    itemCount: ordenes.length,
                    itemBuilder: (context, index) {
                      final ordenCompleta = ordenes[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: _getColorForEstado(ordenCompleta.orden.estado),
                                child: const Icon(Icons.assignment, color: Colors.white),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Orden #${ordenCompleta.orden.id} - ${ordenCompleta.cliente.nombre}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${ordenCompleta.equipo.tipo} ${ordenCompleta.equipo.marca ?? ""}',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      ordenCompleta.orden.estado.toUpperCase(),
                                      style: TextStyle(
                                        color: _getColorForEstado(ordenCompleta.orden.estado),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${ordenCompleta.orden.costo.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      _abrirDetalleOrden(context, ordenCompleta);
                                    },
                                    icon: const Icon(Icons.visibility, size: 16),
                                    label: const Text('Ver Detalle'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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

  void _abrirDetalleOrden(BuildContext context, OrdenCompleta ordenCompleta) {
    showDialog(
      context: context,
      builder: (context) => _DetalleOrdenSimpleDialog(ordenCompleta: ordenCompleta),
    );
  }
}

// Diálogo simple para ver detalle de orden desde el Dashboard
class _DetalleOrdenSimpleDialog extends StatelessWidget {
  final OrdenCompleta ordenCompleta;

  const _DetalleOrdenSimpleDialog({required this.ordenCompleta});

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
            // Header
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
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            // Contenido
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

// ==========================================
// WIDGET: TARJETA DE ESTADÍSTICA
// ==========================================
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}