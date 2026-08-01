import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TerminalView extends ConsumerStatefulWidget {
  const TerminalView({
    super.key,
    required this.serverId,
    required this.sessionId,
    required this.onInput,
  });

  final String serverId;
  final String sessionId;
  final void Function(List<int> data) onInput;

  @override
  ConsumerState<TerminalView> createState() => _TerminalViewState();
}

class _TerminalViewState extends ConsumerState<TerminalView> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();
  final List<String> _output = [];

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Terminal output
        Expanded(
          child: Container(
            color: Colors.black,
            padding: const EdgeInsets.all(8),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _output.length,
              itemBuilder: (context, index) {
                return Text(
                  _output[index],
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: Colors.green,
                  ),
                );
              },
            ),
          ),
        ),

        // Input field
        Container(
          color: Colors.grey[900],
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Text(
                '> ',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: Colors.white,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onSubmitted: _handleInput,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleInput(String input) {
    if (input.isNotEmpty) {
      widget.onInput(input.codeUnits + [13]); // Add newline
      setState(() {
        final prompt = '> ';
        _output.add(prompt + input);
      });
    }
    _controller.clear();
  }
}
