import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:qwe1/core/error/error_mapper.dart';

class WebSocketClient {
  WebSocketClient({required this.baseUrl, this.onTokenRefresh});

  final String baseUrl;
  final Future<String?> Function()? onTokenRefresh;

  WebSocketChannel? _channel;
  final Map<String, StreamController<dynamic>> _channels = {};
  final Map<String, StreamSubscription> _subscriptions = {};
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  bool _isConnected = false;
  bool _intentionalClose = false;
  String? _currentToken;
  List<String> _currentChannels = [];
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;
  static const Duration _maxReconnectDelay = Duration(seconds: 60);

  bool get isConnected => _isConnected;

  Stream<dynamic> subscribe(String channel) {
    if (_channels.containsKey(channel)) {
      return _channels[channel]!.stream;
    }

    final controller = StreamController<dynamic>.broadcast();
    _channels[channel] = controller;

    if (_isConnected) {
      _sendSubscribe(channel);
    }

    return controller.stream;
  }

  void unsubscribe(String channel) {
    _sendUnsubscribe(channel);
    _channels[channel]?.close();
    _channels.remove(channel);
    _subscriptions.remove(channel);
  }

  Future<void> connect({required String token, required List<String> channels}) async {
    _currentToken = token;
    _currentChannels = channels;
    _intentionalClose = false;
    await _doConnect(token, channels);
  }

  Future<void> _doConnect(String token, List<String> channels) async {
    final wsUrl = baseUrl.replaceFirst('https://', 'wss://').replaceFirst('http://', 'ws://');
    final channelParams = channels.join(',');
    final url = '$wsUrl/ws?channels=$channelParams&token=$token';

    try {
      _channel = IOWebSocketChannel.connect(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      _channel!.stream.listen(
        _onMessage,
        onDone: _onDone,
        onError: _onError,
      );

      _isConnected = true;
      _reconnectAttempts = 0;
      _startHeartbeat();

      // Re-subscribe all registered channels
      for (final ch in _channels.keys) {
        _sendSubscribe(ch);
      }
    } catch (e) {
      throw ErrorMapper.fromWebSocketException(e);
    }
  }

  Future<void> disconnect() async {
    _intentionalClose = true;
    _stopHeartbeat();
    _cancelReconnect();
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

    if (!_intentionalClose) {
      _scheduleReconnect();
    }
  }

  void _onError(Object error) {
    _isConnected = false;
    _stopHeartbeat();

    final exception = ErrorMapper.fromWebSocketException(error);
    for (final controller in _channels.values) {
      controller.addError(exception);
    }

    if (!_intentionalClose) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      return;
    }

    _reconnectAttempts++;
    final delay = _getReconnectDelay();

    _reconnectTimer = Timer(delay, () async {
      try {
        // Refresh the token before reconnecting
        String? token = _currentToken;
        if (onTokenRefresh != null) {
          final refreshed = await onTokenRefresh!();
          if (refreshed != null) {
            token = refreshed;
            _currentToken = token;
          }
        }

        if (token == null) {
          _scheduleReconnect();
          return;
        }

        await _doConnect(token, _currentChannels);
      } catch (_) {
        _scheduleReconnect();
      }
    });
  }

  Duration _getReconnectDelay() {
    // Exponential backoff: 1s, 2s, 4s, 8s, 16s, 32s, 60s cap
    final delaySeconds = min(
      pow(2, _reconnectAttempts - 1).toInt(),
      _maxReconnectDelay.inSeconds,
    );
    return Duration(seconds: delaySeconds);
  }

  void _cancelReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectAttempts = 0;
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
