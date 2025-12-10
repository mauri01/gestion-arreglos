import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// ==========================================
// TABLA: CLIENTES
// ==========================================
class Clientes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text().withLength(min: 1, max: 100)();
  TextColumn get telefono => text().withLength(max: 20).nullable()();
  TextColumn get email => text().withLength(max: 100).nullable()();
  TextColumn get direccion => text().withLength(max: 200).nullable()();
  DateTimeColumn get fechaRegistro => dateTime().withDefault(currentDateAndTime)();
}

// ==========================================
// TABLA: EQUIPOS
// ==========================================
class Equipos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get clienteId => integer().references(Clientes, #id, onDelete: KeyAction.cascade)();
  TextColumn get tipo => text().withLength(max: 50)(); // Ej: "Impresora", "PC", "Laptop"
  TextColumn get marca => text().withLength(max: 50).nullable()();
  TextColumn get modelo => text().withLength(max: 100).nullable()();
  TextColumn get numeroSerie => text().withLength(max: 100).nullable()();
  TextColumn get observaciones => text().withLength(max: 500).nullable()();
  DateTimeColumn get fechaRegistro => dateTime().withDefault(currentDateAndTime)();
}

// ==========================================
// TABLA: ÓRDENES DE SERVICIO
// ==========================================
class Ordenes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get equipoId => integer().references(Equipos, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get fechaIngreso => dateTime().withDefault(currentDateAndTime)();
  TextColumn get diagnostico => text().withLength(max: 1000).nullable()();
  TextColumn get solucion => text().withLength(max: 1000).nullable()();
  TextColumn get estado => text().withLength(max: 20)(); // "pendiente", "en_proceso", "finalizada", "entregada"
  RealColumn get costo => real().withDefault(const Constant(0.0))();
  DateTimeColumn get fechaEntrega => dateTime().nullable()();
  TextColumn get observaciones => text().withLength(max: 500).nullable()();
}

// ==========================================
// TABLA: HISTORIAL (opcional pero útil)
// ==========================================
class Historial extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get ordenId => integer().references(Ordenes, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get fecha => dateTime().withDefault(currentDateAndTime)();
  TextColumn get accion => text().withLength(max: 500)(); // "Cambio de estado", "Actualización", etc.
  TextColumn get detalles => text().withLength(max: 1000).nullable()();
}

// ==========================================
// BASE DE DATOS PRINCIPAL
// ==========================================
@DriftDatabase(tables: [Clientes, Equipos, Ordenes, Historial])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ==========================================
  // OPERACIONES: CLIENTES
  // ==========================================

  // Obtener todos los clientes
  Future<List<Cliente>> obtenerTodosLosClientes() => select(clientes).get();

  // Obtener cliente por ID
  Future<Cliente> obtenerClientePorId(int id) =>
      (select(clientes)..where((c) => c.id.equals(id))).getSingle();

  // Buscar clientes por nombre
  Future<List<Cliente>> buscarClientesPorNombre(String nombre) =>
      (select(clientes)..where((c) => c.nombre.like('%$nombre%'))).get();

  // Insertar cliente
  Future<int> insertarCliente(ClientesCompanion cliente) =>
      into(clientes).insert(cliente);

  // Actualizar cliente
  Future<bool> actualizarCliente(Cliente cliente) =>
      update(clientes).replace(cliente);

  // Eliminar cliente
  Future<int> eliminarCliente(int id) =>
      (delete(clientes)..where((c) => c.id.equals(id))).go();

  // ==========================================
  // OPERACIONES: EQUIPOS
  // ==========================================

  // Obtener todos los equipos
  Future<List<Equipo>> obtenerTodosLosEquipos() => select(equipos).get();

  // Obtener equipos de un cliente
  Future<List<Equipo>> obtenerEquiposPorCliente(int clienteId) =>
      (select(equipos)..where((e) => e.clienteId.equals(clienteId))).get();

  // Obtener equipo por ID
  Future<Equipo> obtenerEquipoPorId(int id) =>
      (select(equipos)..where((e) => e.id.equals(id))).getSingle();

  // Insertar equipo
  Future<int> insertarEquipo(EquiposCompanion equipo) =>
      into(equipos).insert(equipo);

  // Actualizar equipo
  Future<bool> actualizarEquipo(Equipo equipo) =>
      update(equipos).replace(equipo);

  // Eliminar equipo
  Future<int> eliminarEquipo(int id) =>
      (delete(equipos)..where((e) => e.id.equals(id))).go();

  // ==========================================
  // OPERACIONES: ÓRDENES
  // ==========================================

  // Obtener todas las órdenes
  Future<List<Ordene>> obtenerTodasLasOrdenes() => select(ordenes).get();

  // Obtener órdenes por estado
  Future<List<Ordene>> obtenerOrdenesPorEstado(String estado) =>
      (select(ordenes)..where((o) => o.estado.equals(estado))).get();

  // Obtener órdenes de un equipo
  Future<List<Ordene>> obtenerOrdenesPorEquipo(int equipoId) =>
      (select(ordenes)..where((o) => o.equipoId.equals(equipoId))).get();

  // Obtener orden por ID
  Future<Ordene> obtenerOrdenPorId(int id) =>
      (select(ordenes)..where((o) => o.id.equals(id))).getSingle();

  // Insertar orden
  Future<int> insertarOrden(OrdenesCompanion orden) =>
      into(ordenes).insert(orden);

  // Actualizar orden
  Future<bool> actualizarOrden(Ordene orden) =>
      update(ordenes).replace(orden);

  // Eliminar orden
  Future<int> eliminarOrden(int id) =>
      (delete(ordenes)..where((o) => o.id.equals(id))).go();

  // ==========================================
  // OPERACIONES: HISTORIAL
  // ==========================================

  // Obtener historial de una orden
  Future<List<HistorialData>> obtenerHistorialPorOrden(int ordenId) =>
      (select(historial)..where((h) => h.ordenId.equals(ordenId))
        ..orderBy([(h) => OrderingTerm.desc(h.fecha)])).get();

  // Insertar registro en historial
  Future<int> insertarHistorial(HistorialCompanion registro) =>
      into(historial).insert(registro);

  // ==========================================
  // CONSULTAS AVANZADAS (con JOINs)
  // ==========================================

  // Obtener orden completa con equipo y cliente
  Future<List<OrdenCompleta>> obtenerOrdenesCompletas() {
    final query = select(ordenes).join([
      leftOuterJoin(equipos, equipos.id.equalsExp(ordenes.equipoId)),
      leftOuterJoin(clientes, clientes.id.equalsExp(equipos.clienteId)),
    ]);

    return query.map((row) {
      return OrdenCompleta(
        orden: row.readTable(ordenes),
        equipo: row.readTable(equipos),
        cliente: row.readTable(clientes),
      );
    }).get();
  }

  // Obtener órdenes pendientes con información completa
  Future<List<OrdenCompleta>> obtenerOrdenesPendientes() {
    final query = select(ordenes).join([
      leftOuterJoin(equipos, equipos.id.equalsExp(ordenes.equipoId)),
      leftOuterJoin(clientes, clientes.id.equalsExp(equipos.clienteId)),
    ])..where(ordenes.estado.equals('pendiente'));

    return query.map((row) {
      return OrdenCompleta(
        orden: row.readTable(ordenes),
        equipo: row.readTable(equipos),
        cliente: row.readTable(clientes),
      );
    }).get();
  }
}

// ==========================================
// CLASE AUXILIAR PARA CONSULTAS COMPLEJAS
// ==========================================
class OrdenCompleta {
  final Ordene orden;
  final Equipo equipo;
  final Cliente cliente;

  OrdenCompleta({
    required this.orden,
    required this.equipo,
    required this.cliente,
  });
}

// ==========================================
// CONFIGURACIÓN DE LA CONEXIÓN
// ==========================================
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'gestion_arreglos.db'));
    return NativeDatabase(file);
  });
}