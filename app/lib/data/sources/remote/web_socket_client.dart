import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:qwe1/core/error/error_mapper.dart';

class WebSocketClient {
  WebSocketClient({required this.baseUrl});

  final String baseUrl;
  WebSocketChannel? _channel;
  final Map<String, StreamController<dynamic>> _channels = {};
  final Map<String, StreamSubscription> _subscriptions = {};
  Timer? _heartbeatTimer;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  Stream<dynamic> subscribe(String channel) {
    if (_channels.containsKey(channel)) {
      return _channels[channel]!.stream;
    }

    final controller = StreamController<dynamic>.broadcast();
    _channels[channel] = controller;

    _sendSubscribe(channel);

    return controller.stream;
  }

  void unsubscribe(String channel) {
    _sendUnsubscribe(channel);
    _channels[channel]?.close();
    _channels.remove(channel);
    _subscriptions.remove(channel);
  }

  Future<void> connect({required String token, required List<String> channels}) async {
    final wsUrl = baseUrl.replaceFirst('https://', 'wss://').replaceFirst('http://', 'ws://');
    final channelParams = channels.join(',');
    final url = '$wsUrl/ws?channels=$channelParams&token=$token';

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));

      _channel!.stream.listen(
        _onMessage,
        onDone: _onDone,
        onError: _onError,
      );

      _isConnected = true;
      _startHeartbeat();
    } catch (e) {
      throw ErrorMapper.fromWebSocketException(e);
    }
  }

  Future<void> disconnect() async {
    _stopHeartbeat();
    _isConnected = false;

    for (final subscription in _subscriptions.values) {
      await subscription.cancel();
    }
    _subscriptions.clear();

    for (final controller in _channels.values) {
      await controller.close();
    }
    _channels.clear();

    await _channel?.sink.close();
    _channel = null;
  }

  void sendBinary(Uint8List data) {
    _channel?.sink.add(data);
  }

  void sendJson(Map<String, dynamic> data) {
    _channel?.sink.add(jsonEncode(data));
  }

  void _onMessage(dynamic message) {
    if (message is String) {
      // The Go agent batches multiple newline-separated JSON objects per frame.
      final lines = message.split('\n');
      for (final line in lines) {
        if (line.isEmpty) continue;
        try {
          final data = jsonDecode(line) as Map<String, dynamic>;
          final channel = data['ch'] as String?;
          final payload = data['data'];

          if (channel != null && _channels.containsKey(channel)) {
            _channels[channel]!.add(payload);
          }
        } catch (_) {}
      }
    } else if (message is Uint8List) {
      // Binary frame - could be terminal output
      for (final controller in _channels.values) {
        controller.add(message);
      }
    }
  }

  void _onDone() {
    _isConnected = false;
    _stopHeartbeat();

    for (final controller in _channels.values) {
      controller.add(null); // Signal stream end
    }
  }

  void _onError(Object error) {
    _isConnected = false;
    _stopHeartbeat();

    final exception = ErrorMapper.fromWebSocketException(error);
    for (final controller in _channels.values) {
      controller.addError(exception);
    }
  }

  void _sendSubscribe(String channel) {
    sendJson({'op': 'subscribe', 'channel': channel});
  }

  void _sendUnsubscribe(String channel) {
    sendJson({'op': 'unsubscribe', 'channel': channel});
  }

  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      sendJson({'op': 'ping'});
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }
}
