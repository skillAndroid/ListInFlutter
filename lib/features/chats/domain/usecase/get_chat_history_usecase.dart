import 'package:list_in/features/chats/domain/entity/chat_message.dart';
import 'package:list_in/features/chats/domain/repository/chat_repository.dart';

class GetChatHistoryUseCase {
  final ChatRepository repository;

  GetChatHistoryUseCase(this.repository);

  Future<List<ChatMessage>> execute(
    String publicationId,
    String senderId,
    String recipientId,
  ) {
    return repository.getChatHistory(publicationId, senderId, recipientId);
  }
}
