// lib/features/chats/domain/repository/chat_repository.dart

import 'package:list_in/features/chats/domain/entity/chat_message.dart';
import 'package:list_in/features/chats/domain/entity/chat_room.dart';
import 'package:list_in/features/chats/domain/entity/user_status.dart';

abstract class ChatRepository {
  // Core chat functionality
  Future<List<ChatRoom>> getChatRooms(String userId);
  Future<List<ChatMessage>> getChatHistory(
    String publicationId,
    String senderId,
    String recipientId,
  );
  Future<void> connectUser(UserConnectionInfo connectionInfo);
  Future<void> disconnectUser(UserConnectionInfo connectionInfo);
  Future<void> sendMessage(ChatMessage message);
  Stream<ChatMessage> get messageStream;
  Stream<UserConnectionInfo> get userStatusStream;

  // WebSocket management
  Future<void> initializeWebSocket(String userId);
  Future<void> closeConnection();
  bool isConnected();

  // Local data management
  Future<List<ChatRoom>> getLocalChatRooms(String userId);
  Future<List<ChatMessage>> getLocalChatHistory(
    String publicationId,
    String senderId,
    String recipientId,
  );
  Future<bool> saveChatMessageLocally(ChatMessage message);
  Future<bool> saveChatRoomsLocally(String userId, List<ChatRoom> chatRooms);
  Future<bool> clearLocalChatData(String userId);

  // Unread messages management
  Future<String?> getLastReadMessageId(
      String publicationId, String userId, String recipientId);

  Future<bool> saveLastReadMessageId(String publicationId, String userId,
      String recipientId, String messageId);

  Future<int> getUnreadCount(
      String publicationId, String userId, String recipientId);

  Future<bool> resetUnreadCount(
      String publicationId, String userId, String recipientId);
}
