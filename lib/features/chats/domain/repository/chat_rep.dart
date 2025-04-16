// Repository interface
import 'package:list_in/features/chats/data/model/chat_message.dart';
import 'package:list_in/features/chats/data/model/chat_room.dart';

abstract class ChatRepository {
  Future<void> connect({required String token});
  void disconnect();
  Stream<ChatMessage> get onMessage;
  Stream<ChatRoom> get onRoomUpdate;
  Future<List<ChatRoom>> getRooms();
  Future<List<ChatMessage>> getMessages(String roomId,
      {int? limit, String? lastMessageId});
  Future<void> sendMessage(String roomId, String content);
  Future<ChatRoom> createRoom(String name, List<String> participants);
  Future<void> joinRoom(String roomId);
  Future<void> leaveRoom(String roomId);
}
