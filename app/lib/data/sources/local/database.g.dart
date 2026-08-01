// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ServersTable extends Servers with TableInfo<$ServersTable, Server> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _agentUrlMeta =
      const VerificationMeta('agentUrl');
  @override
  late final GeneratedColumn<String> agentUrl = GeneratedColumn<String>(
      'agent_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _groupNameMeta =
      const VerificationMeta('groupName');
  @override
  late final GeneratedColumn<String> groupName = GeneratedColumn<String>(
      'group_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _readOnlyMeta =
      const VerificationMeta('readOnly');
  @override
  late final GeneratedColumn<bool> readOnly = GeneratedColumn<bool>(
      'read_only', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("read_only" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _fingerprintHashMeta =
      const VerificationMeta('fingerprintHash');
  @override
  late final GeneratedColumn<String> fingerprintHash = GeneratedColumn<String>(
      'fingerprint_hash', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('unknown'));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _lastSeenAtMeta =
      const VerificationMeta('lastSeenAt');
  @override
  late final GeneratedColumn<DateTime> lastSeenAt = GeneratedColumn<DateTime>(
      'last_seen_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _agentVersionMeta =
      const VerificationMeta('agentVersion');
  @override
  late final GeneratedColumn<String> agentVersion = GeneratedColumn<String>(
      'agent_version', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _capsJsonMeta =
      const VerificationMeta('capsJson');
  @override
  late final GeneratedColumn<String> capsJson = GeneratedColumn<String>(
      'caps_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        agentUrl,
        groupName,
        readOnly,
        fingerprintHash,
        status,
        deviceId,
        lastSeenAt,
        createdAt,
        agentVersion,
        capsJson
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'servers';
  @override
  VerificationContext validateIntegrity(Insertable<Server> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('agent_url')) {
      context.handle(_agentUrlMeta,
          agentUrl.isAcceptableOrUnknown(data['agent_url']!, _agentUrlMeta));
    } else if (isInserting) {
      context.missing(_agentUrlMeta);
    }
    if (data.containsKey('group_name')) {
      context.handle(_groupNameMeta,
          groupName.isAcceptableOrUnknown(data['group_name']!, _groupNameMeta));
    }
    if (data.containsKey('read_only')) {
      context.handle(_readOnlyMeta,
          readOnly.isAcceptableOrUnknown(data['read_only']!, _readOnlyMeta));
    }
    if (data.containsKey('fingerprint_hash')) {
      context.handle(
          _fingerprintHashMeta,
          fingerprintHash.isAcceptableOrUnknown(
              data['fingerprint_hash']!, _fingerprintHashMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
          _lastSeenAtMeta,
          lastSeenAt.isAcceptableOrUnknown(
              data['last_seen_at']!, _lastSeenAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('agent_version')) {
      context.handle(
          _agentVersionMeta,
          agentVersion.isAcceptableOrUnknown(
              data['agent_version']!, _agentVersionMeta));
    }
    if (data.containsKey('caps_json')) {
      context.handle(_capsJsonMeta,
          capsJson.isAcceptableOrUnknown(data['caps_json']!, _capsJsonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Server map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Server(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      agentUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}agent_url'])!,
      groupName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_name'])!,
      readOnly: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}read_only'])!,
      fingerprintHash: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}fingerprint_hash'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      lastSeenAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_seen_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      agentVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}agent_version'])!,
      capsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}caps_json'])!,
    );
  }

  @override
  $ServersTable createAlias(String alias) {
    return $ServersTable(attachedDatabase, alias);
  }
}

class Server extends DataClass implements Insertable<Server> {
  final String id;
  final String name;
  final String agentUrl;
  final String groupName;
  final bool readOnly;
  final String fingerprintHash;
  final String status;
  final String deviceId;
  final DateTime? lastSeenAt;
  final DateTime createdAt;
  final String agentVersion;
  final String capsJson;
  const Server(
      {required this.id,
      required this.name,
      required this.agentUrl,
      required this.groupName,
      required this.readOnly,
      required this.fingerprintHash,
      required this.status,
      required this.deviceId,
      this.lastSeenAt,
      required this.createdAt,
      required this.agentVersion,
      required this.capsJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['agent_url'] = Variable<String>(agentUrl);
    map['group_name'] = Variable<String>(groupName);
    map['read_only'] = Variable<bool>(readOnly);
    map['fingerprint_hash'] = Variable<String>(fingerprintHash);
    map['status'] = Variable<String>(status);
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || lastSeenAt != null) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['agent_version'] = Variable<String>(agentVersion);
    map['caps_json'] = Variable<String>(capsJson);
    return map;
  }

  ServersCompanion toCompanion(bool nullToAbsent) {
    return ServersCompanion(
      id: Value(id),
      name: Value(name),
      agentUrl: Value(agentUrl),
      groupName: Value(groupName),
      readOnly: Value(readOnly),
      fingerprintHash: Value(fingerprintHash),
      status: Value(status),
      deviceId: Value(deviceId),
      lastSeenAt: lastSeenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeenAt),
      createdAt: Value(createdAt),
      agentVersion: Value(agentVersion),
      capsJson: Value(capsJson),
    );
  }

  factory Server.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Server(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      agentUrl: serializer.fromJson<String>(json['agentUrl']),
      groupName: serializer.fromJson<String>(json['groupName']),
      readOnly: serializer.fromJson<bool>(json['readOnly']),
      fingerprintHash: serializer.fromJson<String>(json['fingerprintHash']),
      status: serializer.fromJson<String>(json['status']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      lastSeenAt: serializer.fromJson<DateTime?>(json['lastSeenAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      agentVersion: serializer.fromJson<String>(json['agentVersion']),
      capsJson: serializer.fromJson<String>(json['capsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'agentUrl': serializer.toJson<String>(agentUrl),
      'groupName': serializer.toJson<String>(groupName),
      'readOnly': serializer.toJson<bool>(readOnly),
      'fingerprintHash': serializer.toJson<String>(fingerprintHash),
      'status': serializer.toJson<String>(status),
      'deviceId': serializer.toJson<String>(deviceId),
      'lastSeenAt': serializer.toJson<DateTime?>(lastSeenAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'agentVersion': serializer.toJson<String>(agentVersion),
      'capsJson': serializer.toJson<String>(capsJson),
    };
  }

  Server copyWith(
          {String? id,
          String? name,
          String? agentUrl,
          String? groupName,
          bool? readOnly,
          String? fingerprintHash,
          String? status,
          String? deviceId,
          Value<DateTime?> lastSeenAt = const Value.absent(),
          DateTime? createdAt,
          String? agentVersion,
          String? capsJson}) =>
      Server(
        id: id ?? this.id,
        name: name ?? this.name,
        agentUrl: agentUrl ?? this.agentUrl,
        groupName: groupName ?? this.groupName,
        readOnly: readOnly ?? this.readOnly,
        fingerprintHash: fingerprintHash ?? this.fingerprintHash,
        status: status ?? this.status,
        deviceId: deviceId ?? this.deviceId,
        lastSeenAt: lastSeenAt.present ? lastSeenAt.value : this.lastSeenAt,
        createdAt: createdAt ?? this.createdAt,
        agentVersion: agentVersion ?? this.agentVersion,
        capsJson: capsJson ?? this.capsJson,
      );
  Server copyWithCompanion(ServersCompanion data) {
    return Server(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      agentUrl: data.agentUrl.present ? data.agentUrl.value : this.agentUrl,
      groupName: data.groupName.present ? data.groupName.value : this.groupName,
      readOnly: data.readOnly.present ? data.readOnly.value : this.readOnly,
      fingerprintHash: data.fingerprintHash.present
          ? data.fingerprintHash.value
          : this.fingerprintHash,
      status: data.status.present ? data.status.value : this.status,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      lastSeenAt:
          data.lastSeenAt.present ? data.lastSeenAt.value : this.lastSeenAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      agentVersion: data.agentVersion.present
          ? data.agentVersion.value
          : this.agentVersion,
      capsJson: data.capsJson.present ? data.capsJson.value : this.capsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Server(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('agentUrl: $agentUrl, ')
          ..write('groupName: $groupName, ')
          ..write('readOnly: $readOnly, ')
          ..write('fingerprintHash: $fingerprintHash, ')
          ..write('status: $status, ')
          ..write('deviceId: $deviceId, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('agentVersion: $agentVersion, ')
          ..write('capsJson: $capsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      agentUrl,
      groupName,
      readOnly,
      fingerprintHash,
      status,
      deviceId,
      lastSeenAt,
      createdAt,
      agentVersion,
      capsJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Server &&
          other.id == this.id &&
          other.name == this.name &&
          other.agentUrl == this.agentUrl &&
          other.groupName == this.groupName &&
          other.readOnly == this.readOnly &&
          other.fingerprintHash == this.fingerprintHash &&
          other.status == this.status &&
          other.deviceId == this.deviceId &&
          other.lastSeenAt == this.lastSeenAt &&
          other.createdAt == this.createdAt &&
          other.agentVersion == this.agentVersion &&
          other.capsJson == this.capsJson);
}

class ServersCompanion extends UpdateCompanion<Server> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> agentUrl;
  final Value<String> groupName;
  final Value<bool> readOnly;
  final Value<String> fingerprintHash;
  final Value<String> status;
  final Value<String> deviceId;
  final Value<DateTime?> lastSeenAt;
  final Value<DateTime> createdAt;
  final Value<String> agentVersion;
  final Value<String> capsJson;
  final Value<int> rowid;
  const ServersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.agentUrl = const Value.absent(),
    this.groupName = const Value.absent(),
    this.readOnly = const Value.absent(),
    this.fingerprintHash = const Value.absent(),
    this.status = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.agentVersion = const Value.absent(),
    this.capsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ServersCompanion.insert({
    required String id,
    required String name,
    required String agentUrl,
    this.groupName = const Value.absent(),
    this.readOnly = const Value.absent(),
    this.fingerprintHash = const Value.absent(),
    this.status = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    required DateTime createdAt,
    this.agentVersion = const Value.absent(),
    this.capsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        agentUrl = Value(agentUrl),
        createdAt = Value(createdAt);
  static Insertable<Server> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? agentUrl,
    Expression<String>? groupName,
    Expression<bool>? readOnly,
    Expression<String>? fingerprintHash,
    Expression<String>? status,
    Expression<String>? deviceId,
    Expression<DateTime>? lastSeenAt,
    Expression<DateTime>? createdAt,
    Expression<String>? agentVersion,
    Expression<String>? capsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (agentUrl != null) 'agent_url': agentUrl,
      if (groupName != null) 'group_name': groupName,
      if (readOnly != null) 'read_only': readOnly,
      if (fingerprintHash != null) 'fingerprint_hash': fingerprintHash,
      if (status != null) 'status': status,
      if (deviceId != null) 'device_id': deviceId,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (createdAt != null) 'created_at': createdAt,
      if (agentVersion != null) 'agent_version': agentVersion,
      if (capsJson != null) 'caps_json': capsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ServersCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? agentUrl,
      Value<String>? groupName,
      Value<bool>? readOnly,
      Value<String>? fingerprintHash,
      Value<String>? status,
      Value<String>? deviceId,
      Value<DateTime?>? lastSeenAt,
      Value<DateTime>? createdAt,
      Value<String>? agentVersion,
      Value<String>? capsJson,
      Value<int>? rowid}) {
    return ServersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      agentUrl: agentUrl ?? this.agentUrl,
      groupName: groupName ?? this.groupName,
      readOnly: readOnly ?? this.readOnly,
      fingerprintHash: fingerprintHash ?? this.fingerprintHash,
      status: status ?? this.status,
      deviceId: deviceId ?? this.deviceId,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      createdAt: createdAt ?? this.createdAt,
      agentVersion: agentVersion ?? this.agentVersion,
      capsJson: capsJson ?? this.capsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (agentUrl.present) {
      map['agent_url'] = Variable<String>(agentUrl.value);
    }
    if (groupName.present) {
      map['group_name'] = Variable<String>(groupName.value);
    }
    if (readOnly.present) {
      map['read_only'] = Variable<bool>(readOnly.value);
    }
    if (fingerprintHash.present) {
      map['fingerprint_hash'] = Variable<String>(fingerprintHash.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (agentVersion.present) {
      map['agent_version'] = Variable<String>(agentVersion.value);
    }
    if (capsJson.present) {
      map['caps_json'] = Variable<String>(capsJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('agentUrl: $agentUrl, ')
          ..write('groupName: $groupName, ')
          ..write('readOnly: $readOnly, ')
          ..write('fingerprintHash: $fingerprintHash, ')
          ..write('status: $status, ')
          ..write('deviceId: $deviceId, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('agentVersion: $agentVersion, ')
          ..write('capsJson: $capsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MetricSamplesTable extends MetricSamples
    with TableInfo<$MetricSamplesTable, MetricSample> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetricSamplesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES servers (id)'));
  static const VerificationMeta _tsMeta = const VerificationMeta('ts');
  @override
  late final GeneratedColumn<DateTime> ts = GeneratedColumn<DateTime>(
      'ts', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _cpuPercentMeta =
      const VerificationMeta('cpuPercent');
  @override
  late final GeneratedColumn<double> cpuPercent = GeneratedColumn<double>(
      'cpu_percent', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _memPercentMeta =
      const VerificationMeta('memPercent');
  @override
  late final GeneratedColumn<double> memPercent = GeneratedColumn<double>(
      'mem_percent', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _diskPercentMeta =
      const VerificationMeta('diskPercent');
  @override
  late final GeneratedColumn<double> diskPercent = GeneratedColumn<double>(
      'disk_percent', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _netRxBpsMeta =
      const VerificationMeta('netRxBps');
  @override
  late final GeneratedColumn<double> netRxBps = GeneratedColumn<double>(
      'net_rx_bps', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _netTxBpsMeta =
      const VerificationMeta('netTxBps');
  @override
  late final GeneratedColumn<double> netTxBps = GeneratedColumn<double>(
      'net_tx_bps', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _tempCelsiusMeta =
      const VerificationMeta('tempCelsius');
  @override
  late final GeneratedColumn<double> tempCelsius = GeneratedColumn<double>(
      'temp_celsius', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _load1Meta = const VerificationMeta('load1');
  @override
  late final GeneratedColumn<double> load1 = GeneratedColumn<double>(
      'load1', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverId,
        ts,
        cpuPercent,
        memPercent,
        diskPercent,
        netRxBps,
        netTxBps,
        tempCelsius,
        load1
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'metric_samples';
  @override
  VerificationContext validateIntegrity(Insertable<MetricSample> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    } else if (isInserting) {
      context.missing(_serverIdMeta);
    }
    if (data.containsKey('ts')) {
      context.handle(_tsMeta, ts.isAcceptableOrUnknown(data['ts']!, _tsMeta));
    } else if (isInserting) {
      context.missing(_tsMeta);
    }
    if (data.containsKey('cpu_percent')) {
      context.handle(
          _cpuPercentMeta,
          cpuPercent.isAcceptableOrUnknown(
              data['cpu_percent']!, _cpuPercentMeta));
    }
    if (data.containsKey('mem_percent')) {
      context.handle(
          _memPercentMeta,
          memPercent.isAcceptableOrUnknown(
              data['mem_percent']!, _memPercentMeta));
    }
    if (data.containsKey('disk_percent')) {
      context.handle(
          _diskPercentMeta,
          diskPercent.isAcceptableOrUnknown(
              data['disk_percent']!, _diskPercentMeta));
    }
    if (data.containsKey('net_rx_bps')) {
      context.handle(_netRxBpsMeta,
          netRxBps.isAcceptableOrUnknown(data['net_rx_bps']!, _netRxBpsMeta));
    }
    if (data.containsKey('net_tx_bps')) {
      context.handle(_netTxBpsMeta,
          netTxBps.isAcceptableOrUnknown(data['net_tx_bps']!, _netTxBpsMeta));
    }
    if (data.containsKey('temp_celsius')) {
      context.handle(
          _tempCelsiusMeta,
          tempCelsius.isAcceptableOrUnknown(
              data['temp_celsius']!, _tempCelsiusMeta));
    }
    if (data.containsKey('load1')) {
      context.handle(
          _load1Meta, load1.isAcceptableOrUnknown(data['load1']!, _load1Meta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {serverId, ts},
      ];
  @override
  MetricSample map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetricSample(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id'])!,
      ts: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}ts'])!,
      cpuPercent: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cpu_percent'])!,
      memPercent: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}mem_percent'])!,
      diskPercent: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}disk_percent'])!,
      netRxBps: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}net_rx_bps'])!,
      netTxBps: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}net_tx_bps'])!,
      tempCelsius: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}temp_celsius'])!,
      load1: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}load1'])!,
    );
  }

  @override
  $MetricSamplesTable createAlias(String alias) {
    return $MetricSamplesTable(attachedDatabase, alias);
  }
}

class MetricSample extends DataClass implements Insertable<MetricSample> {
  final int id;
  final String serverId;
  final DateTime ts;
  final double cpuPercent;
  final double memPercent;
  final double diskPercent;
  final double netRxBps;
  final double netTxBps;
  final double tempCelsius;
  final double load1;
  const MetricSample(
      {required this.id,
      required this.serverId,
      required this.ts,
      required this.cpuPercent,
      required this.memPercent,
      required this.diskPercent,
      required this.netRxBps,
      required this.netTxBps,
      required this.tempCelsius,
      required this.load1});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['server_id'] = Variable<String>(serverId);
    map['ts'] = Variable<DateTime>(ts);
    map['cpu_percent'] = Variable<double>(cpuPercent);
    map['mem_percent'] = Variable<double>(memPercent);
    map['disk_percent'] = Variable<double>(diskPercent);
    map['net_rx_bps'] = Variable<double>(netRxBps);
    map['net_tx_bps'] = Variable<double>(netTxBps);
    map['temp_celsius'] = Variable<double>(tempCelsius);
    map['load1'] = Variable<double>(load1);
    return map;
  }

  MetricSamplesCompanion toCompanion(bool nullToAbsent) {
    return MetricSamplesCompanion(
      id: Value(id),
      serverId: Value(serverId),
      ts: Value(ts),
      cpuPercent: Value(cpuPercent),
      memPercent: Value(memPercent),
      diskPercent: Value(diskPercent),
      netRxBps: Value(netRxBps),
      netTxBps: Value(netTxBps),
      tempCelsius: Value(tempCelsius),
      load1: Value(load1),
    );
  }

  factory MetricSample.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetricSample(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<String>(json['serverId']),
      ts: serializer.fromJson<DateTime>(json['ts']),
      cpuPercent: serializer.fromJson<double>(json['cpuPercent']),
      memPercent: serializer.fromJson<double>(json['memPercent']),
      diskPercent: serializer.fromJson<double>(json['diskPercent']),
      netRxBps: serializer.fromJson<double>(json['netRxBps']),
      netTxBps: serializer.fromJson<double>(json['netTxBps']),
      tempCelsius: serializer.fromJson<double>(json['tempCelsius']),
      load1: serializer.fromJson<double>(json['load1']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<String>(serverId),
      'ts': serializer.toJson<DateTime>(ts),
      'cpuPercent': serializer.toJson<double>(cpuPercent),
      'memPercent': serializer.toJson<double>(memPercent),
      'diskPercent': serializer.toJson<double>(diskPercent),
      'netRxBps': serializer.toJson<double>(netRxBps),
      'netTxBps': serializer.toJson<double>(netTxBps),
      'tempCelsius': serializer.toJson<double>(tempCelsius),
      'load1': serializer.toJson<double>(load1),
    };
  }

  MetricSample copyWith(
          {int? id,
          String? serverId,
          DateTime? ts,
          double? cpuPercent,
          double? memPercent,
          double? diskPercent,
          double? netRxBps,
          double? netTxBps,
          double? tempCelsius,
          double? load1}) =>
      MetricSample(
        id: id ?? this.id,
        serverId: serverId ?? this.serverId,
        ts: ts ?? this.ts,
        cpuPercent: cpuPercent ?? this.cpuPercent,
        memPercent: memPercent ?? this.memPercent,
        diskPercent: diskPercent ?? this.diskPercent,
        netRxBps: netRxBps ?? this.netRxBps,
        netTxBps: netTxBps ?? this.netTxBps,
        tempCelsius: tempCelsius ?? this.tempCelsius,
        load1: load1 ?? this.load1,
      );
  MetricSample copyWithCompanion(MetricSamplesCompanion data) {
    return MetricSample(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      ts: data.ts.present ? data.ts.value : this.ts,
      cpuPercent:
          data.cpuPercent.present ? data.cpuPercent.value : this.cpuPercent,
      memPercent:
          data.memPercent.present ? data.memPercent.value : this.memPercent,
      diskPercent:
          data.diskPercent.present ? data.diskPercent.value : this.diskPercent,
      netRxBps: data.netRxBps.present ? data.netRxBps.value : this.netRxBps,
      netTxBps: data.netTxBps.present ? data.netTxBps.value : this.netTxBps,
      tempCelsius:
          data.tempCelsius.present ? data.tempCelsius.value : this.tempCelsius,
      load1: data.load1.present ? data.load1.value : this.load1,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetricSample(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('ts: $ts, ')
          ..write('cpuPercent: $cpuPercent, ')
          ..write('memPercent: $memPercent, ')
          ..write('diskPercent: $diskPercent, ')
          ..write('netRxBps: $netRxBps, ')
          ..write('netTxBps: $netTxBps, ')
          ..write('tempCelsius: $tempCelsius, ')
          ..write('load1: $load1')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, serverId, ts, cpuPercent, memPercent,
      diskPercent, netRxBps, netTxBps, tempCelsius, load1);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetricSample &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.ts == this.ts &&
          other.cpuPercent == this.cpuPercent &&
          other.memPercent == this.memPercent &&
          other.diskPercent == this.diskPercent &&
          other.netRxBps == this.netRxBps &&
          other.netTxBps == this.netTxBps &&
          other.tempCelsius == this.tempCelsius &&
          other.load1 == this.load1);
}

class MetricSamplesCompanion extends UpdateCompanion<MetricSample> {
  final Value<int> id;
  final Value<String> serverId;
  final Value<DateTime> ts;
  final Value<double> cpuPercent;
  final Value<double> memPercent;
  final Value<double> diskPercent;
  final Value<double> netRxBps;
  final Value<double> netTxBps;
  final Value<double> tempCelsius;
  final Value<double> load1;
  const MetricSamplesCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.ts = const Value.absent(),
    this.cpuPercent = const Value.absent(),
    this.memPercent = const Value.absent(),
    this.diskPercent = const Value.absent(),
    this.netRxBps = const Value.absent(),
    this.netTxBps = const Value.absent(),
    this.tempCelsius = const Value.absent(),
    this.load1 = const Value.absent(),
  });
  MetricSamplesCompanion.insert({
    this.id = const Value.absent(),
    required String serverId,
    required DateTime ts,
    this.cpuPercent = const Value.absent(),
    this.memPercent = const Value.absent(),
    this.diskPercent = const Value.absent(),
    this.netRxBps = const Value.absent(),
    this.netTxBps = const Value.absent(),
    this.tempCelsius = const Value.absent(),
    this.load1 = const Value.absent(),
  })  : serverId = Value(serverId),
        ts = Value(ts);
  static Insertable<MetricSample> custom({
    Expression<int>? id,
    Expression<String>? serverId,
    Expression<DateTime>? ts,
    Expression<double>? cpuPercent,
    Expression<double>? memPercent,
    Expression<double>? diskPercent,
    Expression<double>? netRxBps,
    Expression<double>? netTxBps,
    Expression<double>? tempCelsius,
    Expression<double>? load1,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (ts != null) 'ts': ts,
      if (cpuPercent != null) 'cpu_percent': cpuPercent,
      if (memPercent != null) 'mem_percent': memPercent,
      if (diskPercent != null) 'disk_percent': diskPercent,
      if (netRxBps != null) 'net_rx_bps': netRxBps,
      if (netTxBps != null) 'net_tx_bps': netTxBps,
      if (tempCelsius != null) 'temp_celsius': tempCelsius,
      if (load1 != null) 'load1': load1,
    });
  }

  MetricSamplesCompanion copyWith(
      {Value<int>? id,
      Value<String>? serverId,
      Value<DateTime>? ts,
      Value<double>? cpuPercent,
      Value<double>? memPercent,
      Value<double>? diskPercent,
      Value<double>? netRxBps,
      Value<double>? netTxBps,
      Value<double>? tempCelsius,
      Value<double>? load1}) {
    return MetricSamplesCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      ts: ts ?? this.ts,
      cpuPercent: cpuPercent ?? this.cpuPercent,
      memPercent: memPercent ?? this.memPercent,
      diskPercent: diskPercent ?? this.diskPercent,
      netRxBps: netRxBps ?? this.netRxBps,
      netTxBps: netTxBps ?? this.netTxBps,
      tempCelsius: tempCelsius ?? this.tempCelsius,
      load1: load1 ?? this.load1,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (ts.present) {
      map['ts'] = Variable<DateTime>(ts.value);
    }
    if (cpuPercent.present) {
      map['cpu_percent'] = Variable<double>(cpuPercent.value);
    }
    if (memPercent.present) {
      map['mem_percent'] = Variable<double>(memPercent.value);
    }
    if (diskPercent.present) {
      map['disk_percent'] = Variable<double>(diskPercent.value);
    }
    if (netRxBps.present) {
      map['net_rx_bps'] = Variable<double>(netRxBps.value);
    }
    if (netTxBps.present) {
      map['net_tx_bps'] = Variable<double>(netTxBps.value);
    }
    if (tempCelsius.present) {
      map['temp_celsius'] = Variable<double>(tempCelsius.value);
    }
    if (load1.present) {
      map['load1'] = Variable<double>(load1.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetricSamplesCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('ts: $ts, ')
          ..write('cpuPercent: $cpuPercent, ')
          ..write('memPercent: $memPercent, ')
          ..write('diskPercent: $diskPercent, ')
          ..write('netRxBps: $netRxBps, ')
          ..write('netTxBps: $netTxBps, ')
          ..write('tempCelsius: $tempCelsius, ')
          ..write('load1: $load1')
          ..write(')'))
        .toString();
  }
}

class $AlertsTable extends Alerts with TableInfo<$AlertsTable, Alert> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlertsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES servers (id)'));
  static const VerificationMeta _alertTypeMeta =
      const VerificationMeta('alertType');
  @override
  late final GeneratedColumn<String> alertType = GeneratedColumn<String>(
      'alert_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _severityMeta =
      const VerificationMeta('severity');
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
      'severity', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _messageMeta =
      const VerificationMeta('message');
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
      'message', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
      'at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _ackedMeta = const VerificationMeta('acked');
  @override
  late final GeneratedColumn<bool> acked = GeneratedColumn<bool>(
      'acked', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("acked" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _contextJsonMeta =
      const VerificationMeta('contextJson');
  @override
  late final GeneratedColumn<String> contextJson = GeneratedColumn<String>(
      'context_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, serverId, alertType, severity, message, at, acked, contextJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'alerts';
  @override
  VerificationContext validateIntegrity(Insertable<Alert> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    } else if (isInserting) {
      context.missing(_serverIdMeta);
    }
    if (data.containsKey('alert_type')) {
      context.handle(_alertTypeMeta,
          alertType.isAcceptableOrUnknown(data['alert_type']!, _alertTypeMeta));
    } else if (isInserting) {
      context.missing(_alertTypeMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(_severityMeta,
          severity.isAcceptableOrUnknown(data['severity']!, _severityMeta));
    } else if (isInserting) {
      context.missing(_severityMeta);
    }
    if (data.containsKey('message')) {
      context.handle(_messageMeta,
          message.isAcceptableOrUnknown(data['message']!, _messageMeta));
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('acked')) {
      context.handle(
          _ackedMeta, acked.isAcceptableOrUnknown(data['acked']!, _ackedMeta));
    }
    if (data.containsKey('context_json')) {
      context.handle(
          _contextJsonMeta,
          contextJson.isAcceptableOrUnknown(
              data['context_json']!, _contextJsonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Alert map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Alert(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id'])!,
      alertType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}alert_type'])!,
      severity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}severity'])!,
      message: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message'])!,
      at: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}at'])!,
      acked: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}acked'])!,
      contextJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}context_json'])!,
    );
  }

  @override
  $AlertsTable createAlias(String alias) {
    return $AlertsTable(attachedDatabase, alias);
  }
}

class Alert extends DataClass implements Insertable<Alert> {
  final String id;
  final String serverId;
  final String alertType;
  final String severity;
  final String message;
  final DateTime at;
  final bool acked;
  final String contextJson;
  const Alert(
      {required this.id,
      required this.serverId,
      required this.alertType,
      required this.severity,
      required this.message,
      required this.at,
      required this.acked,
      required this.contextJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['server_id'] = Variable<String>(serverId);
    map['alert_type'] = Variable<String>(alertType);
    map['severity'] = Variable<String>(severity);
    map['message'] = Variable<String>(message);
    map['at'] = Variable<DateTime>(at);
    map['acked'] = Variable<bool>(acked);
    map['context_json'] = Variable<String>(contextJson);
    return map;
  }

  AlertsCompanion toCompanion(bool nullToAbsent) {
    return AlertsCompanion(
      id: Value(id),
      serverId: Value(serverId),
      alertType: Value(alertType),
      severity: Value(severity),
      message: Value(message),
      at: Value(at),
      acked: Value(acked),
      contextJson: Value(contextJson),
    );
  }

  factory Alert.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Alert(
      id: serializer.fromJson<String>(json['id']),
      serverId: serializer.fromJson<String>(json['serverId']),
      alertType: serializer.fromJson<String>(json['alertType']),
      severity: serializer.fromJson<String>(json['severity']),
      message: serializer.fromJson<String>(json['message']),
      at: serializer.fromJson<DateTime>(json['at']),
      acked: serializer.fromJson<bool>(json['acked']),
      contextJson: serializer.fromJson<String>(json['contextJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serverId': serializer.toJson<String>(serverId),
      'alertType': serializer.toJson<String>(alertType),
      'severity': serializer.toJson<String>(severity),
      'message': serializer.toJson<String>(message),
      'at': serializer.toJson<DateTime>(at),
      'acked': serializer.toJson<bool>(acked),
      'contextJson': serializer.toJson<String>(contextJson),
    };
  }

  Alert copyWith(
          {String? id,
          String? serverId,
          String? alertType,
          String? severity,
          String? message,
          DateTime? at,
          bool? acked,
          String? contextJson}) =>
      Alert(
        id: id ?? this.id,
        serverId: serverId ?? this.serverId,
        alertType: alertType ?? this.alertType,
        severity: severity ?? this.severity,
        message: message ?? this.message,
        at: at ?? this.at,
        acked: acked ?? this.acked,
        contextJson: contextJson ?? this.contextJson,
      );
  Alert copyWithCompanion(AlertsCompanion data) {
    return Alert(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      alertType: data.alertType.present ? data.alertType.value : this.alertType,
      severity: data.severity.present ? data.severity.value : this.severity,
      message: data.message.present ? data.message.value : this.message,
      at: data.at.present ? data.at.value : this.at,
      acked: data.acked.present ? data.acked.value : this.acked,
      contextJson:
          data.contextJson.present ? data.contextJson.value : this.contextJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Alert(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('alertType: $alertType, ')
          ..write('severity: $severity, ')
          ..write('message: $message, ')
          ..write('at: $at, ')
          ..write('acked: $acked, ')
          ..write('contextJson: $contextJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, serverId, alertType, severity, message, at, acked, contextJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Alert &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.alertType == this.alertType &&
          other.severity == this.severity &&
          other.message == this.message &&
          other.at == this.at &&
          other.acked == this.acked &&
          other.contextJson == this.contextJson);
}

class AlertsCompanion extends UpdateCompanion<Alert> {
  final Value<String> id;
  final Value<String> serverId;
  final Value<String> alertType;
  final Value<String> severity;
  final Value<String> message;
  final Value<DateTime> at;
  final Value<bool> acked;
  final Value<String> contextJson;
  final Value<int> rowid;
  const AlertsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.alertType = const Value.absent(),
    this.severity = const Value.absent(),
    this.message = const Value.absent(),
    this.at = const Value.absent(),
    this.acked = const Value.absent(),
    this.contextJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlertsCompanion.insert({
    required String id,
    required String serverId,
    required String alertType,
    required String severity,
    required String message,
    required DateTime at,
    this.acked = const Value.absent(),
    this.contextJson = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        serverId = Value(serverId),
        alertType = Value(alertType),
        severity = Value(severity),
        message = Value(message),
        at = Value(at);
  static Insertable<Alert> custom({
    Expression<String>? id,
    Expression<String>? serverId,
    Expression<String>? alertType,
    Expression<String>? severity,
    Expression<String>? message,
    Expression<DateTime>? at,
    Expression<bool>? acked,
    Expression<String>? contextJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (alertType != null) 'alert_type': alertType,
      if (severity != null) 'severity': severity,
      if (message != null) 'message': message,
      if (at != null) 'at': at,
      if (acked != null) 'acked': acked,
      if (contextJson != null) 'context_json': contextJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlertsCompanion copyWith(
      {Value<String>? id,
      Value<String>? serverId,
      Value<String>? alertType,
      Value<String>? severity,
      Value<String>? message,
      Value<DateTime>? at,
      Value<bool>? acked,
      Value<String>? contextJson,
      Value<int>? rowid}) {
    return AlertsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      alertType: alertType ?? this.alertType,
      severity: severity ?? this.severity,
      message: message ?? this.message,
      at: at ?? this.at,
      acked: acked ?? this.acked,
      contextJson: contextJson ?? this.contextJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (alertType.present) {
      map['alert_type'] = Variable<String>(alertType.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (acked.present) {
      map['acked'] = Variable<bool>(acked.value);
    }
    if (contextJson.present) {
      map['context_json'] = Variable<String>(contextJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlertsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('alertType: $alertType, ')
          ..write('severity: $severity, ')
          ..write('message: $message, ')
          ..write('at: $at, ')
          ..write('acked: $acked, ')
          ..write('contextJson: $contextJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OfflineOpsTable extends OfflineOps
    with TableInfo<$OfflineOpsTable, OfflineOp> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OfflineOpsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES servers (id)'));
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdOrderMeta =
      const VerificationMeta('createdOrder');
  @override
  late final GeneratedColumn<int> createdOrder = GeneratedColumn<int>(
      'created_order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
      'state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, serverId, kind, payloadJson, createdOrder, state];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'offline_ops';
  @override
  VerificationContext validateIntegrity(Insertable<OfflineOp> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    } else if (isInserting) {
      context.missing(_serverIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_order')) {
      context.handle(
          _createdOrderMeta,
          createdOrder.isAcceptableOrUnknown(
              data['created_order']!, _createdOrderMeta));
    } else if (isInserting) {
      context.missing(_createdOrderMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
          _stateMeta, state.isAcceptableOrUnknown(data['state']!, _stateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OfflineOp map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OfflineOp(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      createdOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_order'])!,
      state: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}state'])!,
    );
  }

  @override
  $OfflineOpsTable createAlias(String alias) {
    return $OfflineOpsTable(attachedDatabase, alias);
  }
}

class OfflineOp extends DataClass implements Insertable<OfflineOp> {
  final int id;
  final String serverId;
  final String kind;
  final String payloadJson;
  final int createdOrder;
  final String state;
  const OfflineOp(
      {required this.id,
      required this.serverId,
      required this.kind,
      required this.payloadJson,
      required this.createdOrder,
      required this.state});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['server_id'] = Variable<String>(serverId);
    map['kind'] = Variable<String>(kind);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_order'] = Variable<int>(createdOrder);
    map['state'] = Variable<String>(state);
    return map;
  }

  OfflineOpsCompanion toCompanion(bool nullToAbsent) {
    return OfflineOpsCompanion(
      id: Value(id),
      serverId: Value(serverId),
      kind: Value(kind),
      payloadJson: Value(payloadJson),
      createdOrder: Value(createdOrder),
      state: Value(state),
    );
  }

  factory OfflineOp.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OfflineOp(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<String>(json['serverId']),
      kind: serializer.fromJson<String>(json['kind']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdOrder: serializer.fromJson<int>(json['createdOrder']),
      state: serializer.fromJson<String>(json['state']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<String>(serverId),
      'kind': serializer.toJson<String>(kind),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdOrder': serializer.toJson<int>(createdOrder),
      'state': serializer.toJson<String>(state),
    };
  }

  OfflineOp copyWith(
          {int? id,
          String? serverId,
          String? kind,
          String? payloadJson,
          int? createdOrder,
          String? state}) =>
      OfflineOp(
        id: id ?? this.id,
        serverId: serverId ?? this.serverId,
        kind: kind ?? this.kind,
        payloadJson: payloadJson ?? this.payloadJson,
        createdOrder: createdOrder ?? this.createdOrder,
        state: state ?? this.state,
      );
  OfflineOp copyWithCompanion(OfflineOpsCompanion data) {
    return OfflineOp(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      kind: data.kind.present ? data.kind.value : this.kind,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      createdOrder: data.createdOrder.present
          ? data.createdOrder.value
          : this.createdOrder,
      state: data.state.present ? data.state.value : this.state,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OfflineOp(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('kind: $kind, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdOrder: $createdOrder, ')
          ..write('state: $state')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, serverId, kind, payloadJson, createdOrder, state);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfflineOp &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.kind == this.kind &&
          other.payloadJson == this.payloadJson &&
          other.createdOrder == this.createdOrder &&
          other.state == this.state);
}

class OfflineOpsCompanion extends UpdateCompanion<OfflineOp> {
  final Value<int> id;
  final Value<String> serverId;
  final Value<String> kind;
  final Value<String> payloadJson;
  final Value<int> createdOrder;
  final Value<String> state;
  const OfflineOpsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.kind = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdOrder = const Value.absent(),
    this.state = const Value.absent(),
  });
  OfflineOpsCompanion.insert({
    this.id = const Value.absent(),
    required String serverId,
    required String kind,
    required String payloadJson,
    required int createdOrder,
    this.state = const Value.absent(),
  })  : serverId = Value(serverId),
        kind = Value(kind),
        payloadJson = Value(payloadJson),
        createdOrder = Value(createdOrder);
  static Insertable<OfflineOp> custom({
    Expression<int>? id,
    Expression<String>? serverId,
    Expression<String>? kind,
    Expression<String>? payloadJson,
    Expression<int>? createdOrder,
    Expression<String>? state,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (kind != null) 'kind': kind,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdOrder != null) 'created_order': createdOrder,
      if (state != null) 'state': state,
    });
  }

  OfflineOpsCompanion copyWith(
      {Value<int>? id,
      Value<String>? serverId,
      Value<String>? kind,
      Value<String>? payloadJson,
      Value<int>? createdOrder,
      Value<String>? state}) {
    return OfflineOpsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      kind: kind ?? this.kind,
      payloadJson: payloadJson ?? this.payloadJson,
      createdOrder: createdOrder ?? this.createdOrder,
      state: state ?? this.state,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdOrder.present) {
      map['created_order'] = Variable<int>(createdOrder.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OfflineOpsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('kind: $kind, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdOrder: $createdOrder, ')
          ..write('state: $state')
          ..write(')'))
        .toString();
  }
}

class $ThresholdOverridesTable extends ThresholdOverrides
    with TableInfo<$ThresholdOverridesTable, ThresholdOverride> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ThresholdOverridesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES servers (id)'));
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
      'value', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _forSecondsMeta =
      const VerificationMeta('forSeconds');
  @override
  late final GeneratedColumn<int> forSeconds = GeneratedColumn<int>(
      'for_seconds', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(60));
  @override
  List<GeneratedColumn> get $columns => [serverId, key, value, forSeconds];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'threshold_overrides';
  @override
  VerificationContext validateIntegrity(Insertable<ThresholdOverride> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    } else if (isInserting) {
      context.missing(_serverIdMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('for_seconds')) {
      context.handle(
          _forSecondsMeta,
          forSeconds.isAcceptableOrUnknown(
              data['for_seconds']!, _forSecondsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {serverId, key};
  @override
  ThresholdOverride map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ThresholdOverride(
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id'])!,
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}value'])!,
      forSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}for_seconds'])!,
    );
  }

  @override
  $ThresholdOverridesTable createAlias(String alias) {
    return $ThresholdOverridesTable(attachedDatabase, alias);
  }
}

class ThresholdOverride extends DataClass
    implements Insertable<ThresholdOverride> {
  final String serverId;
  final String key;
  final double value;
  final int forSeconds;
  const ThresholdOverride(
      {required this.serverId,
      required this.key,
      required this.value,
      required this.forSeconds});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['server_id'] = Variable<String>(serverId);
    map['key'] = Variable<String>(key);
    map['value'] = Variable<double>(value);
    map['for_seconds'] = Variable<int>(forSeconds);
    return map;
  }

  ThresholdOverridesCompanion toCompanion(bool nullToAbsent) {
    return ThresholdOverridesCompanion(
      serverId: Value(serverId),
      key: Value(key),
      value: Value(value),
      forSeconds: Value(forSeconds),
    );
  }

  factory ThresholdOverride.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ThresholdOverride(
      serverId: serializer.fromJson<String>(json['serverId']),
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<double>(json['value']),
      forSeconds: serializer.fromJson<int>(json['forSeconds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'serverId': serializer.toJson<String>(serverId),
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<double>(value),
      'forSeconds': serializer.toJson<int>(forSeconds),
    };
  }

  ThresholdOverride copyWith(
          {String? serverId, String? key, double? value, int? forSeconds}) =>
      ThresholdOverride(
        serverId: serverId ?? this.serverId,
        key: key ?? this.key,
        value: value ?? this.value,
        forSeconds: forSeconds ?? this.forSeconds,
      );
  ThresholdOverride copyWithCompanion(ThresholdOverridesCompanion data) {
    return ThresholdOverride(
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      forSeconds:
          data.forSeconds.present ? data.forSeconds.value : this.forSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ThresholdOverride(')
          ..write('serverId: $serverId, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('forSeconds: $forSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(serverId, key, value, forSeconds);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ThresholdOverride &&
          other.serverId == this.serverId &&
          other.key == this.key &&
          other.value == this.value &&
          other.forSeconds == this.forSeconds);
}

class ThresholdOverridesCompanion extends UpdateCompanion<ThresholdOverride> {
  final Value<String> serverId;
  final Value<String> key;
  final Value<double> value;
  final Value<int> forSeconds;
  final Value<int> rowid;
  const ThresholdOverridesCompanion({
    this.serverId = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.forSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ThresholdOverridesCompanion.insert({
    required String serverId,
    required String key,
    required double value,
    this.forSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : serverId = Value(serverId),
        key = Value(key),
        value = Value(value);
  static Insertable<ThresholdOverride> custom({
    Expression<String>? serverId,
    Expression<String>? key,
    Expression<double>? value,
    Expression<int>? forSeconds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (serverId != null) 'server_id': serverId,
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (forSeconds != null) 'for_seconds': forSeconds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ThresholdOverridesCompanion copyWith(
      {Value<String>? serverId,
      Value<String>? key,
      Value<double>? value,
      Value<int>? forSeconds,
      Value<int>? rowid}) {
    return ThresholdOverridesCompanion(
      serverId: serverId ?? this.serverId,
      key: key ?? this.key,
      value: value ?? this.value,
      forSeconds: forSeconds ?? this.forSeconds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (forSeconds.present) {
      map['for_seconds'] = Variable<int>(forSeconds.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ThresholdOverridesCompanion(')
          ..write('serverId: $serverId, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('forSeconds: $forSeconds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContainerSnapshotsTable extends ContainerSnapshots
    with TableInfo<$ContainerSnapshotsTable, ContainerSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContainerSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES servers (id)'));
  static const VerificationMeta _containerIdMeta =
      const VerificationMeta('containerId');
  @override
  late final GeneratedColumn<String> containerId = GeneratedColumn<String>(
      'container_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _imageMeta = const VerificationMeta('image');
  @override
  late final GeneratedColumn<String> image = GeneratedColumn<String>(
      'image', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
      'state', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _healthMeta = const VerificationMeta('health');
  @override
  late final GeneratedColumn<String> health = GeneratedColumn<String>(
      'health', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _cpuPercentMeta =
      const VerificationMeta('cpuPercent');
  @override
  late final GeneratedColumn<double> cpuPercent = GeneratedColumn<double>(
      'cpu_percent', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _memBytesMeta =
      const VerificationMeta('memBytes');
  @override
  late final GeneratedColumn<double> memBytes = GeneratedColumn<double>(
      'mem_bytes', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  @override
  List<GeneratedColumn> get $columns => [
        serverId,
        containerId,
        name,
        image,
        state,
        health,
        updatedAt,
        cpuPercent,
        memBytes
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'container_snapshots';
  @override
  VerificationContext validateIntegrity(Insertable<ContainerSnapshot> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    } else if (isInserting) {
      context.missing(_serverIdMeta);
    }
    if (data.containsKey('container_id')) {
      context.handle(
          _containerIdMeta,
          containerId.isAcceptableOrUnknown(
              data['container_id']!, _containerIdMeta));
    } else if (isInserting) {
      context.missing(_containerIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('image')) {
      context.handle(
          _imageMeta, image.isAcceptableOrUnknown(data['image']!, _imageMeta));
    } else if (isInserting) {
      context.missing(_imageMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
          _stateMeta, state.isAcceptableOrUnknown(data['state']!, _stateMeta));
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('health')) {
      context.handle(_healthMeta,
          health.isAcceptableOrUnknown(data['health']!, _healthMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('cpu_percent')) {
      context.handle(
          _cpuPercentMeta,
          cpuPercent.isAcceptableOrUnknown(
              data['cpu_percent']!, _cpuPercentMeta));
    }
    if (data.containsKey('mem_bytes')) {
      context.handle(_memBytesMeta,
          memBytes.isAcceptableOrUnknown(data['mem_bytes']!, _memBytesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {serverId, containerId};
  @override
  ContainerSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContainerSnapshot(
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id'])!,
      containerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}container_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      image: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image'])!,
      state: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}state'])!,
      health: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}health'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      cpuPercent: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cpu_percent'])!,
      memBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}mem_bytes'])!,
    );
  }

  @override
  $ContainerSnapshotsTable createAlias(String alias) {
    return $ContainerSnapshotsTable(attachedDatabase, alias);
  }
}

class ContainerSnapshot extends DataClass
    implements Insertable<ContainerSnapshot> {
  final String serverId;
  final String containerId;
  final String name;
  final String image;
  final String state;
  final String health;
  final DateTime updatedAt;
  final double cpuPercent;
  final double memBytes;
  const ContainerSnapshot(
      {required this.serverId,
      required this.containerId,
      required this.name,
      required this.image,
      required this.state,
      required this.health,
      required this.updatedAt,
      required this.cpuPercent,
      required this.memBytes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['server_id'] = Variable<String>(serverId);
    map['container_id'] = Variable<String>(containerId);
    map['name'] = Variable<String>(name);
    map['image'] = Variable<String>(image);
    map['state'] = Variable<String>(state);
    map['health'] = Variable<String>(health);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['cpu_percent'] = Variable<double>(cpuPercent);
    map['mem_bytes'] = Variable<double>(memBytes);
    return map;
  }

  ContainerSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return ContainerSnapshotsCompanion(
      serverId: Value(serverId),
      containerId: Value(containerId),
      name: Value(name),
      image: Value(image),
      state: Value(state),
      health: Value(health),
      updatedAt: Value(updatedAt),
      cpuPercent: Value(cpuPercent),
      memBytes: Value(memBytes),
    );
  }

  factory ContainerSnapshot.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContainerSnapshot(
      serverId: serializer.fromJson<String>(json['serverId']),
      containerId: serializer.fromJson<String>(json['containerId']),
      name: serializer.fromJson<String>(json['name']),
      image: serializer.fromJson<String>(json['image']),
      state: serializer.fromJson<String>(json['state']),
      health: serializer.fromJson<String>(json['health']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      cpuPercent: serializer.fromJson<double>(json['cpuPercent']),
      memBytes: serializer.fromJson<double>(json['memBytes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'serverId': serializer.toJson<String>(serverId),
      'containerId': serializer.toJson<String>(containerId),
      'name': serializer.toJson<String>(name),
      'image': serializer.toJson<String>(image),
      'state': serializer.toJson<String>(state),
      'health': serializer.toJson<String>(health),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'cpuPercent': serializer.toJson<double>(cpuPercent),
      'memBytes': serializer.toJson<double>(memBytes),
    };
  }

  ContainerSnapshot copyWith(
          {String? serverId,
          String? containerId,
          String? name,
          String? image,
          String? state,
          String? health,
          DateTime? updatedAt,
          double? cpuPercent,
          double? memBytes}) =>
      ContainerSnapshot(
        serverId: serverId ?? this.serverId,
        containerId: containerId ?? this.containerId,
        name: name ?? this.name,
        image: image ?? this.image,
        state: state ?? this.state,
        health: health ?? this.health,
        updatedAt: updatedAt ?? this.updatedAt,
        cpuPercent: cpuPercent ?? this.cpuPercent,
        memBytes: memBytes ?? this.memBytes,
      );
  ContainerSnapshot copyWithCompanion(ContainerSnapshotsCompanion data) {
    return ContainerSnapshot(
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      containerId:
          data.containerId.present ? data.containerId.value : this.containerId,
      name: data.name.present ? data.name.value : this.name,
      image: data.image.present ? data.image.value : this.image,
      state: data.state.present ? data.state.value : this.state,
      health: data.health.present ? data.health.value : this.health,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      cpuPercent:
          data.cpuPercent.present ? data.cpuPercent.value : this.cpuPercent,
      memBytes: data.memBytes.present ? data.memBytes.value : this.memBytes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContainerSnapshot(')
          ..write('serverId: $serverId, ')
          ..write('containerId: $containerId, ')
          ..write('name: $name, ')
          ..write('image: $image, ')
          ..write('state: $state, ')
          ..write('health: $health, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cpuPercent: $cpuPercent, ')
          ..write('memBytes: $memBytes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(serverId, containerId, name, image, state,
      health, updatedAt, cpuPercent, memBytes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContainerSnapshot &&
          other.serverId == this.serverId &&
          other.containerId == this.containerId &&
          other.name == this.name &&
          other.image == this.image &&
          other.state == this.state &&
          other.health == this.health &&
          other.updatedAt == this.updatedAt &&
          other.cpuPercent == this.cpuPercent &&
          other.memBytes == this.memBytes);
}

class ContainerSnapshotsCompanion extends UpdateCompanion<ContainerSnapshot> {
  final Value<String> serverId;
  final Value<String> containerId;
  final Value<String> name;
  final Value<String> image;
  final Value<String> state;
  final Value<String> health;
  final Value<DateTime> updatedAt;
  final Value<double> cpuPercent;
  final Value<double> memBytes;
  final Value<int> rowid;
  const ContainerSnapshotsCompanion({
    this.serverId = const Value.absent(),
    this.containerId = const Value.absent(),
    this.name = const Value.absent(),
    this.image = const Value.absent(),
    this.state = const Value.absent(),
    this.health = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.cpuPercent = const Value.absent(),
    this.memBytes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContainerSnapshotsCompanion.insert({
    required String serverId,
    required String containerId,
    required String name,
    required String image,
    required String state,
    this.health = const Value.absent(),
    required DateTime updatedAt,
    this.cpuPercent = const Value.absent(),
    this.memBytes = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : serverId = Value(serverId),
        containerId = Value(containerId),
        name = Value(name),
        image = Value(image),
        state = Value(state),
        updatedAt = Value(updatedAt);
  static Insertable<ContainerSnapshot> custom({
    Expression<String>? serverId,
    Expression<String>? containerId,
    Expression<String>? name,
    Expression<String>? image,
    Expression<String>? state,
    Expression<String>? health,
    Expression<DateTime>? updatedAt,
    Expression<double>? cpuPercent,
    Expression<double>? memBytes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (serverId != null) 'server_id': serverId,
      if (containerId != null) 'container_id': containerId,
      if (name != null) 'name': name,
      if (image != null) 'image': image,
      if (state != null) 'state': state,
      if (health != null) 'health': health,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (cpuPercent != null) 'cpu_percent': cpuPercent,
      if (memBytes != null) 'mem_bytes': memBytes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContainerSnapshotsCompanion copyWith(
      {Value<String>? serverId,
      Value<String>? containerId,
      Value<String>? name,
      Value<String>? image,
      Value<String>? state,
      Value<String>? health,
      Value<DateTime>? updatedAt,
      Value<double>? cpuPercent,
      Value<double>? memBytes,
      Value<int>? rowid}) {
    return ContainerSnapshotsCompanion(
      serverId: serverId ?? this.serverId,
      containerId: containerId ?? this.containerId,
      name: name ?? this.name,
      image: image ?? this.image,
      state: state ?? this.state,
      health: health ?? this.health,
      updatedAt: updatedAt ?? this.updatedAt,
      cpuPercent: cpuPercent ?? this.cpuPercent,
      memBytes: memBytes ?? this.memBytes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (containerId.present) {
      map['container_id'] = Variable<String>(containerId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (image.present) {
      map['image'] = Variable<String>(image.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (health.present) {
      map['health'] = Variable<String>(health.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (cpuPercent.present) {
      map['cpu_percent'] = Variable<double>(cpuPercent.value);
    }
    if (memBytes.present) {
      map['mem_bytes'] = Variable<double>(memBytes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContainerSnapshotsCompanion(')
          ..write('serverId: $serverId, ')
          ..write('containerId: $containerId, ')
          ..write('name: $name, ')
          ..write('image: $image, ')
          ..write('state: $state, ')
          ..write('health: $health, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cpuPercent: $cpuPercent, ')
          ..write('memBytes: $memBytes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES servers (id)'));
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastActiveAtMeta =
      const VerificationMeta('lastActiveAt');
  @override
  late final GeneratedColumn<DateTime> lastActiveAt = GeneratedColumn<DateTime>(
      'last_active_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, serverId, kind, payloadJson, lastActiveAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(Insertable<Session> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    } else if (isInserting) {
      context.missing(_serverIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('last_active_at')) {
      context.handle(
          _lastActiveAtMeta,
          lastActiveAt.isAcceptableOrUnknown(
              data['last_active_at']!, _lastActiveAtMeta));
    } else if (isInserting) {
      context.missing(_lastActiveAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      lastActiveAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_active_at'])!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final String id;
  final String serverId;
  final String kind;
  final String payloadJson;
  final DateTime lastActiveAt;
  const Session(
      {required this.id,
      required this.serverId,
      required this.kind,
      required this.payloadJson,
      required this.lastActiveAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['server_id'] = Variable<String>(serverId);
    map['kind'] = Variable<String>(kind);
    map['payload_json'] = Variable<String>(payloadJson);
    map['last_active_at'] = Variable<DateTime>(lastActiveAt);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      serverId: Value(serverId),
      kind: Value(kind),
      payloadJson: Value(payloadJson),
      lastActiveAt: Value(lastActiveAt),
    );
  }

  factory Session.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<String>(json['id']),
      serverId: serializer.fromJson<String>(json['serverId']),
      kind: serializer.fromJson<String>(json['kind']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      lastActiveAt: serializer.fromJson<DateTime>(json['lastActiveAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serverId': serializer.toJson<String>(serverId),
      'kind': serializer.toJson<String>(kind),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'lastActiveAt': serializer.toJson<DateTime>(lastActiveAt),
    };
  }

  Session copyWith(
          {String? id,
          String? serverId,
          String? kind,
          String? payloadJson,
          DateTime? lastActiveAt}) =>
      Session(
        id: id ?? this.id,
        serverId: serverId ?? this.serverId,
        kind: kind ?? this.kind,
        payloadJson: payloadJson ?? this.payloadJson,
        lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      kind: data.kind.present ? data.kind.value : this.kind,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      lastActiveAt: data.lastActiveAt.present
          ? data.lastActiveAt.value
          : this.lastActiveAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('kind: $kind, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('lastActiveAt: $lastActiveAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, serverId, kind, payloadJson, lastActiveAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.kind == this.kind &&
          other.payloadJson == this.payloadJson &&
          other.lastActiveAt == this.lastActiveAt);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<String> id;
  final Value<String> serverId;
  final Value<String> kind;
  final Value<String> payloadJson;
  final Value<DateTime> lastActiveAt;
  final Value<int> rowid;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.kind = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.lastActiveAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsCompanion.insert({
    required String id,
    required String serverId,
    required String kind,
    required String payloadJson,
    required DateTime lastActiveAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        serverId = Value(serverId),
        kind = Value(kind),
        payloadJson = Value(payloadJson),
        lastActiveAt = Value(lastActiveAt);
  static Insertable<Session> custom({
    Expression<String>? id,
    Expression<String>? serverId,
    Expression<String>? kind,
    Expression<String>? payloadJson,
    Expression<DateTime>? lastActiveAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (kind != null) 'kind': kind,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (lastActiveAt != null) 'last_active_at': lastActiveAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? serverId,
      Value<String>? kind,
      Value<String>? payloadJson,
      Value<DateTime>? lastActiveAt,
      Value<int>? rowid}) {
    return SessionsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      kind: kind ?? this.kind,
      payloadJson: payloadJson ?? this.payloadJson,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (lastActiveAt.present) {
      map['last_active_at'] = Variable<DateTime>(lastActiveAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('kind: $kind, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('lastActiveAt: $lastActiveAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ServersTable servers = $ServersTable(this);
  late final $MetricSamplesTable metricSamples = $MetricSamplesTable(this);
  late final $AlertsTable alerts = $AlertsTable(this);
  late final $OfflineOpsTable offlineOps = $OfflineOpsTable(this);
  late final $ThresholdOverridesTable thresholdOverrides =
      $ThresholdOverridesTable(this);
  late final $ContainerSnapshotsTable containerSnapshots =
      $ContainerSnapshotsTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        servers,
        metricSamples,
        alerts,
        offlineOps,
        thresholdOverrides,
        containerSnapshots,
        sessions
      ];
}

typedef $$ServersTableCreateCompanionBuilder = ServersCompanion Function({
  required String id,
  required String name,
  required String agentUrl,
  Value<String> groupName,
  Value<bool> readOnly,
  Value<String> fingerprintHash,
  Value<String> status,
  Value<String> deviceId,
  Value<DateTime?> lastSeenAt,
  required DateTime createdAt,
  Value<String> agentVersion,
  Value<String> capsJson,
  Value<int> rowid,
});
typedef $$ServersTableUpdateCompanionBuilder = ServersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> agentUrl,
  Value<String> groupName,
  Value<bool> readOnly,
  Value<String> fingerprintHash,
  Value<String> status,
  Value<String> deviceId,
  Value<DateTime?> lastSeenAt,
  Value<DateTime> createdAt,
  Value<String> agentVersion,
  Value<String> capsJson,
  Value<int> rowid,
});

class $$ServersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ServersTable,
    Server,
    $$ServersTableFilterComposer,
    $$ServersTableOrderingComposer,
    $$ServersTableCreateCompanionBuilder,
    $$ServersTableUpdateCompanionBuilder> {
  $$ServersTableTableManager(_$AppDatabase db, $ServersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ServersTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ServersTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> agentUrl = const Value.absent(),
            Value<String> groupName = const Value.absent(),
            Value<bool> readOnly = const Value.absent(),
            Value<String> fingerprintHash = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<DateTime?> lastSeenAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> agentVersion = const Value.absent(),
            Value<String> capsJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ServersCompanion(
            id: id,
            name: name,
            agentUrl: agentUrl,
            groupName: groupName,
            readOnly: readOnly,
            fingerprintHash: fingerprintHash,
            status: status,
            deviceId: deviceId,
            lastSeenAt: lastSeenAt,
            createdAt: createdAt,
            agentVersion: agentVersion,
            capsJson: capsJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String agentUrl,
            Value<String> groupName = const Value.absent(),
            Value<bool> readOnly = const Value.absent(),
            Value<String> fingerprintHash = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<DateTime?> lastSeenAt = const Value.absent(),
            required DateTime createdAt,
            Value<String> agentVersion = const Value.absent(),
            Value<String> capsJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ServersCompanion.insert(
            id: id,
            name: name,
            agentUrl: agentUrl,
            groupName: groupName,
            readOnly: readOnly,
            fingerprintHash: fingerprintHash,
            status: status,
            deviceId: deviceId,
            lastSeenAt: lastSeenAt,
            createdAt: createdAt,
            agentVersion: agentVersion,
            capsJson: capsJson,
            rowid: rowid,
          ),
        ));
}

class $$ServersTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ServersTable> {
  $$ServersTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get agentUrl => $state.composableBuilder(
      column: $state.table.agentUrl,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get groupName => $state.composableBuilder(
      column: $state.table.groupName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get readOnly => $state.composableBuilder(
      column: $state.table.readOnly,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get fingerprintHash => $state.composableBuilder(
      column: $state.table.fingerprintHash,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get deviceId => $state.composableBuilder(
      column: $state.table.deviceId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get lastSeenAt => $state.composableBuilder(
      column: $state.table.lastSeenAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get agentVersion => $state.composableBuilder(
      column: $state.table.agentVersion,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get capsJson => $state.composableBuilder(
      column: $state.table.capsJson,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter metricSamplesRefs(
      ComposableFilter Function($$MetricSamplesTableFilterComposer f) f) {
    final $$MetricSamplesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.metricSamples,
        getReferencedColumn: (t) => t.serverId,
        builder: (joinBuilder, parentComposers) =>
            $$MetricSamplesTableFilterComposer(ComposerState($state.db,
                $state.db.metricSamples, joinBuilder, parentComposers)));
    return f(composer);
  }

  ComposableFilter alertsRefs(
      ComposableFilter Function($$AlertsTableFilterComposer f) f) {
    final $$AlertsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.alerts,
        getReferencedColumn: (t) => t.serverId,
        builder: (joinBuilder, parentComposers) => $$AlertsTableFilterComposer(
            ComposerState(
                $state.db, $state.db.alerts, joinBuilder, parentComposers)));
    return f(composer);
  }

  ComposableFilter offlineOpsRefs(
      ComposableFilter Function($$OfflineOpsTableFilterComposer f) f) {
    final $$OfflineOpsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.offlineOps,
        getReferencedColumn: (t) => t.serverId,
        builder: (joinBuilder, parentComposers) =>
            $$OfflineOpsTableFilterComposer(ComposerState($state.db,
                $state.db.offlineOps, joinBuilder, parentComposers)));
    return f(composer);
  }

  ComposableFilter thresholdOverridesRefs(
      ComposableFilter Function($$ThresholdOverridesTableFilterComposer f) f) {
    final $$ThresholdOverridesTableFilterComposer composer = $state
        .composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $state.db.thresholdOverrides,
            getReferencedColumn: (t) => t.serverId,
            builder: (joinBuilder, parentComposers) =>
                $$ThresholdOverridesTableFilterComposer(ComposerState(
                    $state.db,
                    $state.db.thresholdOverrides,
                    joinBuilder,
                    parentComposers)));
    return f(composer);
  }

  ComposableFilter containerSnapshotsRefs(
      ComposableFilter Function($$ContainerSnapshotsTableFilterComposer f) f) {
    final $$ContainerSnapshotsTableFilterComposer composer = $state
        .composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $state.db.containerSnapshots,
            getReferencedColumn: (t) => t.serverId,
            builder: (joinBuilder, parentComposers) =>
                $$ContainerSnapshotsTableFilterComposer(ComposerState(
                    $state.db,
                    $state.db.containerSnapshots,
                    joinBuilder,
                    parentComposers)));
    return f(composer);
  }

  ComposableFilter sessionsRefs(
      ComposableFilter Function($$SessionsTableFilterComposer f) f) {
    final $$SessionsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.sessions,
        getReferencedColumn: (t) => t.serverId,
        builder: (joinBuilder, parentComposers) =>
            $$SessionsTableFilterComposer(ComposerState(
                $state.db, $state.db.sessions, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$ServersTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ServersTable> {
  $$ServersTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get agentUrl => $state.composableBuilder(
      column: $state.table.agentUrl,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get groupName => $state.composableBuilder(
      column: $state.table.groupName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get readOnly => $state.composableBuilder(
      column: $state.table.readOnly,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get fingerprintHash => $state.composableBuilder(
      column: $state.table.fingerprintHash,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get deviceId => $state.composableBuilder(
      column: $state.table.deviceId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get lastSeenAt => $state.composableBuilder(
      column: $state.table.lastSeenAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get agentVersion => $state.composableBuilder(
      column: $state.table.agentVersion,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get capsJson => $state.composableBuilder(
      column: $state.table.capsJson,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$MetricSamplesTableCreateCompanionBuilder = MetricSamplesCompanion
    Function({
  Value<int> id,
  required String serverId,
  required DateTime ts,
  Value<double> cpuPercent,
  Value<double> memPercent,
  Value<double> diskPercent,
  Value<double> netRxBps,
  Value<double> netTxBps,
  Value<double> tempCelsius,
  Value<double> load1,
});
typedef $$MetricSamplesTableUpdateCompanionBuilder = MetricSamplesCompanion
    Function({
  Value<int> id,
  Value<String> serverId,
  Value<DateTime> ts,
  Value<double> cpuPercent,
  Value<double> memPercent,
  Value<double> diskPercent,
  Value<double> netRxBps,
  Value<double> netTxBps,
  Value<double> tempCelsius,
  Value<double> load1,
});

class $$MetricSamplesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MetricSamplesTable,
    MetricSample,
    $$MetricSamplesTableFilterComposer,
    $$MetricSamplesTableOrderingComposer,
    $$MetricSamplesTableCreateCompanionBuilder,
    $$MetricSamplesTableUpdateCompanionBuilder> {
  $$MetricSamplesTableTableManager(_$AppDatabase db, $MetricSamplesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$MetricSamplesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$MetricSamplesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> serverId = const Value.absent(),
            Value<DateTime> ts = const Value.absent(),
            Value<double> cpuPercent = const Value.absent(),
            Value<double> memPercent = const Value.absent(),
            Value<double> diskPercent = const Value.absent(),
            Value<double> netRxBps = const Value.absent(),
            Value<double> netTxBps = const Value.absent(),
            Value<double> tempCelsius = const Value.absent(),
            Value<double> load1 = const Value.absent(),
          }) =>
              MetricSamplesCompanion(
            id: id,
            serverId: serverId,
            ts: ts,
            cpuPercent: cpuPercent,
            memPercent: memPercent,
            diskPercent: diskPercent,
            netRxBps: netRxBps,
            netTxBps: netTxBps,
            tempCelsius: tempCelsius,
            load1: load1,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String serverId,
            required DateTime ts,
            Value<double> cpuPercent = const Value.absent(),
            Value<double> memPercent = const Value.absent(),
            Value<double> diskPercent = const Value.absent(),
            Value<double> netRxBps = const Value.absent(),
            Value<double> netTxBps = const Value.absent(),
            Value<double> tempCelsius = const Value.absent(),
            Value<double> load1 = const Value.absent(),
          }) =>
              MetricSamplesCompanion.insert(
            id: id,
            serverId: serverId,
            ts: ts,
            cpuPercent: cpuPercent,
            memPercent: memPercent,
            diskPercent: diskPercent,
            netRxBps: netRxBps,
            netTxBps: netTxBps,
            tempCelsius: tempCelsius,
            load1: load1,
          ),
        ));
}

class $$MetricSamplesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $MetricSamplesTable> {
  $$MetricSamplesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get ts => $state.composableBuilder(
      column: $state.table.ts,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get cpuPercent => $state.composableBuilder(
      column: $state.table.cpuPercent,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get memPercent => $state.composableBuilder(
      column: $state.table.memPercent,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get diskPercent => $state.composableBuilder(
      column: $state.table.diskPercent,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get netRxBps => $state.composableBuilder(
      column: $state.table.netRxBps,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get netTxBps => $state.composableBuilder(
      column: $state.table.netTxBps,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get tempCelsius => $state.composableBuilder(
      column: $state.table.tempCelsius,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get load1 => $state.composableBuilder(
      column: $state.table.load1,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$ServersTableFilterComposer get serverId {
    final $$ServersTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.serverId,
        referencedTable: $state.db.servers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$ServersTableFilterComposer(
            ComposerState(
                $state.db, $state.db.servers, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$MetricSamplesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $MetricSamplesTable> {
  $$MetricSamplesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get ts => $state.composableBuilder(
      column: $state.table.ts,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get cpuPercent => $state.composableBuilder(
      column: $state.table.cpuPercent,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get memPercent => $state.composableBuilder(
      column: $state.table.memPercent,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get diskPercent => $state.composableBuilder(
      column: $state.table.diskPercent,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get netRxBps => $state.composableBuilder(
      column: $state.table.netRxBps,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get netTxBps => $state.composableBuilder(
      column: $state.table.netTxBps,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get tempCelsius => $state.composableBuilder(
      column: $state.table.tempCelsius,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get load1 => $state.composableBuilder(
      column: $state.table.load1,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$ServersTableOrderingComposer get serverId {
    final $$ServersTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.serverId,
        referencedTable: $state.db.servers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ServersTableOrderingComposer(ComposerState(
                $state.db, $state.db.servers, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$AlertsTableCreateCompanionBuilder = AlertsCompanion Function({
  required String id,
  required String serverId,
  required String alertType,
  required String severity,
  required String message,
  required DateTime at,
  Value<bool> acked,
  Value<String> contextJson,
  Value<int> rowid,
});
typedef $$AlertsTableUpdateCompanionBuilder = AlertsCompanion Function({
  Value<String> id,
  Value<String> serverId,
  Value<String> alertType,
  Value<String> severity,
  Value<String> message,
  Value<DateTime> at,
  Value<bool> acked,
  Value<String> contextJson,
  Value<int> rowid,
});

class $$AlertsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AlertsTable,
    Alert,
    $$AlertsTableFilterComposer,
    $$AlertsTableOrderingComposer,
    $$AlertsTableCreateCompanionBuilder,
    $$AlertsTableUpdateCompanionBuilder> {
  $$AlertsTableTableManager(_$AppDatabase db, $AlertsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$AlertsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$AlertsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> serverId = const Value.absent(),
            Value<String> alertType = const Value.absent(),
            Value<String> severity = const Value.absent(),
            Value<String> message = const Value.absent(),
            Value<DateTime> at = const Value.absent(),
            Value<bool> acked = const Value.absent(),
            Value<String> contextJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AlertsCompanion(
            id: id,
            serverId: serverId,
            alertType: alertType,
            severity: severity,
            message: message,
            at: at,
            acked: acked,
            contextJson: contextJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String serverId,
            required String alertType,
            required String severity,
            required String message,
            required DateTime at,
            Value<bool> acked = const Value.absent(),
            Value<String> contextJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AlertsCompanion.insert(
            id: id,
            serverId: serverId,
            alertType: alertType,
            severity: severity,
            message: message,
            at: at,
            acked: acked,
            contextJson: contextJson,
            rowid: rowid,
          ),
        ));
}

class $$AlertsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $AlertsTable> {
  $$AlertsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get alertType => $state.composableBuilder(
      column: $state.table.alertType,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get severity => $state.composableBuilder(
      column: $state.table.severity,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get message => $state.composableBuilder(
      column: $state.table.message,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get at => $state.composableBuilder(
      column: $state.table.at,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get acked => $state.composableBuilder(
      column: $state.table.acked,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get contextJson => $state.composableBuilder(
      column: $state.table.contextJson,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$ServersTableFilterComposer get serverId {
    final $$ServersTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.serverId,
        referencedTable: $state.db.servers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$ServersTableFilterComposer(
            ComposerState(
                $state.db, $state.db.servers, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$AlertsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $AlertsTable> {
  $$AlertsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get alertType => $state.composableBuilder(
      column: $state.table.alertType,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get severity => $state.composableBuilder(
      column: $state.table.severity,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get message => $state.composableBuilder(
      column: $state.table.message,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get at => $state.composableBuilder(
      column: $state.table.at,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get acked => $state.composableBuilder(
      column: $state.table.acked,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get contextJson => $state.composableBuilder(
      column: $state.table.contextJson,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$ServersTableOrderingComposer get serverId {
    final $$ServersTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.serverId,
        referencedTable: $state.db.servers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ServersTableOrderingComposer(ComposerState(
                $state.db, $state.db.servers, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$OfflineOpsTableCreateCompanionBuilder = OfflineOpsCompanion Function({
  Value<int> id,
  required String serverId,
  required String kind,
  required String payloadJson,
  required int createdOrder,
  Value<String> state,
});
typedef $$OfflineOpsTableUpdateCompanionBuilder = OfflineOpsCompanion Function({
  Value<int> id,
  Value<String> serverId,
  Value<String> kind,
  Value<String> payloadJson,
  Value<int> createdOrder,
  Value<String> state,
});

class $$OfflineOpsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OfflineOpsTable,
    OfflineOp,
    $$OfflineOpsTableFilterComposer,
    $$OfflineOpsTableOrderingComposer,
    $$OfflineOpsTableCreateCompanionBuilder,
    $$OfflineOpsTableUpdateCompanionBuilder> {
  $$OfflineOpsTableTableManager(_$AppDatabase db, $OfflineOpsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$OfflineOpsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$OfflineOpsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> serverId = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<int> createdOrder = const Value.absent(),
            Value<String> state = const Value.absent(),
          }) =>
              OfflineOpsCompanion(
            id: id,
            serverId: serverId,
            kind: kind,
            payloadJson: payloadJson,
            createdOrder: createdOrder,
            state: state,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String serverId,
            required String kind,
            required String payloadJson,
            required int createdOrder,
            Value<String> state = const Value.absent(),
          }) =>
              OfflineOpsCompanion.insert(
            id: id,
            serverId: serverId,
            kind: kind,
            payloadJson: payloadJson,
            createdOrder: createdOrder,
            state: state,
          ),
        ));
}

class $$OfflineOpsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $OfflineOpsTable> {
  $$OfflineOpsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get kind => $state.composableBuilder(
      column: $state.table.kind,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get payloadJson => $state.composableBuilder(
      column: $state.table.payloadJson,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get createdOrder => $state.composableBuilder(
      column: $state.table.createdOrder,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get state => $state.composableBuilder(
      column: $state.table.state,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$ServersTableFilterComposer get serverId {
    final $$ServersTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.serverId,
        referencedTable: $state.db.servers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$ServersTableFilterComposer(
            ComposerState(
                $state.db, $state.db.servers, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$OfflineOpsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $OfflineOpsTable> {
  $$OfflineOpsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get kind => $state.composableBuilder(
      column: $state.table.kind,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get payloadJson => $state.composableBuilder(
      column: $state.table.payloadJson,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get createdOrder => $state.composableBuilder(
      column: $state.table.createdOrder,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get state => $state.composableBuilder(
      column: $state.table.state,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$ServersTableOrderingComposer get serverId {
    final $$ServersTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.serverId,
        referencedTable: $state.db.servers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ServersTableOrderingComposer(ComposerState(
                $state.db, $state.db.servers, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$ThresholdOverridesTableCreateCompanionBuilder
    = ThresholdOverridesCompanion Function({
  required String serverId,
  required String key,
  required double value,
  Value<int> forSeconds,
  Value<int> rowid,
});
typedef $$ThresholdOverridesTableUpdateCompanionBuilder
    = ThresholdOverridesCompanion Function({
  Value<String> serverId,
  Value<String> key,
  Value<double> value,
  Value<int> forSeconds,
  Value<int> rowid,
});

class $$ThresholdOverridesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ThresholdOverridesTable,
    ThresholdOverride,
    $$ThresholdOverridesTableFilterComposer,
    $$ThresholdOverridesTableOrderingComposer,
    $$ThresholdOverridesTableCreateCompanionBuilder,
    $$ThresholdOverridesTableUpdateCompanionBuilder> {
  $$ThresholdOverridesTableTableManager(
      _$AppDatabase db, $ThresholdOverridesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ThresholdOverridesTableFilterComposer(ComposerState(db, table)),
          orderingComposer: $$ThresholdOverridesTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> serverId = const Value.absent(),
            Value<String> key = const Value.absent(),
            Value<double> value = const Value.absent(),
            Value<int> forSeconds = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ThresholdOverridesCompanion(
            serverId: serverId,
            key: key,
            value: value,
            forSeconds: forSeconds,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String serverId,
            required String key,
            required double value,
            Value<int> forSeconds = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ThresholdOverridesCompanion.insert(
            serverId: serverId,
            key: key,
            value: value,
            forSeconds: forSeconds,
            rowid: rowid,
          ),
        ));
}

class $$ThresholdOverridesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ThresholdOverridesTable> {
  $$ThresholdOverridesTableFilterComposer(super.$state);
  ColumnFilters<String> get key => $state.composableBuilder(
      column: $state.table.key,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get value => $state.composableBuilder(
      column: $state.table.value,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get forSeconds => $state.composableBuilder(
      column: $state.table.forSeconds,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$ServersTableFilterComposer get serverId {
    final $$ServersTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.serverId,
        referencedTable: $state.db.servers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$ServersTableFilterComposer(
            ComposerState(
                $state.db, $state.db.servers, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$ThresholdOverridesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ThresholdOverridesTable> {
  $$ThresholdOverridesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get key => $state.composableBuilder(
      column: $state.table.key,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get value => $state.composableBuilder(
      column: $state.table.value,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get forSeconds => $state.composableBuilder(
      column: $state.table.forSeconds,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$ServersTableOrderingComposer get serverId {
    final $$ServersTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.serverId,
        referencedTable: $state.db.servers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ServersTableOrderingComposer(ComposerState(
                $state.db, $state.db.servers, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$ContainerSnapshotsTableCreateCompanionBuilder
    = ContainerSnapshotsCompanion Function({
  required String serverId,
  required String containerId,
  required String name,
  required String image,
  required String state,
  Value<String> health,
  required DateTime updatedAt,
  Value<double> cpuPercent,
  Value<double> memBytes,
  Value<int> rowid,
});
typedef $$ContainerSnapshotsTableUpdateCompanionBuilder
    = ContainerSnapshotsCompanion Function({
  Value<String> serverId,
  Value<String> containerId,
  Value<String> name,
  Value<String> image,
  Value<String> state,
  Value<String> health,
  Value<DateTime> updatedAt,
  Value<double> cpuPercent,
  Value<double> memBytes,
  Value<int> rowid,
});

class $$ContainerSnapshotsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ContainerSnapshotsTable,
    ContainerSnapshot,
    $$ContainerSnapshotsTableFilterComposer,
    $$ContainerSnapshotsTableOrderingComposer,
    $$ContainerSnapshotsTableCreateCompanionBuilder,
    $$ContainerSnapshotsTableUpdateCompanionBuilder> {
  $$ContainerSnapshotsTableTableManager(
      _$AppDatabase db, $ContainerSnapshotsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ContainerSnapshotsTableFilterComposer(ComposerState(db, table)),
          orderingComposer: $$ContainerSnapshotsTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> serverId = const Value.absent(),
            Value<String> containerId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> image = const Value.absent(),
            Value<String> state = const Value.absent(),
            Value<String> health = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<double> cpuPercent = const Value.absent(),
            Value<double> memBytes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ContainerSnapshotsCompanion(
            serverId: serverId,
            containerId: containerId,
            name: name,
            image: image,
            state: state,
            health: health,
            updatedAt: updatedAt,
            cpuPercent: cpuPercent,
            memBytes: memBytes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String serverId,
            required String containerId,
            required String name,
            required String image,
            required String state,
            Value<String> health = const Value.absent(),
            required DateTime updatedAt,
            Value<double> cpuPercent = const Value.absent(),
            Value<double> memBytes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ContainerSnapshotsCompanion.insert(
            serverId: serverId,
            containerId: containerId,
            name: name,
            image: image,
            state: state,
            health: health,
            updatedAt: updatedAt,
            cpuPercent: cpuPercent,
            memBytes: memBytes,
            rowid: rowid,
          ),
        ));
}

class $$ContainerSnapshotsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ContainerSnapshotsTable> {
  $$ContainerSnapshotsTableFilterComposer(super.$state);
  ColumnFilters<String> get containerId => $state.composableBuilder(
      column: $state.table.containerId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get image => $state.composableBuilder(
      column: $state.table.image,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get state => $state.composableBuilder(
      column: $state.table.state,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get health => $state.composableBuilder(
      column: $state.table.health,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get cpuPercent => $state.composableBuilder(
      column: $state.table.cpuPercent,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get memBytes => $state.composableBuilder(
      column: $state.table.memBytes,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$ServersTableFilterComposer get serverId {
    final $$ServersTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.serverId,
        referencedTable: $state.db.servers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$ServersTableFilterComposer(
            ComposerState(
                $state.db, $state.db.servers, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$ContainerSnapshotsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ContainerSnapshotsTable> {
  $$ContainerSnapshotsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get containerId => $state.composableBuilder(
      column: $state.table.containerId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get image => $state.composableBuilder(
      column: $state.table.image,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get state => $state.composableBuilder(
      column: $state.table.state,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get health => $state.composableBuilder(
      column: $state.table.health,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get cpuPercent => $state.composableBuilder(
      column: $state.table.cpuPercent,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get memBytes => $state.composableBuilder(
      column: $state.table.memBytes,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$ServersTableOrderingComposer get serverId {
    final $$ServersTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.serverId,
        referencedTable: $state.db.servers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ServersTableOrderingComposer(ComposerState(
                $state.db, $state.db.servers, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$SessionsTableCreateCompanionBuilder = SessionsCompanion Function({
  required String id,
  required String serverId,
  required String kind,
  required String payloadJson,
  required DateTime lastActiveAt,
  Value<int> rowid,
});
typedef $$SessionsTableUpdateCompanionBuilder = SessionsCompanion Function({
  Value<String> id,
  Value<String> serverId,
  Value<String> kind,
  Value<String> payloadJson,
  Value<DateTime> lastActiveAt,
  Value<int> rowid,
});

class $$SessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SessionsTable,
    Session,
    $$SessionsTableFilterComposer,
    $$SessionsTableOrderingComposer,
    $$SessionsTableCreateCompanionBuilder,
    $$SessionsTableUpdateCompanionBuilder> {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$SessionsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$SessionsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> serverId = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<DateTime> lastActiveAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SessionsCompanion(
            id: id,
            serverId: serverId,
            kind: kind,
            payloadJson: payloadJson,
            lastActiveAt: lastActiveAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String serverId,
            required String kind,
            required String payloadJson,
            required DateTime lastActiveAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SessionsCompanion.insert(
            id: id,
            serverId: serverId,
            kind: kind,
            payloadJson: payloadJson,
            lastActiveAt: lastActiveAt,
            rowid: rowid,
          ),
        ));
}

class $$SessionsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get kind => $state.composableBuilder(
      column: $state.table.kind,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get payloadJson => $state.composableBuilder(
      column: $state.table.payloadJson,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get lastActiveAt => $state.composableBuilder(
      column: $state.table.lastActiveAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$ServersTableFilterComposer get serverId {
    final $$ServersTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.serverId,
        referencedTable: $state.db.servers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$ServersTableFilterComposer(
            ComposerState(
                $state.db, $state.db.servers, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$SessionsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get kind => $state.composableBuilder(
      column: $state.table.kind,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get payloadJson => $state.composableBuilder(
      column: $state.table.payloadJson,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get lastActiveAt => $state.composableBuilder(
      column: $state.table.lastActiveAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$ServersTableOrderingComposer get serverId {
    final $$ServersTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.serverId,
        referencedTable: $state.db.servers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ServersTableOrderingComposer(ComposerState(
                $state.db, $state.db.servers, joinBuilder, parentComposers)));
    return composer;
  }
}

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ServersTableTableManager get servers =>
      $$ServersTableTableManager(_db, _db.servers);
  $$MetricSamplesTableTableManager get metricSamples =>
      $$MetricSamplesTableTableManager(_db, _db.metricSamples);
  $$AlertsTableTableManager get alerts =>
      $$AlertsTableTableManager(_db, _db.alerts);
  $$OfflineOpsTableTableManager get offlineOps =>
      $$OfflineOpsTableTableManager(_db, _db.offlineOps);
  $$ThresholdOverridesTableTableManager get thresholdOverrides =>
      $$ThresholdOverridesTableTableManager(_db, _db.thresholdOverrides);
  $$ContainerSnapshotsTableTableManager get containerSnapshots =>
      $$ContainerSnapshotsTableTableManager(_db, _db.containerSnapshots);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
}
