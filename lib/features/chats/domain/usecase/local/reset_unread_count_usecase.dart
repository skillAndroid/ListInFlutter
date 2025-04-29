import 'package:list_in/features/chats/domain/repository/chat_repository.dart';

class ResetUnreadCountUseCase {
  final ChatRepository repository;

  ResetUnreadCountUseCase(this.repository);

  Future<bool> execute(
    String publicationId,
    String userId,
    String recipientId,
  ) async {
    return await repository.resetUnreadCount(
      publicationId,
      userId,
      recipientId,
    );
  }
}
