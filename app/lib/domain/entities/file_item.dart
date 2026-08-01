import 'package:freezed_annotation/freezed_annotation.dart';

part 'file_item.freezed.dart';

@freezed
class FileItem with _$FileItem {
  const factory FileItem({
    required String name,
    required bool isDir,
    @Default(0) int size,
    @Default('') String mode,
    DateTime? modified,
  }) = _FileItem;
}
