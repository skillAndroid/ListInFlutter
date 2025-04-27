// ignore_for_file: avoid_print, use_rethrow_when_possible

import 'dart:async';

import 'package:list_in/features/chats/data/source/chat_remote_datasource.dart';
import 'package:list_in/features/chats/domain/entity/chat_message.dart';
import 'package:list_in/features/chats/domain/entity/chat_room.dart';
import 'package:list_in/features/chats/domain/entity/user_status.dart';
import 'package:list_in/features/chats/domain/repository/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final String currentUserId;

  // Connection tracking
  bool _initializing = false;
  Completer<void>? _initialConnectionCompleter;

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.currentUserId,
  });

  // Improved initialization with better state tracking
  Future<void> initializeWebSocket(String userId) async {
    // If already initializing, wait for it to complete
    if (_initializing &&
        _initialConnectionCompleter != null &&
        !_initialConnectionCompleter!.isCompleted) {
      print(
          'Repository: WebSocket initialization already in progress, waiting...');
      return _initialConnectionCompleter!.future;
    }

    _initializing = true;
    _initialConnectionCompleter = Completer<void>();

    try {
      print('Repository: Initializing WebSocket for user $userId...');
      await remoteDataSource.initializeWebSocket(userId);

      if (!_initialConnectionCompleter!.isCompleted) {
        _initialConnectionCompleter!.complete();
      }
      print('Repository: WebSocket initialization completed');
    } catch (e) {
      print('Repository: Error initializing WebSocket: $e');
      if (!_initialConnectionCompleter!.isCompleted) {
        _initialConnectionCompleter!.completeError(e);
      }
      throw e;
    } finally {
      _initializing = false;
    }
  }

  @override
  Future<List<ChatRoom>> getChatRooms(String userId) async {
    try {
      // Ensure connection before getting chat rooms
      await initializeWebSocket(userId);
      print('Repository: Getting chat rooms for user $userId');
      return await remoteDataSource.getChatRooms(userId);
    } catch (e) {
      print('Repository: Error getting chat rooms: $e');
      throw e;
    }
  }

  @override
  Future<List<ChatMessage>> getChatHistory(
    String publicationId,
    String senderId,
    String recipientId,
  ) async {
    try {
      // Ensure connection before getting chat history
      await initializeWebSocket(senderId);
      print(
          'Repository: Getting chat history for pub $publicationId, sender $senderId, recipient $recipientId');
      return await remoteDataSource.getChatHistory(
        publicationId,
        senderId,
        recipientId,
      );
    } catch (e) {
      print('Repository: Error getting chat history: $e');
      throw e;
    }
  }

  @override
  Future<void> connectUser(UserConnectionInfo connectionInfo) async {
    try {
      // Ensure connection before connecting user
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
      // Don't throw on disconnect error
    }
  }

  @override
  Future<void> sendMessage(ChatMessage message) async {
    try {
      // Ensure connection before sending message
      await initializeWebSocket(message.senderId);
      print(
          'Repository: Sending message from ${message.senderId} to ${message.recipientId}: ${message.content}');
      await remoteDataSource.sendMessage(
        id: message.id,
        senderId: message.senderId,
        recipientId: message.recipientId,
        publicationId: message.publicationId,
        content: message.content,
      );
    } catch (e) {
      print('Repository: Error sending message: $e');
      throw e;
    }
  }

  @override
  Stream<ChatMessage> get messageStream => remoteDataSource.messageStream;

  @override
  Stream<UserConnectionInfo> get userStatusStream =>
      remoteDataSource.userStatusStream;
}
