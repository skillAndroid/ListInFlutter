import 'package:list_in/features/chats/domain/repository/chat_repository.dart';

class SendMessageViewedStatusUseCase {
  final ChatRepository repository;

  SendMessageViewedStatusUseCase(this.repository);

  Future<void> execute(String senderId, List<String> messageIds) {
    return repository.sendMessageViewedStatus(senderId, messageIds);
  }
}
