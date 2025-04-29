// save_last_read_message_id_usecase.dart
import 'package:list_in/features/chats/domain/repository/chat_repository.dart';

class SaveLastReadMessageIdUseCase {
  final ChatRepository repository;

  SaveLastReadMessageIdUseCase(this.repository);

  Future<bool> execute(
    String publicationId,
    String userId,
    String recipientId,
    String messageId,
  ) async {
    return await repository.saveLastReadMessageId(
      publicationId,
      userId,
      recipientId,
      messageId,
    );
  }
}
