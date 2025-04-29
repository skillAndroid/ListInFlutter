// get_unread_count_usecase.dart
import 'package:list_in/features/chats/domain/repository/chat_repository.dart';

class GetUnreadCountUseCase {
  final ChatRepository repository;

  GetUnreadCountUseCase(this.repository);

  Future<int> execute(
    String publicationId,
    String userId,
    String recipientId,
  ) async {
    return await repository.getUnreadCount(
      publicationId,
      userId,
      recipientId,
    );
  }
}
