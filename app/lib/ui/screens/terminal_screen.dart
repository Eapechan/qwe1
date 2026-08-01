import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qwe1/state/terminal/terminal_provider.dart';
import 'package:qwe1/ui/theme/app_theme.dart';
import 'package:qwe1/ui/widgets/terminal_view.dart';

class TerminalScreen extends ConsumerStatefulWidget {
  const TerminalScreen({super.key, required this.serverId});

  final String serverId;

  @override
  ConsumerState<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends ConsumerState<TerminalScreen> {
  bool _isConnected = false;
  String? _sessionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terminal'),
        actions: [
          if (_isConnected)
            IconButton(
              icon: const Icon(Icons.copy_rounded),
              onPressed: _copyToClipboard,
              tooltip: 'Copy',
            ),
          IconButton(
            icon: Icon(_isConnected ? Icons.stop_circle_rounded : Icons.play_circle_rounded),
            onPressed: _isConnected ? _disconnect : _connect,
            tooltip: _isConnected ? 'Disconnect' : 'Connect',
          ),
        ],
      ),
      body: Column(
        children: [
          // Connection status
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _isConnected
                  ? context.success.withOpacity(0.1)
                  : Theme.of(context).colorScheme.surfaceVariant,
              border: Border(
                bottom: BorderSide(
                  color: _isConnected
                      ? context.success.withOpacity(0.2)
                      : context.border,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isConnected
                        ? context.success
                        : context.onSurfaceMuted,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _isConnected ? 'Connected' : 'Disconnected',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                if (_sessionId != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    _sessionId!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.onSurfaceMuted,
                          fontFamily: 'monospace',
                        ),
                  ),
                ],
              ],
            ),
          ),

          // Terminal view
          Expanded(
            child: _isConnected
                ? TerminalView(
                    sessionId: _sessionId!,
                    serverId: widget.serverId,
                    onInput: (data) {},
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.terminal_rounded,
                            size: 40,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No Active Session',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Connect to start a terminal session',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.onSurfaceMuted,
                              ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _connect,
                          icon: const Icon(Icons.play_circle_rounded),
                          label: const Text('Connect'),
                        ),
                      ],
                    ),
                  ),
          ),

          // Quick action buttons
          if (_isConnected)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(color: context.border),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickKey('ESC', () => _sendKey('\x1b')),
                  _buildQuickKey('TAB', () => _sendKey('\t')),
                  _buildQuickKey('CTRL+C', () => _sendKey('\x03')),
                  _buildQuickKey('↑', () => _sendKey('\x1b[A')),
                  _buildQuickKey('↓', () => _sendKey('\x1b[B')),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickKey(String label, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
              ),
        ),
      ),
    );
  }

  Future<void> _connect() async {
    try {
      final session = await ref
          .read(terminalSessionsProvider(widget.serverId).notifier)
          .createSession();
      setState(() {
        _isConnected = true;
        _sessionId = session.sessionId;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect: $e')),
        );
      }
    }
  }

  void _disconnect() {
    if (_sessionId != null) {
      ref.read(terminalSessionsProvider(widget.serverId).notifier).deleteSession(_sessionId!);
    }
    setState(() {
      _isConnected = false;
      _sessionId = null;
    });
  }

  void _sendKey(String key) {
    // TODO: Send key to terminal via WebSocket
  }

  void _copyToClipboard() {
    // TODO: Copy terminal output to clipboard
  }
}
