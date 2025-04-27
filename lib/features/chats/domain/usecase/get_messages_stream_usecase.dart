import 'package:list_in/features/chats/domain/entity/chat_message.dart';
import 'package:list_in/features/chats/domain/repository/chat_repository.dart';

class GetMessageStreamUseCase {
  final ChatRepository repository;

  GetMessageStreamUseCase(this.repository);

  Stream<ChatMessage> execute() {
    return repository.messageStream;
  }
}
