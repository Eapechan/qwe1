import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qwe1/state/terminal/terminal_provider.dart';
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
              icon: const Icon(Icons.content_copy),
              onPressed: _copyToClipboard,
              tooltip: 'Copy',
            ),
          IconButton(
            icon: Icon(_isConnected ? Icons.stop : Icons.play_arrow),
            onPressed: _isConnected ? _disconnect : _connect,
          ),
        ],
      ),
      body: Column(
        children: [
          // Connection status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: _isConnected ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
            child: Row(
              children: [
                Icon(
                  _isConnected ? Icons.circle : Icons.circle_outlined,
                  color: _isConnected ? Colors.green : Colors.red,
                  size: 12,
                ),
                const SizedBox(width: 8),
                Text(
                  _isConnected ? 'Connected' : 'Disconnected',
                  style: TextStyle(
                    color: _isConnected ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (_sessionId != null)
                  Text(
                    'Session: $_sessionId',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),

          // Terminal view
          Expanded(
            child: _isConnected
                ? TerminalView(
                    serverId: widget.serverId,
                    sessionId: _sessionId!,
                    onInput: _sendInput,
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.terminal, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'Not connected',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _connect,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Connect'),
                        ),
                      ],
                    ),
                  ),
          ),

          // Quick action buttons
          if (_isConnected)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                border: Border(
                  top: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildQuickButton('ESC', '\x1b'),
                  _buildQuickButton('TAB', '\t'),
                  _buildQuickButton('CTRL+C', '\x03'),
                  _buildQuickButton('↑', '\x1b[A'),
                  _buildQuickButton('↓', '\x1b[B'),
                  _buildQuickButton('←', '\x1b[D'),
                  _buildQuickButton('→', '\x1b[C'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickButton(String label, String sequence) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: () => _sendInput(sequence.codeUnits),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  Future<void> _connect() async {
    try {
      final notifier = ref.read(terminalSessionsProvider(widget.serverId).notifier);
      final session = await notifier.createSession();

      setState(() {
        _isConnected = true;
        _sessionId = session.sessionId;
      });

      ref.read(activeTerminalProvider.notifier).state = session;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect: $e')),
        );
      }
    }
  }

  Future<void> _disconnect() async {
    if (_sessionId != null) {
      try {
        final notifier = ref.read(terminalSessionsProvider(widget.serverId).notifier);
        await notifier.deleteSession(_sessionId!);
      } catch (e) {
        // Ignore errors on disconnect
      }
    }

    setState(() {
      _isConnected = false;
      _sessionId = null;
    });

    ref.read(activeTerminalProvider.notifier).state = null;
  }

  void _sendInput(List<int> data) {
    // TODO: Send input to terminal
  }

  void _copyToClipboard() {
    // TODO: Copy terminal output to clipboard
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }
}
