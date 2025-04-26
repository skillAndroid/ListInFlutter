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
}
