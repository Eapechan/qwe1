import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qwe1/core/error/app_exception.dart';
import 'package:qwe1/ui/theme/app_theme.dart';
import 'package:qwe1/ui/theme/app_typography.dart';
import 'package:qwe1/ui/widgets/container_card.dart';
import 'package:qwe1/ui/widgets/empty_state.dart';
import 'package:qwe1/ui/widgets/skeleton_card.dart';
import 'package:qwe1/state/docker/container_provider.dart';

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
      backgroundColor: context.background,
      appBar: AppBar(
        title: const Text('Containers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(containerListProvider(widget.serverId)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              onChanged: (value) => setState(() => _search = value),
              decoration: InputDecoration(
                hintText: 'Search containers...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

          // Container list
          Expanded(
            child: containersAsync.when(
              data: (containers) {
                var filtered = containers.where((c) {
                  final matchesFilter = _filter == 'all' ||
                      (_filter == 'running' &&
                          c.state.toLowerCase() == 'running') ||
                      (_filter == 'stopped' &&
                          c.state.toLowerCase() != 'running');
                  final matchesSearch = _search.isEmpty ||
                      c.name
                          .toLowerCase()
                          .contains(_search.toLowerCase()) ||
                      c.image
                          .toLowerCase()
                          .contains(_search.toLowerCase());
                  return matchesFilter && matchesSearch;
                }).toList();

                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: Icons.inventory_2_rounded,
                    title: 'No containers',
                    message: _search.isEmpty
                        ? 'No containers found on this server'
                        : 'No containers match your search',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(containerListProvider(widget.serverId));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final container = filtered[index];
                      return ContainerCard(
                        container: container,
                        onTap: () => context.push(
                          '/server/${widget.serverId}/containers/${container.id}',
                        ),
                        onStart: () => ref
                            .read(
                              containerListProvider(widget.serverId).notifier,
                            )
                            .startContainer(container.id),
                        onStop: () => ref
                            .read(
                              containerListProvider(widget.serverId).notifier,
                            )
                            .stopContainer(container.id),
                        onRestart: () => ref
                            .read(
                              containerListProvider(widget.serverId).notifier,
                            )
                            .restartContainer(container.id),
                      );
                    },
                  ),
                );
              },
              loading: () => ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: 5,
                itemBuilder: (context, index) => const SkeletonCard(),
              ),
              error: (error, _) {
                final isDockerUnavailable =
                    error is ServerUnavailableException;
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isDockerUnavailable
                              ? Icons.cloud_off_rounded
                              : Icons.error_outline_rounded,
                          size: 48,
                          color: isDockerUnavailable
                              ? Colors.grey
                              : context.danger,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isDockerUnavailable
                              ? 'Docker is not available'
                              : 'Error: $error',
                          textAlign: TextAlign.center,
                          style: AppTypography.titleLarge(context),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isDockerUnavailable
                              ? 'Docker is not reachable on this server. '
                                  'Confirm the Docker daemon socket is mounted '
                                  'and the agent can access it.'
                              : '',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall(context).copyWith(
                            color: context.onSurfaceMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
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
      onSelected: (selected) => setState(() => _filter = value),
      selectedColor: Theme.of(context).colorScheme.primary,
      checkmarkColor: Theme.of(context).colorScheme.onPrimary,
      labelStyle: TextStyle(
        color: isSelected
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}