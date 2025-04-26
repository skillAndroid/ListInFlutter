import 'package:list_in/features/chats/domain/entity/chat_room.dart';
import 'package:list_in/features/chats/domain/repository/chat_repository.dart';

class GetChatRoomsUseCase {
  final ChatRepository repository;

  GetChatRoomsUseCase(this.repository);

  Future<List<ChatRoom>> execute(String userId) {
    return repository.getChatRooms(userId);
  }
}
