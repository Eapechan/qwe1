import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qwe1/state/servers/server_provider.dart';
import 'package:qwe1/core/utils/validators.dart';

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

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _tokenController.dispose();
    _groupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Server'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Instructions
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'How to get started',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '1. Install the agent on your server\n'
                        '2. Run "qwe1-agent enroll" to get a token\n'
                        '3. Scan the QR code or paste the token below',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Server name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Server Name',
                  hintText: 'e.g., my-server',
                ),
                validator: Validators.validateServerName,
              ),
              const SizedBox(height: 16),

              // Agent URL
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'Agent URL',
                  hintText: 'https://192.168.1.100:9443',
                ),
                keyboardType: TextInputType.url,
                validator: Validators.validateUrl,
              ),
              const SizedBox(height: 16),

              // Enrollment token
              TextFormField(
                controller: _tokenController,
                decoration: const InputDecoration(
                  labelText: 'Enrollment Token',
                  hintText: 'qwe1-XXXXXXXXXXXX',
                ),
                validator: Validators.validateEnrollmentToken,
              ),
              const SizedBox(height: 16),

              // Group (optional)
              TextFormField(
                controller: _groupController,
                decoration: const InputDecoration(
                  labelText: 'Group (optional)',
                  hintText: 'e.g., home, production',
                ),
              ),
              const SizedBox(height: 24),

              // Error message
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),

              // Add button
              ElevatedButton(
                onPressed: _isLoading ? null : _addServer,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
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
