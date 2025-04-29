import 'package:list_in/features/chats/domain/repository/chat_repository.dart';

class GetLastReadMessageIdUseCase {
  final ChatRepository repository;

  GetLastReadMessageIdUseCase(this.repository);

  Future<String?> execute(
    String publicationId,
    String userId,
    String recipientId,
  ) async {
    return await repository.getLastReadMessageId(
      publicationId,
      userId,
      recipientId,
    );
  }
}
