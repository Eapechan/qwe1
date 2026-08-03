import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qwe1/state/servers/server_provider.dart';
import 'package:qwe1/core/utils/validators.dart';
import 'package:qwe1/core/utils/qr_enrollment.dart';
import 'package:qwe1/ui/screens/qr_scan_screen.dart';
import 'package:qwe1/ui/theme/app_theme.dart';

class AddServerScreen extends ConsumerStatefulWidget {
  const AddServerScreen({super.key});

  @override
  ConsumerState<AddServerScreen> createState() => _AddServerScreenState();
}

class _AddServerScreenState extends ConsumerState<AddServerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _tokenController = TextEditingController();
  final _groupController = TextEditingController();

  bool _isLoading = false;
  String? _error;
  String _tailscaleUrl = '';

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _tokenController.dispose();
    _groupController.dispose();
    super.dispose();
  }

  Future<void> _scanQr() async {
    final data = await Navigator.of(context).push<QrEnrollmentData>(
      MaterialPageRoute(builder: (_) => const QrScanScreen()),
    );
    if (data == null || !mounted) return;

    // Show editable-name dialog, then auto-submit.
    final nameCtrl = TextEditingController(text: data.name);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Server Name'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(hintText: 'e.g., my-server'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, nameCtrl.text.trim()),
            child: const Text('Connect'),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty || !mounted) return;

    setState(() {
      _nameController.text = result;
      _urlController.text = data.agentUrl;
      _tokenController.text = data.token;
      _tailscaleUrl = data.tailscaleUrl;
      _isLoading = true;
      _error = null;
    });

    await _addServer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Server'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Scan QR button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _scanQr,
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                  label: const Text('Scan QR Code'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or enter manually',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.onSurfaceMuted,
                          ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 12),

              // Instructions card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.08),
                      Theme.of(context).colorScheme.primary.withOpacity(0.03),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.info_outline_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How to get started',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Run "./token.sh" or "qwe1-agent --enroll" on your server to get a QR code or token.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: context.onSurfaceMuted,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Server name
              Text(
                'Server Name',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'e.g., my-server',
                  prefixIcon: Icon(Icons.dns_rounded, size: 20),
                ),
                validator: Validators.validateServerName,
              ),
              const SizedBox(height: 20),

              // Agent URL
              Text(
                'Agent URL',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  hintText: 'http://192.168.1.100:9443',
                  prefixIcon: Icon(Icons.link_rounded, size: 20),
                ),
                keyboardType: TextInputType.url,
                validator: Validators.validateUrl,
              ),
              const SizedBox(height: 20),

              // Enrollment token
              Text(
                'Enrollment Token',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _tokenController,
                decoration: const InputDecoration(
                  hintText: 'Paste token from qwe1-agent --enroll',
                  prefixIcon: Icon(Icons.vpn_key_rounded, size: 20),
                ),
                validator: Validators.validateEnrollmentToken,
              ),
              const SizedBox(height: 20),

              // Group (optional)
              Text(
                'Group (optional)',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _groupController,
                decoration: const InputDecoration(
                  hintText: 'e.g., home, production',
                  prefixIcon: Icon(Icons.folder_rounded, size: 20),
                ),
              ),
              const SizedBox(height: 28),

              // Error message
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: context.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.danger.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: context.danger,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: context.danger,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Add button
              ElevatedButton(
                onPressed: _isLoading ? null : _addServer,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Add Server'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addServer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(serverListProvider.notifier).addServer(
            name: _nameController.text.trim(),
            agentUrl: _urlController.text.trim(),
            enrollmentToken: _tokenController.text.trim(),
            tailscaleUrl: _tailscaleUrl,
            groupName: _groupController.text.trim(),
          );

      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
