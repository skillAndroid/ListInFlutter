import 'package:list_in/features/chats/domain/entity/chat_message.dart';
import 'package:list_in/features/chats/domain/repository/chat_repository.dart';

class GetMessageDeliveredStreamUseCase {
  final ChatRepository repository;

  GetMessageDeliveredStreamUseCase(this.repository);

  Stream<ChatMessage> execute() {
    return repository.messageDeliveredStream;
  }
}
