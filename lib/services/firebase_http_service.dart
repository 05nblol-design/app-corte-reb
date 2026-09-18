import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

enum FirebaseSyncStatus { disconnected, connecting, connected, error }

class FirebaseHttpService {
  String firebaseUrl;
  final Duration refreshInterval;
  final Function(Map<String, dynamic> data) onDataReceived;
  final Function(FirebaseSyncStatus status)? onStatusChanged;

  Timer? _pollingTimer;
  FirebaseSyncStatus _status = FirebaseSyncStatus.disconnected;
  bool _isDisposed = false;

  FirebaseHttpService({
    required this.firebaseUrl,
    required this.onDataReceived,
    this.refreshInterval = const Duration(seconds: 5),
    this.onStatusChanged,
  });

  FirebaseSyncStatus get status => _status;

  void start() {
    _isDisposed = false;
    fetchNow();
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(refreshInterval, (_) => fetchNow());
  }

  Future<void> fetchNow() async {
    if (_isDisposed || firebaseUrl.trim().isEmpty) return;

    try {
      if (_status != FirebaseSyncStatus.connected) {
        _setStatus(FirebaseSyncStatus.connecting);
      }

      final uri = Uri.parse(firebaseUrl.trim());
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        _setStatus(FirebaseSyncStatus.connected);
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          onDataReceived(decoded);
        } else if (decoded is String) {
          final inner = jsonDecode(decoded);
          if (inner is Map<String, dynamic>) {
            onDataReceived(inner);
          }
        }
      } else {
        debugPrint('[FirebaseHttp] Status ${response.statusCode}');
        _setStatus(FirebaseSyncStatus.error);
      }
    } catch (e) {
      debugPrint('[FirebaseHttp] Erro ao sincronizar: $e');
      _setStatus(FirebaseSyncStatus.error);
    }
  }

  void updateUrl(String newUrl) {
    firebaseUrl = newUrl;
    fetchNow();
  }

  void _setStatus(FirebaseSyncStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      onStatusChanged?.call(_status);
    }
  }

  void stop() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _setStatus(FirebaseSyncStatus.disconnected);
  }

  void dispose() {
    _isDisposed = true;
    stop();
  }
}
