// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'container.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Container {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get image => throw _privateConstructorUsedError;
  String get state => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get health => throw _privateConstructorUsedError;
  List<PortMapping> get ports => throw _privateConstructorUsedError;
  double get cpuPercent => throw _privateConstructorUsedError;
  int get memoryBytes => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ContainerCopyWith<Container> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ContainerCopyWith<$Res> {
  factory $ContainerCopyWith(Container value, $Res Function(Container) then) =
      _$ContainerCopyWithImpl<$Res, Container>;
  @useResult
  $Res call(
      {String id,
      String name,
      String image,
      String state,
      String status,
      String health,
      List<PortMapping> ports,
      double cpuPercent,
      int memoryBytes,
      DateTime? createdAt});
}

/// @nodoc
class _$ContainerCopyWithImpl<$Res, $Val extends Container>
    implements $ContainerCopyWith<$Res> {
  _$ContainerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? image = null,
    Object? state = null,
    Object? status = null,
    Object? health = null,
    Object? ports = null,
    Object? cpuPercent = null,
    Object? memoryBytes = null,
    Object? createdAt = freezed,
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
      image: null == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      health: null == health
          ? _value.health
          : health // ignore: cast_nullable_to_non_nullable
              as String,
      ports: null == ports
          ? _value.ports
          : ports // ignore: cast_nullable_to_non_nullable
              as List<PortMapping>,
      cpuPercent: null == cpuPercent
          ? _value.cpuPercent
          : cpuPercent // ignore: cast_nullable_to_non_nullable
              as double,
      memoryBytes: null == memoryBytes
          ? _value.memoryBytes
          : memoryBytes // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ContainerImplCopyWith<$Res>
    implements $ContainerCopyWith<$Res> {
  factory _$$ContainerImplCopyWith(
          _$ContainerImpl value, $Res Function(_$ContainerImpl) then) =
      __$$ContainerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String image,
      String state,
      String status,
      String health,
      List<PortMapping> ports,
      double cpuPercent,
      int memoryBytes,
      DateTime? createdAt});
}

/// @nodoc
class __$$ContainerImplCopyWithImpl<$Res>
    extends _$ContainerCopyWithImpl<$Res, _$ContainerImpl>
    implements _$$ContainerImplCopyWith<$Res> {
  __$$ContainerImplCopyWithImpl(
      _$ContainerImpl _value, $Res Function(_$ContainerImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? image = null,
    Object? state = null,
    Object? status = null,
    Object? health = null,
    Object? ports = null,
    Object? cpuPercent = null,
    Object? memoryBytes = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$ContainerImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      image: null == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      health: null == health
          ? _value.health
          : health // ignore: cast_nullable_to_non_nullable
              as String,
      ports: null == ports
          ? _value._ports
          : ports // ignore: cast_nullable_to_non_nullable
              as List<PortMapping>,
      cpuPercent: null == cpuPercent
          ? _value.cpuPercent
          : cpuPercent // ignore: cast_nullable_to_non_nullable
              as double,
      memoryBytes: null == memoryBytes
          ? _value.memoryBytes
          : memoryBytes // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$ContainerImpl implements _Container {
  const _$ContainerImpl(
      {required this.id,
      required this.name,
      required this.image,
      required this.state,
      this.status = '',
      this.health = '',
      final List<PortMapping> ports = const [],
      this.cpuPercent = 0.0,
      this.memoryBytes = 0,
      this.createdAt})
      : _ports = ports;

  @override
  final String id;
  @override
  final String name;
  @override
  final String image;
  @override
  final String state;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey()
  final String health;
  final List<PortMapping> _ports;
  @override
  @JsonKey()
  List<PortMapping> get ports {
    if (_ports is EqualUnmodifiableListView) return _ports;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ports);
  }

  @override
  @JsonKey()
  final double cpuPercent;
  @override
  @JsonKey()
  final int memoryBytes;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'Container(id: $id, name: $name, image: $image, state: $state, status: $status, health: $health, ports: $ports, cpuPercent: $cpuPercent, memoryBytes: $memoryBytes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ContainerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.health, health) || other.health == health) &&
            const DeepCollectionEquality().equals(other._ports, _ports) &&
            (identical(other.cpuPercent, cpuPercent) ||
                other.cpuPercent == cpuPercent) &&
            (identical(other.memoryBytes, memoryBytes) ||
                other.memoryBytes == memoryBytes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      image,
      state,
      status,
      health,
      const DeepCollectionEquality().hash(_ports),
      cpuPercent,
      memoryBytes,
      createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ContainerImplCopyWith<_$ContainerImpl> get copyWith =>
      __$$ContainerImplCopyWithImpl<_$ContainerImpl>(this, _$identity);
}

abstract class _Container implements Container {
  const factory _Container(
      {required final String id,
      required final String name,
      required final String image,
      required final String state,
      final String status,
      final String health,
      final List<PortMapping> ports,
      final double cpuPercent,
      final int memoryBytes,
      final DateTime? createdAt}) = _$ContainerImpl;

  @override
  String get id;
  @override
  String get name;
  @override
  String get image;
  @override
  String get state;
  @override
  String get status;
  @override
  String get health;
  @override
  List<PortMapping> get ports;
  @override
  double get cpuPercent;
  @override
  int get memoryBytes;
  @override
  DateTime? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$ContainerImplCopyWith<_$ContainerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PortMapping {
  String get host => throw _privateConstructorUsedError;
  String get container => throw _privateConstructorUsedError;
  String get protocol => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PortMappingCopyWith<PortMapping> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PortMappingCopyWith<$Res> {
  factory $PortMappingCopyWith(
          PortMapping value, $Res Function(PortMapping) then) =
      _$PortMappingCopyWithImpl<$Res, PortMapping>;
  @useResult
  $Res call({String host, String container, String protocol});
}

/// @nodoc
class _$PortMappingCopyWithImpl<$Res, $Val extends PortMapping>
    implements $PortMappingCopyWith<$Res> {
  _$PortMappingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? host = null,
    Object? container = null,
    Object? protocol = null,
  }) {
    return _then(_value.copyWith(
      host: null == host
          ? _value.host
          : host // ignore: cast_nullable_to_non_nullable
              as String,
      container: null == container
          ? _value.container
          : container // ignore: cast_nullable_to_non_nullable
              as String,
      protocol: null == protocol
          ? _value.protocol
          : protocol // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PortMappingImplCopyWith<$Res>
    implements $PortMappingCopyWith<$Res> {
  factory _$$PortMappingImplCopyWith(
          _$PortMappingImpl value, $Res Function(_$PortMappingImpl) then) =
      __$$PortMappingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String host, String container, String protocol});
}

/// @nodoc
class __$$PortMappingImplCopyWithImpl<$Res>
    extends _$PortMappingCopyWithImpl<$Res, _$PortMappingImpl>
    implements _$$PortMappingImplCopyWith<$Res> {
  __$$PortMappingImplCopyWithImpl(
      _$PortMappingImpl _value, $Res Function(_$PortMappingImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? host = null,
    Object? container = null,
    Object? protocol = null,
  }) {
    return _then(_$PortMappingImpl(
      host: null == host
          ? _value.host
          : host // ignore: cast_nullable_to_non_nullable
              as String,
      container: null == container
          ? _value.container
          : container // ignore: cast_nullable_to_non_nullable
              as String,
      protocol: null == protocol
          ? _value.protocol
          : protocol // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$PortMappingImpl implements _PortMapping {
  const _$PortMappingImpl(
      {required this.host, required this.container, this.protocol = 'tcp'});

  @override
  final String host;
  @override
  final String container;
  @override
  @JsonKey()
  final String protocol;

  @override
  String toString() {
    return 'PortMapping(host: $host, container: $container, protocol: $protocol)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PortMappingImpl &&
            (identical(other.host, host) || other.host == host) &&
            (identical(other.container, container) ||
                other.container == container) &&
            (identical(other.protocol, protocol) ||
                other.protocol == protocol));
  }

  @override
  int get hashCode => Object.hash(runtimeType, host, container, protocol);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PortMappingImplCopyWith<_$PortMappingImpl> get copyWith =>
      __$$PortMappingImplCopyWithImpl<_$PortMappingImpl>(this, _$identity);
}

abstract class _PortMapping implements PortMapping {
  const factory _PortMapping(
      {required final String host,
      required final String container,
      final String protocol}) = _$PortMappingImpl;

  @override
  String get host;
  @override
  String get container;
  @override
  String get protocol;
  @override
  @JsonKey(ignore: true)
  _$$PortMappingImplCopyWith<_$PortMappingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ContainerInspect {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get image => throw _privateConstructorUsedError;
  String get state => throw _privateConstructorUsedError;
  Map<String, dynamic> get config => throw _privateConstructorUsedError;
  List<String> get env => throw _privateConstructorUsedError;
  List<MountPoint> get mounts => throw _privateConstructorUsedError;
  Map<String, dynamic> get networkSettings =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> get labels => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ContainerInspectCopyWith<ContainerInspect> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ContainerInspectCopyWith<$Res> {
  factory $ContainerInspectCopyWith(
          ContainerInspect value, $Res Function(ContainerInspect) then) =
      _$ContainerInspectCopyWithImpl<$Res, ContainerInspect>;
  @useResult
  $Res call(
      {String id,
      String name,
      String image,
      String state,
      Map<String, dynamic> config,
      List<String> env,
      List<MountPoint> mounts,
      Map<String, dynamic> networkSettings,
      Map<String, dynamic> labels});
}

/// @nodoc
class _$ContainerInspectCopyWithImpl<$Res, $Val extends ContainerInspect>
    implements $ContainerInspectCopyWith<$Res> {
  _$ContainerInspectCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? image = null,
    Object? state = null,
    Object? config = null,
    Object? env = null,
    Object? mounts = null,
    Object? networkSettings = null,
    Object? labels = null,
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
      image: null == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      config: null == config
          ? _value.config
          : config // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      env: null == env
          ? _value.env
          : env // ignore: cast_nullable_to_non_nullable
              as List<String>,
      mounts: null == mounts
          ? _value.mounts
          : mounts // ignore: cast_nullable_to_non_nullable
              as List<MountPoint>,
      networkSettings: null == networkSettings
          ? _value.networkSettings
          : networkSettings // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      labels: null == labels
          ? _value.labels
          : labels // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ContainerInspectImplCopyWith<$Res>
    implements $ContainerInspectCopyWith<$Res> {
  factory _$$ContainerInspectImplCopyWith(_$ContainerInspectImpl value,
          $Res Function(_$ContainerInspectImpl) then) =
      __$$ContainerInspectImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String image,
      String state,
      Map<String, dynamic> config,
      List<String> env,
      List<MountPoint> mounts,
      Map<String, dynamic> networkSettings,
      Map<String, dynamic> labels});
}

/// @nodoc
class __$$ContainerInspectImplCopyWithImpl<$Res>
    extends _$ContainerInspectCopyWithImpl<$Res, _$ContainerInspectImpl>
    implements _$$ContainerInspectImplCopyWith<$Res> {
  __$$ContainerInspectImplCopyWithImpl(_$ContainerInspectImpl _value,
      $Res Function(_$ContainerInspectImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? image = null,
    Object? state = null,
    Object? config = null,
    Object? env = null,
    Object? mounts = null,
    Object? networkSettings = null,
    Object? labels = null,
  }) {
    return _then(_$ContainerInspectImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      image: null == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      config: null == config
          ? _value._config
          : config // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      env: null == env
          ? _value._env
          : env // ignore: cast_nullable_to_non_nullable
              as List<String>,
      mounts: null == mounts
          ? _value._mounts
          : mounts // ignore: cast_nullable_to_non_nullable
              as List<MountPoint>,
      networkSettings: null == networkSettings
          ? _value._networkSettings
          : networkSettings // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      labels: null == labels
          ? _value._labels
          : labels // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc

class _$ContainerInspectImpl implements _ContainerInspect {
  const _$ContainerInspectImpl(
      {required this.id,
      required this.name,
      required this.image,
      required this.state,
      final Map<String, dynamic> config = const {},
      final List<String> env = const [],
      final List<MountPoint> mounts = const [],
      final Map<String, dynamic> networkSettings = const {},
      final Map<String, dynamic> labels = const {}})
      : _config = config,
        _env = env,
        _mounts = mounts,
        _networkSettings = networkSettings,
        _labels = labels;

  @override
  final String id;
  @override
  final String name;
  @override
  final String image;
  @override
  final String state;
  final Map<String, dynamic> _config;
  @override
  @JsonKey()
  Map<String, dynamic> get config {
    if (_config is EqualUnmodifiableMapView) return _config;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_config);
  }

  final List<String> _env;
  @override
  @JsonKey()
  List<String> get env {
    if (_env is EqualUnmodifiableListView) return _env;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_env);
  }

  final List<MountPoint> _mounts;
  @override
  @JsonKey()
  List<MountPoint> get mounts {
    if (_mounts is EqualUnmodifiableListView) return _mounts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mounts);
  }

  final Map<String, dynamic> _networkSettings;
  @override
  @JsonKey()
  Map<String, dynamic> get networkSettings {
    if (_networkSettings is EqualUnmodifiableMapView) return _networkSettings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_networkSettings);
  }

  final Map<String, dynamic> _labels;
  @override
  @JsonKey()
  Map<String, dynamic> get labels {
    if (_labels is EqualUnmodifiableMapView) return _labels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_labels);
  }

  @override
  String toString() {
    return 'ContainerInspect(id: $id, name: $name, image: $image, state: $state, config: $config, env: $env, mounts: $mounts, networkSettings: $networkSettings, labels: $labels)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ContainerInspectImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.state, state) || other.state == state) &&
            const DeepCollectionEquality().equals(other._config, _config) &&
            const DeepCollectionEquality().equals(other._env, _env) &&
            const DeepCollectionEquality().equals(other._mounts, _mounts) &&
            const DeepCollectionEquality()
                .equals(other._networkSettings, _networkSettings) &&
            const DeepCollectionEquality().equals(other._labels, _labels));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      image,
      state,
      const DeepCollectionEquality().hash(_config),
      const DeepCollectionEquality().hash(_env),
      const DeepCollectionEquality().hash(_mounts),
      const DeepCollectionEquality().hash(_networkSettings),
      const DeepCollectionEquality().hash(_labels));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ContainerInspectImplCopyWith<_$ContainerInspectImpl> get copyWith =>
      __$$ContainerInspectImplCopyWithImpl<_$ContainerInspectImpl>(
          this, _$identity);
}

abstract class _ContainerInspect implements ContainerInspect {
  const factory _ContainerInspect(
      {required final String id,
      required final String name,
      required final String image,
      required final String state,
      final Map<String, dynamic> config,
      final List<String> env,
      final List<MountPoint> mounts,
      final Map<String, dynamic> networkSettings,
      final Map<String, dynamic> labels}) = _$ContainerInspectImpl;

  @override
  String get id;
  @override
  String get name;
  @override
  String get image;
  @override
  String get state;
  @override
  Map<String, dynamic> get config;
  @override
  List<String> get env;
  @override
  List<MountPoint> get mounts;
  @override
  Map<String, dynamic> get networkSettings;
  @override
  Map<String, dynamic> get labels;
  @override
  @JsonKey(ignore: true)
  _$$ContainerInspectImplCopyWith<_$ContainerInspectImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MountPoint {
  String get type => throw _privateConstructorUsedError;
  String get source => throw _privateConstructorUsedError;
  String get destination => throw _privateConstructorUsedError;
  bool get rw => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MountPointCopyWith<MountPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MountPointCopyWith<$Res> {
  factory $MountPointCopyWith(
          MountPoint value, $Res Function(MountPoint) then) =
      _$MountPointCopyWithImpl<$Res, MountPoint>;
  @useResult
  $Res call({String type, String source, String destination, bool rw});
}

/// @nodoc
class _$MountPointCopyWithImpl<$Res, $Val extends MountPoint>
    implements $MountPointCopyWith<$Res> {
  _$MountPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? source = null,
    Object? destination = null,
    Object? rw = null,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      destination: null == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as String,
      rw: null == rw
          ? _value.rw
          : rw // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MountPointImplCopyWith<$Res>
    implements $MountPointCopyWith<$Res> {
  factory _$$MountPointImplCopyWith(
          _$MountPointImpl value, $Res Function(_$MountPointImpl) then) =
      __$$MountPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String type, String source, String destination, bool rw});
}

/// @nodoc
class __$$MountPointImplCopyWithImpl<$Res>
    extends _$MountPointCopyWithImpl<$Res, _$MountPointImpl>
    implements _$$MountPointImplCopyWith<$Res> {
  __$$MountPointImplCopyWithImpl(
      _$MountPointImpl _value, $Res Function(_$MountPointImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? source = null,
    Object? destination = null,
    Object? rw = null,
  }) {
    return _then(_$MountPointImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      destination: null == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as String,
      rw: null == rw
          ? _value.rw
          : rw // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$MountPointImpl implements _MountPoint {
  const _$MountPointImpl(
      {required this.type,
      required this.source,
      required this.destination,
      this.rw = false});

  @override
  final String type;
  @override
  final String source;
  @override
  final String destination;
  @override
  @JsonKey()
  final bool rw;

  @override
  String toString() {
    return 'MountPoint(type: $type, source: $source, destination: $destination, rw: $rw)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MountPointImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.destination, destination) ||
                other.destination == destination) &&
            (identical(other.rw, rw) || other.rw == rw));
  }

  @override
  int get hashCode => Object.hash(runtimeType, type, source, destination, rw);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MountPointImplCopyWith<_$MountPointImpl> get copyWith =>
      __$$MountPointImplCopyWithImpl<_$MountPointImpl>(this, _$identity);
}

abstract class _MountPoint implements MountPoint {
  const factory _MountPoint(
      {required final String type,
      required final String source,
      required final String destination,
      final bool rw}) = _$MountPointImpl;

  @override
  String get type;
  @override
  String get source;
  @override
  String get destination;
  @override
  bool get rw;
  @override
  @JsonKey(ignore: true)
  _$$MountPointImplCopyWith<_$MountPointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
