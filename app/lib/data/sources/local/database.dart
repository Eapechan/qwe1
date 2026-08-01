import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class Servers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get agentUrl => text()();
  TextColumn get groupName => text().withDefault(const Constant(''))();
  BoolColumn get readOnly => boolean().withDefault(const Constant(false))();
  TextColumn get fingerprintHash => text().withDefault(const Constant(''))();
  TextColumn get status => text().withDefault(const Constant('unknown'))();
  TextColumn get deviceId => text().withDefault(const Constant(''))();
  DateTimeColumn get lastSeenAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get agentVersion => text().withDefault(const Constant(''))();
  TextColumn get capsJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {id};
}

class MetricSamples extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().references(Servers, #id)();
  DateTimeColumn get ts => dateTime()();
  RealColumn get cpuPercent => real().withDefault(const Constant(0.0))();
  RealColumn get memPercent => real().withDefault(const Constant(0.0))();
  RealColumn get diskPercent => real().withDefault(const Constant(0.0))();
  RealColumn get netRxBps => real().withDefault(const Constant(0.0))();
  RealColumn get netTxBps => real().withDefault(const Constant(0.0))();
  RealColumn get tempCelsius => real().withDefault(const Constant(0.0))();
  RealColumn get load1 => real().withDefault(const Constant(0.0))();

  @override
  List<Set<Column>> get uniqueKeys => [{serverId, ts}];
}

class Alerts extends Table {
  TextColumn get id => text()();
  TextColumn get serverId => text().references(Servers, #id)();
  TextColumn get alertType => text()();
  TextColumn get severity => text()();
  TextColumn get message => text()();
  DateTimeColumn get at => dateTime()();
  BoolColumn get acked => boolean().withDefault(const Constant(false))();
  TextColumn get contextJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {id};
}

class OfflineOps extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().references(Servers, #id)();
  TextColumn get kind => text()();
  TextColumn get payloadJson => text()();
  IntColumn get createdOrder => integer()();
  TextColumn get state => text().withDefault(const Constant('pending'))();
}

class ThresholdOverrides extends Table {
  TextColumn get serverId => text().references(Servers, #id)();
  TextColumn get key => text()();
  RealColumn get value => real()();
  IntColumn get forSeconds => integer().withDefault(const Constant(60))();

  @override
  Set<Column> get primaryKey => {serverId, key};
}

class ContainerSnapshots extends Table {
  TextColumn get serverId => text().references(Servers, #id)();
  TextColumn get containerId => text()();
  TextColumn get name => text()();
  TextColumn get image => text()();
  TextColumn get state => text()();
  TextColumn get health => text().withDefault(const Constant(''))();
  DateTimeColumn get updatedAt => dateTime()();
  RealColumn get cpuPercent => real().withDefault(const Constant(0.0))();
  RealColumn get memBytes => real().withDefault(const Constant(0.0))();

  @override
  Set<Column> get primaryKey => {serverId, containerId};
}

class Sessions extends Table {
  TextColumn get id => text()();
  TextColumn get serverId => text().references(Servers, #id)();
  TextColumn get kind => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get lastActiveAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  Servers,
  MetricSamples,
  Alerts,
  OfflineOps,
  ThresholdOverrides,
  ContainerSnapshots,
  Sessions,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // Future migrations go here
        },
      );

  // Server operations
  Future<List<Server>> getAllServers() => select(servers).get();

  Future<Server?> getServer(String id) =>
      (select(servers)..where((s) => s.id.equals(id))).getSingleOrNull();

  Future<void> insertServer(ServersCompanion server) => into(servers).insert(server);

  Future<void> updateServer(ServersCompanion server) => update(servers).replace(server);

  Future<void> deleteServer(String id) =>
      (delete(servers)..where((s) => s.id.equals(id))).go();

  // Metric operations
  Future<void> insertMetric(MetricSamplesCompanion metric) =>
      into(metricSamples).insert(metric);

  Future<List<MetricSample>> getMetricsForServer(
    String serverId, {
    DateTime? since,
    int limit = 100,
  }) {
    final query = select(metricSamples)
      ..where((m) => m.serverId.equals(serverId))
      ..orderBy([(m) => OrderingTerm.desc(m.ts)])
      ..limit(limit);

    if (since != null) {
      query.where((m) => m.ts.isBiggerOrEqualValue(since));
    }

    return query.get();
  }

  Future<void> cleanupOldMetrics(DateTime before) =>
      (delete(metricSamples)..where((m) => m.ts.isSmallerThanValue(before))).go();

  // Alert operations
  Future<List<Alert>> getAlertsForServer(
    String serverId, {
    String? severity,
    DateTime? since,
  }) {
    final query = select(alerts)
      ..where((a) => a.serverId.equals(serverId))
      ..orderBy([(a) => OrderingTerm.desc(a.at)]);

    if (severity != null) {
      query.where((a) => a.severity.equals(severity));
    }
    if (since != null) {
      query.where((a) => a.at.isBiggerOrEqualValue(since));
    }

    return query.get();
  }

  Future<void> insertAlert(AlertsCompanion alert) => into(alerts).insert(alert);

  Future<void> acknowledgeAlert(String id) =>
      (update(alerts)..where((a) => a.id.equals(id)))
          .write(AlertsCompanion(acked: const Value(true)));

  // Container snapshot operations
  Future<List<ContainerSnapshot>> getContainerSnapshots(String serverId) =>
      (select(containerSnapshots)
            ..where((c) => c.serverId.equals(serverId))
            ..orderBy([(c) => OrderingTerm.asc(c.name)]))
          .get();

  Future<void> upsertContainerSnapshot(ContainerSnapshotsCompanion snapshot) =>
      into(containerSnapshots).insertOnConflictUpdate(snapshot);

  // Session operations
  Future<List<Session>> getSessions(String serverId) =>
      (select(sessions)
            ..where((s) => s.serverId.equals(serverId))
            ..orderBy([(s) => OrderingTerm.desc(s.lastActiveAt)]))
          .get();

  Future<void> insertSession(SessionsCompanion session) => into(sessions).insert(session);

  Future<void> deleteSession(String id) =>
      (delete(sessions)..where((s) => s.id.equals(id))).go();

  // Offline operations
  Future<List<OfflineOp>> getPendingOfflineOps() =>
      (select(offlineOps)
            ..where((o) => o.state.equals('pending'))
            ..orderBy([(o) => OrderingTerm.asc(o.createdOrder)]))
          .get();

  Future<void> insertOfflineOp(OfflineOpsCompanion op) => into(offlineOps).insert(op);

  Future<void> markOfflineOpComplete(int id) =>
      (update(offlineOps)..where((o) => o.id.equals(id)))
          .write(OfflineOpsCompanion(state: const Value('completed')));
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'qwe1.sqlite'));
    return NativeDatabase(file);
  });
}
