// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:list_in/core/error/exeptions.dart';
import 'package:list_in/core/services/auth_service.dart';
import 'package:list_in/features/auth/data/sources/auth_local_data_source.dart';
import 'package:list_in/features/chats/data/model/chat_message_model.dart';
import 'package:list_in/features/chats/data/model/chat_room_model.dart';
import 'package:list_in/features/chats/domain/entity/user_status.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class ChatRemoteDataSource {
  final AuthLocalDataSource authLocalDataSource;
  final AuthService authService;
  final Dio dio;
  final String baseUrl = 'http://listin.uz';
  StompClient? _stompClient;

  final _messageStreamController =
      StreamController<ChatMessageModel>.broadcast();
  final _userStatusStreamController =
      StreamController<UserConnectionInfo>.broadcast();

  Stream<ChatMessageModel> get messageStream => _messageStreamController.stream;
  Stream<UserConnectionInfo> get userStatusStream =>
      _userStatusStreamController.stream;

  ChatRemoteDataSource({
    required this.dio,
    required this.authLocalDataSource,
    required this.authService,
  });

  Future<void> initializeWebSocket(String userId) async {
    final authToken = await authLocalDataSource.getLastAuthToken();
    if (authToken == null) {
      throw UnauthorizedException('No auth token found');
    }
    final wsUrl = 'ws://listin.uz:80/ws?token=${authToken.accessToken}';
    _stompClient = StompClient(
      config: StompConfig(
        url: wsUrl,
        beforeConnect: () async {
          print('Attempting to connect to WebSocket...');
          print('Using token: ${authToken.accessToken}...');
        },
        onWebSocketError: (dynamic error) {
          print('WebSocket Error: $error');
        },
        onStompError: (StompFrame frame) {
          print('STOMP Error: ${frame.body}');
        },
        onConnect: (StompFrame frame) {
          // Subscribe to private message channel
          _stompClient!.subscribe(
            destination: '/user/$userId/queue/messages',
            callback: (StompFrame frame) {
              if (frame.body != null) {
                final message =
                    ChatMessageModel.fromJson(jsonDecode(frame.body!));
                _messageStreamController.add(message);
              }
            },
          );

          // Subscribe to user status updates
          _stompClient!.subscribe(
            destination: '/user/public',
            callback: (StompFrame frame) {
              if (frame.body != null) {
                final data = jsonDecode(frame.body!);
                final userStatus = UserConnectionInfo(
                  nickName: data['nickName'],
                  email: data['email'],
                  status: data['status'] == 'ONLINE'
                      ? UserStatus.ONLINE
                      : UserStatus.OFFLINE,
                );
                _userStatusStreamController.add(userStatus);
              }
            },
          );
        },
      ),
    );

    _stompClient!.activate();
  }

  Future<void> disconnectWebSocket() async {
    _stompClient?.deactivate();
  }

  Future<void> connectUser(UserConnectionInfo connectionInfo) async {
    _stompClient?.send(
      destination: '/app/user.connectUser',
      body: jsonEncode(connectionInfo.toJson()),
    );
  }

  Future<void> disconnectUser(UserConnectionInfo connectionInfo) async {
    _stompClient?.send(
      destination: '/app/user.disconnectUser',
      body: jsonEncode(connectionInfo.toJson()),
    );
  }

  Future<void> sendMessage({
    String? id,
    required String senderId,
    required String recipientId,
    required String publicationId,
    required String content,
  }) async {
    final message = {
      'id': id,
      'senderId': senderId,
      'recipientId': recipientId,
      'publicationId': publicationId,
      'content': content,
    };

    _stompClient?.send(
      destination: '/app/chat',
      body: jsonEncode(message),
    );
  }

  Future<List<ChatRoomModel>> getChatRooms(String userId) async {
    final options = await authService.getAuthOptions();
    final response = await dio.get(
      '/chat-rooms/$userId',
      options: options,
    );

    if (response.statusCode == 200) {
      final List<dynamic> roomsJson = response.data;
      return roomsJson.map((json) => ChatRoomModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load chat rooms');
    }
  }

  Future<List<ChatMessageModel>> getChatHistory(
    String publicationId,
    String senderId,
    String recipientId,
  ) async {
    final options = await authService.getAuthOptions();
    final response = await dio.get(
      '/messages/$publicationId/$senderId/$recipientId',
      options: options,
    );

    if (response.statusCode == 200) {
      final List<dynamic> messagesJson = response.data;
      return messagesJson
          .map((json) => ChatMessageModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load chat history');
    }
  }

  void dispose() {
    _messageStreamController.close();
    _userStatusStreamController.close();
    _stompClient?.deactivate();
  }
}
