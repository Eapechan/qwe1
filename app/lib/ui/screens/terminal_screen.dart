import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qwe1/state/terminal/terminal_provider.dart';
import 'package:qwe1/ui/theme/app_theme.dart';
import 'package:qwe1/ui/theme/app_typography.dart';
import 'package:qwe1/ui/widgets/touch_feedback.dart';

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
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        title: const Text('Terminal'),
        backgroundColor: const Color(0xFF000000),
        foregroundColor: Colors.white,
        actions: [
          if (_isConnected)
            IconButton(
              icon: const Icon(Icons.copy_rounded),
              onPressed: _copyToClipboard,
              tooltip: 'Copy',
            ),
          IconButton(
            icon: Icon(
              _isConnected
                  ? Icons.stop_circle_rounded
                  : Icons.play_circle_rounded,
            ),
            onPressed: _isConnected ? _disconnect : _connect,
            tooltip: _isConnected ? 'Disconnect' : 'Connect',
          ),
        ],
      ),
      body: Column(
        children: [
          // Connection status bar
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _isConnected
                  ? context.success.withOpacity(0.1)
                  : context.surfaceVariant,
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
                    color:
                        _isConnected ? context.success : context.onSurfaceMuted,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _isConnected ? 'Connected' : 'Disconnected',
                  style: AppTypography.labelMedium(context).copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_sessionId != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    _sessionId!,
                    style: AppTypography.labelSmall(context).copyWith(
                      color: context.onSurfaceMuted,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Terminal output area
          Expanded(
            child: _isConnected
                ? _buildTerminalOutput()
                : _buildDisconnectedState(),
          ),

          // Quick action buttons
          if (_isConnected)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: context.surface,
                border: Border(
                  top: BorderSide(color: context.border),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickKey('ESC', '\x1b'),
                  _buildQuickKey('TAB', '\t'),
                  _buildQuickKey('CTRL+C', '\x03'),
                  _buildQuickKey('↑', '\x1b[A'),
                  _buildQuickKey('↓', '\x1b[B'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTerminalOutput() {
    if (_sessionId == null) return const SizedBox.shrink();

    final outputAsync = ref.watch(
      terminalOutputProvider(
        (serverId: widget.serverId, sessionId: _sessionId!),
      ),
    );

    return outputAsync.when(
      data: (data) {
        final text = utf8.decode(data, allowMalformed: true);
        return Container(
          color: const Color(0xFF000000),
          padding: const EdgeInsets.all(12),
          child: SelectableText(
            text,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              color: Color(0xFFE0E0E0),
              height: 1.4,
            ),
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF06B6D4),
          strokeWidth: 2,
        ),
      ),
      error: (error, _) => Center(
        child: Text(
          'Error: $error',
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildDisconnectedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: context.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.terminal_rounded,
              size: 40,
              color: context.primary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Active Session',
            style: AppTypography.displaySmall(context).copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Connect to start a terminal session',
            style: AppTypography.bodyMedium(context).copyWith(
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
    );
  }

  Widget _buildQuickKey(String label, String sequence) {
    return TouchFeedback(
      onTap: () => _sendInput(sequence),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: context.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall(context).copyWith(
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  void _sendInput(String data) {
    if (_sessionId == null) return;
    final repository = ref.read(terminalRepositoryProvider);
    repository.sendInput(
      widget.serverId,
      _sessionId!,
      Uint8List.fromList(utf8.encode(data)),
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
      ref
          .read(terminalSessionsProvider(widget.serverId).notifier)
          .deleteSession(_sessionId!);
    }
    setState(() {
      _isConnected = false;
      _sessionId = null;
    });
  }

  void _copyToClipboard() {
    final outputAsync = ref.read(
      terminalOutputProvider(
        (serverId: widget.serverId, sessionId: _sessionId!),
      ),
    );
    outputAsync.whenData((data) {
      final text = utf8.decode(data, allowMalformed: true);
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terminal output copied to clipboard'),
          duration: Duration(seconds: 1),
        ),
      );
    });
  }
}
