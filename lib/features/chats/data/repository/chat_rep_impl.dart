// Repository implementation
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:list_in/features/chats/data/model/chat_message.dart';
import 'package:list_in/features/chats/data/model/chat_room.dart';
import 'package:list_in/features/chats/data/service/web_socet_sevice_impl.dart';
import 'package:list_in/features/chats/domain/repository/chat_rep.dart';

class ChatRepositoryImpl implements ChatRepository {
  final WebSocketService _webSocketService;

  final _messageController = StreamController<ChatMessage>.broadcast();
  final _roomUpdateController = StreamController<ChatRoom>.broadcast();

  // For handling request/response pattern over WebSocket
  final Map<String, Completer<dynamic>> _pendingRequests = {};
  int _requestId = 0;

  ChatRepositoryImpl({
    required WebSocketService webSocketService,
  }) : _webSocketService = webSocketService;

  @override
  Future<void> connect({required String token}) async {
    await _webSocketService.connect(token: token);

    // Listen to WebSocket messages and filter them by type
    _webSocketService.onMessage.listen((message) {
      if (message is Map<String, dynamic>) {
        final type = message['type'];

        // Handle specific message types
        if (type == 'new_message') {
          final chatMessage = ChatMessage.fromJson(message['data']);
          _messageController.add(chatMessage);
        } else if (type == 'room_update') {
          final chatRoom = ChatRoom.fromJson(message['data']);
          _roomUpdateController.add(chatRoom);
        }
        // Handle responses to requests
        else if (type == 'response' && message.containsKey('request_id')) {
          final requestId = message['request_id'];
          if (_pendingRequests.containsKey(requestId)) {
            final completer = _pendingRequests.remove(requestId);
            completer?.complete(message['data']);
          }
        }
      }
    });
  }

  @override
  void disconnect() {
    _webSocketService.disconnect();

    // Complete any pending requests with errors
    for (final completer in _pendingRequests.values) {
      completer.completeError('WebSocket disconnected');
    }
    _pendingRequests.clear();
  }

  // Helper method to send a request and wait for a response
  Future<dynamic> _sendRequest(
      String action, Map<String, dynamic> params) async {
    if (!_webSocketService.isConnected) {
      throw Exception('WebSocket not connected');
    }

    final requestId = (++_requestId).toString();
    final completer = Completer<dynamic>();
    _pendingRequests[requestId] = completer;

    // Set a timeout
    Timer(const Duration(seconds: 10), () {
      if (_pendingRequests.containsKey(requestId)) {
        final completer = _pendingRequests.remove(requestId);
        completer?.completeError('Request timed out');
      }
    });

    // Send the request
    await _webSocketService.sendMessage({
      'type': 'request',
      'action': action,
      'request_id': requestId,
      ...params,
    });

    return completer.future;
  }

  @override
  Stream<ChatMessage> get onMessage => _messageController.stream;

  @override
  Stream<ChatRoom> get onRoomUpdate => _roomUpdateController.stream;

  @override
  Future<List<ChatRoom>> getRooms() async {
    try {
      final response = await _sendRequest('get_rooms', {});
      final List<dynamic> rooms = response as List<dynamic>;
      return rooms.map((json) => ChatRoom.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Failed to get chat rooms: $e');
      rethrow;
    }
  }

  @override
  Future<List<ChatMessage>> getMessages(String roomId,
      {int? limit, String? lastMessageId}) async {
    try {
      final params = {
        'room_id': roomId,
      };

      if (limit != null) {
        params['limit'] = limit as String;
      }

      if (lastMessageId != null) {
        params['last_id'] = lastMessageId;
      }

      final response = await _sendRequest('get_messages', params);
      final List<dynamic> messages = response as List<dynamic>;
      return messages.map((json) => ChatMessage.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Failed to get chat messages: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendMessage(String roomId, String content) async {
    await _webSocketService.sendMessage({
      'type': 'message',
      'room_id': roomId,
      'content': content,
    });
  }

  @override
  Future<ChatRoom> createRoom(String name, List<String> participants) async {
    final response = await _sendRequest('create_room', {
      'name': name,
      'participants': participants,
    });

    return ChatRoom.fromJson(response);
  }

  @override
  Future<void> joinRoom(String roomId) async {
    await _webSocketService.sendMessage({
      'type': 'join_room',
      'room_id': roomId,
    });
  }

  @override
  Future<void> leaveRoom(String roomId) async {
    await _webSocketService.sendMessage({
      'type': 'leave_room',
      'room_id': roomId,
    });
  }
}
