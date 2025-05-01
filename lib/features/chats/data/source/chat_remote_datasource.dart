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

  final _messageStatusStreamController =
      StreamController<List<String>>.broadcast();
  final _userStatusStreamController =
      StreamController<UserConnectionInfo>.broadcast();

  final _messageDeliveredStreamController =
      StreamController<ChatMessageModel>.broadcast();

  Stream<ChatMessageModel> get messageStream => _messageStreamController.stream;
  Stream<List<String>> get messageStatusStream =>
      _messageStatusStreamController.stream;
  Stream<UserConnectionInfo> get userStatusStream =>
      _userStatusStreamController.stream;

  Stream<ChatMessageModel> get messageDeliveredStream =>
      _messageDeliveredStreamController.stream;

  // Retry configuration
  static const int maxRetryAttempts = 3;
  static const Duration initialRetryDelay = Duration(seconds: 2);

  ChatRemoteDataSource({
    required this.dio,
    required this.authLocalDataSource,
    required this.authService,
  });

  final Set<String> _activeSubscriptionDestinations = {};

  Future<void> initializeWebSocket(String userId) async {
    if (_isConnected && _stompClient != null) {
      print('WebSocket already connected');
      return;
    }

    final authToken = await authLocalDataSource.getLastAuthToken();
    if (authToken == null) {
      throw UnauthorizedException('No auth token found');
    }

    final wsUrl = 'ws://listin.uz:80/ws?token=${authToken.accessToken}';

    int retryCount = 0;
    Duration delay = initialRetryDelay;

    while (retryCount < maxRetryAttempts) {
      try {
        _stompClient = StompClient(
          config: StompConfig(
            url: wsUrl,
            beforeConnect: () async {
              print(
                  'Attempting to connect to WebSocket (Attempt ${retryCount + 1})...');
              print('Using token: ${authToken.accessToken.substring(0, 5)}...');
            },
            onWebSocketError: (dynamic error) {
              print('WebSocket Error: $error');
              _isConnected = false;
            },
            onStompError: (StompFrame frame) {
              print('STOMP Error: ${frame.body}');
            },
            onConnect: (StompFrame frame) async {
              _isConnected = true;
              print('Connected to WebSocket');

              _subscribeToDestination('/user/$userId/queue/messages', (frame) {
                if (frame.body != null) {
                  try {
                    final message =
                        ChatMessageModel.fromJson(jsonDecode(frame.body!));
                    print('Parsed private message: ${message.content}');
                    _messageStreamController.add(message);
                  } catch (e) {
                    print('Error parsing private message: $e');
                  }
                }
              });

              // Add new subscription for delivered messages
              _subscribeToDestination('/user/$userId/queue/messages/delivered',
                  (frame) {
                if (frame.body != null) {
                  try {
                    print('Received delivered message: ${frame.body}');
                    final message =
                        ChatMessageModel.fromJson(jsonDecode(frame.body!));
                    print(
                        'Message marked as delivered: ${message.id} - ${message.content}');
                    _messageDeliveredStreamController.add(message);
                  } catch (e) {
                    print('Error parsing delivered message: $e');
                    print('Raw delivered data: ${frame.body}');
                  }
                }
              });

              _subscribeToDestination('/user/$userId/queue/messages/status',
                  (frame) {
                if (frame.body != null) {
                  try {
                    // Parse the JSON into a Map
                    final Map<String, dynamic> data = jsonDecode(frame.body!);

                    // Extract the messageIds array from the response
                    if (data.containsKey('messageIds') &&
                        data['messageIds'] is List) {
                      final List<dynamic> messageIdsList = data['messageIds'];
                      final List<String> viewedMessageIds =
                          messageIdsList.map((id) => id.toString()).toList();

                      print(
                          'Received viewed status for messages: $viewedMessageIds');

                      // Add the message IDs to the stream
                      _messageStatusStreamController.add(viewedMessageIds);
                    } else {
                      print(
                          'Message status update missing messageIds field: $data');
                    }
                  } catch (e) {
                    print('Error parsing message status update: $e');
                    print('Original data: ${frame.body}');
                  }
                }
              });
              _subscribeToDestination('/topic/user-status', (StompFrame frame) {
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
              });
            },
            reconnectDelay: Duration(seconds: 5),
          ),
        );

        _stompClient!.activate();
        break;
      } catch (e) {
        print('Error initializing WebSocket (Attempt ${retryCount + 1}): $e');

        retryCount++;
        if (retryCount >= maxRetryAttempts) {
          print('Max retry attempts reached. Failed to connect.');
          throw Exception(
              'Failed to initialize WebSocket after $maxRetryAttempts attempts: $e');
        }
        await Future.delayed(delay);
        delay *= 2;
      }
    }
  }

  void _subscribeToDestination(
      String destination, Function(StompFrame) callback) {
    if (_activeSubscriptionDestinations.contains(destination)) {
      print('Already subscribed to $destination, skipping');
      return;
    }

    if (_stompClient == null || !_isConnected) {
      print('Cannot subscribe to $destination: client not connected');
      return;
    }

    _stompClient!.subscribe(
      destination: destination,
      callback: callback,
    );

    _activeSubscriptionDestinations.add(destination);
    print('Subscribed to $destination');
  }

  Future<void> disconnectWebSocket() async {
    if (_stompClient != null) {
      _activeSubscriptionDestinations.clear();
      _stompClient!.deactivate();
      _isConnected = false;
      print('WebSocket disconnected');
    }
  }

  Future<void> connectUser(UserConnectionInfo connectionInfo) async {
    if (!_isConnected || _stompClient == null) {
      print('WebSocket not connected. Cannot send user connection info.');
      throw Exception('WebSocket not connected');
    }

    try {
      _stompClient?.send(
        destination: '/app/user.connectUser',
        body: jsonEncode(connectionInfo.toJson()),
      );
      print('User connection info sent for ${connectionInfo.email}');
    } catch (e) {
      print('Error connecting user: $e');
      throw Exception('Failed to connect user: $e');
    }
  }

  Future<void> disconnectUser(UserConnectionInfo connectionInfo) async {
    if (!_isConnected || _stompClient == null) {
      print('WebSocket not connected. Cannot send user disconnection info.');
      return;
    }

    try {
      _stompClient?.send(
        destination: '/app/user.disconnectUser',
        body: jsonEncode(connectionInfo.toJson()),
      );
      print('User disconnection info sent for ${connectionInfo.email}');
    } catch (e) {
      print('Error disconnecting user: $e');
    }
  }

  Future<void> sendMessage({
    required String messageId,
    required String senderId,
    required String recipientId,
    required String publicationId,
    required String content,
  }) async {
    if (!_isConnected || _stompClient == null) {
      print('WebSocket not connected. Cannot send message.');
      throw Exception('WebSocket not connected');
    }

    final message = {
      'id': messageId,
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
      print('Message sent to recipient $recipientId: $content');
    } catch (e) {
      print('Error sending message: $e');
      throw Exception('Failed to send message: $e');
    }
  }

  Future<void> sendMessageViewedStatus({
    required String senderId,
    required List<String> messageIds,
  }) async {
    if (!_isConnected || _stompClient == null) {
      print('WebSocket not connected. Cannot send message viewed status.');
      throw Exception('WebSocket not connected');
    }

    final viewData = {
      'senderId': senderId,
      'messageIds': messageIds,
    };

    try {
      _stompClient?.send(
        destination: '/app/chat/view',
        body: jsonEncode(viewData),
      );
      print('Message viewed status sent for ${messageIds.length} messages');
    } catch (e) {
      print('Error sending message viewed status: $e');
      throw Exception('Failed to send message viewed status: $e');
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
        final rooms =
            roomsJson.map((json) => ChatRoomModel.fromJson(json)).toList();
        print('Retrieved ${rooms.length} chat rooms for user $userId');
        return rooms;
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
      print('Loading chat history:');
      print('publicationId: $publicationId');
      print('senderId: $senderId');
      print('recipientId: $recipientId');

      final response = await dio.get(
        '$baseUrl/messages/$publicationId/$senderId/$recipientId',
        options: options,
      );

      if (response.statusCode == 200) {
        final List<dynamic> messagesJson = response.data;
        final messages = messagesJson
            .map((json) => ChatMessageModel.fromJson(json))
            .toList();
        print('Retrieved ${messages.length} messages for conversation');
        return messages;
      } else {
        throw Exception('Failed to load chat history: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching chat history: $e');
      throw Exception('Failed to load chat history: $e');
    }
  }

  bool isConnected() {
    return _isConnected && _stompClient != null;
  }

  void dispose() {
    _messageStreamController.close();
    _userStatusStreamController.close();
    _messageStatusStreamController.close();
    _messageDeliveredStreamController.close();
    disconnectWebSocket();
  }
}
