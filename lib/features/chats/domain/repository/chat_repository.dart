// lib/features/chats/domain/repository/chat_repository.dart

import 'package:list_in/features/chats/domain/entity/chat_message.dart';
import 'package:list_in/features/chats/domain/entity/chat_room.dart';
import 'package:list_in/features/chats/domain/entity/user_status.dart';

abstract class ChatRepository {
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

  // New methods
  Future<void> initializeWebSocket(String userId);

  Future<void> closeConnection();

  // Method to check if WebSocket is connected
  bool isConnected();

  // Local data methods
  Future<List<ChatRoom>> getLocalChatRooms(String userId);
  Future<List<ChatMessage>> getLocalChatHistory(
    String publicationId,
    String senderId,
    String recipientId,
  );
  Future<bool> saveChatMessageLocally(ChatMessage message);
  Future<bool> saveChatRoomsLocally(String userId, List<ChatRoom> chatRooms);
  Future<bool> clearLocalChatData(String userId);
  // Add new method to send message viewed status
  Future<void> sendMessageViewedStatus(
      String senderId, List<String> messageIds);

  // Add new stream for message status updates
  Stream<List<String>> get messageStatusStream;
}
