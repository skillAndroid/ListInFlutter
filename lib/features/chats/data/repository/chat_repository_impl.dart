// ignore_for_file: avoid_print, use_rethrow_when_possible

import 'dart:async';

import 'package:list_in/features/auth/data/sources/auth_local_data_source.dart';
import 'package:list_in/features/chats/data/source/chat_remote_datasource.dart';
import 'package:list_in/features/chats/domain/entity/chat_message.dart';
import 'package:list_in/features/chats/domain/entity/chat_room.dart';
import 'package:list_in/features/chats/domain/entity/user_status.dart';
import 'package:list_in/features/chats/domain/repository/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final AuthLocalDataSource authLocalDataSource;
  final String currentUserId;
  bool _initializing = false;
  bool _isConnected = false;
  String? _initializedUserId;
  Completer<void>? _initialConnectionCompleter;
  // Add connection status tracking
  final _connectionStatusController = StreamController<bool>.broadcast();
  StreamSubscription<bool>? _remoteConnectionSubscription;

  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;
  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.authLocalDataSource,
    required this.currentUserId,
  }) {
    // Listen to remote data source connection status
    _remoteConnectionSubscription =
        remoteDataSource.connectionStatusStream.listen(
      (isConnected) {
        _isConnected = isConnected;
        if (!_connectionStatusController.isClosed) {
          _connectionStatusController.add(isConnected);
        }
      },
    );
  }

  @override
  Future<void> initializeWebSocket(String userId) async {
    // Don't initialize if we're already initializing
    if (_initializing) {
      await _initialConnectionCompleter?.future;
      return;
    }

    if (_initializedUserId == userId && !_initializing && _isConnected) {
      print('Repository: WebSocket already initialized for user $userId');
      return;
    }

    _initializedUserId = userId;
    _initializing = true;
    _initialConnectionCompleter = Completer<void>();

    try {
      print('Repository: Initializing WebSocket for user $userId...');
      await remoteDataSource.initializeWebSocket(userId);
      _isConnected = true;

      if (!_initialConnectionCompleter!.isCompleted) {
        _initialConnectionCompleter!.complete();
      }
      print('Repository: WebSocket initialization completed');
    } catch (e) {
      print('Repository: Error initializing WebSocket: $e');
      _isConnected = false;
      if (!_initialConnectionCompleter!.isCompleted) {
        _initialConnectionCompleter!.completeError(e);
      }
      rethrow;
    } finally {
      _initializing = false;
    }
  }

// Add method to force reconnection
  Future<void> forceReconnect() async {
    try {
      await closeConnection();
      if (_initializedUserId != null) {
        await initializeWebSocket(_initializedUserId!);
      }
    } catch (e) {
      print('Repository: Error during force reconnect: $e');
      rethrow;
    }
  }

  // Add connection health check
  Future<bool> checkConnectionHealth() async {
    if (!_isConnected) return false;

    try {
      return await remoteDataSource.checkConnectionHealth();
    } catch (e) {
      print('Repository: Connection health check failed: $e');
      return false;
    }
  }

  @override
  Future<void> closeConnection() async {
    try {
      await remoteDataSource.disconnectWebSocket();
      _isConnected = false;
      _initializedUserId = null;
      print('Repository: WebSocket connection closed');
    } catch (e) {
      print('Repository: Error closing WebSocket connection: $e');
    }
  }

  @override
  bool isConnected() {
    return _isConnected;
  }

  // Enhanced method with connection check
  @override
  Future<List<ChatRoom>> getChatRooms(String userId) async {
    try {
      // Check if we need to reconnect
      if (!_isConnected || !remoteDataSource.isWebSocketReady()) {
        print('Repository: Connection not ready, initializing...');
        await initializeWebSocket(userId);
      }

      print('Repository: Getting chat rooms for user $userId');
      final remoteRooms = await remoteDataSource.getChatRooms(userId);
      return remoteRooms;
    } catch (e) {
      print('Repository: Error getting chat rooms: $e');
      // If connection fails, try to reconnect once
      if (e.toString().contains('WebSocket')) {
        try {
          await forceReconnect();
          return await remoteDataSource.getChatRooms(userId);
        } catch (reconnectError) {
          print('Repository: Reconnection failed: $reconnectError');
        }
      }
      return [];
    }
  }

  @override
  Future<List<ChatMessage>> getChatHistory(
    String publicationId,
    String senderId,
    String recipientId,
  ) async {
    try {
      await initializeWebSocket(senderId);
      print(
          'Repository: Getting chat history for pub $publicationId, sender $senderId, recipient $recipientId');

      final remoteMessages = await remoteDataSource.getChatHistory(
        publicationId,
        senderId,
        recipientId,
      );

      return remoteMessages;
    } catch (e) {
      print('Repository: Error getting chat history: $e');
      // If both fail, return empty list
      return [];
    }
  }

  @override
  Future<void> connectUser(UserConnectionInfo connectionInfo) async {
    try {
      await initializeWebSocket(connectionInfo.email);
      print('Repository: Connecting user ${connectionInfo.email}');
      await remoteDataSource.connectUser(connectionInfo);
    } catch (e) {
      print('Repository: Error connecting user: $e');
      throw e;
    }
  }

  @override
  Future<void> disconnectUser(UserConnectionInfo connectionInfo) async {
    try {
      print('Repository: Disconnecting user ${connectionInfo.email}');
      await remoteDataSource.disconnectUser(connectionInfo);
    } catch (e) {
      print('Repository: Error disconnecting user: $e');
    }
  }

  // Similar enhancements for other methods...
  @override
  Future<void> sendMessage(ChatMessage message) async {
    try {
      await initializeWebSocket(message.senderId);

      // Verify connection before sending
      if (!_isConnected || !remoteDataSource.isWebSocketReady()) {
        throw Exception('WebSocket not ready to send message');
      }

      print(
          'Repository: Sending message from ${message.senderId} to ${message.recipientId}: ${message.content}');
      await remoteDataSource.sendMessage(
        messageId: message.id,
        senderId: message.senderId,
        recipientId: message.recipientId,
        publicationId: message.publicationId,
        content: message.content,
      );
    } catch (e) {
      print('Repository: Error sending message: $e');
      rethrow;
    }
  }

  @override
  Stream<ChatMessage> get messageDeliveredStream {
    return remoteDataSource.messageDeliveredStream;
  }

  @override
  Stream<ChatMessage> get messageStream {
    // Combine both remote and local message streams if needed
    return remoteDataSource.messageStream;
  }

  @override
  Stream<List<String>> get messageStatusStream {
    return remoteDataSource.messageStatusStream;
  }

  @override
  Future<void> sendMessageViewedStatus(
      String senderId, List<String> messageIds) async {
    try {
      await initializeWebSocket(senderId);
      print(
          'Repository: Sending message viewed status for ${messageIds.length} messages');

      await remoteDataSource.sendMessageViewedStatus(
        senderId: senderId,
        messageIds: messageIds,
      );
    } catch (e) {
      print('Repository: Error sending message viewed status: $e');
      throw e;
    }
  }

  @override
  Stream<UserConnectionInfo> get userStatusStream {
    // Combine both remote and local status streams if needed
    return remoteDataSource.userStatusStream;
  }

  @override
  Future<bool> clearLocalChatData(String userId) {
    throw UnimplementedError();
  }

  @override
  Future<List<ChatMessage>> getLocalChatHistory(
      String publicationId, String senderId, String recipientId) {
    throw UnimplementedError();
  }

  @override
  Future<List<ChatRoom>> getLocalChatRooms(String userId) {
    throw UnimplementedError();
  }

  @override
  Future<bool> saveChatMessageLocally(ChatMessage message) {
    throw UnimplementedError();
  }

  @override
  Future<bool> saveChatRoomsLocally(String userId, List<ChatRoom> chatRooms) {
    throw UnimplementedError();
  }
}
