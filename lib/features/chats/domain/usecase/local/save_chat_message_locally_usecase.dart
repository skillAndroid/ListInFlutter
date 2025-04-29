import 'package:list_in/features/chats/domain/entity/chat_message.dart';
import 'package:list_in/features/chats/domain/repository/chat_repository.dart';

class SaveChatMessageLocallyUseCase {
  final ChatRepository repository;

  SaveChatMessageLocallyUseCase(this.repository);

  Future<bool> execute(ChatMessage message) async {
    return await repository.saveChatMessageLocally(message);
  }
}
