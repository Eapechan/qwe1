import 'dart:typed_data';

import 'package:qwe1/domain/entities/file_item.dart';
import 'package:qwe1/domain/repositories/file_repository.dart';
import 'package:qwe1/domain/repositories/server_repository.dart';

class FileRepositoryImpl implements FileRepository {
  FileRepositoryImpl({required this.serverRepository});

  final ServerRepository serverRepository;

  @override
  Future<List<FileItem>> listFiles(String serverId, String path, {bool hidden = false}) async {
    final client = serverRepository.getClient(serverId);
    final response = await client.get('/fs/list', queryParameters: {
      'path': path,
      'hidden': hidden,
    });

    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List;

    return items.map((e) {
      final item = e as Map<String, dynamic>;
      return FileItem(
        name: item['name'] as String,
        isDir: item['isDir'] as bool,
        size: (item['size'] as num).toInt(),
        mode: item['mode'] as String? ?? '',
        modified: item['modified'] != null ? DateTime.parse(item['modified'] as String) : null,
      );
    }).toList();
  }

  @override
  Future<Uint8List> readFile(String serverId, String path, {int? maxBytes}) async {
    final client = serverRepository.getClient(serverId);
    final response = await client.get('/fs/read', queryParameters: {
      'path': path,
    });
    return response.data as Uint8List;
  }

  @override
  Future<void> writeFile(String serverId, String path, Uint8List data) async {
    final client = serverRepository.getClient(serverId);
    await client.post('/fs/write', data: {
      'path': path,
      'content': String.fromCharCodes(data),
    });
  }

  @override
  Future<void> createDirectory(String serverId, String path) async {
    final client = serverRepository.getClient(serverId);
    await client.post('/fs/mkdir', data: {
      'path': path,
    });
  }

  @override
  Future<void> rename(String serverId, String from, String to) async {
    final client = serverRepository.getClient(serverId);
    await client.patch('/fs/rename', data: {
      'from': from,
      'to': to,
    });
  }

  @override
  Future<void> delete(String serverId, String path, {bool recursive = false}) async {
    final client = serverRepository.getClient(serverId);
    await client.delete('/fs', queryParameters: {
      'path': path,
      'recursive': recursive,
    });
  }

  @override
  Future<void> upload(String serverId, String path, String name, Uint8List data) async {
    final client = serverRepository.getClient(serverId);
    await client.post('/fs/upload', data: {
      'path': path,
      'name': name,
      'content': String.fromCharCodes(data),
    });
  }
}
