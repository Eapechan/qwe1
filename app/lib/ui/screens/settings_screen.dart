import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qwe1/state/settings/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Appearance section
          _buildSectionHeader(context, 'Appearance'),
          _buildThemeSelector(context, ref, settings.themeMode),

          // Security section
          _buildSectionHeader(context, 'Security'),
          SwitchListTile(
            title: const Text('Biometric Lock'),
            subtitle: const Text('Require biometric authentication to open the app'),
            value: settings.biometricEnabled,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setBiometricEnabled(value);
            },
          ),

          // Server defaults
          _buildSectionHeader(context, 'Server Defaults'),
          SwitchListTile(
            title: const Text('Read-only Mode'),
            subtitle: const Text('Default to read-only mode for new servers'),
            value: settings.readOnlyMode,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setReadOnlyMode(value);
            },
          ),

          // Data section
          _buildSectionHeader(context, 'Data'),
          ListTile(
            title: const Text('Clear Cache'),
            subtitle: const Text('Remove all cached metrics and container snapshots'),
            onTap: () => _showClearCacheDialog(context),
          ),
          ListTile(
            title: const Text('Export Server List'),
            subtitle: const Text('Export server configurations (without tokens)'),
            onTap: () {
              // TODO: Implement export
            },
          ),

          // About section
          _buildSectionHeader(context, 'About'),
          const ListTile(
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
          ListTile(
            title: const Text('Source Code'),
            subtitle: const Text('View on GitHub'),
            onTap: () {
              // TODO: Launch GitHub URL
            },
          ),
          ListTile(
            title: const Text('License'),
            subtitle: const Text('AGPL-3.0-or-later'),
            onTap: () {
              // TODO: Show license
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context, WidgetRef ref, ThemeMode currentMode) {
    return ListTile(
      title: const Text('Theme'),
      subtitle: Text(_getThemeModeLabel(currentMode)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => SimpleDialog(
            title: const Text('Select Theme'),
            children: ThemeMode.values.map((mode) {
              return SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(settingsProvider.notifier).setThemeMode(mode);
                },
                child: Row(
                  children: [
                    Icon(
                      currentMode == mode ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: currentMode == mode ? Theme.of(context).colorScheme.primary : null,
                    ),
                    const SizedBox(width: 12),
                    Text(_getThemeModeLabel(mode)),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  String _getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will remove all cached metrics and container snapshots. '
          'Server configurations will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement clear cache
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared')),
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
