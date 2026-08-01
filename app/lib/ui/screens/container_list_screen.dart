import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qwe1/state/docker/container_provider.dart';
import 'package:qwe1/ui/widgets/container_card.dart';
import 'package:qwe1/ui/widgets/empty_state.dart';

class ContainerListScreen extends ConsumerStatefulWidget {
  const ContainerListScreen({super.key, required this.serverId});

  final String serverId;

  @override
  ConsumerState<ContainerListScreen> createState() => _ContainerListScreenState();
}

class _ContainerListScreenState extends ConsumerState<ContainerListScreen> {
  String _filter = 'all';
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final containersAsync = ref.watch(containerListProvider(widget.serverId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Containers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(containerListProvider(widget.serverId).notifier).loadContainers();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Running', 'running'),
                const SizedBox(width: 8),
                _buildFilterChip('Stopped', 'stopped'),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search containers...',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (value) {
                setState(() {
                  _search = value.toLowerCase();
                });
              },
            ),
          ),
          const SizedBox(height: 8),

          // Container list
          Expanded(
            child: containersAsync.when(
              data: (containers) {
                final filtered = containers.where((c) {
                  final matchesFilter = _filter == 'all' ||
                      (_filter == 'running' && c.state == 'running') ||
                      (_filter == 'stopped' && c.state != 'running');

                  final matchesSearch = _search.isEmpty ||
                      c.name.toLowerCase().contains(_search) ||
                      c.image.toLowerCase().contains(_search);

                  return matchesFilter && matchesSearch;
                }).toList();

                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: Icons.inventory_2,
                    title: 'No containers found',
                    message: _search.isEmpty
                        ? 'No containers match the selected filter'
                        : 'No containers match your search',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.read(containerListProvider(widget.serverId).notifier).loadContainers();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final container = filtered[index];
                      return ContainerCard(
                        container: container,
                        onTap: () => context.push(
                          '/server/${widget.serverId}/containers/${container.id}',
                        ),
                        onStart: () => ref
                            .read(containerListProvider(widget.serverId).notifier)
                            .startContainer(container.id),
                        onStop: () => ref
                            .read(containerListProvider(widget.serverId).notifier)
                            .stopContainer(container.id),
                        onRestart: () => ref
                            .read(containerListProvider(widget.serverId).notifier)
                            .restartContainer(container.id),
                      );
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

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filter = value;
        });
      },
    );
  }
}
