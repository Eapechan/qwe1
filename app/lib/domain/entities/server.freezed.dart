// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'server.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Server {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get agentUrl => throw _privateConstructorUsedError;
  String? get tailscaleUrl => throw _privateConstructorUsedError;
  String get groupName => throw _privateConstructorUsedError;
  bool get readOnly => throw _privateConstructorUsedError;
  String get fingerprintHash => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get deviceId => throw _privateConstructorUsedError;
  DateTime? get lastSeenAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String get agentVersion => throw _privateConstructorUsedError;
  Map<String, dynamic> get capabilities => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ServerCopyWith<Server> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServerCopyWith<$Res> {
  factory $ServerCopyWith(Server value, $Res Function(Server) then) =
      _$ServerCopyWithImpl<$Res, Server>;
  @useResult
  $Res call(
      {String id,
      String name,
      String agentUrl,
      String? tailscaleUrl,
      String groupName,
      bool readOnly,
      String fingerprintHash,
      String status,
      String deviceId,
      DateTime? lastSeenAt,
      DateTime createdAt,
      String agentVersion,
      Map<String, dynamic> capabilities});
}

/// @nodoc
class _$ServerCopyWithImpl<$Res, $Val extends Server>
    implements $ServerCopyWith<$Res> {
  _$ServerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? agentUrl = null,
    Object? tailscaleUrl = freezed,
    Object? groupName = null,
    Object? readOnly = null,
    Object? fingerprintHash = null,
    Object? status = null,
    Object? deviceId = null,
    Object? lastSeenAt = freezed,
    Object? createdAt = null,
    Object? agentVersion = null,
    Object? capabilities = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      agentUrl: null == agentUrl
          ? _value.agentUrl
          : agentUrl // ignore: cast_nullable_to_non_nullable
              as String,
      tailscaleUrl: freezed == tailscaleUrl
          ? _value.tailscaleUrl
          : tailscaleUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      groupName: null == groupName
          ? _value.groupName
          : groupName // ignore: cast_nullable_to_non_nullable
              as String,
      readOnly: null == readOnly
          ? _value.readOnly
          : readOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      fingerprintHash: null == fingerprintHash
          ? _value.fingerprintHash
          : fingerprintHash // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      lastSeenAt: freezed == lastSeenAt
          ? _value.lastSeenAt
          : lastSeenAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      agentVersion: null == agentVersion
          ? _value.agentVersion
          : agentVersion // ignore: cast_nullable_to_non_nullable
              as String,
      capabilities: null == capabilities
          ? _value.capabilities
          : capabilities // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ServerImplCopyWith<$Res> implements $ServerCopyWith<$Res> {
  factory _$$ServerImplCopyWith(
          _$ServerImpl value, $Res Function(_$ServerImpl) then) =
      __$$ServerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String agentUrl,
      String? tailscaleUrl,
      String groupName,
      bool readOnly,
      String fingerprintHash,
      String status,
      String deviceId,
      DateTime? lastSeenAt,
      DateTime createdAt,
      String agentVersion,
      Map<String, dynamic> capabilities});
}

/// @nodoc
class __$$ServerImplCopyWithImpl<$Res>
    extends _$ServerCopyWithImpl<$Res, _$ServerImpl>
    implements _$$ServerImplCopyWith<$Res> {
  __$$ServerImplCopyWithImpl(
      _$ServerImpl _value, $Res Function(_$ServerImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? agentUrl = null,
    Object? tailscaleUrl = freezed,
    Object? groupName = null,
    Object? readOnly = null,
    Object? fingerprintHash = null,
    Object? status = null,
    Object? deviceId = null,
    Object? lastSeenAt = freezed,
    Object? createdAt = null,
    Object? agentVersion = null,
    Object? capabilities = null,
  }) {
    return _then(_$ServerImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      agentUrl: null == agentUrl
          ? _value.agentUrl
          : agentUrl // ignore: cast_nullable_to_non_nullable
              as String,
      tailscaleUrl: freezed == tailscaleUrl
          ? _value.tailscaleUrl
          : tailscaleUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      groupName: null == groupName
          ? _value.groupName
          : groupName // ignore: cast_nullable_to_non_nullable
              as String,
      readOnly: null == readOnly
          ? _value.readOnly
          : readOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      fingerprintHash: null == fingerprintHash
          ? _value.fingerprintHash
          : fingerprintHash // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      lastSeenAt: freezed == lastSeenAt
          ? _value.lastSeenAt
          : lastSeenAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      agentVersion: null == agentVersion
          ? _value.agentVersion
          : agentVersion // ignore: cast_nullable_to_non_nullable
              as String,
      capabilities: null == capabilities
          ? _value._capabilities
          : capabilities // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc

class _$ServerImpl implements _Server {
  const _$ServerImpl(
      {required this.id,
      required this.name,
      required this.agentUrl,
      this.tailscaleUrl,
      this.groupName = '',
      this.readOnly = false,
      this.fingerprintHash = '',
      this.status = 'unknown',
      this.deviceId = '',
      this.lastSeenAt,
      required this.createdAt,
      this.agentVersion = '',
      final Map<String, dynamic> capabilities = const {}})
      : _capabilities = capabilities;

  @override
  final String id;
  @override
  final String name;
  @override
  final String agentUrl;
  @override
  final String? tailscaleUrl;
  @override
  @JsonKey()
  final String groupName;
  @override
  @JsonKey()
  final bool readOnly;
  @override
  @JsonKey()
  final String fingerprintHash;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey()
  final String deviceId;
  @override
  final DateTime? lastSeenAt;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final String agentVersion;
  final Map<String, dynamic> _capabilities;
  @override
  @JsonKey()
  Map<String, dynamic> get capabilities {
    if (_capabilities is EqualUnmodifiableMapView) return _capabilities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_capabilities);
  }

  @override
  String toString() {
    return 'Server(id: $id, name: $name, agentUrl: $agentUrl, tailscaleUrl: $tailscaleUrl, groupName: $groupName, readOnly: $readOnly, fingerprintHash: $fingerprintHash, status: $status, deviceId: $deviceId, lastSeenAt: $lastSeenAt, createdAt: $createdAt, agentVersion: $agentVersion, capabilities: $capabilities)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.agentUrl, agentUrl) ||
                other.agentUrl == agentUrl) &&
            (identical(other.tailscaleUrl, tailscaleUrl) ||
                other.tailscaleUrl == tailscaleUrl) &&
            (identical(other.groupName, groupName) ||
                other.groupName == groupName) &&
            (identical(other.readOnly, readOnly) ||
                other.readOnly == readOnly) &&
            (identical(other.fingerprintHash, fingerprintHash) ||
                other.fingerprintHash == fingerprintHash) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.lastSeenAt, lastSeenAt) ||
                other.lastSeenAt == lastSeenAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.agentVersion, agentVersion) ||
                other.agentVersion == agentVersion) &&
            const DeepCollectionEquality()
                .equals(other._capabilities, _capabilities));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      agentUrl,
      tailscaleUrl,
      groupName,
      readOnly,
      fingerprintHash,
      status,
      deviceId,
      lastSeenAt,
      createdAt,
      agentVersion,
      const DeepCollectionEquality().hash(_capabilities));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ServerImplCopyWith<_$ServerImpl> get copyWith =>
      __$$ServerImplCopyWithImpl<_$ServerImpl>(this, _$identity);
}

abstract class _Server implements Server {
  const factory _Server(
      {required final String id,
      required final String name,
      required final String agentUrl,
      final String? tailscaleUrl,
      final String groupName,
      final bool readOnly,
      final String fingerprintHash,
      final String status,
      final String deviceId,
      final DateTime? lastSeenAt,
      required final DateTime createdAt,
      final String agentVersion,
      final Map<String, dynamic> capabilities}) = _$ServerImpl;

  @override
  String get id;
  @override
  String get name;
  @override
  String get agentUrl;
  @override
  String? get tailscaleUrl;
  @override
  String get groupName;
  @override
  bool get readOnly;
  @override
  String get fingerprintHash;
  @override
  String get status;
  @override
  String get deviceId;
  @override
  DateTime? get lastSeenAt;
  @override
  DateTime get createdAt;
  @override
  String get agentVersion;
  @override
  Map<String, dynamic> get capabilities;
  @override
  @JsonKey(ignore: true)
  _$$ServerImplCopyWith<_$ServerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
