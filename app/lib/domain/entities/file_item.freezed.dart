// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'file_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$FileItem {
  String get name => throw _privateConstructorUsedError;
  bool get isDir => throw _privateConstructorUsedError;
  int get size => throw _privateConstructorUsedError;
  String get mode => throw _privateConstructorUsedError;
  DateTime? get modified => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $FileItemCopyWith<FileItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FileItemCopyWith<$Res> {
  factory $FileItemCopyWith(FileItem value, $Res Function(FileItem) then) =
      _$FileItemCopyWithImpl<$Res, FileItem>;
  @useResult
  $Res call(
      {String name, bool isDir, int size, String mode, DateTime? modified});
}

/// @nodoc
class _$FileItemCopyWithImpl<$Res, $Val extends FileItem>
    implements $FileItemCopyWith<$Res> {
  _$FileItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? isDir = null,
    Object? size = null,
    Object? mode = null,
    Object? modified = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      isDir: null == isDir
          ? _value.isDir
          : isDir // ignore: cast_nullable_to_non_nullable
              as bool,
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as String,
      modified: freezed == modified
          ? _value.modified
          : modified // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FileItemImplCopyWith<$Res>
    implements $FileItemCopyWith<$Res> {
  factory _$$FileItemImplCopyWith(
          _$FileItemImpl value, $Res Function(_$FileItemImpl) then) =
      __$$FileItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name, bool isDir, int size, String mode, DateTime? modified});
}

/// @nodoc
class __$$FileItemImplCopyWithImpl<$Res>
    extends _$FileItemCopyWithImpl<$Res, _$FileItemImpl>
    implements _$$FileItemImplCopyWith<$Res> {
  __$$FileItemImplCopyWithImpl(
      _$FileItemImpl _value, $Res Function(_$FileItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? isDir = null,
    Object? size = null,
    Object? mode = null,
    Object? modified = freezed,
  }) {
    return _then(_$FileItemImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      isDir: null == isDir
          ? _value.isDir
          : isDir // ignore: cast_nullable_to_non_nullable
              as bool,
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as String,
      modified: freezed == modified
          ? _value.modified
          : modified // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$FileItemImpl implements _FileItem {
  const _$FileItemImpl(
      {required this.name,
      required this.isDir,
      this.size = 0,
      this.mode = '',
      this.modified});

  @override
  final String name;
  @override
  final bool isDir;
  @override
  @JsonKey()
  final int size;
  @override
  @JsonKey()
  final String mode;
  @override
  final DateTime? modified;

  @override
  String toString() {
    return 'FileItem(name: $name, isDir: $isDir, size: $size, mode: $mode, modified: $modified)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FileItemImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.isDir, isDir) || other.isDir == isDir) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.modified, modified) ||
                other.modified == modified));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, name, isDir, size, mode, modified);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FileItemImplCopyWith<_$FileItemImpl> get copyWith =>
      __$$FileItemImplCopyWithImpl<_$FileItemImpl>(this, _$identity);
}

abstract class _FileItem implements FileItem {
  const factory _FileItem(
      {required final String name,
      required final bool isDir,
      final int size,
      final String mode,
      final DateTime? modified}) = _$FileItemImpl;

  @override
  String get name;
  @override
  bool get isDir;
  @override
  int get size;
  @override
  String get mode;
  @override
  DateTime? get modified;
  @override
  @JsonKey(ignore: true)
  _$$FileItemImplCopyWith<_$FileItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
