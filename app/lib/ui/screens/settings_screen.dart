import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qwe1/state/settings/settings_provider.dart';
import 'package:qwe1/ui/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

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
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Appearance
          _buildSectionHeader(context, 'Appearance'),
          _buildSettingsTile(
            context,
            icon: Icons.dark_mode_rounded,
            title: 'Theme',
            subtitle: _getThemeName(settings.themeMode),
            onTap: () => _showThemeDialog(context, ref, settings.themeMode),
          ),
          const Divider(indent: 56, endIndent: 16),

          // Security
          _buildSectionHeader(context, 'Security'),
          _buildSwitchTile(
            context,
            icon: Icons.fingerprint_rounded,
            title: 'Biometric Lock',
            subtitle: 'Require biometric authentication to open the app',
            value: settings.biometricEnabled,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setBiometricEnabled(value);
            },
          ),
          const Divider(indent: 56, endIndent: 16),

          // Server Defaults
          _buildSectionHeader(context, 'Server Defaults'),
          _buildSwitchTile(
            context,
            icon: Icons.lock_rounded,
            title: 'Read-only Mode',
            subtitle: 'New servers default to read-only mode',
            value: settings.readOnlyMode,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setReadOnlyMode(value);
            },
          ),
          const Divider(indent: 56, endIndent: 16),

          // Data
          _buildSectionHeader(context, 'Data'),
          _buildSettingsTile(
            context,
            icon: Icons.cleaning_services_rounded,
            title: 'Clear Cache',
            subtitle: 'Clear cached data and temporary files',
            onTap: () => _showClearCacheDialog(context, ref),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.upload_rounded,
            title: 'Export Server List',
            subtitle: 'Export your server configurations',
            onTap: () {
              // TODO: Implement export
            },
          ),
          const Divider(indent: 56, endIndent: 16),

          // About
          _buildSectionHeader(context, 'About'),
          _buildSettingsTile(
            context,
            icon: Icons.info_outline_rounded,
            title: 'Version',
            subtitle: '1.0.0',
          ),
          _buildSettingsTile(
            context,
            icon: Icons.code_rounded,
            title: 'Source Code',
            subtitle: 'View on GitHub',
            onTap: () async {
              final url = Uri.parse('https://github.com/qwe1/qwe1');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.gavel_rounded,
            title: 'License',
            subtitle: 'AGPL-3.0-or-later',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: context.onSurfaceMuted),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: context.onSurfaceMuted),
      ),
      trailing: onTap != null
          ? Icon(Icons.chevron_right_rounded, color: context.onSurfaceMuted)
          : null,
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: context.onSurfaceMuted),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: context.onSurfaceMuted),
      ),
      value: value,
      onChanged: onChanged,
    );
  }

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref, ThemeMode currentMode) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Theme'),
        children: [
          _buildThemeOption(context, ref, 'Light', ThemeMode.light, currentMode),
          _buildThemeOption(context, ref, 'Dark', ThemeMode.dark, currentMode),
          _buildThemeOption(context, ref, 'System Default', ThemeMode.system, currentMode),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref,
    String title,
    ThemeMode mode,
    ThemeMode currentMode,
  ) {
    return RadioListTile<ThemeMode>(
      title: Text(title),
      value: mode,
      groupValue: currentMode,
      onChanged: (value) {
        if (value != null) {
          ref.read(settingsProvider.notifier).setThemeMode(value);
          Navigator.pop(context);
        }
      },
    );
  }

  void _showClearCacheDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will clear cached data and temporary files. Server configurations will not be affected.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement cache clearing
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
