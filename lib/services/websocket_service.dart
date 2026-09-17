import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum WebSocketStatus { disconnected, connecting, connected, error }

class WebSocketService {
  final String serverUrl;
  final Function(Map<String, dynamic> data)? onTelemetryReceived;
  final Function(WebSocketStatus status)? onStatusChanged;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  bool _shouldReconnect = true;

  WebSocketStatus _status = WebSocketStatus.disconnected;
  WebSocketStatus get status => _status;

  WebSocketService({
    this.serverUrl = 'ws://localhost:1880/ws/telemetria',
    this.onTelemetryReceived,
    this.onStatusChanged,
  });

  void _updateStatus(WebSocketStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      debugPrint('[WebSocket] Status: $_status ($serverUrl)');
      onStatusChanged?.call(_status);
    }
  }

  Future<void> connect() async {
    if (_status == WebSocketStatus.connected || _status == WebSocketStatus.connecting) {
      return;
    }

    _shouldReconnect = true;
    _updateStatus(WebSocketStatus.connecting);

    try {
      final uri = Uri.parse(serverUrl);
      _channel = WebSocketChannel.connect(uri);

      // Wait for the ready event or listen to stream
      await _channel!.ready;

      _updateStatus(WebSocketStatus.connected);

      _subscription = _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onDone: () {
          debugPrint('[WebSocket] Conexão encerrada pelo servidor');
          _cleanupConnection();
          _scheduleReconnect();
        },
        onError: (error) {
          debugPrint('[WebSocket] Erro na transmissão: $error');
          _cleanupConnection();
          _scheduleReconnect();
        },
        cancelOnError: true,
      );
    } catch (e) {
      debugPrint('[WebSocket] Falha ao conectar em $serverUrl: $e');
      _cleanupConnection();
      _scheduleReconnect();
    }
  }

  void _handleMessage(dynamic rawMessage) {
    try {
      final String text = rawMessage is String ? rawMessage : utf8.decode(rawMessage);
      final dynamic decoded = jsonDecode(text);

      if (decoded is Map<String, dynamic>) {
        onTelemetryReceived?.call(decoded);
      } else if (decoded is List) {
        onTelemetryReceived?.call({'items': decoded});
      }
    } catch (e) {
      debugPrint('[WebSocket] Erro ao decodificar JSON: $e');
    }
  }

  void sendJson(Map<String, dynamic> data) {
    if (_channel != null && _status == WebSocketStatus.connected) {
      try {
        final encoded = jsonEncode(data);
        _channel!.sink.add(encoded);
      } catch (e) {
        debugPrint('[WebSocket] Erro ao enviar mensagem: $e');
      }
    }
  }

  void _scheduleReconnect() {
    if (!_shouldReconnect) return;
    _updateStatus(WebSocketStatus.disconnected);
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 4), () {
      if (_status != WebSocketStatus.connected) {
        debugPrint('[WebSocket] Tentando reconectar a $serverUrl...');
        connect();
      }
    });
  }

  void _cleanupConnection() {
    _subscription?.cancel();
    _subscription = null;
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
  }

  void disconnect() {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _cleanupConnection();
    _updateStatus(WebSocketStatus.disconnected);
  }
}
