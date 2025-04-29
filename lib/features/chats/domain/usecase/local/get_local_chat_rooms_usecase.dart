import 'package:list_in/features/chats/domain/entity/chat_room.dart';
import 'package:list_in/features/chats/domain/repository/chat_repository.dart';

class GetLocalChatRoomsUseCase {
  final ChatRepository repository;

  GetLocalChatRoomsUseCase(this.repository);

  Future<List<ChatRoom>> execute(String userId) async {
    return await repository.getLocalChatRooms(userId);
  }
}
