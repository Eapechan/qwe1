import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qwe1/domain/entities/file_item.dart';
import 'package:qwe1/state/files/file_provider.dart';

class FileBrowserScreen extends ConsumerStatefulWidget {
  const FileBrowserScreen({
    super.key,
    required this.serverId,
    this.initialPath = '/',
  });

  final String serverId;
  final String initialPath;

  @override
  ConsumerState<FileBrowserScreen> createState() => _FileBrowserScreenState();
}

class _FileBrowserScreenState extends ConsumerState<FileBrowserScreen> {
  late String _currentPath;

  @override
  void initState() {
    super.initState();
    _currentPath = widget.initialPath;
  }

  @override
  Widget build(BuildContext context) {
    final filesAsync = ref.watch(
      fileListProvider((serverId: widget.serverId, path: _currentPath)),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentPath),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(
                fileListProvider((serverId: widget.serverId, path: _currentPath)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.create_new_folder),
            onPressed: () => _showCreateDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Breadcrumb path
          _buildBreadcrumb(),

          // File list
          Expanded(
            child: filesAsync.when(
              data: (files) {
                if (files.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('This folder is empty'),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(
                      fileListProvider((serverId: widget.serverId, path: _currentPath)),
                    );
                  },
                  child: ListView.builder(
                    itemCount: files.length,
                    itemBuilder: (context, index) {
                      final file = files[index];
                      return _buildFileTile(file);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumb() {
    final parts = _currentPath.split('/').where((p) => p.isNotEmpty).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            InkWell(
              onTap: () => _navigateTo('/'),
              child: const Icon(Icons.home, size: 16),
            ),
            for (int i = 0; i < parts.length; i++) ...[
              const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
              InkWell(
                onTap: () {
                  final path = '/' + parts.sublist(0, i + 1).join('/');
                  _navigateTo(path);
                },
                child: Text(
                  parts[i],
                  style: TextStyle(
                    color: i == parts.length - 1
                        ? Theme.of(context).colorScheme.primary
                        : null,
                    fontWeight: i == parts.length - 1 ? FontWeight.bold : null,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFileTile(FileItem file) {
    final icon = file.isDir ? Icons.folder : _getFileIcon(file.name);

    return ListTile(
      leading: Icon(
        icon,
        color: file.isDir ? Colors.amber : Theme.of(context).colorScheme.primary,
      ),
      title: Text(file.name),
      subtitle: file.isDir ? null : Text(_formatSize(file.size)),
      trailing: PopupMenuButton<String>(
        onSelected: (action) => _handleFileAction(action, file),
        itemBuilder: (context) => [
          if (!file.isDir) ...[
            const PopupMenuItem(value: 'download', child: Text('Download')),
            const PopupMenuItem(value: 'preview', child: Text('Preview')),
          ],
          const PopupMenuItem(value: 'rename', child: Text('Rename')),
          const PopupMenuItem(
            value: 'delete',
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
      onTap: () {
        if (file.isDir) {
          final newPath = _currentPath.endsWith('/')
              ? '$_currentPath${file.name}'
              : '$_currentPath/${file.name}';
          _navigateTo(newPath);
        }
      },
    );
  }

  IconData _getFileIcon(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'txt':
      case 'md':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'zip':
      case 'tar':
      case 'gz':
        return Icons.archive;
      case 'json':
      case 'yaml':
      case 'yml':
        return Icons.code;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  void _navigateTo(String path) {
    setState(() {
      _currentPath = path;
    });
  }

  void _showCreateDialog(BuildContext context) {
    final controller = TextEditingController();
    bool isFolder = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create New'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Name',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: isFolder,
                    onChanged: (value) {
                      setState(() {
                        isFolder = value ?? true;
                      });
                    },
                  ),
                  const Text('Folder'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (isFolder) {
                  ref
                      .read(fileListProvider((serverId: widget.serverId, path: _currentPath)).notifier)
                      .createDirectory(controller.text);
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleFileAction(String action, FileItem file) {
    switch (action) {
      case 'download':
        // TODO: Implement download
        break;
      case 'preview':
        // TODO: Implement preview
        break;
      case 'rename':
        _showRenameDialog(file);
        break;
      case 'delete':
        _showDeleteDialog(file);
        break;
    }
  }

  void _showRenameDialog(FileItem file) {
    final controller = TextEditingController(text: file.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'New name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(fileListProvider((serverId: widget.serverId, path: _currentPath)).notifier)
                  .renameItem(file.name, controller.text);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(FileItem file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete'),
        content: Text('Are you sure you want to delete "${file.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(fileListProvider((serverId: widget.serverId, path: _currentPath)).notifier)
                  .deleteItem(file.name);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
