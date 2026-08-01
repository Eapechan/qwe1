// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'metrics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$HostMetrics {
  DateTime get timestamp => throw _privateConstructorUsedError;
  HostInfo get host => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $HostMetricsCopyWith<HostMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HostMetricsCopyWith<$Res> {
  factory $HostMetricsCopyWith(
          HostMetrics value, $Res Function(HostMetrics) then) =
      _$HostMetricsCopyWithImpl<$Res, HostMetrics>;
  @useResult
  $Res call({DateTime timestamp, HostInfo host});

  $HostInfoCopyWith<$Res> get host;
}

/// @nodoc
class _$HostMetricsCopyWithImpl<$Res, $Val extends HostMetrics>
    implements $HostMetricsCopyWith<$Res> {
  _$HostMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? host = null,
  }) {
    return _then(_value.copyWith(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      host: null == host
          ? _value.host
          : host // ignore: cast_nullable_to_non_nullable
              as HostInfo,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $HostInfoCopyWith<$Res> get host {
    return $HostInfoCopyWith<$Res>(_value.host, (value) {
      return _then(_value.copyWith(host: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$HostMetricsImplCopyWith<$Res>
    implements $HostMetricsCopyWith<$Res> {
  factory _$$HostMetricsImplCopyWith(
          _$HostMetricsImpl value, $Res Function(_$HostMetricsImpl) then) =
      __$$HostMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime timestamp, HostInfo host});

  @override
  $HostInfoCopyWith<$Res> get host;
}

/// @nodoc
class __$$HostMetricsImplCopyWithImpl<$Res>
    extends _$HostMetricsCopyWithImpl<$Res, _$HostMetricsImpl>
    implements _$$HostMetricsImplCopyWith<$Res> {
  __$$HostMetricsImplCopyWithImpl(
      _$HostMetricsImpl _value, $Res Function(_$HostMetricsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? host = null,
  }) {
    return _then(_$HostMetricsImpl(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      host: null == host
          ? _value.host
          : host // ignore: cast_nullable_to_non_nullable
              as HostInfo,
    ));
  }
}

/// @nodoc

class _$HostMetricsImpl implements _HostMetrics {
  const _$HostMetricsImpl({required this.timestamp, required this.host});

  @override
  final DateTime timestamp;
  @override
  final HostInfo host;

  @override
  String toString() {
    return 'HostMetrics(timestamp: $timestamp, host: $host)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HostMetricsImpl &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.host, host) || other.host == host));
  }

  @override
  int get hashCode => Object.hash(runtimeType, timestamp, host);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HostMetricsImplCopyWith<_$HostMetricsImpl> get copyWith =>
      __$$HostMetricsImplCopyWithImpl<_$HostMetricsImpl>(this, _$identity);
}

abstract class _HostMetrics implements HostMetrics {
  const factory _HostMetrics(
      {required final DateTime timestamp,
      required final HostInfo host}) = _$HostMetricsImpl;

  @override
  DateTime get timestamp;
  @override
  HostInfo get host;
  @override
  @JsonKey(ignore: true)
  _$$HostMetricsImplCopyWith<_$HostMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$HostInfo {
  String get hostname => throw _privateConstructorUsedError;
  int get uptimeSeconds => throw _privateConstructorUsedError;
  List<double> get load => throw _privateConstructorUsedError;
  CpuMetrics get cpu => throw _privateConstructorUsedError;
  MemoryMetrics get memory => throw _privateConstructorUsedError;
  List<DiskMetrics> get disk => throw _privateConstructorUsedError;
  NetworkMetrics get network => throw _privateConstructorUsedError;
  List<TempSensor> get sensors => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $HostInfoCopyWith<HostInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HostInfoCopyWith<$Res> {
  factory $HostInfoCopyWith(HostInfo value, $Res Function(HostInfo) then) =
      _$HostInfoCopyWithImpl<$Res, HostInfo>;
  @useResult
  $Res call(
      {String hostname,
      int uptimeSeconds,
      List<double> load,
      CpuMetrics cpu,
      MemoryMetrics memory,
      List<DiskMetrics> disk,
      NetworkMetrics network,
      List<TempSensor> sensors});

  $CpuMetricsCopyWith<$Res> get cpu;
  $MemoryMetricsCopyWith<$Res> get memory;
  $NetworkMetricsCopyWith<$Res> get network;
}

/// @nodoc
class _$HostInfoCopyWithImpl<$Res, $Val extends HostInfo>
    implements $HostInfoCopyWith<$Res> {
  _$HostInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hostname = null,
    Object? uptimeSeconds = null,
    Object? load = null,
    Object? cpu = null,
    Object? memory = null,
    Object? disk = null,
    Object? network = null,
    Object? sensors = null,
  }) {
    return _then(_value.copyWith(
      hostname: null == hostname
          ? _value.hostname
          : hostname // ignore: cast_nullable_to_non_nullable
              as String,
      uptimeSeconds: null == uptimeSeconds
          ? _value.uptimeSeconds
          : uptimeSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      load: null == load
          ? _value.load
          : load // ignore: cast_nullable_to_non_nullable
              as List<double>,
      cpu: null == cpu
          ? _value.cpu
          : cpu // ignore: cast_nullable_to_non_nullable
              as CpuMetrics,
      memory: null == memory
          ? _value.memory
          : memory // ignore: cast_nullable_to_non_nullable
              as MemoryMetrics,
      disk: null == disk
          ? _value.disk
          : disk // ignore: cast_nullable_to_non_nullable
              as List<DiskMetrics>,
      network: null == network
          ? _value.network
          : network // ignore: cast_nullable_to_non_nullable
              as NetworkMetrics,
      sensors: null == sensors
          ? _value.sensors
          : sensors // ignore: cast_nullable_to_non_nullable
              as List<TempSensor>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $CpuMetricsCopyWith<$Res> get cpu {
    return $CpuMetricsCopyWith<$Res>(_value.cpu, (value) {
      return _then(_value.copyWith(cpu: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $MemoryMetricsCopyWith<$Res> get memory {
    return $MemoryMetricsCopyWith<$Res>(_value.memory, (value) {
      return _then(_value.copyWith(memory: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $NetworkMetricsCopyWith<$Res> get network {
    return $NetworkMetricsCopyWith<$Res>(_value.network, (value) {
      return _then(_value.copyWith(network: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$HostInfoImplCopyWith<$Res>
    implements $HostInfoCopyWith<$Res> {
  factory _$$HostInfoImplCopyWith(
          _$HostInfoImpl value, $Res Function(_$HostInfoImpl) then) =
      __$$HostInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String hostname,
      int uptimeSeconds,
      List<double> load,
      CpuMetrics cpu,
      MemoryMetrics memory,
      List<DiskMetrics> disk,
      NetworkMetrics network,
      List<TempSensor> sensors});

  @override
  $CpuMetricsCopyWith<$Res> get cpu;
  @override
  $MemoryMetricsCopyWith<$Res> get memory;
  @override
  $NetworkMetricsCopyWith<$Res> get network;
}

/// @nodoc
class __$$HostInfoImplCopyWithImpl<$Res>
    extends _$HostInfoCopyWithImpl<$Res, _$HostInfoImpl>
    implements _$$HostInfoImplCopyWith<$Res> {
  __$$HostInfoImplCopyWithImpl(
      _$HostInfoImpl _value, $Res Function(_$HostInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hostname = null,
    Object? uptimeSeconds = null,
    Object? load = null,
    Object? cpu = null,
    Object? memory = null,
    Object? disk = null,
    Object? network = null,
    Object? sensors = null,
  }) {
    return _then(_$HostInfoImpl(
      hostname: null == hostname
          ? _value.hostname
          : hostname // ignore: cast_nullable_to_non_nullable
              as String,
      uptimeSeconds: null == uptimeSeconds
          ? _value.uptimeSeconds
          : uptimeSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      load: null == load
          ? _value._load
          : load // ignore: cast_nullable_to_non_nullable
              as List<double>,
      cpu: null == cpu
          ? _value.cpu
          : cpu // ignore: cast_nullable_to_non_nullable
              as CpuMetrics,
      memory: null == memory
          ? _value.memory
          : memory // ignore: cast_nullable_to_non_nullable
              as MemoryMetrics,
      disk: null == disk
          ? _value._disk
          : disk // ignore: cast_nullable_to_non_nullable
              as List<DiskMetrics>,
      network: null == network
          ? _value.network
          : network // ignore: cast_nullable_to_non_nullable
              as NetworkMetrics,
      sensors: null == sensors
          ? _value._sensors
          : sensors // ignore: cast_nullable_to_non_nullable
              as List<TempSensor>,
    ));
  }
}

/// @nodoc

class _$HostInfoImpl implements _HostInfo {
  const _$HostInfoImpl(
      {required this.hostname,
      required this.uptimeSeconds,
      final List<double> load = const [],
      required this.cpu,
      required this.memory,
      final List<DiskMetrics> disk = const [],
      required this.network,
      final List<TempSensor> sensors = const []})
      : _load = load,
        _disk = disk,
        _sensors = sensors;

  @override
  final String hostname;
  @override
  final int uptimeSeconds;
  final List<double> _load;
  @override
  @JsonKey()
  List<double> get load {
    if (_load is EqualUnmodifiableListView) return _load;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_load);
  }

  @override
  final CpuMetrics cpu;
  @override
  final MemoryMetrics memory;
  final List<DiskMetrics> _disk;
  @override
  @JsonKey()
  List<DiskMetrics> get disk {
    if (_disk is EqualUnmodifiableListView) return _disk;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_disk);
  }

  @override
  final NetworkMetrics network;
  final List<TempSensor> _sensors;
  @override
  @JsonKey()
  List<TempSensor> get sensors {
    if (_sensors is EqualUnmodifiableListView) return _sensors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sensors);
  }

  @override
  String toString() {
    return 'HostInfo(hostname: $hostname, uptimeSeconds: $uptimeSeconds, load: $load, cpu: $cpu, memory: $memory, disk: $disk, network: $network, sensors: $sensors)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HostInfoImpl &&
            (identical(other.hostname, hostname) ||
                other.hostname == hostname) &&
            (identical(other.uptimeSeconds, uptimeSeconds) ||
                other.uptimeSeconds == uptimeSeconds) &&
            const DeepCollectionEquality().equals(other._load, _load) &&
            (identical(other.cpu, cpu) || other.cpu == cpu) &&
            (identical(other.memory, memory) || other.memory == memory) &&
            const DeepCollectionEquality().equals(other._disk, _disk) &&
            (identical(other.network, network) || other.network == network) &&
            const DeepCollectionEquality().equals(other._sensors, _sensors));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      hostname,
      uptimeSeconds,
      const DeepCollectionEquality().hash(_load),
      cpu,
      memory,
      const DeepCollectionEquality().hash(_disk),
      network,
      const DeepCollectionEquality().hash(_sensors));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HostInfoImplCopyWith<_$HostInfoImpl> get copyWith =>
      __$$HostInfoImplCopyWithImpl<_$HostInfoImpl>(this, _$identity);
}

abstract class _HostInfo implements HostInfo {
  const factory _HostInfo(
      {required final String hostname,
      required final int uptimeSeconds,
      final List<double> load,
      required final CpuMetrics cpu,
      required final MemoryMetrics memory,
      final List<DiskMetrics> disk,
      required final NetworkMetrics network,
      final List<TempSensor> sensors}) = _$HostInfoImpl;

  @override
  String get hostname;
  @override
  int get uptimeSeconds;
  @override
  List<double> get load;
  @override
  CpuMetrics get cpu;
  @override
  MemoryMetrics get memory;
  @override
  List<DiskMetrics> get disk;
  @override
  NetworkMetrics get network;
  @override
  List<TempSensor> get sensors;
  @override
  @JsonKey(ignore: true)
  _$$HostInfoImplCopyWith<_$HostInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CpuMetrics {
  double get percent => throw _privateConstructorUsedError;
  List<double> get perCore => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CpuMetricsCopyWith<CpuMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CpuMetricsCopyWith<$Res> {
  factory $CpuMetricsCopyWith(
          CpuMetrics value, $Res Function(CpuMetrics) then) =
      _$CpuMetricsCopyWithImpl<$Res, CpuMetrics>;
  @useResult
  $Res call({double percent, List<double> perCore});
}

/// @nodoc
class _$CpuMetricsCopyWithImpl<$Res, $Val extends CpuMetrics>
    implements $CpuMetricsCopyWith<$Res> {
  _$CpuMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? percent = null,
    Object? perCore = null,
  }) {
    return _then(_value.copyWith(
      percent: null == percent
          ? _value.percent
          : percent // ignore: cast_nullable_to_non_nullable
              as double,
      perCore: null == perCore
          ? _value.perCore
          : perCore // ignore: cast_nullable_to_non_nullable
              as List<double>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CpuMetricsImplCopyWith<$Res>
    implements $CpuMetricsCopyWith<$Res> {
  factory _$$CpuMetricsImplCopyWith(
          _$CpuMetricsImpl value, $Res Function(_$CpuMetricsImpl) then) =
      __$$CpuMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double percent, List<double> perCore});
}

/// @nodoc
class __$$CpuMetricsImplCopyWithImpl<$Res>
    extends _$CpuMetricsCopyWithImpl<$Res, _$CpuMetricsImpl>
    implements _$$CpuMetricsImplCopyWith<$Res> {
  __$$CpuMetricsImplCopyWithImpl(
      _$CpuMetricsImpl _value, $Res Function(_$CpuMetricsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? percent = null,
    Object? perCore = null,
  }) {
    return _then(_$CpuMetricsImpl(
      percent: null == percent
          ? _value.percent
          : percent // ignore: cast_nullable_to_non_nullable
              as double,
      perCore: null == perCore
          ? _value._perCore
          : perCore // ignore: cast_nullable_to_non_nullable
              as List<double>,
    ));
  }
}

/// @nodoc

class _$CpuMetricsImpl implements _CpuMetrics {
  const _$CpuMetricsImpl(
      {required this.percent, final List<double> perCore = const []})
      : _perCore = perCore;

  @override
  final double percent;
  final List<double> _perCore;
  @override
  @JsonKey()
  List<double> get perCore {
    if (_perCore is EqualUnmodifiableListView) return _perCore;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_perCore);
  }

  @override
  String toString() {
    return 'CpuMetrics(percent: $percent, perCore: $perCore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CpuMetricsImpl &&
            (identical(other.percent, percent) || other.percent == percent) &&
            const DeepCollectionEquality().equals(other._perCore, _perCore));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, percent, const DeepCollectionEquality().hash(_perCore));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CpuMetricsImplCopyWith<_$CpuMetricsImpl> get copyWith =>
      __$$CpuMetricsImplCopyWithImpl<_$CpuMetricsImpl>(this, _$identity);
}

abstract class _CpuMetrics implements CpuMetrics {
  const factory _CpuMetrics(
      {required final double percent,
      final List<double> perCore}) = _$CpuMetricsImpl;

  @override
  double get percent;
  @override
  List<double> get perCore;
  @override
  @JsonKey(ignore: true)
  _$$CpuMetricsImplCopyWith<_$CpuMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MemoryMetrics {
  int get total => throw _privateConstructorUsedError;
  int get used => throw _privateConstructorUsedError;
  double get percent => throw _privateConstructorUsedError;
  double get swapPercent => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MemoryMetricsCopyWith<MemoryMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MemoryMetricsCopyWith<$Res> {
  factory $MemoryMetricsCopyWith(
          MemoryMetrics value, $Res Function(MemoryMetrics) then) =
      _$MemoryMetricsCopyWithImpl<$Res, MemoryMetrics>;
  @useResult
  $Res call({int total, int used, double percent, double swapPercent});
}

/// @nodoc
class _$MemoryMetricsCopyWithImpl<$Res, $Val extends MemoryMetrics>
    implements $MemoryMetricsCopyWith<$Res> {
  _$MemoryMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? used = null,
    Object? percent = null,
    Object? swapPercent = null,
  }) {
    return _then(_value.copyWith(
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      used: null == used
          ? _value.used
          : used // ignore: cast_nullable_to_non_nullable
              as int,
      percent: null == percent
          ? _value.percent
          : percent // ignore: cast_nullable_to_non_nullable
              as double,
      swapPercent: null == swapPercent
          ? _value.swapPercent
          : swapPercent // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MemoryMetricsImplCopyWith<$Res>
    implements $MemoryMetricsCopyWith<$Res> {
  factory _$$MemoryMetricsImplCopyWith(
          _$MemoryMetricsImpl value, $Res Function(_$MemoryMetricsImpl) then) =
      __$$MemoryMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int total, int used, double percent, double swapPercent});
}

/// @nodoc
class __$$MemoryMetricsImplCopyWithImpl<$Res>
    extends _$MemoryMetricsCopyWithImpl<$Res, _$MemoryMetricsImpl>
    implements _$$MemoryMetricsImplCopyWith<$Res> {
  __$$MemoryMetricsImplCopyWithImpl(
      _$MemoryMetricsImpl _value, $Res Function(_$MemoryMetricsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? used = null,
    Object? percent = null,
    Object? swapPercent = null,
  }) {
    return _then(_$MemoryMetricsImpl(
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      used: null == used
          ? _value.used
          : used // ignore: cast_nullable_to_non_nullable
              as int,
      percent: null == percent
          ? _value.percent
          : percent // ignore: cast_nullable_to_non_nullable
              as double,
      swapPercent: null == swapPercent
          ? _value.swapPercent
          : swapPercent // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$MemoryMetricsImpl implements _MemoryMetrics {
  const _$MemoryMetricsImpl(
      {required this.total,
      required this.used,
      required this.percent,
      this.swapPercent = 0.0});

  @override
  final int total;
  @override
  final int used;
  @override
  final double percent;
  @override
  @JsonKey()
  final double swapPercent;

  @override
  String toString() {
    return 'MemoryMetrics(total: $total, used: $used, percent: $percent, swapPercent: $swapPercent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MemoryMetricsImpl &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.used, used) || other.used == used) &&
            (identical(other.percent, percent) || other.percent == percent) &&
            (identical(other.swapPercent, swapPercent) ||
                other.swapPercent == swapPercent));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, total, used, percent, swapPercent);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MemoryMetricsImplCopyWith<_$MemoryMetricsImpl> get copyWith =>
      __$$MemoryMetricsImplCopyWithImpl<_$MemoryMetricsImpl>(this, _$identity);
}

abstract class _MemoryMetrics implements MemoryMetrics {
  const factory _MemoryMetrics(
      {required final int total,
      required final int used,
      required final double percent,
      final double swapPercent}) = _$MemoryMetricsImpl;

  @override
  int get total;
  @override
  int get used;
  @override
  double get percent;
  @override
  double get swapPercent;
  @override
  @JsonKey(ignore: true)
  _$$MemoryMetricsImplCopyWith<_$MemoryMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$DiskMetrics {
  String get mount => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  int get used => throw _privateConstructorUsedError;
  double get percent => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DiskMetricsCopyWith<DiskMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiskMetricsCopyWith<$Res> {
  factory $DiskMetricsCopyWith(
          DiskMetrics value, $Res Function(DiskMetrics) then) =
      _$DiskMetricsCopyWithImpl<$Res, DiskMetrics>;
  @useResult
  $Res call({String mount, int total, int used, double percent});
}

/// @nodoc
class _$DiskMetricsCopyWithImpl<$Res, $Val extends DiskMetrics>
    implements $DiskMetricsCopyWith<$Res> {
  _$DiskMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mount = null,
    Object? total = null,
    Object? used = null,
    Object? percent = null,
  }) {
    return _then(_value.copyWith(
      mount: null == mount
          ? _value.mount
          : mount // ignore: cast_nullable_to_non_nullable
              as String,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      used: null == used
          ? _value.used
          : used // ignore: cast_nullable_to_non_nullable
              as int,
      percent: null == percent
          ? _value.percent
          : percent // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DiskMetricsImplCopyWith<$Res>
    implements $DiskMetricsCopyWith<$Res> {
  factory _$$DiskMetricsImplCopyWith(
          _$DiskMetricsImpl value, $Res Function(_$DiskMetricsImpl) then) =
      __$$DiskMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String mount, int total, int used, double percent});
}

/// @nodoc
class __$$DiskMetricsImplCopyWithImpl<$Res>
    extends _$DiskMetricsCopyWithImpl<$Res, _$DiskMetricsImpl>
    implements _$$DiskMetricsImplCopyWith<$Res> {
  __$$DiskMetricsImplCopyWithImpl(
      _$DiskMetricsImpl _value, $Res Function(_$DiskMetricsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mount = null,
    Object? total = null,
    Object? used = null,
    Object? percent = null,
  }) {
    return _then(_$DiskMetricsImpl(
      mount: null == mount
          ? _value.mount
          : mount // ignore: cast_nullable_to_non_nullable
              as String,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      used: null == used
          ? _value.used
          : used // ignore: cast_nullable_to_non_nullable
              as int,
      percent: null == percent
          ? _value.percent
          : percent // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$DiskMetricsImpl implements _DiskMetrics {
  const _$DiskMetricsImpl(
      {required this.mount,
      required this.total,
      required this.used,
      required this.percent});

  @override
  final String mount;
  @override
  final int total;
  @override
  final int used;
  @override
  final double percent;

  @override
  String toString() {
    return 'DiskMetrics(mount: $mount, total: $total, used: $used, percent: $percent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiskMetricsImpl &&
            (identical(other.mount, mount) || other.mount == mount) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.used, used) || other.used == used) &&
            (identical(other.percent, percent) || other.percent == percent));
  }

  @override
  int get hashCode => Object.hash(runtimeType, mount, total, used, percent);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DiskMetricsImplCopyWith<_$DiskMetricsImpl> get copyWith =>
      __$$DiskMetricsImplCopyWithImpl<_$DiskMetricsImpl>(this, _$identity);
}

abstract class _DiskMetrics implements DiskMetrics {
  const factory _DiskMetrics(
      {required final String mount,
      required final int total,
      required final int used,
      required final double percent}) = _$DiskMetricsImpl;

  @override
  String get mount;
  @override
  int get total;
  @override
  int get used;
  @override
  double get percent;
  @override
  @JsonKey(ignore: true)
  _$$DiskMetricsImplCopyWith<_$DiskMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$NetworkMetrics {
  double get rxBytesPerSec => throw _privateConstructorUsedError;
  double get txBytesPerSec => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $NetworkMetricsCopyWith<NetworkMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NetworkMetricsCopyWith<$Res> {
  factory $NetworkMetricsCopyWith(
          NetworkMetrics value, $Res Function(NetworkMetrics) then) =
      _$NetworkMetricsCopyWithImpl<$Res, NetworkMetrics>;
  @useResult
  $Res call({double rxBytesPerSec, double txBytesPerSec});
}

/// @nodoc
class _$NetworkMetricsCopyWithImpl<$Res, $Val extends NetworkMetrics>
    implements $NetworkMetricsCopyWith<$Res> {
  _$NetworkMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rxBytesPerSec = null,
    Object? txBytesPerSec = null,
  }) {
    return _then(_value.copyWith(
      rxBytesPerSec: null == rxBytesPerSec
          ? _value.rxBytesPerSec
          : rxBytesPerSec // ignore: cast_nullable_to_non_nullable
              as double,
      txBytesPerSec: null == txBytesPerSec
          ? _value.txBytesPerSec
          : txBytesPerSec // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NetworkMetricsImplCopyWith<$Res>
    implements $NetworkMetricsCopyWith<$Res> {
  factory _$$NetworkMetricsImplCopyWith(_$NetworkMetricsImpl value,
          $Res Function(_$NetworkMetricsImpl) then) =
      __$$NetworkMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double rxBytesPerSec, double txBytesPerSec});
}

/// @nodoc
class __$$NetworkMetricsImplCopyWithImpl<$Res>
    extends _$NetworkMetricsCopyWithImpl<$Res, _$NetworkMetricsImpl>
    implements _$$NetworkMetricsImplCopyWith<$Res> {
  __$$NetworkMetricsImplCopyWithImpl(
      _$NetworkMetricsImpl _value, $Res Function(_$NetworkMetricsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rxBytesPerSec = null,
    Object? txBytesPerSec = null,
  }) {
    return _then(_$NetworkMetricsImpl(
      rxBytesPerSec: null == rxBytesPerSec
          ? _value.rxBytesPerSec
          : rxBytesPerSec // ignore: cast_nullable_to_non_nullable
              as double,
      txBytesPerSec: null == txBytesPerSec
          ? _value.txBytesPerSec
          : txBytesPerSec // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$NetworkMetricsImpl implements _NetworkMetrics {
  const _$NetworkMetricsImpl(
      {this.rxBytesPerSec = 0.0, this.txBytesPerSec = 0.0});

  @override
  @JsonKey()
  final double rxBytesPerSec;
  @override
  @JsonKey()
  final double txBytesPerSec;

  @override
  String toString() {
    return 'NetworkMetrics(rxBytesPerSec: $rxBytesPerSec, txBytesPerSec: $txBytesPerSec)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NetworkMetricsImpl &&
            (identical(other.rxBytesPerSec, rxBytesPerSec) ||
                other.rxBytesPerSec == rxBytesPerSec) &&
            (identical(other.txBytesPerSec, txBytesPerSec) ||
                other.txBytesPerSec == txBytesPerSec));
  }

  @override
  int get hashCode => Object.hash(runtimeType, rxBytesPerSec, txBytesPerSec);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NetworkMetricsImplCopyWith<_$NetworkMetricsImpl> get copyWith =>
      __$$NetworkMetricsImplCopyWithImpl<_$NetworkMetricsImpl>(
          this, _$identity);
}

abstract class _NetworkMetrics implements NetworkMetrics {
  const factory _NetworkMetrics(
      {final double rxBytesPerSec,
      final double txBytesPerSec}) = _$NetworkMetricsImpl;

  @override
  double get rxBytesPerSec;
  @override
  double get txBytesPerSec;
  @override
  @JsonKey(ignore: true)
  _$$NetworkMetricsImplCopyWith<_$NetworkMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$TempSensor {
  String get name => throw _privateConstructorUsedError;
  double get celsius => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TempSensorCopyWith<TempSensor> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TempSensorCopyWith<$Res> {
  factory $TempSensorCopyWith(
          TempSensor value, $Res Function(TempSensor) then) =
      _$TempSensorCopyWithImpl<$Res, TempSensor>;
  @useResult
  $Res call({String name, double celsius});
}

/// @nodoc
class _$TempSensorCopyWithImpl<$Res, $Val extends TempSensor>
    implements $TempSensorCopyWith<$Res> {
  _$TempSensorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? celsius = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      celsius: null == celsius
          ? _value.celsius
          : celsius // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TempSensorImplCopyWith<$Res>
    implements $TempSensorCopyWith<$Res> {
  factory _$$TempSensorImplCopyWith(
          _$TempSensorImpl value, $Res Function(_$TempSensorImpl) then) =
      __$$TempSensorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, double celsius});
}

/// @nodoc
class __$$TempSensorImplCopyWithImpl<$Res>
    extends _$TempSensorCopyWithImpl<$Res, _$TempSensorImpl>
    implements _$$TempSensorImplCopyWith<$Res> {
  __$$TempSensorImplCopyWithImpl(
      _$TempSensorImpl _value, $Res Function(_$TempSensorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? celsius = null,
  }) {
    return _then(_$TempSensorImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      celsius: null == celsius
          ? _value.celsius
          : celsius // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$TempSensorImpl implements _TempSensor {
  const _$TempSensorImpl({required this.name, required this.celsius});

  @override
  final String name;
  @override
  final double celsius;

  @override
  String toString() {
    return 'TempSensor(name: $name, celsius: $celsius)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TempSensorImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.celsius, celsius) || other.celsius == celsius));
  }

  @override
  int get hashCode => Object.hash(runtimeType, name, celsius);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TempSensorImplCopyWith<_$TempSensorImpl> get copyWith =>
      __$$TempSensorImplCopyWithImpl<_$TempSensorImpl>(this, _$identity);
}

abstract class _TempSensor implements TempSensor {
  const factory _TempSensor(
      {required final String name,
      required final double celsius}) = _$TempSensorImpl;

  @override
  String get name;
  @override
  double get celsius;
  @override
  @JsonKey(ignore: true)
  _$$TempSensorImplCopyWith<_$TempSensorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
