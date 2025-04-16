import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

abstract class WebSocketService {
  Future<void> connect({required String token});
  void disconnect();
  Stream<dynamic> get onMessage;
  Future<void> sendMessage(Map<String, dynamic> message);
  bool get isConnected;
}

class WebSocketServiceImpl implements WebSocketService {
  final String baseUrl;
  WebSocketChannel? _channel;
  final _messageStreamController = StreamController<dynamic>.broadcast();
  bool _isConnected = false;
  Timer? _pingTimer;
  final Duration _pingInterval = const Duration(seconds: 30);

  WebSocketServiceImpl({required this.baseUrl});

  @override
  Future<void> connect({String? token}) async {
    if (_isConnected) return;

    try {
      debugPrint('Connecting to WebSocket: $baseUrl');

      _channel = IOWebSocketChannel.connect(
        headers: {'Authorization': 'Bearer $token'},
        baseUrl,
        pingInterval: _pingInterval,
      );

      _isConnected = true;

      // Listen to incoming messages and forward them to our stream
      _channel!.stream.listen(
        (message) {
          // Parse JSON message
          try {
            final decodedMessage = jsonDecode(message);
            _messageStreamController.add(decodedMessage);
          } catch (e) {
            debugPrint('Failed to decode WebSocket message: $e');
            _messageStreamController.add(message);
          }
        },
        onDone: () {
          debugPrint('WebSocket connection closed');
          _isConnected = false;
          _cancelPingTimer();

          // Attempt to reconnect after a delay
          Future.delayed(const Duration(seconds: 5), () {
            if (!_isConnected) {
              connect(token: token);
            }
          });
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
          _isConnected = false;
          _cancelPingTimer();
        },
      );

      // Start ping timer for keeping connection alive
      _startPingTimer();
    } catch (e) {
      debugPrint('Failed to connect to WebSocket: $e');
      _isConnected = false;
      // Retry connection after delay
      Future.delayed(const Duration(seconds: 5), () {
        connect(token: token);
      });
    }
  }

  void _startPingTimer() {
    _pingTimer = Timer.periodic(_pingInterval, (_) {
      if (_isConnected && _channel != null) {
        try {
          // Send a ping message to keep the connection alive
          sendMessage({'type': 'ping'});
        } catch (e) {
          debugPrint('Failed to send ping: $e');
        }
      }
    });
  }

  void _cancelPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  @override
  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close(status.goingAway);
      _channel = null;
    }
    _isConnected = false;
    _cancelPingTimer();
  }

  @override
  Stream<dynamic> get onMessage => _messageStreamController.stream;

  @override
  Future<void> sendMessage(Map<String, dynamic> message) async {
    if (!_isConnected || _channel == null) {
      throw Exception('WebSocket not connected');
    }

    try {
      final jsonMessage = jsonEncode(message);
      _channel!.sink.add(jsonMessage);
    } catch (e) {
      debugPrint('Failed to send message: $e');
      rethrow;
    }
  }

  @override
  bool get isConnected => _isConnected;
}
