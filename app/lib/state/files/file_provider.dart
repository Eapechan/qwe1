import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qwe1/domain/entities/file_item.dart';
import 'package:qwe1/domain/repositories/file_repository.dart';

// File list provider
final fileListProvider = StateNotifierProvider.family<FileListNotifier, AsyncValue<List<FileItem>>, ({String serverId, String path})>((ref, params) {
  return FileListNotifier(ref, params.serverId, params.path);
});

class FileListNotifier extends StateNotifier<AsyncValue<List<FileItem>>> {
  FileListNotifier(this.ref, this.serverId, this.path) : super(const AsyncValue.loading()) {
    loadFiles();
  }

  final Ref ref;
  final String serverId;
  final String path;

  Future<void> loadFiles() async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(fileRepositoryProvider);
      final files = await repository.listFiles(serverId, path);
      state = AsyncValue.data(files);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createDirectory(String name) async {
    try {
      final repository = ref.read(fileRepositoryProvider);
      await repository.createDirectory(serverId, '$path/$name');
      await loadFiles();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteItem(String name) async {
    try {
      final repository = ref.read(fileRepositoryProvider);
      await repository.delete(serverId, '$path/$name');
      await loadFiles();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> renameItem(String from, String to) async {
    try {
      final repository = ref.read(fileRepositoryProvider);
      await repository.rename(serverId, '$path/$from', '$path/$to');
      await loadFiles();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// File content provider
final fileContentProvider = FutureProvider.family<List<int>, ({String serverId, String path})>((ref, params) async {
  final repository = ref.watch(fileRepositoryProvider);
  final data = await repository.readFile(params.serverId, params.path);
  return data.toList();
});

// File repository provider (placeholder)
final fileRepositoryProvider = Provider<FileRepository>((ref) {
  throw UnimplementedError('File repository not initialized');
});
