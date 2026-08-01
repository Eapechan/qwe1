import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qwe1/state/files/file_provider.dart';
import 'package:qwe1/ui/theme/app_theme.dart';
import 'package:qwe1/ui/widgets/empty_state.dart';

class FileBrowserScreen extends ConsumerStatefulWidget {
  const FileBrowserScreen({super.key, required this.serverId, this.initialPath = '/'});

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
    final filesAsync = ref.watch(fileListProvider((serverId: widget.serverId, path: _currentPath)));

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentPath.split('/').last.isEmpty ? 'Files' : _currentPath.split('/').last),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(fileListProvider((serverId: widget.serverId, path: _currentPath))),
          ),
          IconButton(
            icon: const Icon(Icons.create_new_folder_rounded),
            onPressed: _showCreateDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Breadcrumb
          _buildBreadcrumb(context),
          // File list
          Expanded(
            child: filesAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return EmptyState(
                    icon: Icons.folder_rounded,
                    title: 'Empty folder',
                    message: 'This folder is empty',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(fileListProvider((serverId: widget.serverId, path: _currentPath)));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildFileTile(context, item);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 48, color: context.danger),
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

  Widget _buildBreadcrumb(BuildContext context) {
    final parts = _currentPath.split('/').where((p) => p.isNotEmpty).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: context.border),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildBreadcrumbItem(context, '/', -1),
            for (int i = 0; i < parts.length; i++) ...[
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: context.onSurfaceMuted,
              ),
              _buildBreadcrumbItem(context, parts[i], i),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBreadcrumbItem(BuildContext context, String label, int index) {
    final isLast = index == _currentPath.split('/').length - 2;

    return InkWell(
      onTap: isLast
          ? null
          : () {
              final newPath = index == -1
                  ? '/'
                  : '/' + _currentPath.split('/').where((p) => p.isNotEmpty).take(index + 1).join('/');
              setState(() => _currentPath = newPath);
            },
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: isLast ? FontWeight.w600 : FontWeight.w500,
                color: isLast
                    ? Theme.of(context).colorScheme.primary
                    : context.onSurfaceMuted,
              ),
        ),
      ),
    );
  }

  Widget _buildFileTile(BuildContext context, item) {
    final isDir = item.isDir;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: InkWell(
        onTap: isDir
            ? () => setState(() => _currentPath = item.path)
            : () => _showFileActions(context, item),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDir
                      ? context.warning.withOpacity(0.12)
                      : Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isDir ? Icons.folder_rounded : _getFileIcon(item.name),
                  color: isDir
                      ? context.warning
                    : context.onSurfaceMuted,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!isDir && item.size != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _formatSize(item.size!),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.onSurfaceMuted,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!isDir)
                PopupMenuButton<String>(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'rename',
                      child: Row(
                        children: [
                          Icon(Icons.edit_rounded, size: 20),
                          SizedBox(width: 8),
                          Text('Rename'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_rounded, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'rename') _showRenameDialog(context, item);
                    if (value == 'delete') _showDeleteDialog(context, item);
                  },
                  icon: Icon(
                    Icons.more_vert_rounded,
                color: context.onSurfaceMuted,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getFileIcon(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'txt':
      case 'md':
        return Icons.description_rounded;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image_rounded;
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'zip':
      case 'tar':
      case 'gz':
        return Icons.archive_rounded;
      case 'json':
      case 'yaml':
      case 'yml':
        return Icons.code_rounded;
      case 'sh':
      case 'bash':
        return Icons.terminal_rounded;
      default:
        return Icons.insert_drive_file_rounded;
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

  void _showFileActions(BuildContext context, item) {
    // TODO: Implement file preview
  }

  void _showCreateDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Folder'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Folder name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(fileListProvider((serverId: widget.serverId, path: _currentPath)).notifier).createDirectory(
                      controller.text,
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, item) {
    final controller = TextEditingController(text: item.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'New name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(fileListProvider((serverId: widget.serverId, path: _currentPath)).notifier).renameItem(
                      item.name,
                      controller.text,
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text('Delete "${item.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(fileListProvider((serverId: widget.serverId, path: _currentPath)).notifier).deleteItem(
                    item.name,
                  );
              Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: context.danger),
            ),
          ),
        ],
      ),
    );
  }
}
