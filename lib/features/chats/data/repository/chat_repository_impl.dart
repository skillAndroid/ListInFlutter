// ignore_for_file: avoid_print, use_rethrow_when_possible

import 'dart:async';

import 'package:list_in/features/auth/data/sources/auth_local_data_source.dart';
import 'package:list_in/features/chats/data/model/chat_room_model.dart';
import 'package:list_in/features/chats/data/source/chat_local_datasourse.dart';
import 'package:list_in/features/chats/data/source/chat_remote_datasource.dart';
import 'package:list_in/features/chats/domain/entity/chat_message.dart';
import 'package:list_in/features/chats/domain/entity/chat_room.dart';
import 'package:list_in/features/chats/domain/entity/user_status.dart';
import 'package:list_in/features/chats/domain/repository/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final ChatLocalDataSource localDataSource;
  final AuthLocalDataSource authLocalDataSource;
  final String currentUserId;
  bool _initializing = false;
  bool _isConnected = false;
  String? _initializedUserId;
  Completer<void>? _initialConnectionCompleter;

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.authLocalDataSource,
    required this.currentUserId,
  });

  @override
  Future<void> initializeWebSocket(String userId) async {
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
      throw e;
    } finally {
      _initializing = false;
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

  @override
  Future<List<ChatRoom>> getChatRooms(String userId) async {
    try {
      await initializeWebSocket(userId);
      print('Repository: Getting chat rooms for user $userId');

      // First try to get from remote
      try {
        final List<ChatRoomModel> remoteRooms =
            await remoteDataSource.getChatRooms(userId);

        // Get existing local rooms to compare last messages
        final List<ChatRoomModel> localRooms =
            await localDataSource.getChatRooms(userId);

        // Create a map of local rooms by chatRoomId for easy lookup
        final Map<String, ChatRoomModel> localRoomsMap = {
          for (var room in localRooms) room.chatRoomId: room
        };

        // Calculate unread counts for each room
        final List<ChatRoomModel> roomsWithUnreadCounts = [];

        for (var remoteRoom in remoteRooms) {
          int unreadCount = 0;

          // Compare with local room if exists
          if (localRoomsMap.containsKey(remoteRoom.chatRoomId)) {
            final localRoom = localRoomsMap[remoteRoom.chatRoomId]!;

            // If remote has a newer message than local, calculate unread count
            if (remoteRoom.lastMessage != null &&
                (localRoom.lastMessage == null ||
                    remoteRoom.lastMessage!.sentAt
                        .isAfter(localRoom.lastMessage!.sentAt))) {
              // Get last read message ID
              final lastReadMessageId =
                  await localDataSource.getLastReadMessageId(
                remoteRoom.publicationId,
                userId,
                remoteRoom.recipientId,
              );

              if (lastReadMessageId != null) {
                // Get chat history to count unread messages
                final messages = await getLocalChatHistory(
                  remoteRoom.publicationId,
                  userId,
                  remoteRoom.recipientId,
                );

                // Find index of last read message
                int lastReadIndex =
                    messages.indexWhere((msg) => msg.id == lastReadMessageId);

                // Count messages after last read
                if (lastReadIndex >= 0) {
                  unreadCount = messages.length - lastReadIndex - 1;
                } else {
                  // If lastReadMessageId not found, all messages are unread
                  unreadCount = messages.length;
                }
              } else {
                // If no last read message ID, count all messages as unread
                unreadCount = await localDataSource.getUnreadCount(
                  remoteRoom.publicationId,
                  userId,
                  remoteRoom.recipientId,
                );
              }
            }
          } else {
            // New room, count all messages as unread
            if (remoteRoom.lastMessage != null) {
              unreadCount = 1; // At least the last message is unread
            }
          }

          // Create a new room with the calculated unread count
          final roomWithUnreadCount = ChatRoomModel(
            chatRoomId: remoteRoom.chatRoomId,
            publicationId: remoteRoom.publicationId,
            publicationImagePath: remoteRoom.publicationImagePath,
            publicationTitle: remoteRoom.publicationTitle,
            publicationPrice: remoteRoom.publicationPrice,
            recipientId: remoteRoom.recipientId,
            recipientImagePath: remoteRoom.recipientImagePath,
            recipientNickname: remoteRoom.recipientNickname,
            lastMessage: remoteRoom.lastMessage?.toModel(),
            unreadCount: unreadCount,
          );

          roomsWithUnreadCounts.add(roomWithUnreadCount);
        }

        // Save to local storage
        await localDataSource.saveChatRooms(userId, roomsWithUnreadCounts);

        return roomsWithUnreadCounts;
      } catch (e) {
        print(
            'Failed to get chat rooms from remote, falling back to local: $e');
        // If remote fails, return local data
        return await localDataSource.getChatRooms(userId);
      }
    } catch (e) {
      print('Repository: Error getting chat rooms: $e');
      // If both fail, return empty list
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

      // Try to get from remote
      try {
        final remoteMessages = await remoteDataSource.getChatHistory(
          publicationId,
          senderId,
          recipientId,
        );

        // Compare with local messages to determine which are new
        final localMessages = await localDataSource.getChatMessages(
          publicationId,
          senderId,
          recipientId,
        );

        // If we have new messages (more messages than local)
        if (remoteMessages.length > localMessages.length) {
          final int newMessageCount =
              remoteMessages.length - localMessages.length;
          print('Found $newMessageCount new messages from remote');

          // Increment unread count if necessary
          // Only consider messages addressed to the current user as unread
          int unreadCount = 0;
          for (int i = remoteMessages.length - newMessageCount;
              i < remoteMessages.length;
              i++) {
            if (remoteMessages[i].recipientId == senderId) {
              unreadCount++;
            }
          }

          if (unreadCount > 0) {
            print('Updating unread count for $unreadCount new messages');
            // Update the unread count
            await localDataSource.resetUnreadCount(
              publicationId,
              senderId,
              recipientId,
            );

            // Then set it to the actual count
            for (int i = 0; i < unreadCount; i++) {
              await localDataSource.incrementUnreadCount(
                publicationId,
                senderId,
                recipientId,
              );
            }
          }
        }

        // Save to local storage
        await localDataSource.saveChatMessages(
          publicationId,
          senderId,
          recipientId,
          remoteMessages,
        );

        return remoteMessages;
      } catch (e) {
        print('Failed to get chat history from remote: $e');
        // Don't throw here - we want to return local data seamlessly
        return await localDataSource.getChatMessages(
          publicationId,
          senderId,
          recipientId,
        );
      }
    } catch (e) {
      print('Repository: Error getting chat history: $e');
      // Still try to return local data as a last resort
      try {
        return await localDataSource.getChatMessages(
          publicationId,
          senderId,
          recipientId,
        );
      } catch (localError) {
        print(
            'Repository: Error getting local chat history after remote failure: $localError');
        return [];
      }
    }
  }

  @override
  Future<void> connectUser(UserConnectionInfo connectionInfo) async {
    try {
      await initializeWebSocket(connectionInfo.email);
      print('Repository: Connecting user ${connectionInfo.email}');
      await remoteDataSource.connectUser(connectionInfo);
      // Save user status locally
      await localDataSource.saveUserStatus(
          connectionInfo.email, connectionInfo.status);
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
      // Save user status locally
      await localDataSource.saveUserStatus(
          connectionInfo.email, UserStatus.OFFLINE);
    } catch (e) {
      print('Repository: Error disconnecting user: $e');
    }
  }

  @override
  Future<void> sendMessage(ChatMessage message) async {
    try {
      await initializeWebSocket(message.senderId);
      print(
          'Repository: Sending message from ${message.senderId} to ${message.recipientId}: ${message.content}');

      await localDataSource.saveChatMessage(message.toModel());

      // If this message has an ID, set it as last read for sender immediately
      if (message.id != null && message.id!.isNotEmpty) {
        await localDataSource.saveLastReadMessageId(
          message.publicationId,
          message.senderId,
          message.recipientId,
          message.id!,
        );
      }

      await remoteDataSource.sendMessage(
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
  Stream<ChatMessage> get messageStream {
    // Process incoming messages to track unread status
    return remoteDataSource.messageStream.map((message) {
      // If the message is addressed to the current user, increment unread count
      if (message.recipientId == currentUserId) {
        // Don't await this operation as we don't want to block the stream
        localDataSource.incrementUnreadCount(
          message.publicationId,
          currentUserId,
          message.senderId,
        );
      }
      return message;
    });
  }

  @override
  Stream<UserConnectionInfo> get userStatusStream {
    return remoteDataSource.userStatusStream;
  }

  @override
  Future<bool> clearLocalChatData(String userId) async {
    try {
      return await localDataSource.clearUserChatData(userId);
    } catch (e) {
      print('Error clearing local chat data: $e');
      return false;
    }
  }

  @override
  Future<List<ChatMessage>> getLocalChatHistory(
      String publicationId, String senderId, String recipientId) async {
    try {
      print(
          'Getting local chat history for publication: $publicationId, sender: $senderId, recipient: $recipientId');
      final messages = await localDataSource.getChatMessages(
        publicationId,
        senderId,
        recipientId,
      );
      print('Retrieved ${messages.length} messages from local storage');
      return messages;
    } catch (e) {
      print('Error getting local chat history: $e');
      return [];
    }
  }

  @override
  Future<List<ChatRoom>> getLocalChatRooms(String userId) async {
    try {
      return await localDataSource.getChatRooms(userId);
    } catch (e) {
      print('Error getting local chat rooms: $e');
      return [];
    }
  }

  @override
  Future<bool> saveChatMessageLocally(ChatMessage message) async {
    try {
      return await localDataSource.saveChatMessage(message.toModel());
    } catch (e) {
      print('Error saving chat message locally: $e');
      return false;
    }
  }

  @override
  Future<bool> saveChatRoomsLocally(
      String userId, List<ChatRoom> chatRooms) async {
    try {
      // Convert ChatRoom to ChatRoomModel
      final List<ChatRoomModel> roomModels = chatRooms.map((room) {
        if (room is ChatRoomModel) {
          return room;
        } else {
          return ChatRoomModel(
            chatRoomId: room.chatRoomId,
            publicationId: room.publicationId,
            publicationImagePath: room.publicationImagePath,
            publicationTitle: room.publicationTitle,
            publicationPrice: room.publicationPrice,
            recipientId: room.recipientId,
            recipientImagePath: room.recipientImagePath,
            recipientNickname: room.recipientNickname,
            lastMessage: room.lastMessage?.toModel(),
            unreadCount: room.unreadCount,
          );
        }
      }).toList();

      return await localDataSource.saveChatRooms(userId, roomModels);
    } catch (e) {
      print('Error saving chat rooms locally: $e');
      return false;
    }
  }

  // Methods for unread messages

  @override
  Future<String?> getLastReadMessageId(
      String publicationId, String userId, String recipientId) async {
    try {
      return await localDataSource.getLastReadMessageId(
        publicationId,
        userId,
        recipientId,
      );
    } catch (e) {
      print('Error getting last read message ID: $e');
      return null;
    }
  }

  @override
  Future<bool> saveLastReadMessageId(String publicationId, String userId,
      String recipientId, String messageId) async {
    try {
      return await localDataSource.saveLastReadMessageId(
        publicationId,
        userId,
        recipientId,
        messageId,
      );
    } catch (e) {
      print('Error saving last read message ID: $e');
      return false;
    }
  }

  @override
  Future<int> getUnreadCount(
      String publicationId, String userId, String recipientId) async {
    try {
      return await localDataSource.getUnreadCount(
        publicationId,
        userId,
        recipientId,
      );
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  @override
  Future<bool> resetUnreadCount(
      String publicationId, String userId, String recipientId) async {
    try {
      return await localDataSource.resetUnreadCount(
        publicationId,
        userId,
        recipientId,
      );
    } catch (e) {
      print('Error resetting unread count: $e');
      return false;
    }
  }
}
