import 'package:list_in/features/chats/domain/entity/chat_room.dart';
import 'package:list_in/features/chats/domain/repository/chat_repository.dart';

class SaveChatRoomsLocallyUseCase {
  final ChatRepository repository;

  SaveChatRoomsLocallyUseCase(this.repository);

  Future<bool> execute(String userId, List<ChatRoom> chatRooms) async {
    return await repository.saveChatRoomsLocally(userId, chatRooms);
  }
}
