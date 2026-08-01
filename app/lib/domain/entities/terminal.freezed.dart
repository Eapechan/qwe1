// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'terminal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TerminalSession {
  String get sessionId => throw _privateConstructorUsedError;
  String get serverId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime? get lastActiveAt => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TerminalSessionCopyWith<TerminalSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TerminalSessionCopyWith<$Res> {
  factory $TerminalSessionCopyWith(
          TerminalSession value, $Res Function(TerminalSession) then) =
      _$TerminalSessionCopyWithImpl<$Res, TerminalSession>;
  @useResult
  $Res call(
      {String sessionId,
      String serverId,
      String title,
      bool isActive,
      DateTime? lastActiveAt});
}

/// @nodoc
class _$TerminalSessionCopyWithImpl<$Res, $Val extends TerminalSession>
    implements $TerminalSessionCopyWith<$Res> {
  _$TerminalSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? serverId = null,
    Object? title = null,
    Object? isActive = null,
    Object? lastActiveAt = freezed,
  }) {
    return _then(_value.copyWith(
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      serverId: null == serverId
          ? _value.serverId
          : serverId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      lastActiveAt: freezed == lastActiveAt
          ? _value.lastActiveAt
          : lastActiveAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TerminalSessionImplCopyWith<$Res>
    implements $TerminalSessionCopyWith<$Res> {
  factory _$$TerminalSessionImplCopyWith(_$TerminalSessionImpl value,
          $Res Function(_$TerminalSessionImpl) then) =
      __$$TerminalSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String sessionId,
      String serverId,
      String title,
      bool isActive,
      DateTime? lastActiveAt});
}

/// @nodoc
class __$$TerminalSessionImplCopyWithImpl<$Res>
    extends _$TerminalSessionCopyWithImpl<$Res, _$TerminalSessionImpl>
    implements _$$TerminalSessionImplCopyWith<$Res> {
  __$$TerminalSessionImplCopyWithImpl(
      _$TerminalSessionImpl _value, $Res Function(_$TerminalSessionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? serverId = null,
    Object? title = null,
    Object? isActive = null,
    Object? lastActiveAt = freezed,
  }) {
    return _then(_$TerminalSessionImpl(
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      serverId: null == serverId
          ? _value.serverId
          : serverId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      lastActiveAt: freezed == lastActiveAt
          ? _value.lastActiveAt
          : lastActiveAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$TerminalSessionImpl implements _TerminalSession {
  const _$TerminalSessionImpl(
      {required this.sessionId,
      required this.serverId,
      this.title = '',
      this.isActive = false,
      this.lastActiveAt});

  @override
  final String sessionId;
  @override
  final String serverId;
  @override
  @JsonKey()
  final String title;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime? lastActiveAt;

  @override
  String toString() {
    return 'TerminalSession(sessionId: $sessionId, serverId: $serverId, title: $title, isActive: $isActive, lastActiveAt: $lastActiveAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TerminalSessionImpl &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.serverId, serverId) ||
                other.serverId == serverId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.lastActiveAt, lastActiveAt) ||
                other.lastActiveAt == lastActiveAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, sessionId, serverId, title, isActive, lastActiveAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TerminalSessionImplCopyWith<_$TerminalSessionImpl> get copyWith =>
      __$$TerminalSessionImplCopyWithImpl<_$TerminalSessionImpl>(
          this, _$identity);
}

abstract class _TerminalSession implements TerminalSession {
  const factory _TerminalSession(
      {required final String sessionId,
      required final String serverId,
      final String title,
      final bool isActive,
      final DateTime? lastActiveAt}) = _$TerminalSessionImpl;

  @override
  String get sessionId;
  @override
  String get serverId;
  @override
  String get title;
  @override
  bool get isActive;
  @override
  DateTime? get lastActiveAt;
  @override
  @JsonKey(ignore: true)
  _$$TerminalSessionImplCopyWith<_$TerminalSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
