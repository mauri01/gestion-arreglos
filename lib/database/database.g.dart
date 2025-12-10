// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ClientesTable extends Clientes with TableInfo<$ClientesTable, Cliente> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
      'nombre', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _telefonoMeta =
      const VerificationMeta('telefono');
  @override
  late final GeneratedColumn<String> telefono = GeneratedColumn<String>(
      'telefono', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _direccionMeta =
      const VerificationMeta('direccion');
  @override
  late final GeneratedColumn<String> direccion = GeneratedColumn<String>(
      'direccion', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _fechaRegistroMeta =
      const VerificationMeta('fechaRegistro');
  @override
  late final GeneratedColumn<DateTime> fechaRegistro =
      GeneratedColumn<DateTime>('fecha_registro', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, nombre, telefono, email, direccion, fechaRegistro];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clientes';
  @override
  VerificationContext validateIntegrity(Insertable<Cliente> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(_nombreMeta,
          nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta));
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('telefono')) {
      context.handle(_telefonoMeta,
          telefono.isAcceptableOrUnknown(data['telefono']!, _telefonoMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('direccion')) {
      context.handle(_direccionMeta,
          direccion.isAcceptableOrUnknown(data['direccion']!, _direccionMeta));
    }
    if (data.containsKey('fecha_registro')) {
      context.handle(
          _fechaRegistroMeta,
          fechaRegistro.isAcceptableOrUnknown(
              data['fecha_registro']!, _fechaRegistroMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Cliente map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Cliente(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nombre: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nombre'])!,
      telefono: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}telefono']),
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      direccion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}direccion']),
      fechaRegistro: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_registro'])!,
    );
  }

  @override
  $ClientesTable createAlias(String alias) {
    return $ClientesTable(attachedDatabase, alias);
  }
}

class Cliente extends DataClass implements Insertable<Cliente> {
  final int id;
  final String nombre;
  final String? telefono;
  final String? email;
  final String? direccion;
  final DateTime fechaRegistro;
  const Cliente(
      {required this.id,
      required this.nombre,
      this.telefono,
      this.email,
      this.direccion,
      required this.fechaRegistro});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || telefono != null) {
      map['telefono'] = Variable<String>(telefono);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || direccion != null) {
      map['direccion'] = Variable<String>(direccion);
    }
    map['fecha_registro'] = Variable<DateTime>(fechaRegistro);
    return map;
  }

  ClientesCompanion toCompanion(bool nullToAbsent) {
    return ClientesCompanion(
      id: Value(id),
      nombre: Value(nombre),
      telefono: telefono == null && nullToAbsent
          ? const Value.absent()
          : Value(telefono),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      direccion: direccion == null && nullToAbsent
          ? const Value.absent()
          : Value(direccion),
      fechaRegistro: Value(fechaRegistro),
    );
  }

  factory Cliente.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Cliente(
      id: serializer.fromJson<int>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      telefono: serializer.fromJson<String?>(json['telefono']),
      email: serializer.fromJson<String?>(json['email']),
      direccion: serializer.fromJson<String?>(json['direccion']),
      fechaRegistro: serializer.fromJson<DateTime>(json['fechaRegistro']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombre': serializer.toJson<String>(nombre),
      'telefono': serializer.toJson<String?>(telefono),
      'email': serializer.toJson<String?>(email),
      'direccion': serializer.toJson<String?>(direccion),
      'fechaRegistro': serializer.toJson<DateTime>(fechaRegistro),
    };
  }

  Cliente copyWith(
          {int? id,
          String? nombre,
          Value<String?> telefono = const Value.absent(),
          Value<String?> email = const Value.absent(),
          Value<String?> direccion = const Value.absent(),
          DateTime? fechaRegistro}) =>
      Cliente(
        id: id ?? this.id,
        nombre: nombre ?? this.nombre,
        telefono: telefono.present ? telefono.value : this.telefono,
        email: email.present ? email.value : this.email,
        direccion: direccion.present ? direccion.value : this.direccion,
        fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      );
  @override
  String toString() {
    return (StringBuffer('Cliente(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('telefono: $telefono, ')
          ..write('email: $email, ')
          ..write('direccion: $direccion, ')
          ..write('fechaRegistro: $fechaRegistro')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nombre, telefono, email, direccion, fechaRegistro);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cliente &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.telefono == this.telefono &&
          other.email == this.email &&
          other.direccion == this.direccion &&
          other.fechaRegistro == this.fechaRegistro);
}

class ClientesCompanion extends UpdateCompanion<Cliente> {
  final Value<int> id;
  final Value<String> nombre;
  final Value<String?> telefono;
  final Value<String?> email;
  final Value<String?> direccion;
  final Value<DateTime> fechaRegistro;
  const ClientesCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.telefono = const Value.absent(),
    this.email = const Value.absent(),
    this.direccion = const Value.absent(),
    this.fechaRegistro = const Value.absent(),
  });
  ClientesCompanion.insert({
    this.id = const Value.absent(),
    required String nombre,
    this.telefono = const Value.absent(),
    this.email = const Value.absent(),
    this.direccion = const Value.absent(),
    this.fechaRegistro = const Value.absent(),
  }) : nombre = Value(nombre);
  static Insertable<Cliente> custom({
    Expression<int>? id,
    Expression<String>? nombre,
    Expression<String>? telefono,
    Expression<String>? email,
    Expression<String>? direccion,
    Expression<DateTime>? fechaRegistro,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (telefono != null) 'telefono': telefono,
      if (email != null) 'email': email,
      if (direccion != null) 'direccion': direccion,
      if (fechaRegistro != null) 'fecha_registro': fechaRegistro,
    });
  }

  ClientesCompanion copyWith(
      {Value<int>? id,
      Value<String>? nombre,
      Value<String?>? telefono,
      Value<String?>? email,
      Value<String?>? direccion,
      Value<DateTime>? fechaRegistro}) {
    return ClientesCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      direccion: direccion ?? this.direccion,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (telefono.present) {
      map['telefono'] = Variable<String>(telefono.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (direccion.present) {
      map['direccion'] = Variable<String>(direccion.value);
    }
    if (fechaRegistro.present) {
      map['fecha_registro'] = Variable<DateTime>(fechaRegistro.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientesCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('telefono: $telefono, ')
          ..write('email: $email, ')
          ..write('direccion: $direccion, ')
          ..write('fechaRegistro: $fechaRegistro')
          ..write(')'))
        .toString();
  }
}

class $EquiposTable extends Equipos with TableInfo<$EquiposTable, Equipo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EquiposTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _clienteIdMeta =
      const VerificationMeta('clienteId');
  @override
  late final GeneratedColumn<int> clienteId = GeneratedColumn<int>(
      'cliente_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES clientes (id) ON DELETE CASCADE'));
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
      'tipo', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _marcaMeta = const VerificationMeta('marca');
  @override
  late final GeneratedColumn<String> marca = GeneratedColumn<String>(
      'marca', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _modeloMeta = const VerificationMeta('modelo');
  @override
  late final GeneratedColumn<String> modelo = GeneratedColumn<String>(
      'modelo', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _numeroSerieMeta =
      const VerificationMeta('numeroSerie');
  @override
  late final GeneratedColumn<String> numeroSerie = GeneratedColumn<String>(
      'numero_serie', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _observacionesMeta =
      const VerificationMeta('observaciones');
  @override
  late final GeneratedColumn<String> observaciones = GeneratedColumn<String>(
      'observaciones', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 500),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _fechaRegistroMeta =
      const VerificationMeta('fechaRegistro');
  @override
  late final GeneratedColumn<DateTime> fechaRegistro =
      GeneratedColumn<DateTime>('fecha_registro', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        clienteId,
        tipo,
        marca,
        modelo,
        numeroSerie,
        observaciones,
        fechaRegistro
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'equipos';
  @override
  VerificationContext validateIntegrity(Insertable<Equipo> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cliente_id')) {
      context.handle(_clienteIdMeta,
          clienteId.isAcceptableOrUnknown(data['cliente_id']!, _clienteIdMeta));
    } else if (isInserting) {
      context.missing(_clienteIdMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
          _tipoMeta, tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta));
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('marca')) {
      context.handle(
          _marcaMeta, marca.isAcceptableOrUnknown(data['marca']!, _marcaMeta));
    }
    if (data.containsKey('modelo')) {
      context.handle(_modeloMeta,
          modelo.isAcceptableOrUnknown(data['modelo']!, _modeloMeta));
    }
    if (data.containsKey('numero_serie')) {
      context.handle(
          _numeroSerieMeta,
          numeroSerie.isAcceptableOrUnknown(
              data['numero_serie']!, _numeroSerieMeta));
    }
    if (data.containsKey('observaciones')) {
      context.handle(
          _observacionesMeta,
          observaciones.isAcceptableOrUnknown(
              data['observaciones']!, _observacionesMeta));
    }
    if (data.containsKey('fecha_registro')) {
      context.handle(
          _fechaRegistroMeta,
          fechaRegistro.isAcceptableOrUnknown(
              data['fecha_registro']!, _fechaRegistroMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Equipo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Equipo(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      clienteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cliente_id'])!,
      tipo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tipo'])!,
      marca: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}marca']),
      modelo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}modelo']),
      numeroSerie: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}numero_serie']),
      observaciones: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}observaciones']),
      fechaRegistro: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_registro'])!,
    );
  }

  @override
  $EquiposTable createAlias(String alias) {
    return $EquiposTable(attachedDatabase, alias);
  }
}

class Equipo extends DataClass implements Insertable<Equipo> {
  final int id;
  final int clienteId;
  final String tipo;
  final String? marca;
  final String? modelo;
  final String? numeroSerie;
  final String? observaciones;
  final DateTime fechaRegistro;
  const Equipo(
      {required this.id,
      required this.clienteId,
      required this.tipo,
      this.marca,
      this.modelo,
      this.numeroSerie,
      this.observaciones,
      required this.fechaRegistro});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cliente_id'] = Variable<int>(clienteId);
    map['tipo'] = Variable<String>(tipo);
    if (!nullToAbsent || marca != null) {
      map['marca'] = Variable<String>(marca);
    }
    if (!nullToAbsent || modelo != null) {
      map['modelo'] = Variable<String>(modelo);
    }
    if (!nullToAbsent || numeroSerie != null) {
      map['numero_serie'] = Variable<String>(numeroSerie);
    }
    if (!nullToAbsent || observaciones != null) {
      map['observaciones'] = Variable<String>(observaciones);
    }
    map['fecha_registro'] = Variable<DateTime>(fechaRegistro);
    return map;
  }

  EquiposCompanion toCompanion(bool nullToAbsent) {
    return EquiposCompanion(
      id: Value(id),
      clienteId: Value(clienteId),
      tipo: Value(tipo),
      marca:
          marca == null && nullToAbsent ? const Value.absent() : Value(marca),
      modelo:
          modelo == null && nullToAbsent ? const Value.absent() : Value(modelo),
      numeroSerie: numeroSerie == null && nullToAbsent
          ? const Value.absent()
          : Value(numeroSerie),
      observaciones: observaciones == null && nullToAbsent
          ? const Value.absent()
          : Value(observaciones),
      fechaRegistro: Value(fechaRegistro),
    );
  }

  factory Equipo.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Equipo(
      id: serializer.fromJson<int>(json['id']),
      clienteId: serializer.fromJson<int>(json['clienteId']),
      tipo: serializer.fromJson<String>(json['tipo']),
      marca: serializer.fromJson<String?>(json['marca']),
      modelo: serializer.fromJson<String?>(json['modelo']),
      numeroSerie: serializer.fromJson<String?>(json['numeroSerie']),
      observaciones: serializer.fromJson<String?>(json['observaciones']),
      fechaRegistro: serializer.fromJson<DateTime>(json['fechaRegistro']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'clienteId': serializer.toJson<int>(clienteId),
      'tipo': serializer.toJson<String>(tipo),
      'marca': serializer.toJson<String?>(marca),
      'modelo': serializer.toJson<String?>(modelo),
      'numeroSerie': serializer.toJson<String?>(numeroSerie),
      'observaciones': serializer.toJson<String?>(observaciones),
      'fechaRegistro': serializer.toJson<DateTime>(fechaRegistro),
    };
  }

  Equipo copyWith(
          {int? id,
          int? clienteId,
          String? tipo,
          Value<String?> marca = const Value.absent(),
          Value<String?> modelo = const Value.absent(),
          Value<String?> numeroSerie = const Value.absent(),
          Value<String?> observaciones = const Value.absent(),
          DateTime? fechaRegistro}) =>
      Equipo(
        id: id ?? this.id,
        clienteId: clienteId ?? this.clienteId,
        tipo: tipo ?? this.tipo,
        marca: marca.present ? marca.value : this.marca,
        modelo: modelo.present ? modelo.value : this.modelo,
        numeroSerie: numeroSerie.present ? numeroSerie.value : this.numeroSerie,
        observaciones:
            observaciones.present ? observaciones.value : this.observaciones,
        fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      );
  @override
  String toString() {
    return (StringBuffer('Equipo(')
          ..write('id: $id, ')
          ..write('clienteId: $clienteId, ')
          ..write('tipo: $tipo, ')
          ..write('marca: $marca, ')
          ..write('modelo: $modelo, ')
          ..write('numeroSerie: $numeroSerie, ')
          ..write('observaciones: $observaciones, ')
          ..write('fechaRegistro: $fechaRegistro')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, clienteId, tipo, marca, modelo,
      numeroSerie, observaciones, fechaRegistro);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Equipo &&
          other.id == this.id &&
          other.clienteId == this.clienteId &&
          other.tipo == this.tipo &&
          other.marca == this.marca &&
          other.modelo == this.modelo &&
          other.numeroSerie == this.numeroSerie &&
          other.observaciones == this.observaciones &&
          other.fechaRegistro == this.fechaRegistro);
}

class EquiposCompanion extends UpdateCompanion<Equipo> {
  final Value<int> id;
  final Value<int> clienteId;
  final Value<String> tipo;
  final Value<String?> marca;
  final Value<String?> modelo;
  final Value<String?> numeroSerie;
  final Value<String?> observaciones;
  final Value<DateTime> fechaRegistro;
  const EquiposCompanion({
    this.id = const Value.absent(),
    this.clienteId = const Value.absent(),
    this.tipo = const Value.absent(),
    this.marca = const Value.absent(),
    this.modelo = const Value.absent(),
    this.numeroSerie = const Value.absent(),
    this.observaciones = const Value.absent(),
    this.fechaRegistro = const Value.absent(),
  });
  EquiposCompanion.insert({
    this.id = const Value.absent(),
    required int clienteId,
    required String tipo,
    this.marca = const Value.absent(),
    this.modelo = const Value.absent(),
    this.numeroSerie = const Value.absent(),
    this.observaciones = const Value.absent(),
    this.fechaRegistro = const Value.absent(),
  })  : clienteId = Value(clienteId),
        tipo = Value(tipo);
  static Insertable<Equipo> custom({
    Expression<int>? id,
    Expression<int>? clienteId,
    Expression<String>? tipo,
    Expression<String>? marca,
    Expression<String>? modelo,
    Expression<String>? numeroSerie,
    Expression<String>? observaciones,
    Expression<DateTime>? fechaRegistro,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clienteId != null) 'cliente_id': clienteId,
      if (tipo != null) 'tipo': tipo,
      if (marca != null) 'marca': marca,
      if (modelo != null) 'modelo': modelo,
      if (numeroSerie != null) 'numero_serie': numeroSerie,
      if (observaciones != null) 'observaciones': observaciones,
      if (fechaRegistro != null) 'fecha_registro': fechaRegistro,
    });
  }

  EquiposCompanion copyWith(
      {Value<int>? id,
      Value<int>? clienteId,
      Value<String>? tipo,
      Value<String?>? marca,
      Value<String?>? modelo,
      Value<String?>? numeroSerie,
      Value<String?>? observaciones,
      Value<DateTime>? fechaRegistro}) {
    return EquiposCompanion(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      tipo: tipo ?? this.tipo,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      numeroSerie: numeroSerie ?? this.numeroSerie,
      observaciones: observaciones ?? this.observaciones,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (clienteId.present) {
      map['cliente_id'] = Variable<int>(clienteId.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (marca.present) {
      map['marca'] = Variable<String>(marca.value);
    }
    if (modelo.present) {
      map['modelo'] = Variable<String>(modelo.value);
    }
    if (numeroSerie.present) {
      map['numero_serie'] = Variable<String>(numeroSerie.value);
    }
    if (observaciones.present) {
      map['observaciones'] = Variable<String>(observaciones.value);
    }
    if (fechaRegistro.present) {
      map['fecha_registro'] = Variable<DateTime>(fechaRegistro.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EquiposCompanion(')
          ..write('id: $id, ')
          ..write('clienteId: $clienteId, ')
          ..write('tipo: $tipo, ')
          ..write('marca: $marca, ')
          ..write('modelo: $modelo, ')
          ..write('numeroSerie: $numeroSerie, ')
          ..write('observaciones: $observaciones, ')
          ..write('fechaRegistro: $fechaRegistro')
          ..write(')'))
        .toString();
  }
}

class $OrdenesTable extends Ordenes with TableInfo<$OrdenesTable, Ordene> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrdenesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _equipoIdMeta =
      const VerificationMeta('equipoId');
  @override
  late final GeneratedColumn<int> equipoId = GeneratedColumn<int>(
      'equipo_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES equipos (id) ON DELETE CASCADE'));
  static const VerificationMeta _fechaIngresoMeta =
      const VerificationMeta('fechaIngreso');
  @override
  late final GeneratedColumn<DateTime> fechaIngreso = GeneratedColumn<DateTime>(
      'fecha_ingreso', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _diagnosticoMeta =
      const VerificationMeta('diagnostico');
  @override
  late final GeneratedColumn<String> diagnostico = GeneratedColumn<String>(
      'diagnostico', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 1000),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _solucionMeta =
      const VerificationMeta('solucion');
  @override
  late final GeneratedColumn<String> solucion = GeneratedColumn<String>(
      'solucion', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 1000),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
      'estado', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _costoMeta = const VerificationMeta('costo');
  @override
  late final GeneratedColumn<double> costo = GeneratedColumn<double>(
      'costo', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _fechaEntregaMeta =
      const VerificationMeta('fechaEntrega');
  @override
  late final GeneratedColumn<DateTime> fechaEntrega = GeneratedColumn<DateTime>(
      'fecha_entrega', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _observacionesMeta =
      const VerificationMeta('observaciones');
  @override
  late final GeneratedColumn<String> observaciones = GeneratedColumn<String>(
      'observaciones', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 500),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        equipoId,
        fechaIngreso,
        diagnostico,
        solucion,
        estado,
        costo,
        fechaEntrega,
        observaciones
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ordenes';
  @override
  VerificationContext validateIntegrity(Insertable<Ordene> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('equipo_id')) {
      context.handle(_equipoIdMeta,
          equipoId.isAcceptableOrUnknown(data['equipo_id']!, _equipoIdMeta));
    } else if (isInserting) {
      context.missing(_equipoIdMeta);
    }
    if (data.containsKey('fecha_ingreso')) {
      context.handle(
          _fechaIngresoMeta,
          fechaIngreso.isAcceptableOrUnknown(
              data['fecha_ingreso']!, _fechaIngresoMeta));
    }
    if (data.containsKey('diagnostico')) {
      context.handle(
          _diagnosticoMeta,
          diagnostico.isAcceptableOrUnknown(
              data['diagnostico']!, _diagnosticoMeta));
    }
    if (data.containsKey('solucion')) {
      context.handle(_solucionMeta,
          solucion.isAcceptableOrUnknown(data['solucion']!, _solucionMeta));
    }
    if (data.containsKey('estado')) {
      context.handle(_estadoMeta,
          estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta));
    } else if (isInserting) {
      context.missing(_estadoMeta);
    }
    if (data.containsKey('costo')) {
      context.handle(
          _costoMeta, costo.isAcceptableOrUnknown(data['costo']!, _costoMeta));
    }
    if (data.containsKey('fecha_entrega')) {
      context.handle(
          _fechaEntregaMeta,
          fechaEntrega.isAcceptableOrUnknown(
              data['fecha_entrega']!, _fechaEntregaMeta));
    }
    if (data.containsKey('observaciones')) {
      context.handle(
          _observacionesMeta,
          observaciones.isAcceptableOrUnknown(
              data['observaciones']!, _observacionesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Ordene map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Ordene(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      equipoId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}equipo_id'])!,
      fechaIngreso: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_ingreso'])!,
      diagnostico: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}diagnostico']),
      solucion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}solucion']),
      estado: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}estado'])!,
      costo: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}costo'])!,
      fechaEntrega: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fecha_entrega']),
      observaciones: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}observaciones']),
    );
  }

  @override
  $OrdenesTable createAlias(String alias) {
    return $OrdenesTable(attachedDatabase, alias);
  }
}

class Ordene extends DataClass implements Insertable<Ordene> {
  final int id;
  final int equipoId;
  final DateTime fechaIngreso;
  final String? diagnostico;
  final String? solucion;
  final String estado;
  final double costo;
  final DateTime? fechaEntrega;
  final String? observaciones;
  const Ordene(
      {required this.id,
      required this.equipoId,
      required this.fechaIngreso,
      this.diagnostico,
      this.solucion,
      required this.estado,
      required this.costo,
      this.fechaEntrega,
      this.observaciones});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['equipo_id'] = Variable<int>(equipoId);
    map['fecha_ingreso'] = Variable<DateTime>(fechaIngreso);
    if (!nullToAbsent || diagnostico != null) {
      map['diagnostico'] = Variable<String>(diagnostico);
    }
    if (!nullToAbsent || solucion != null) {
      map['solucion'] = Variable<String>(solucion);
    }
    map['estado'] = Variable<String>(estado);
    map['costo'] = Variable<double>(costo);
    if (!nullToAbsent || fechaEntrega != null) {
      map['fecha_entrega'] = Variable<DateTime>(fechaEntrega);
    }
    if (!nullToAbsent || observaciones != null) {
      map['observaciones'] = Variable<String>(observaciones);
    }
    return map;
  }

  OrdenesCompanion toCompanion(bool nullToAbsent) {
    return OrdenesCompanion(
      id: Value(id),
      equipoId: Value(equipoId),
      fechaIngreso: Value(fechaIngreso),
      diagnostico: diagnostico == null && nullToAbsent
          ? const Value.absent()
          : Value(diagnostico),
      solucion: solucion == null && nullToAbsent
          ? const Value.absent()
          : Value(solucion),
      estado: Value(estado),
      costo: Value(costo),
      fechaEntrega: fechaEntrega == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaEntrega),
      observaciones: observaciones == null && nullToAbsent
          ? const Value.absent()
          : Value(observaciones),
    );
  }

  factory Ordene.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Ordene(
      id: serializer.fromJson<int>(json['id']),
      equipoId: serializer.fromJson<int>(json['equipoId']),
      fechaIngreso: serializer.fromJson<DateTime>(json['fechaIngreso']),
      diagnostico: serializer.fromJson<String?>(json['diagnostico']),
      solucion: serializer.fromJson<String?>(json['solucion']),
      estado: serializer.fromJson<String>(json['estado']),
      costo: serializer.fromJson<double>(json['costo']),
      fechaEntrega: serializer.fromJson<DateTime?>(json['fechaEntrega']),
      observaciones: serializer.fromJson<String?>(json['observaciones']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'equipoId': serializer.toJson<int>(equipoId),
      'fechaIngreso': serializer.toJson<DateTime>(fechaIngreso),
      'diagnostico': serializer.toJson<String?>(diagnostico),
      'solucion': serializer.toJson<String?>(solucion),
      'estado': serializer.toJson<String>(estado),
      'costo': serializer.toJson<double>(costo),
      'fechaEntrega': serializer.toJson<DateTime?>(fechaEntrega),
      'observaciones': serializer.toJson<String?>(observaciones),
    };
  }

  Ordene copyWith(
          {int? id,
          int? equipoId,
          DateTime? fechaIngreso,
          Value<String?> diagnostico = const Value.absent(),
          Value<String?> solucion = const Value.absent(),
          String? estado,
          double? costo,
          Value<DateTime?> fechaEntrega = const Value.absent(),
          Value<String?> observaciones = const Value.absent()}) =>
      Ordene(
        id: id ?? this.id,
        equipoId: equipoId ?? this.equipoId,
        fechaIngreso: fechaIngreso ?? this.fechaIngreso,
        diagnostico: diagnostico.present ? diagnostico.value : this.diagnostico,
        solucion: solucion.present ? solucion.value : this.solucion,
        estado: estado ?? this.estado,
        costo: costo ?? this.costo,
        fechaEntrega:
            fechaEntrega.present ? fechaEntrega.value : this.fechaEntrega,
        observaciones:
            observaciones.present ? observaciones.value : this.observaciones,
      );
  @override
  String toString() {
    return (StringBuffer('Ordene(')
          ..write('id: $id, ')
          ..write('equipoId: $equipoId, ')
          ..write('fechaIngreso: $fechaIngreso, ')
          ..write('diagnostico: $diagnostico, ')
          ..write('solucion: $solucion, ')
          ..write('estado: $estado, ')
          ..write('costo: $costo, ')
          ..write('fechaEntrega: $fechaEntrega, ')
          ..write('observaciones: $observaciones')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, equipoId, fechaIngreso, diagnostico,
      solucion, estado, costo, fechaEntrega, observaciones);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ordene &&
          other.id == this.id &&
          other.equipoId == this.equipoId &&
          other.fechaIngreso == this.fechaIngreso &&
          other.diagnostico == this.diagnostico &&
          other.solucion == this.solucion &&
          other.estado == this.estado &&
          other.costo == this.costo &&
          other.fechaEntrega == this.fechaEntrega &&
          other.observaciones == this.observaciones);
}

class OrdenesCompanion extends UpdateCompanion<Ordene> {
  final Value<int> id;
  final Value<int> equipoId;
  final Value<DateTime> fechaIngreso;
  final Value<String?> diagnostico;
  final Value<String?> solucion;
  final Value<String> estado;
  final Value<double> costo;
  final Value<DateTime?> fechaEntrega;
  final Value<String?> observaciones;
  const OrdenesCompanion({
    this.id = const Value.absent(),
    this.equipoId = const Value.absent(),
    this.fechaIngreso = const Value.absent(),
    this.diagnostico = const Value.absent(),
    this.solucion = const Value.absent(),
    this.estado = const Value.absent(),
    this.costo = const Value.absent(),
    this.fechaEntrega = const Value.absent(),
    this.observaciones = const Value.absent(),
  });
  OrdenesCompanion.insert({
    this.id = const Value.absent(),
    required int equipoId,
    this.fechaIngreso = const Value.absent(),
    this.diagnostico = const Value.absent(),
    this.solucion = const Value.absent(),
    required String estado,
    this.costo = const Value.absent(),
    this.fechaEntrega = const Value.absent(),
    this.observaciones = const Value.absent(),
  })  : equipoId = Value(equipoId),
        estado = Value(estado);
  static Insertable<Ordene> custom({
    Expression<int>? id,
    Expression<int>? equipoId,
    Expression<DateTime>? fechaIngreso,
    Expression<String>? diagnostico,
    Expression<String>? solucion,
    Expression<String>? estado,
    Expression<double>? costo,
    Expression<DateTime>? fechaEntrega,
    Expression<String>? observaciones,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (equipoId != null) 'equipo_id': equipoId,
      if (fechaIngreso != null) 'fecha_ingreso': fechaIngreso,
      if (diagnostico != null) 'diagnostico': diagnostico,
      if (solucion != null) 'solucion': solucion,
      if (estado != null) 'estado': estado,
      if (costo != null) 'costo': costo,
      if (fechaEntrega != null) 'fecha_entrega': fechaEntrega,
      if (observaciones != null) 'observaciones': observaciones,
    });
  }

  OrdenesCompanion copyWith(
      {Value<int>? id,
      Value<int>? equipoId,
      Value<DateTime>? fechaIngreso,
      Value<String?>? diagnostico,
      Value<String?>? solucion,
      Value<String>? estado,
      Value<double>? costo,
      Value<DateTime?>? fechaEntrega,
      Value<String?>? observaciones}) {
    return OrdenesCompanion(
      id: id ?? this.id,
      equipoId: equipoId ?? this.equipoId,
      fechaIngreso: fechaIngreso ?? this.fechaIngreso,
      diagnostico: diagnostico ?? this.diagnostico,
      solucion: solucion ?? this.solucion,
      estado: estado ?? this.estado,
      costo: costo ?? this.costo,
      fechaEntrega: fechaEntrega ?? this.fechaEntrega,
      observaciones: observaciones ?? this.observaciones,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (equipoId.present) {
      map['equipo_id'] = Variable<int>(equipoId.value);
    }
    if (fechaIngreso.present) {
      map['fecha_ingreso'] = Variable<DateTime>(fechaIngreso.value);
    }
    if (diagnostico.present) {
      map['diagnostico'] = Variable<String>(diagnostico.value);
    }
    if (solucion.present) {
      map['solucion'] = Variable<String>(solucion.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (costo.present) {
      map['costo'] = Variable<double>(costo.value);
    }
    if (fechaEntrega.present) {
      map['fecha_entrega'] = Variable<DateTime>(fechaEntrega.value);
    }
    if (observaciones.present) {
      map['observaciones'] = Variable<String>(observaciones.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrdenesCompanion(')
          ..write('id: $id, ')
          ..write('equipoId: $equipoId, ')
          ..write('fechaIngreso: $fechaIngreso, ')
          ..write('diagnostico: $diagnostico, ')
          ..write('solucion: $solucion, ')
          ..write('estado: $estado, ')
          ..write('costo: $costo, ')
          ..write('fechaEntrega: $fechaEntrega, ')
          ..write('observaciones: $observaciones')
          ..write(')'))
        .toString();
  }
}

class $HistorialTable extends Historial
    with TableInfo<$HistorialTable, HistorialData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistorialTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _ordenIdMeta =
      const VerificationMeta('ordenId');
  @override
  late final GeneratedColumn<int> ordenId = GeneratedColumn<int>(
      'orden_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES ordenes (id) ON DELETE CASCADE'));
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
      'fecha', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _accionMeta = const VerificationMeta('accion');
  @override
  late final GeneratedColumn<String> accion = GeneratedColumn<String>(
      'accion', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 500),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _detallesMeta =
      const VerificationMeta('detalles');
  @override
  late final GeneratedColumn<String> detalles = GeneratedColumn<String>(
      'detalles', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 1000),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, ordenId, fecha, accion, detalles];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'historial';
  @override
  VerificationContext validateIntegrity(Insertable<HistorialData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('orden_id')) {
      context.handle(_ordenIdMeta,
          ordenId.isAcceptableOrUnknown(data['orden_id']!, _ordenIdMeta));
    } else if (isInserting) {
      context.missing(_ordenIdMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
          _fechaMeta, fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta));
    }
    if (data.containsKey('accion')) {
      context.handle(_accionMeta,
          accion.isAcceptableOrUnknown(data['accion']!, _accionMeta));
    } else if (isInserting) {
      context.missing(_accionMeta);
    }
    if (data.containsKey('detalles')) {
      context.handle(_detallesMeta,
          detalles.isAcceptableOrUnknown(data['detalles']!, _detallesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HistorialData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HistorialData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      ordenId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}orden_id'])!,
      fecha: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fecha'])!,
      accion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}accion'])!,
      detalles: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}detalles']),
    );
  }

  @override
  $HistorialTable createAlias(String alias) {
    return $HistorialTable(attachedDatabase, alias);
  }
}

class HistorialData extends DataClass implements Insertable<HistorialData> {
  final int id;
  final int ordenId;
  final DateTime fecha;
  final String accion;
  final String? detalles;
  const HistorialData(
      {required this.id,
      required this.ordenId,
      required this.fecha,
      required this.accion,
      this.detalles});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['orden_id'] = Variable<int>(ordenId);
    map['fecha'] = Variable<DateTime>(fecha);
    map['accion'] = Variable<String>(accion);
    if (!nullToAbsent || detalles != null) {
      map['detalles'] = Variable<String>(detalles);
    }
    return map;
  }

  HistorialCompanion toCompanion(bool nullToAbsent) {
    return HistorialCompanion(
      id: Value(id),
      ordenId: Value(ordenId),
      fecha: Value(fecha),
      accion: Value(accion),
      detalles: detalles == null && nullToAbsent
          ? const Value.absent()
          : Value(detalles),
    );
  }

  factory HistorialData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HistorialData(
      id: serializer.fromJson<int>(json['id']),
      ordenId: serializer.fromJson<int>(json['ordenId']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      accion: serializer.fromJson<String>(json['accion']),
      detalles: serializer.fromJson<String?>(json['detalles']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ordenId': serializer.toJson<int>(ordenId),
      'fecha': serializer.toJson<DateTime>(fecha),
      'accion': serializer.toJson<String>(accion),
      'detalles': serializer.toJson<String?>(detalles),
    };
  }

  HistorialData copyWith(
          {int? id,
          int? ordenId,
          DateTime? fecha,
          String? accion,
          Value<String?> detalles = const Value.absent()}) =>
      HistorialData(
        id: id ?? this.id,
        ordenId: ordenId ?? this.ordenId,
        fecha: fecha ?? this.fecha,
        accion: accion ?? this.accion,
        detalles: detalles.present ? detalles.value : this.detalles,
      );
  @override
  String toString() {
    return (StringBuffer('HistorialData(')
          ..write('id: $id, ')
          ..write('ordenId: $ordenId, ')
          ..write('fecha: $fecha, ')
          ..write('accion: $accion, ')
          ..write('detalles: $detalles')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ordenId, fecha, accion, detalles);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HistorialData &&
          other.id == this.id &&
          other.ordenId == this.ordenId &&
          other.fecha == this.fecha &&
          other.accion == this.accion &&
          other.detalles == this.detalles);
}

class HistorialCompanion extends UpdateCompanion<HistorialData> {
  final Value<int> id;
  final Value<int> ordenId;
  final Value<DateTime> fecha;
  final Value<String> accion;
  final Value<String?> detalles;
  const HistorialCompanion({
    this.id = const Value.absent(),
    this.ordenId = const Value.absent(),
    this.fecha = const Value.absent(),
    this.accion = const Value.absent(),
    this.detalles = const Value.absent(),
  });
  HistorialCompanion.insert({
    this.id = const Value.absent(),
    required int ordenId,
    this.fecha = const Value.absent(),
    required String accion,
    this.detalles = const Value.absent(),
  })  : ordenId = Value(ordenId),
        accion = Value(accion);
  static Insertable<HistorialData> custom({
    Expression<int>? id,
    Expression<int>? ordenId,
    Expression<DateTime>? fecha,
    Expression<String>? accion,
    Expression<String>? detalles,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ordenId != null) 'orden_id': ordenId,
      if (fecha != null) 'fecha': fecha,
      if (accion != null) 'accion': accion,
      if (detalles != null) 'detalles': detalles,
    });
  }

  HistorialCompanion copyWith(
      {Value<int>? id,
      Value<int>? ordenId,
      Value<DateTime>? fecha,
      Value<String>? accion,
      Value<String?>? detalles}) {
    return HistorialCompanion(
      id: id ?? this.id,
      ordenId: ordenId ?? this.ordenId,
      fecha: fecha ?? this.fecha,
      accion: accion ?? this.accion,
      detalles: detalles ?? this.detalles,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ordenId.present) {
      map['orden_id'] = Variable<int>(ordenId.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (accion.present) {
      map['accion'] = Variable<String>(accion.value);
    }
    if (detalles.present) {
      map['detalles'] = Variable<String>(detalles.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistorialCompanion(')
          ..write('id: $id, ')
          ..write('ordenId: $ordenId, ')
          ..write('fecha: $fecha, ')
          ..write('accion: $accion, ')
          ..write('detalles: $detalles')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $ClientesTable clientes = $ClientesTable(this);
  late final $EquiposTable equipos = $EquiposTable(this);
  late final $OrdenesTable ordenes = $OrdenesTable(this);
  late final $HistorialTable historial = $HistorialTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [clientes, equipos, ordenes, historial];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('clientes',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('equipos', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('equipos',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('ordenes', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('ordenes',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('historial', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}
