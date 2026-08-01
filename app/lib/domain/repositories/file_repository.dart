import 'dart:typed_data';

import 'package:qwe1/domain/entities/file_item.dart';

abstract class FileRepository {
  Future<List<FileItem>> listFiles(String serverId, String path, {bool hidden = false});
  Future<Uint8List> readFile(String serverId, String path, {int? maxBytes});
  Future<void> writeFile(String serverId, String path, Uint8List data);
  Future<void> createDirectory(String serverId, String path);
  Future<void> rename(String serverId, String from, String to);
  Future<void> delete(String serverId, String path, {bool recursive = false});
  Future<void> upload(String serverId, String path, String name, Uint8List data);
}
