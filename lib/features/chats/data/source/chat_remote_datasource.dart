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
  bool _isConnected = false;

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
    if (_isConnected) {
      print('WebSocket already connected');
      return;
    }

    final authToken = await authLocalDataSource.getLastAuthToken();
    if (authToken == null) {
      throw UnauthorizedException('No auth token found');
    }

    final wsUrl = 'ws://listin.uz:80/ws?token=${authToken.accessToken}';

    try {
      _stompClient = StompClient(
        config: StompConfig(
          url: wsUrl,
          beforeConnect: () async {
            print('💋💋Attempting to connect to WebSocket...');
            print('💋💋Using token: ${authToken.accessToken}...');
          },
          onWebSocketError: (dynamic error) {
            print('💋💋WebSocket Error: $error');
            _isConnected = false;
          },
          onStompError: (StompFrame frame) {
            print('💋💋STOMP Error: ${frame.body}');
          },
          onConnect: (StompFrame frame) {
            _isConnected = true;
            print('💋💋Connected to WebSocket');

            // // Subscribe to global messages
            // _stompClient!.subscribe(
            //   destination: '/topic/messages',
            //   callback: (StompFrame frame) {
            //     print('💋💋Received message from /topic/messages');
            //     if (frame.body != null) {
            //       try {
            //         final message =
            //             ChatMessageModel.fromJson(jsonDecode(frame.body!));
            //         print('Parsed message: ${message.content}');
            //         _messageStreamController.add(message);
            //       } catch (e) {
            //         print('Error parsing message: $e');
            //       }
            //     }
            //   },
            // );

            // Subscribe to private message channel
            _stompClient!.subscribe(
              destination: '/user/$userId/queue/messages',
              callback: (StompFrame frame) {
                print('💋💋Received message from /user/$userId/queue/messages');
                if (frame.body != null) {
                  try {
                    final message =
                        ChatMessageModel.fromJson(jsonDecode(frame.body!));
                    print('💋💋Parsed private message: ${message.content}');
                    _messageStreamController.add(message);
                  } catch (e) {
                    print('💋💋Error parsing private message: $e');
                  }
                }
              },
            );

            // Subscribe to user status updates
            _stompClient!.subscribe(
              destination: '/topic/user-status',
              callback: (StompFrame frame) {
                if (frame.body != null) {
                  try {
                    final data = jsonDecode(frame.body!);
                    final userStatus = UserConnectionInfo(
                      nickName: data['nickName'],
                      email: data['email'],
                      status: data['status'] == 'ONLINE'
                          ? UserStatus.ONLINE
                          : UserStatus.OFFLINE,
                    );
                    _userStatusStreamController.add(userStatus);
                  } catch (e) {
                    print('Error parsing user status: $e');
                  }
                }
              },
            );
          },
          // Add reconnect delay to handle disconnections
          reconnectDelay: Duration(seconds: 5),
        ),
      );

      _stompClient!.activate();
    } catch (e) {
      print('Error initializing WebSocket: $e');
      throw Exception('Failed to initialize WebSocket: $e');
    }
  }

  Future<void> disconnectWebSocket() async {
    if (_stompClient != null) {
      _stompClient!.deactivate();
      _isConnected = false;
    }
  }

  Future<void> connectUser(UserConnectionInfo connectionInfo) async {
    if (!_isConnected) {
      print('WebSocket not connected. Cannot send user connection info.');
      return;
    }

    try {
      _stompClient?.send(
        destination: '/app/user.connectUser',
        body: jsonEncode(connectionInfo.toJson()),
      );
    } catch (e) {
      print('Error connecting user: $e');
    }
  }

  Future<void> disconnectUser(UserConnectionInfo connectionInfo) async {
    if (!_isConnected) {
      print('WebSocket not connected. Cannot send user disconnection info.');
      return;
    }

    try {
      _stompClient?.send(
        destination: '/app/user.disconnectUser',
        body: jsonEncode(connectionInfo.toJson()),
      );
    } catch (e) {
      print('Error disconnecting user: $e');
    }
  }

  Future<void> sendMessage({
    String? id,
    required String senderId,
    required String recipientId,
    required String publicationId,
    required String content,
  }) async {
    if (!_isConnected) {
      print('WebSocket not connected. Cannot send message.');
      throw Exception('WebSocket not connected');
    }

    final message = {
      'senderId': senderId,
      'recipientId': recipientId,
      'publicationId': publicationId,
      'content': content,
    };

    try {
      _stompClient?.send(
        destination: '/app/chat',
        body: jsonEncode(message),
      );
    } catch (e) {
      print('Error sending message: $e');
      throw Exception('Failed to send message: $e');
    }
  }

  Future<List<ChatRoomModel>> getChatRooms(String userId) async {
    try {
      final options = await authService.getAuthOptions();
      final response = await dio.get(
        '$baseUrl/chat-rooms/$userId',
        options: options,
      );

      if (response.statusCode == 200) {
        final List<dynamic> roomsJson = response.data;
        return roomsJson.map((json) => ChatRoomModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load chat rooms: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching chat rooms: $e');
      throw Exception('Failed to load chat rooms: $e');
    }
  }

  Future<List<ChatMessageModel>> getChatHistory(
    String publicationId,
    String senderId,
    String recipientId,
  ) async {
    try {
      final options = await authService.getAuthOptions();
      final response = await dio.get(
        '$baseUrl/messages/$publicationId/$senderId/$recipientId',
        options: options,
      );

      if (response.statusCode == 200) {
        final List<dynamic> messagesJson = response.data;
        return messagesJson
            .map((json) => ChatMessageModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load chat history: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching chat history: $e');
      throw Exception('Failed to load chat history: $e');
    }
  }

  void dispose() {
    _messageStreamController.close();
    _userStatusStreamController.close();
    disconnectWebSocket();
  }
}
