import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService extends ChangeNotifier {
  WebSocketChannel? _channel;
  final List<String> _logs = [];
  bool _isConnected = false;
  StreamSubscription? _subscription;
  
  // Custom alert notifier for in-app critical alerts
  final ValueNotifier<String?> criticalAlert = ValueNotifier(null);

  List<String> get logs => List.unmodifiable(_logs);
  bool get isConnected => _isConnected;

  void connect(String url) {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _isConnected = true;
      _addLog('SYSTEM: WebSocket connected to $url');

      _subscription = _channel!.stream.listen(
        (message) {
          final msgStr = message.toString();
          _addLog(msgStr);
          if (msgStr.contains('CRITICAL')) {
            criticalAlert.value = msgStr; // Trigger UI alert
            // Clear it after a moment so it can trigger again
            Future.delayed(const Duration(seconds: 5), () {
              if (criticalAlert.value == msgStr) criticalAlert.value = null;
            });
          }
        },
        onError: (error) {
          _addLog('ERROR: WebSocket error — $error');
          _isConnected = false;
          notifyListeners();
        },
        onDone: () {
          _addLog('SYSTEM: WebSocket connection closed.');
          _isConnected = false;
          notifyListeners();
        },
      );
      notifyListeners();
    } catch (e) {
      _addLog('ERROR: Could not connect. Is FastAPI running at $url?');
      _isConnected = false;
      notifyListeners();
    }
  }

  void send(String message) {
    _channel?.sink.add(message);
  }

  void _addLog(String log) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    _logs.add('[$timestamp] $log');
    notifyListeners();
  }

  void disconnect() {
    _subscription?.cancel();
    _channel?.sink.close();
    _isConnected = false;
    _addLog('SYSTEM: Disconnected.');
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    criticalAlert.dispose();
    super.dispose();
  }
}

