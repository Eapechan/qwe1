// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'alert.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Alert {
  String get id => throw _privateConstructorUsedError;
  String get serverId => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  AlertSeverity get severity => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  DateTime get at => throw _privateConstructorUsedError;
  bool get acked => throw _privateConstructorUsedError;
  Map<String, dynamic> get context => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AlertCopyWith<Alert> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AlertCopyWith<$Res> {
  factory $AlertCopyWith(Alert value, $Res Function(Alert) then) =
      _$AlertCopyWithImpl<$Res, Alert>;
  @useResult
  $Res call(
      {String id,
      String serverId,
      String type,
      AlertSeverity severity,
      String message,
      DateTime at,
      bool acked,
      Map<String, dynamic> context});
}

/// @nodoc
class _$AlertCopyWithImpl<$Res, $Val extends Alert>
    implements $AlertCopyWith<$Res> {
  _$AlertCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? serverId = null,
    Object? type = null,
    Object? severity = null,
    Object? message = null,
    Object? at = null,
    Object? acked = null,
    Object? context = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      serverId: null == serverId
          ? _value.serverId
          : serverId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as AlertSeverity,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      at: null == at
          ? _value.at
          : at // ignore: cast_nullable_to_non_nullable
              as DateTime,
      acked: null == acked
          ? _value.acked
          : acked // ignore: cast_nullable_to_non_nullable
              as bool,
      context: null == context
          ? _value.context
          : context // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AlertImplCopyWith<$Res> implements $AlertCopyWith<$Res> {
  factory _$$AlertImplCopyWith(
          _$AlertImpl value, $Res Function(_$AlertImpl) then) =
      __$$AlertImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String serverId,
      String type,
      AlertSeverity severity,
      String message,
      DateTime at,
      bool acked,
      Map<String, dynamic> context});
}

/// @nodoc
class __$$AlertImplCopyWithImpl<$Res>
    extends _$AlertCopyWithImpl<$Res, _$AlertImpl>
    implements _$$AlertImplCopyWith<$Res> {
  __$$AlertImplCopyWithImpl(
      _$AlertImpl _value, $Res Function(_$AlertImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? serverId = null,
    Object? type = null,
    Object? severity = null,
    Object? message = null,
    Object? at = null,
    Object? acked = null,
    Object? context = null,
  }) {
    return _then(_$AlertImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      serverId: null == serverId
          ? _value.serverId
          : serverId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as AlertSeverity,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      at: null == at
          ? _value.at
          : at // ignore: cast_nullable_to_non_nullable
              as DateTime,
      acked: null == acked
          ? _value.acked
          : acked // ignore: cast_nullable_to_non_nullable
              as bool,
      context: null == context
          ? _value._context
          : context // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc

class _$AlertImpl implements _Alert {
  const _$AlertImpl(
      {required this.id,
      required this.serverId,
      required this.type,
      required this.severity,
      required this.message,
      required this.at,
      this.acked = false,
      final Map<String, dynamic> context = const {}})
      : _context = context;

  @override
  final String id;
  @override
  final String serverId;
  @override
  final String type;
  @override
  final AlertSeverity severity;
  @override
  final String message;
  @override
  final DateTime at;
  @override
  @JsonKey()
  final bool acked;
  final Map<String, dynamic> _context;
  @override
  @JsonKey()
  Map<String, dynamic> get context {
    if (_context is EqualUnmodifiableMapView) return _context;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_context);
  }

  @override
  String toString() {
    return 'Alert(id: $id, serverId: $serverId, type: $type, severity: $severity, message: $message, at: $at, acked: $acked, context: $context)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AlertImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.serverId, serverId) ||
                other.serverId == serverId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.at, at) || other.at == at) &&
            (identical(other.acked, acked) || other.acked == acked) &&
            const DeepCollectionEquality().equals(other._context, _context));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, serverId, type, severity,
      message, at, acked, const DeepCollectionEquality().hash(_context));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AlertImplCopyWith<_$AlertImpl> get copyWith =>
      __$$AlertImplCopyWithImpl<_$AlertImpl>(this, _$identity);
}

abstract class _Alert implements Alert {
  const factory _Alert(
      {required final String id,
      required final String serverId,
      required final String type,
      required final AlertSeverity severity,
      required final String message,
      required final DateTime at,
      final bool acked,
      final Map<String, dynamic> context}) = _$AlertImpl;

  @override
  String get id;
  @override
  String get serverId;
  @override
  String get type;
  @override
  AlertSeverity get severity;
  @override
  String get message;
  @override
  DateTime get at;
  @override
  bool get acked;
  @override
  Map<String, dynamic> get context;
  @override
  @JsonKey(ignore: true)
  _$$AlertImplCopyWith<_$AlertImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AlertThreshold {
  double get cpuPercent => throw _privateConstructorUsedError;
  int get cpuForSeconds => throw _privateConstructorUsedError;
  double get memPercent => throw _privateConstructorUsedError;
  int get memForSeconds => throw _privateConstructorUsedError;
  double get diskPercent => throw _privateConstructorUsedError;
  int get diskForSeconds => throw _privateConstructorUsedError;
  double get tempCelsius => throw _privateConstructorUsedError;
  int get tempForSeconds => throw _privateConstructorUsedError;
  bool get containerDown => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AlertThresholdCopyWith<AlertThreshold> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AlertThresholdCopyWith<$Res> {
  factory $AlertThresholdCopyWith(
          AlertThreshold value, $Res Function(AlertThreshold) then) =
      _$AlertThresholdCopyWithImpl<$Res, AlertThreshold>;
  @useResult
  $Res call(
      {double cpuPercent,
      int cpuForSeconds,
      double memPercent,
      int memForSeconds,
      double diskPercent,
      int diskForSeconds,
      double tempCelsius,
      int tempForSeconds,
      bool containerDown});
}

/// @nodoc
class _$AlertThresholdCopyWithImpl<$Res, $Val extends AlertThreshold>
    implements $AlertThresholdCopyWith<$Res> {
  _$AlertThresholdCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cpuPercent = null,
    Object? cpuForSeconds = null,
    Object? memPercent = null,
    Object? memForSeconds = null,
    Object? diskPercent = null,
    Object? diskForSeconds = null,
    Object? tempCelsius = null,
    Object? tempForSeconds = null,
    Object? containerDown = null,
  }) {
    return _then(_value.copyWith(
      cpuPercent: null == cpuPercent
          ? _value.cpuPercent
          : cpuPercent // ignore: cast_nullable_to_non_nullable
              as double,
      cpuForSeconds: null == cpuForSeconds
          ? _value.cpuForSeconds
          : cpuForSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      memPercent: null == memPercent
          ? _value.memPercent
          : memPercent // ignore: cast_nullable_to_non_nullable
              as double,
      memForSeconds: null == memForSeconds
          ? _value.memForSeconds
          : memForSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      diskPercent: null == diskPercent
          ? _value.diskPercent
          : diskPercent // ignore: cast_nullable_to_non_nullable
              as double,
      diskForSeconds: null == diskForSeconds
          ? _value.diskForSeconds
          : diskForSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      tempCelsius: null == tempCelsius
          ? _value.tempCelsius
          : tempCelsius // ignore: cast_nullable_to_non_nullable
              as double,
      tempForSeconds: null == tempForSeconds
          ? _value.tempForSeconds
          : tempForSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      containerDown: null == containerDown
          ? _value.containerDown
          : containerDown // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AlertThresholdImplCopyWith<$Res>
    implements $AlertThresholdCopyWith<$Res> {
  factory _$$AlertThresholdImplCopyWith(_$AlertThresholdImpl value,
          $Res Function(_$AlertThresholdImpl) then) =
      __$$AlertThresholdImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double cpuPercent,
      int cpuForSeconds,
      double memPercent,
      int memForSeconds,
      double diskPercent,
      int diskForSeconds,
      double tempCelsius,
      int tempForSeconds,
      bool containerDown});
}

/// @nodoc
class __$$AlertThresholdImplCopyWithImpl<$Res>
    extends _$AlertThresholdCopyWithImpl<$Res, _$AlertThresholdImpl>
    implements _$$AlertThresholdImplCopyWith<$Res> {
  __$$AlertThresholdImplCopyWithImpl(
      _$AlertThresholdImpl _value, $Res Function(_$AlertThresholdImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cpuPercent = null,
    Object? cpuForSeconds = null,
    Object? memPercent = null,
    Object? memForSeconds = null,
    Object? diskPercent = null,
    Object? diskForSeconds = null,
    Object? tempCelsius = null,
    Object? tempForSeconds = null,
    Object? containerDown = null,
  }) {
    return _then(_$AlertThresholdImpl(
      cpuPercent: null == cpuPercent
          ? _value.cpuPercent
          : cpuPercent // ignore: cast_nullable_to_non_nullable
              as double,
      cpuForSeconds: null == cpuForSeconds
          ? _value.cpuForSeconds
          : cpuForSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      memPercent: null == memPercent
          ? _value.memPercent
          : memPercent // ignore: cast_nullable_to_non_nullable
              as double,
      memForSeconds: null == memForSeconds
          ? _value.memForSeconds
          : memForSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      diskPercent: null == diskPercent
          ? _value.diskPercent
          : diskPercent // ignore: cast_nullable_to_non_nullable
              as double,
      diskForSeconds: null == diskForSeconds
          ? _value.diskForSeconds
          : diskForSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      tempCelsius: null == tempCelsius
          ? _value.tempCelsius
          : tempCelsius // ignore: cast_nullable_to_non_nullable
              as double,
      tempForSeconds: null == tempForSeconds
          ? _value.tempForSeconds
          : tempForSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      containerDown: null == containerDown
          ? _value.containerDown
          : containerDown // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$AlertThresholdImpl implements _AlertThreshold {
  const _$AlertThresholdImpl(
      {this.cpuPercent = 90.0,
      this.cpuForSeconds = 60,
      this.memPercent = 90.0,
      this.memForSeconds = 60,
      this.diskPercent = 85.0,
      this.diskForSeconds = 300,
      this.tempCelsius = 75.0,
      this.tempForSeconds = 300,
      this.containerDown = true});

  @override
  @JsonKey()
  final double cpuPercent;
  @override
  @JsonKey()
  final int cpuForSeconds;
  @override
  @JsonKey()
  final double memPercent;
  @override
  @JsonKey()
  final int memForSeconds;
  @override
  @JsonKey()
  final double diskPercent;
  @override
  @JsonKey()
  final int diskForSeconds;
  @override
  @JsonKey()
  final double tempCelsius;
  @override
  @JsonKey()
  final int tempForSeconds;
  @override
  @JsonKey()
  final bool containerDown;

  @override
  String toString() {
    return 'AlertThreshold(cpuPercent: $cpuPercent, cpuForSeconds: $cpuForSeconds, memPercent: $memPercent, memForSeconds: $memForSeconds, diskPercent: $diskPercent, diskForSeconds: $diskForSeconds, tempCelsius: $tempCelsius, tempForSeconds: $tempForSeconds, containerDown: $containerDown)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AlertThresholdImpl &&
            (identical(other.cpuPercent, cpuPercent) ||
                other.cpuPercent == cpuPercent) &&
            (identical(other.cpuForSeconds, cpuForSeconds) ||
                other.cpuForSeconds == cpuForSeconds) &&
            (identical(other.memPercent, memPercent) ||
                other.memPercent == memPercent) &&
            (identical(other.memForSeconds, memForSeconds) ||
                other.memForSeconds == memForSeconds) &&
            (identical(other.diskPercent, diskPercent) ||
                other.diskPercent == diskPercent) &&
            (identical(other.diskForSeconds, diskForSeconds) ||
                other.diskForSeconds == diskForSeconds) &&
            (identical(other.tempCelsius, tempCelsius) ||
                other.tempCelsius == tempCelsius) &&
            (identical(other.tempForSeconds, tempForSeconds) ||
                other.tempForSeconds == tempForSeconds) &&
            (identical(other.containerDown, containerDown) ||
                other.containerDown == containerDown));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      cpuPercent,
      cpuForSeconds,
      memPercent,
      memForSeconds,
      diskPercent,
      diskForSeconds,
      tempCelsius,
      tempForSeconds,
      containerDown);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AlertThresholdImplCopyWith<_$AlertThresholdImpl> get copyWith =>
      __$$AlertThresholdImplCopyWithImpl<_$AlertThresholdImpl>(
          this, _$identity);
}

abstract class _AlertThreshold implements AlertThreshold {
  const factory _AlertThreshold(
      {final double cpuPercent,
      final int cpuForSeconds,
      final double memPercent,
      final int memForSeconds,
      final double diskPercent,
      final int diskForSeconds,
      final double tempCelsius,
      final int tempForSeconds,
      final bool containerDown}) = _$AlertThresholdImpl;

  @override
  double get cpuPercent;
  @override
  int get cpuForSeconds;
  @override
  double get memPercent;
  @override
  int get memForSeconds;
  @override
  double get diskPercent;
  @override
  int get diskForSeconds;
  @override
  double get tempCelsius;
  @override
  int get tempForSeconds;
  @override
  bool get containerDown;
  @override
  @JsonKey(ignore: true)
  _$$AlertThresholdImplCopyWith<_$AlertThresholdImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
