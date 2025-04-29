import 'package:list_in/features/chats/domain/entity/chat_message.dart';
import 'package:list_in/features/chats/domain/repository/chat_repository.dart';

class GetLocalChatHistoryUseCase {
  final ChatRepository repository;

  GetLocalChatHistoryUseCase(this.repository);

  Future<List<ChatMessage>> execute({
    required String publicationId,
    required String senderId,
    required String recipientId,
  }) async {
    return await repository.getLocalChatHistory(
      publicationId,
      senderId,
      recipientId,
    );
  }
}
