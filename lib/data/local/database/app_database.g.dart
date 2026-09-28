// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $JeepneyRoutesTable extends JeepneyRoutes
    with TableInfo<$JeepneyRoutesTable, JeepneyRouteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JeepneyRoutesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _codeNameMeta = const VerificationMeta(
    'codeName',
  );
  @override
  late final GeneratedColumn<String> codeName = GeneratedColumn<String>(
    'code_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stopCountMeta = const VerificationMeta(
    'stopCount',
  );
  @override
  late final GeneratedColumn<int> stopCount = GeneratedColumn<int>(
    'stop_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalKmMeta = const VerificationMeta(
    'totalKm',
  );
  @override
  late final GeneratedColumn<int> totalKm = GeneratedColumn<int>(
    'total_km',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usageCountMeta = const VerificationMeta(
    'usageCount',
  );
  @override
  late final GeneratedColumn<int> usageCount = GeneratedColumn<int>(
    'usage_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastUsedAtMeta = const VerificationMeta(
    'lastUsedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastUsedAt = GeneratedColumn<DateTime>(
    'last_used_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    codeName,
    displayName,
    stopCount,
    totalKm,
    usageCount,
    lastUsedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'jeepney_routes';
  @override
  VerificationContext validateIntegrity(
    Insertable<JeepneyRouteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('code_name')) {
      context.handle(
        _codeNameMeta,
        codeName.isAcceptableOrUnknown(data['code_name']!, _codeNameMeta),
      );
    } else if (isInserting) {
      context.missing(_codeNameMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('stop_count')) {
      context.handle(
        _stopCountMeta,
        stopCount.isAcceptableOrUnknown(data['stop_count']!, _stopCountMeta),
      );
    } else if (isInserting) {
      context.missing(_stopCountMeta);
    }
    if (data.containsKey('total_km')) {
      context.handle(
        _totalKmMeta,
        totalKm.isAcceptableOrUnknown(data['total_km']!, _totalKmMeta),
      );
    } else if (isInserting) {
      context.missing(_totalKmMeta);
    }
    if (data.containsKey('usage_count')) {
      context.handle(
        _usageCountMeta,
        usageCount.isAcceptableOrUnknown(data['usage_count']!, _usageCountMeta),
      );
    }
    if (data.containsKey('last_used_at')) {
      context.handle(
        _lastUsedAtMeta,
        lastUsedAt.isAcceptableOrUnknown(
          data['last_used_at']!,
          _lastUsedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JeepneyRouteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JeepneyRouteRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      codeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code_name'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      stopCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stop_count'],
      )!,
      totalKm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_km'],
      )!,
      usageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}usage_count'],
      )!,
      lastUsedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_used_at'],
      ),
    );
  }

  @override
  $JeepneyRoutesTable createAlias(String alias) {
    return $JeepneyRoutesTable(attachedDatabase, alias);
  }
}

class JeepneyRouteRow extends DataClass implements Insertable<JeepneyRouteRow> {
  final int id;
  final String codeName;
  final String displayName;
  final int stopCount;
  final int totalKm;

  /// How many times the user has priced a ride on this route. Drives the
  /// "most popular" ranking, so it must reflect real local usage and never a
  /// curated list.
  final int usageCount;

  /// Tie-breaker when two routes share the same [usageCount].
  final DateTime? lastUsedAt;
  const JeepneyRouteRow({
    required this.id,
    required this.codeName,
    required this.displayName,
    required this.stopCount,
    required this.totalKm,
    required this.usageCount,
    this.lastUsedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['code_name'] = Variable<String>(codeName);
    map['display_name'] = Variable<String>(displayName);
    map['stop_count'] = Variable<int>(stopCount);
    map['total_km'] = Variable<int>(totalKm);
    map['usage_count'] = Variable<int>(usageCount);
    if (!nullToAbsent || lastUsedAt != null) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt);
    }
    return map;
  }

  JeepneyRoutesCompanion toCompanion(bool nullToAbsent) {
    return JeepneyRoutesCompanion(
      id: Value(id),
      codeName: Value(codeName),
      displayName: Value(displayName),
      stopCount: Value(stopCount),
      totalKm: Value(totalKm),
      usageCount: Value(usageCount),
      lastUsedAt: lastUsedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUsedAt),
    );
  }

  factory JeepneyRouteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JeepneyRouteRow(
      id: serializer.fromJson<int>(json['id']),
      codeName: serializer.fromJson<String>(json['codeName']),
      displayName: serializer.fromJson<String>(json['displayName']),
      stopCount: serializer.fromJson<int>(json['stopCount']),
      totalKm: serializer.fromJson<int>(json['totalKm']),
      usageCount: serializer.fromJson<int>(json['usageCount']),
      lastUsedAt: serializer.fromJson<DateTime?>(json['lastUsedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'codeName': serializer.toJson<String>(codeName),
      'displayName': serializer.toJson<String>(displayName),
      'stopCount': serializer.toJson<int>(stopCount),
      'totalKm': serializer.toJson<int>(totalKm),
      'usageCount': serializer.toJson<int>(usageCount),
      'lastUsedAt': serializer.toJson<DateTime?>(lastUsedAt),
    };
  }

  JeepneyRouteRow copyWith({
    int? id,
    String? codeName,
    String? displayName,
    int? stopCount,
    int? totalKm,
    int? usageCount,
    Value<DateTime?> lastUsedAt = const Value.absent(),
  }) => JeepneyRouteRow(
    id: id ?? this.id,
    codeName: codeName ?? this.codeName,
    displayName: displayName ?? this.displayName,
    stopCount: stopCount ?? this.stopCount,
    totalKm: totalKm ?? this.totalKm,
    usageCount: usageCount ?? this.usageCount,
    lastUsedAt: lastUsedAt.present ? lastUsedAt.value : this.lastUsedAt,
  );
  JeepneyRouteRow copyWithCompanion(JeepneyRoutesCompanion data) {
    return JeepneyRouteRow(
      id: data.id.present ? data.id.value : this.id,
      codeName: data.codeName.present ? data.codeName.value : this.codeName,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      stopCount: data.stopCount.present ? data.stopCount.value : this.stopCount,
      totalKm: data.totalKm.present ? data.totalKm.value : this.totalKm,
      usageCount: data.usageCount.present
          ? data.usageCount.value
          : this.usageCount,
      lastUsedAt: data.lastUsedAt.present
          ? data.lastUsedAt.value
          : this.lastUsedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JeepneyRouteRow(')
          ..write('id: $id, ')
          ..write('codeName: $codeName, ')
          ..write('displayName: $displayName, ')
          ..write('stopCount: $stopCount, ')
          ..write('totalKm: $totalKm, ')
          ..write('usageCount: $usageCount, ')
          ..write('lastUsedAt: $lastUsedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    codeName,
    displayName,
    stopCount,
    totalKm,
    usageCount,
    lastUsedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JeepneyRouteRow &&
          other.id == this.id &&
          other.codeName == this.codeName &&
          other.displayName == this.displayName &&
          other.stopCount == this.stopCount &&
          other.totalKm == this.totalKm &&
          other.usageCount == this.usageCount &&
          other.lastUsedAt == this.lastUsedAt);
}

class JeepneyRoutesCompanion extends UpdateCompanion<JeepneyRouteRow> {
  final Value<int> id;
  final Value<String> codeName;
  final Value<String> displayName;
  final Value<int> stopCount;
  final Value<int> totalKm;
  final Value<int> usageCount;
  final Value<DateTime?> lastUsedAt;
  const JeepneyRoutesCompanion({
    this.id = const Value.absent(),
    this.codeName = const Value.absent(),
    this.displayName = const Value.absent(),
    this.stopCount = const Value.absent(),
    this.totalKm = const Value.absent(),
    this.usageCount = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
  });
  JeepneyRoutesCompanion.insert({
    this.id = const Value.absent(),
    required String codeName,
    required String displayName,
    required int stopCount,
    required int totalKm,
    this.usageCount = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
  }) : codeName = Value(codeName),
       displayName = Value(displayName),
       stopCount = Value(stopCount),
       totalKm = Value(totalKm);
  static Insertable<JeepneyRouteRow> custom({
    Expression<int>? id,
    Expression<String>? codeName,
    Expression<String>? displayName,
    Expression<int>? stopCount,
    Expression<int>? totalKm,
    Expression<int>? usageCount,
    Expression<DateTime>? lastUsedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (codeName != null) 'code_name': codeName,
      if (displayName != null) 'display_name': displayName,
      if (stopCount != null) 'stop_count': stopCount,
      if (totalKm != null) 'total_km': totalKm,
      if (usageCount != null) 'usage_count': usageCount,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
    });
  }

  JeepneyRoutesCompanion copyWith({
    Value<int>? id,
    Value<String>? codeName,
    Value<String>? displayName,
    Value<int>? stopCount,
    Value<int>? totalKm,
    Value<int>? usageCount,
    Value<DateTime?>? lastUsedAt,
  }) {
    return JeepneyRoutesCompanion(
      id: id ?? this.id,
      codeName: codeName ?? this.codeName,
      displayName: displayName ?? this.displayName,
      stopCount: stopCount ?? this.stopCount,
      totalKm: totalKm ?? this.totalKm,
      usageCount: usageCount ?? this.usageCount,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (codeName.present) {
      map['code_name'] = Variable<String>(codeName.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (stopCount.present) {
      map['stop_count'] = Variable<int>(stopCount.value);
    }
    if (totalKm.present) {
      map['total_km'] = Variable<int>(totalKm.value);
    }
    if (usageCount.present) {
      map['usage_count'] = Variable<int>(usageCount.value);
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JeepneyRoutesCompanion(')
          ..write('id: $id, ')
          ..write('codeName: $codeName, ')
          ..write('displayName: $displayName, ')
          ..write('stopCount: $stopCount, ')
          ..write('totalKm: $totalKm, ')
          ..write('usageCount: $usageCount, ')
          ..write('lastUsedAt: $lastUsedAt')
          ..write(')'))
        .toString();
  }
}

class $RouteStopsTable extends RouteStops
    with TableInfo<$RouteStopsTable, RouteStopRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RouteStopsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _routeIdMeta = const VerificationMeta(
    'routeId',
  );
  @override
  late final GeneratedColumn<int> routeId = GeneratedColumn<int>(
    'route_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES jeepney_routes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kmIndexMeta = const VerificationMeta(
    'kmIndex',
  );
  @override
  late final GeneratedColumn<int> kmIndex = GeneratedColumn<int>(
    'km_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, routeId, name, kmIndex, sequence];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'route_stops';
  @override
  VerificationContext validateIntegrity(
    Insertable<RouteStopRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('route_id')) {
      context.handle(
        _routeIdMeta,
        routeId.isAcceptableOrUnknown(data['route_id']!, _routeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routeIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('km_index')) {
      context.handle(
        _kmIndexMeta,
        kmIndex.isAcceptableOrUnknown(data['km_index']!, _kmIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_kmIndexMeta);
    }
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    } else if (isInserting) {
      context.missing(_sequenceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {routeId, sequence},
  ];
  @override
  RouteStopRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RouteStopRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      routeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}route_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kmIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}km_index'],
      )!,
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
    );
  }

  @override
  $RouteStopsTable createAlias(String alias) {
    return $RouteStopsTable(attachedDatabase, alias);
  }
}

class RouteStopRow extends DataClass implements Insertable<RouteStopRow> {
  final int id;
  final int routeId;
  final String name;
  final int kmIndex;
  final int sequence;
  const RouteStopRow({
    required this.id,
    required this.routeId,
    required this.name,
    required this.kmIndex,
    required this.sequence,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['route_id'] = Variable<int>(routeId);
    map['name'] = Variable<String>(name);
    map['km_index'] = Variable<int>(kmIndex);
    map['sequence'] = Variable<int>(sequence);
    return map;
  }

  RouteStopsCompanion toCompanion(bool nullToAbsent) {
    return RouteStopsCompanion(
      id: Value(id),
      routeId: Value(routeId),
      name: Value(name),
      kmIndex: Value(kmIndex),
      sequence: Value(sequence),
    );
  }

  factory RouteStopRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RouteStopRow(
      id: serializer.fromJson<int>(json['id']),
      routeId: serializer.fromJson<int>(json['routeId']),
      name: serializer.fromJson<String>(json['name']),
      kmIndex: serializer.fromJson<int>(json['kmIndex']),
      sequence: serializer.fromJson<int>(json['sequence']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'routeId': serializer.toJson<int>(routeId),
      'name': serializer.toJson<String>(name),
      'kmIndex': serializer.toJson<int>(kmIndex),
      'sequence': serializer.toJson<int>(sequence),
    };
  }

  RouteStopRow copyWith({
    int? id,
    int? routeId,
    String? name,
    int? kmIndex,
    int? sequence,
  }) => RouteStopRow(
    id: id ?? this.id,
    routeId: routeId ?? this.routeId,
    name: name ?? this.name,
    kmIndex: kmIndex ?? this.kmIndex,
    sequence: sequence ?? this.sequence,
  );
  RouteStopRow copyWithCompanion(RouteStopsCompanion data) {
    return RouteStopRow(
      id: data.id.present ? data.id.value : this.id,
      routeId: data.routeId.present ? data.routeId.value : this.routeId,
      name: data.name.present ? data.name.value : this.name,
      kmIndex: data.kmIndex.present ? data.kmIndex.value : this.kmIndex,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RouteStopRow(')
          ..write('id: $id, ')
          ..write('routeId: $routeId, ')
          ..write('name: $name, ')
          ..write('kmIndex: $kmIndex, ')
          ..write('sequence: $sequence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, routeId, name, kmIndex, sequence);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RouteStopRow &&
          other.id == this.id &&
          other.routeId == this.routeId &&
          other.name == this.name &&
          other.kmIndex == this.kmIndex &&
          other.sequence == this.sequence);
}

class RouteStopsCompanion extends UpdateCompanion<RouteStopRow> {
  final Value<int> id;
  final Value<int> routeId;
  final Value<String> name;
  final Value<int> kmIndex;
  final Value<int> sequence;
  const RouteStopsCompanion({
    this.id = const Value.absent(),
    this.routeId = const Value.absent(),
    this.name = const Value.absent(),
    this.kmIndex = const Value.absent(),
    this.sequence = const Value.absent(),
  });
  RouteStopsCompanion.insert({
    this.id = const Value.absent(),
    required int routeId,
    required String name,
    required int kmIndex,
    required int sequence,
  }) : routeId = Value(routeId),
       name = Value(name),
       kmIndex = Value(kmIndex),
       sequence = Value(sequence);
  static Insertable<RouteStopRow> custom({
    Expression<int>? id,
    Expression<int>? routeId,
    Expression<String>? name,
    Expression<int>? kmIndex,
    Expression<int>? sequence,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routeId != null) 'route_id': routeId,
      if (name != null) 'name': name,
      if (kmIndex != null) 'km_index': kmIndex,
      if (sequence != null) 'sequence': sequence,
    });
  }

  RouteStopsCompanion copyWith({
    Value<int>? id,
    Value<int>? routeId,
    Value<String>? name,
    Value<int>? kmIndex,
    Value<int>? sequence,
  }) {
    return RouteStopsCompanion(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      name: name ?? this.name,
      kmIndex: kmIndex ?? this.kmIndex,
      sequence: sequence ?? this.sequence,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (routeId.present) {
      map['route_id'] = Variable<int>(routeId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kmIndex.present) {
      map['km_index'] = Variable<int>(kmIndex.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RouteStopsCompanion(')
          ..write('id: $id, ')
          ..write('routeId: $routeId, ')
          ..write('name: $name, ')
          ..write('kmIndex: $kmIndex, ')
          ..write('sequence: $sequence')
          ..write(')'))
        .toString();
  }
}

class $TripsTable extends Trips with TableInfo<$TripsTable, TripRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _routeIdMeta = const VerificationMeta(
    'routeId',
  );
  @override
  late final GeneratedColumn<int> routeId = GeneratedColumn<int>(
    'route_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES jeepney_routes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _startStopMeta = const VerificationMeta(
    'startStop',
  );
  @override
  late final GeneratedColumn<String> startStop = GeneratedColumn<String>(
    'start_stop',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endStopMeta = const VerificationMeta(
    'endStop',
  );
  @override
  late final GeneratedColumn<String> endStop = GeneratedColumn<String>(
    'end_stop',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distanceKmMeta = const VerificationMeta(
    'distanceKm',
  );
  @override
  late final GeneratedColumn<int> distanceKm = GeneratedColumn<int>(
    'distance_km',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fareCentavosMeta = const VerificationMeta(
    'fareCentavos',
  );
  @override
  late final GeneratedColumn<int> fareCentavos = GeneratedColumn<int>(
    'fare_centavos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _takenAtMeta = const VerificationMeta(
    'takenAt',
  );
  @override
  late final GeneratedColumn<DateTime> takenAt = GeneratedColumn<DateTime>(
    'taken_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    routeId,
    startStop,
    endStop,
    distanceKm,
    fareCentavos,
    category,
    takenAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trips';
  @override
  VerificationContext validateIntegrity(
    Insertable<TripRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('route_id')) {
      context.handle(
        _routeIdMeta,
        routeId.isAcceptableOrUnknown(data['route_id']!, _routeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routeIdMeta);
    }
    if (data.containsKey('start_stop')) {
      context.handle(
        _startStopMeta,
        startStop.isAcceptableOrUnknown(data['start_stop']!, _startStopMeta),
      );
    } else if (isInserting) {
      context.missing(_startStopMeta);
    }
    if (data.containsKey('end_stop')) {
      context.handle(
        _endStopMeta,
        endStop.isAcceptableOrUnknown(data['end_stop']!, _endStopMeta),
      );
    } else if (isInserting) {
      context.missing(_endStopMeta);
    }
    if (data.containsKey('distance_km')) {
      context.handle(
        _distanceKmMeta,
        distanceKm.isAcceptableOrUnknown(data['distance_km']!, _distanceKmMeta),
      );
    } else if (isInserting) {
      context.missing(_distanceKmMeta);
    }
    if (data.containsKey('fare_centavos')) {
      context.handle(
        _fareCentavosMeta,
        fareCentavos.isAcceptableOrUnknown(
          data['fare_centavos']!,
          _fareCentavosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fareCentavosMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('taken_at')) {
      context.handle(
        _takenAtMeta,
        takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta),
      );
    } else if (isInserting) {
      context.missing(_takenAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TripRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      routeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}route_id'],
      )!,
      startStop: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_stop'],
      )!,
      endStop: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_stop'],
      )!,
      distanceKm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}distance_km'],
      )!,
      fareCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fare_centavos'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      takenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}taken_at'],
      )!,
    );
  }

  @override
  $TripsTable createAlias(String alias) {
    return $TripsTable(attachedDatabase, alias);
  }
}

class TripRow extends DataClass implements Insertable<TripRow> {
  final int id;
  final int routeId;
  final String startStop;
  final String endStop;
  final int distanceKm;
  final int fareCentavos;
  final String category;
  final DateTime takenAt;
  const TripRow({
    required this.id,
    required this.routeId,
    required this.startStop,
    required this.endStop,
    required this.distanceKm,
    required this.fareCentavos,
    required this.category,
    required this.takenAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['route_id'] = Variable<int>(routeId);
    map['start_stop'] = Variable<String>(startStop);
    map['end_stop'] = Variable<String>(endStop);
    map['distance_km'] = Variable<int>(distanceKm);
    map['fare_centavos'] = Variable<int>(fareCentavos);
    map['category'] = Variable<String>(category);
    map['taken_at'] = Variable<DateTime>(takenAt);
    return map;
  }

  TripsCompanion toCompanion(bool nullToAbsent) {
    return TripsCompanion(
      id: Value(id),
      routeId: Value(routeId),
      startStop: Value(startStop),
      endStop: Value(endStop),
      distanceKm: Value(distanceKm),
      fareCentavos: Value(fareCentavos),
      category: Value(category),
      takenAt: Value(takenAt),
    );
  }

  factory TripRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripRow(
      id: serializer.fromJson<int>(json['id']),
      routeId: serializer.fromJson<int>(json['routeId']),
      startStop: serializer.fromJson<String>(json['startStop']),
      endStop: serializer.fromJson<String>(json['endStop']),
      distanceKm: serializer.fromJson<int>(json['distanceKm']),
      fareCentavos: serializer.fromJson<int>(json['fareCentavos']),
      category: serializer.fromJson<String>(json['category']),
      takenAt: serializer.fromJson<DateTime>(json['takenAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'routeId': serializer.toJson<int>(routeId),
      'startStop': serializer.toJson<String>(startStop),
      'endStop': serializer.toJson<String>(endStop),
      'distanceKm': serializer.toJson<int>(distanceKm),
      'fareCentavos': serializer.toJson<int>(fareCentavos),
      'category': serializer.toJson<String>(category),
      'takenAt': serializer.toJson<DateTime>(takenAt),
    };
  }

  TripRow copyWith({
    int? id,
    int? routeId,
    String? startStop,
    String? endStop,
    int? distanceKm,
    int? fareCentavos,
    String? category,
    DateTime? takenAt,
  }) => TripRow(
    id: id ?? this.id,
    routeId: routeId ?? this.routeId,
    startStop: startStop ?? this.startStop,
    endStop: endStop ?? this.endStop,
    distanceKm: distanceKm ?? this.distanceKm,
    fareCentavos: fareCentavos ?? this.fareCentavos,
    category: category ?? this.category,
    takenAt: takenAt ?? this.takenAt,
  );
  TripRow copyWithCompanion(TripsCompanion data) {
    return TripRow(
      id: data.id.present ? data.id.value : this.id,
      routeId: data.routeId.present ? data.routeId.value : this.routeId,
      startStop: data.startStop.present ? data.startStop.value : this.startStop,
      endStop: data.endStop.present ? data.endStop.value : this.endStop,
      distanceKm: data.distanceKm.present
          ? data.distanceKm.value
          : this.distanceKm,
      fareCentavos: data.fareCentavos.present
          ? data.fareCentavos.value
          : this.fareCentavos,
      category: data.category.present ? data.category.value : this.category,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripRow(')
          ..write('id: $id, ')
          ..write('routeId: $routeId, ')
          ..write('startStop: $startStop, ')
          ..write('endStop: $endStop, ')
          ..write('distanceKm: $distanceKm, ')
          ..write('fareCentavos: $fareCentavos, ')
          ..write('category: $category, ')
          ..write('takenAt: $takenAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    routeId,
    startStop,
    endStop,
    distanceKm,
    fareCentavos,
    category,
    takenAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripRow &&
          other.id == this.id &&
          other.routeId == this.routeId &&
          other.startStop == this.startStop &&
          other.endStop == this.endStop &&
          other.distanceKm == this.distanceKm &&
          other.fareCentavos == this.fareCentavos &&
          other.category == this.category &&
          other.takenAt == this.takenAt);
}

class TripsCompanion extends UpdateCompanion<TripRow> {
  final Value<int> id;
  final Value<int> routeId;
  final Value<String> startStop;
  final Value<String> endStop;
  final Value<int> distanceKm;
  final Value<int> fareCentavos;
  final Value<String> category;
  final Value<DateTime> takenAt;
  const TripsCompanion({
    this.id = const Value.absent(),
    this.routeId = const Value.absent(),
    this.startStop = const Value.absent(),
    this.endStop = const Value.absent(),
    this.distanceKm = const Value.absent(),
    this.fareCentavos = const Value.absent(),
    this.category = const Value.absent(),
    this.takenAt = const Value.absent(),
  });
  TripsCompanion.insert({
    this.id = const Value.absent(),
    required int routeId,
    required String startStop,
    required String endStop,
    required int distanceKm,
    required int fareCentavos,
    required String category,
    required DateTime takenAt,
  }) : routeId = Value(routeId),
       startStop = Value(startStop),
       endStop = Value(endStop),
       distanceKm = Value(distanceKm),
       fareCentavos = Value(fareCentavos),
       category = Value(category),
       takenAt = Value(takenAt);
  static Insertable<TripRow> custom({
    Expression<int>? id,
    Expression<int>? routeId,
    Expression<String>? startStop,
    Expression<String>? endStop,
    Expression<int>? distanceKm,
    Expression<int>? fareCentavos,
    Expression<String>? category,
    Expression<DateTime>? takenAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routeId != null) 'route_id': routeId,
      if (startStop != null) 'start_stop': startStop,
      if (endStop != null) 'end_stop': endStop,
      if (distanceKm != null) 'distance_km': distanceKm,
      if (fareCentavos != null) 'fare_centavos': fareCentavos,
      if (category != null) 'category': category,
      if (takenAt != null) 'taken_at': takenAt,
    });
  }

  TripsCompanion copyWith({
    Value<int>? id,
    Value<int>? routeId,
    Value<String>? startStop,
    Value<String>? endStop,
    Value<int>? distanceKm,
    Value<int>? fareCentavos,
    Value<String>? category,
    Value<DateTime>? takenAt,
  }) {
    return TripsCompanion(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      startStop: startStop ?? this.startStop,
      endStop: endStop ?? this.endStop,
      distanceKm: distanceKm ?? this.distanceKm,
      fareCentavos: fareCentavos ?? this.fareCentavos,
      category: category ?? this.category,
      takenAt: takenAt ?? this.takenAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (routeId.present) {
      map['route_id'] = Variable<int>(routeId.value);
    }
    if (startStop.present) {
      map['start_stop'] = Variable<String>(startStop.value);
    }
    if (endStop.present) {
      map['end_stop'] = Variable<String>(endStop.value);
    }
    if (distanceKm.present) {
      map['distance_km'] = Variable<int>(distanceKm.value);
    }
    if (fareCentavos.present) {
      map['fare_centavos'] = Variable<int>(fareCentavos.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<DateTime>(takenAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripsCompanion(')
          ..write('id: $id, ')
          ..write('routeId: $routeId, ')
          ..write('startStop: $startStop, ')
          ..write('endStop: $endStop, ')
          ..write('distanceKm: $distanceKm, ')
          ..write('fareCentavos: $fareCentavos, ')
          ..write('category: $category, ')
          ..write('takenAt: $takenAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $JeepneyRoutesTable jeepneyRoutes = $JeepneyRoutesTable(this);
  late final $RouteStopsTable routeStops = $RouteStopsTable(this);
  late final $TripsTable trips = $TripsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    jeepneyRoutes,
    routeStops,
    trips,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'jeepney_routes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('route_stops', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'jeepney_routes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('trips', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$JeepneyRoutesTableCreateCompanionBuilder =
    JeepneyRoutesCompanion Function({
      Value<int> id,
      required String codeName,
      required String displayName,
      required int stopCount,
      required int totalKm,
      Value<int> usageCount,
      Value<DateTime?> lastUsedAt,
    });
typedef $$JeepneyRoutesTableUpdateCompanionBuilder =
    JeepneyRoutesCompanion Function({
      Value<int> id,
      Value<String> codeName,
      Value<String> displayName,
      Value<int> stopCount,
      Value<int> totalKm,
      Value<int> usageCount,
      Value<DateTime?> lastUsedAt,
    });

final class $$JeepneyRoutesTableReferences
    extends
        BaseReferences<_$AppDatabase, $JeepneyRoutesTable, JeepneyRouteRow> {
  $$JeepneyRoutesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$RouteStopsTable, List<RouteStopRow>>
  _routeStopsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.routeStops,
    aliasName: 'jeepney_routes__id__route_stops__route_id',
  );

  $$RouteStopsTableProcessedTableManager get routeStopsRefs {
    final manager = $$RouteStopsTableTableManager(
      $_db,
      $_db.routeStops,
    ).filter((f) => f.routeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_routeStopsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TripsTable, List<TripRow>> _tripsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.trips,
    aliasName: 'jeepney_routes__id__trips__route_id',
  );

  $$TripsTableProcessedTableManager get tripsRefs {
    final manager = $$TripsTableTableManager(
      $_db,
      $_db.trips,
    ).filter((f) => f.routeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tripsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$JeepneyRoutesTableFilterComposer
    extends Composer<_$AppDatabase, $JeepneyRoutesTable> {
  $$JeepneyRoutesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codeName => $composableBuilder(
    column: $table.codeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stopCount => $composableBuilder(
    column: $table.stopCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalKm => $composableBuilder(
    column: $table.totalKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> routeStopsRefs(
    Expression<bool> Function($$RouteStopsTableFilterComposer f) f,
  ) {
    final $$RouteStopsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routeStops,
      getReferencedColumn: (t) => t.routeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RouteStopsTableFilterComposer(
            $db: $db,
            $table: $db.routeStops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tripsRefs(
    Expression<bool> Function($$TripsTableFilterComposer f) f,
  ) {
    final $$TripsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.routeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableFilterComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$JeepneyRoutesTableOrderingComposer
    extends Composer<_$AppDatabase, $JeepneyRoutesTable> {
  $$JeepneyRoutesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codeName => $composableBuilder(
    column: $table.codeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stopCount => $composableBuilder(
    column: $table.stopCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalKm => $composableBuilder(
    column: $table.totalKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JeepneyRoutesTableAnnotationComposer
    extends Composer<_$AppDatabase, $JeepneyRoutesTable> {
  $$JeepneyRoutesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get codeName =>
      $composableBuilder(column: $table.codeName, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stopCount =>
      $composableBuilder(column: $table.stopCount, builder: (column) => column);

  GeneratedColumn<int> get totalKm =>
      $composableBuilder(column: $table.totalKm, builder: (column) => column);

  GeneratedColumn<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => column,
  );

  Expression<T> routeStopsRefs<T extends Object>(
    Expression<T> Function($$RouteStopsTableAnnotationComposer a) f,
  ) {
    final $$RouteStopsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routeStops,
      getReferencedColumn: (t) => t.routeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RouteStopsTableAnnotationComposer(
            $db: $db,
            $table: $db.routeStops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tripsRefs<T extends Object>(
    Expression<T> Function($$TripsTableAnnotationComposer a) f,
  ) {
    final $$TripsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.routeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableAnnotationComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$JeepneyRoutesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JeepneyRoutesTable,
          JeepneyRouteRow,
          $$JeepneyRoutesTableFilterComposer,
          $$JeepneyRoutesTableOrderingComposer,
          $$JeepneyRoutesTableAnnotationComposer,
          $$JeepneyRoutesTableCreateCompanionBuilder,
          $$JeepneyRoutesTableUpdateCompanionBuilder,
          (JeepneyRouteRow, $$JeepneyRoutesTableReferences),
          JeepneyRouteRow,
          PrefetchHooks Function({bool routeStopsRefs, bool tripsRefs})
        > {
  $$JeepneyRoutesTableTableManager(_$AppDatabase db, $JeepneyRoutesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JeepneyRoutesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JeepneyRoutesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JeepneyRoutesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> codeName = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<int> stopCount = const Value.absent(),
                Value<int> totalKm = const Value.absent(),
                Value<int> usageCount = const Value.absent(),
                Value<DateTime?> lastUsedAt = const Value.absent(),
              }) => JeepneyRoutesCompanion(
                id: id,
                codeName: codeName,
                displayName: displayName,
                stopCount: stopCount,
                totalKm: totalKm,
                usageCount: usageCount,
                lastUsedAt: lastUsedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String codeName,
                required String displayName,
                required int stopCount,
                required int totalKm,
                Value<int> usageCount = const Value.absent(),
                Value<DateTime?> lastUsedAt = const Value.absent(),
              }) => JeepneyRoutesCompanion.insert(
                id: id,
                codeName: codeName,
                displayName: displayName,
                stopCount: stopCount,
                totalKm: totalKm,
                usageCount: usageCount,
                lastUsedAt: lastUsedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$JeepneyRoutesTable, JeepneyRouteRow>(table),
                  $$JeepneyRoutesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({routeStopsRefs = false, tripsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (routeStopsRefs) db.routeStops,
                if (tripsRefs) db.trips,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (routeStopsRefs)
                    await $_getPrefetchedData<
                      JeepneyRouteRow,
                      $JeepneyRoutesTable,
                      RouteStopRow
                    >(
                      currentTable: table,
                      referencedTable: $$JeepneyRoutesTableReferences
                          ._routeStopsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$JeepneyRoutesTableReferences(
                            db,
                            table,
                            p0,
                          ).routeStopsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.routeId == item.id),
                      typedResults: items,
                    ),
                  if (tripsRefs)
                    await $_getPrefetchedData<
                      JeepneyRouteRow,
                      $JeepneyRoutesTable,
                      TripRow
                    >(
                      currentTable: table,
                      referencedTable: $$JeepneyRoutesTableReferences
                          ._tripsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$JeepneyRoutesTableReferences(
                            db,
                            table,
                            p0,
                          ).tripsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.routeId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$JeepneyRoutesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JeepneyRoutesTable,
      JeepneyRouteRow,
      $$JeepneyRoutesTableFilterComposer,
      $$JeepneyRoutesTableOrderingComposer,
      $$JeepneyRoutesTableAnnotationComposer,
      $$JeepneyRoutesTableCreateCompanionBuilder,
      $$JeepneyRoutesTableUpdateCompanionBuilder,
      (JeepneyRouteRow, $$JeepneyRoutesTableReferences),
      JeepneyRouteRow,
      PrefetchHooks Function({bool routeStopsRefs, bool tripsRefs})
    >;
typedef $$RouteStopsTableCreateCompanionBuilder = RouteStopsCompanion Function({
  Value<int> id,
  required int routeId,
  required String name,
  required int kmIndex,
  required int sequence,
});
typedef $$RouteStopsTableUpdateCompanionBuilder = RouteStopsCompanion Function({
  Value<int> id,
  Value<int> routeId,
  Value<String> name,
  Value<int> kmIndex,
  Value<int> sequence,
});

final class $$RouteStopsTableReferences
    extends BaseReferences<_$AppDatabase, $RouteStopsTable, RouteStopRow> {
  $$RouteStopsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $JeepneyRoutesTable _routeIdTable(_$AppDatabase db) =>
      db.jeepneyRoutes.createAlias('route_stops__route_id__jeepney_routes__id');

  $$JeepneyRoutesTableProcessedTableManager get routeId {
    final $_column = $_itemColumn<int>('route_id')!;

    final manager = $$JeepneyRoutesTableTableManager(
      $_db,
      $_db.jeepneyRoutes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RouteStopsTableFilterComposer
    extends Composer<_$AppDatabase, $RouteStopsTable> {
  $$RouteStopsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get kmIndex => $composableBuilder(
    column: $table.kmIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  $$JeepneyRoutesTableFilterComposer get routeId {
    final $$JeepneyRoutesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routeId,
      referencedTable: $db.jeepneyRoutes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JeepneyRoutesTableFilterComposer(
            $db: $db,
            $table: $db.jeepneyRoutes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RouteStopsTableOrderingComposer
    extends Composer<_$AppDatabase, $RouteStopsTable> {
  $$RouteStopsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get kmIndex => $composableBuilder(
    column: $table.kmIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  $$JeepneyRoutesTableOrderingComposer get routeId {
    final $$JeepneyRoutesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routeId,
      referencedTable: $db.jeepneyRoutes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JeepneyRoutesTableOrderingComposer(
            $db: $db,
            $table: $db.jeepneyRoutes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RouteStopsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RouteStopsTable> {
  $$RouteStopsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get kmIndex =>
      $composableBuilder(column: $table.kmIndex, builder: (column) => column);

  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  $$JeepneyRoutesTableAnnotationComposer get routeId {
    final $$JeepneyRoutesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routeId,
      referencedTable: $db.jeepneyRoutes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JeepneyRoutesTableAnnotationComposer(
            $db: $db,
            $table: $db.jeepneyRoutes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RouteStopsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RouteStopsTable,
          RouteStopRow,
          $$RouteStopsTableFilterComposer,
          $$RouteStopsTableOrderingComposer,
          $$RouteStopsTableAnnotationComposer,
          $$RouteStopsTableCreateCompanionBuilder,
          $$RouteStopsTableUpdateCompanionBuilder,
          (RouteStopRow, $$RouteStopsTableReferences),
          RouteStopRow,
          PrefetchHooks Function({bool routeId})
        > {
  $$RouteStopsTableTableManager(_$AppDatabase db, $RouteStopsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RouteStopsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RouteStopsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RouteStopsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> routeId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> kmIndex = const Value.absent(),
                Value<int> sequence = const Value.absent(),
              }) => RouteStopsCompanion(
                id: id,
                routeId: routeId,
                name: name,
                kmIndex: kmIndex,
                sequence: sequence,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int routeId,
                required String name,
                required int kmIndex,
                required int sequence,
              }) => RouteStopsCompanion.insert(
                id: id,
                routeId: routeId,
                name: name,
                kmIndex: kmIndex,
                sequence: sequence,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RouteStopsTable, RouteStopRow>(table),
                  $$RouteStopsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({routeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (routeId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.routeId,
                        referencedTable: $$RouteStopsTableReferences
                            ._routeIdTable(db),
                        referencedColumn: $$RouteStopsTableReferences
                            ._routeIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RouteStopsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RouteStopsTable,
      RouteStopRow,
      $$RouteStopsTableFilterComposer,
      $$RouteStopsTableOrderingComposer,
      $$RouteStopsTableAnnotationComposer,
      $$RouteStopsTableCreateCompanionBuilder,
      $$RouteStopsTableUpdateCompanionBuilder,
      (RouteStopRow, $$RouteStopsTableReferences),
      RouteStopRow,
      PrefetchHooks Function({bool routeId})
    >;
typedef $$TripsTableCreateCompanionBuilder = TripsCompanion Function({
  Value<int> id,
  required int routeId,
  required String startStop,
  required String endStop,
  required int distanceKm,
  required int fareCentavos,
  required String category,
  required DateTime takenAt,
});
typedef $$TripsTableUpdateCompanionBuilder = TripsCompanion Function({
  Value<int> id,
  Value<int> routeId,
  Value<String> startStop,
  Value<String> endStop,
  Value<int> distanceKm,
  Value<int> fareCentavos,
  Value<String> category,
  Value<DateTime> takenAt,
});

final class $$TripsTableReferences
    extends BaseReferences<_$AppDatabase, $TripsTable, TripRow> {
  $$TripsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $JeepneyRoutesTable _routeIdTable(_$AppDatabase db) =>
      db.jeepneyRoutes.createAlias('trips__route_id__jeepney_routes__id');

  $$JeepneyRoutesTableProcessedTableManager get routeId {
    final $_column = $_itemColumn<int>('route_id')!;

    final manager = $$JeepneyRoutesTableTableManager(
      $_db,
      $_db.jeepneyRoutes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TripsTableFilterComposer extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startStop => $composableBuilder(
    column: $table.startStop,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endStop => $composableBuilder(
    column: $table.endStop,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get distanceKm => $composableBuilder(
    column: $table.distanceKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fareCentavos => $composableBuilder(
    column: $table.fareCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnFilters(column),
  );

  $$JeepneyRoutesTableFilterComposer get routeId {
    final $$JeepneyRoutesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routeId,
      referencedTable: $db.jeepneyRoutes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JeepneyRoutesTableFilterComposer(
            $db: $db,
            $table: $db.jeepneyRoutes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TripsTableOrderingComposer
    extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startStop => $composableBuilder(
    column: $table.startStop,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endStop => $composableBuilder(
    column: $table.endStop,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get distanceKm => $composableBuilder(
    column: $table.distanceKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fareCentavos => $composableBuilder(
    column: $table.fareCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$JeepneyRoutesTableOrderingComposer get routeId {
    final $$JeepneyRoutesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routeId,
      referencedTable: $db.jeepneyRoutes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JeepneyRoutesTableOrderingComposer(
            $db: $db,
            $table: $db.jeepneyRoutes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TripsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get startStop =>
      $composableBuilder(column: $table.startStop, builder: (column) => column);

  GeneratedColumn<String> get endStop =>
      $composableBuilder(column: $table.endStop, builder: (column) => column);

  GeneratedColumn<int> get distanceKm => $composableBuilder(
    column: $table.distanceKm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fareCentavos => $composableBuilder(
    column: $table.fareCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<DateTime> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => column);

  $$JeepneyRoutesTableAnnotationComposer get routeId {
    final $$JeepneyRoutesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routeId,
      referencedTable: $db.jeepneyRoutes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JeepneyRoutesTableAnnotationComposer(
            $db: $db,
            $table: $db.jeepneyRoutes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TripsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripsTable,
          TripRow,
          $$TripsTableFilterComposer,
          $$TripsTableOrderingComposer,
          $$TripsTableAnnotationComposer,
          $$TripsTableCreateCompanionBuilder,
          $$TripsTableUpdateCompanionBuilder,
          (TripRow, $$TripsTableReferences),
          TripRow,
          PrefetchHooks Function({bool routeId})
        > {
  $$TripsTableTableManager(_$AppDatabase db, $TripsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> routeId = const Value.absent(),
                Value<String> startStop = const Value.absent(),
                Value<String> endStop = const Value.absent(),
                Value<int> distanceKm = const Value.absent(),
                Value<int> fareCentavos = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<DateTime> takenAt = const Value.absent(),
              }) => TripsCompanion(
                id: id,
                routeId: routeId,
                startStop: startStop,
                endStop: endStop,
                distanceKm: distanceKm,
                fareCentavos: fareCentavos,
                category: category,
                takenAt: takenAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int routeId,
                required String startStop,
                required String endStop,
                required int distanceKm,
                required int fareCentavos,
                required String category,
                required DateTime takenAt,
              }) => TripsCompanion.insert(
                id: id,
                routeId: routeId,
                startStop: startStop,
                endStop: endStop,
                distanceKm: distanceKm,
                fareCentavos: fareCentavos,
                category: category,
                takenAt: takenAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TripsTable, TripRow>(table),
                  $$TripsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({routeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (routeId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.routeId,
                        referencedTable: $$TripsTableReferences._routeIdTable(
                          db,
                        ),
                        referencedColumn: $$TripsTableReferences
                            ._routeIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TripsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripsTable,
      TripRow,
      $$TripsTableFilterComposer,
      $$TripsTableOrderingComposer,
      $$TripsTableAnnotationComposer,
      $$TripsTableCreateCompanionBuilder,
      $$TripsTableUpdateCompanionBuilder,
      (TripRow, $$TripsTableReferences),
      TripRow,
      PrefetchHooks Function({bool routeId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$JeepneyRoutesTableTableManager get jeepneyRoutes =>
      $$JeepneyRoutesTableTableManager(_db, _db.jeepneyRoutes);
  $$RouteStopsTableTableManager get routeStops =>
      $$RouteStopsTableTableManager(_db, _db.routeStops);
  $$TripsTableTableManager get trips =>
      $$TripsTableTableManager(_db, _db.trips);
}
