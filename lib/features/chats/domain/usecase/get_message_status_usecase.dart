import 'package:list_in/features/chats/domain/repository/chat_repository.dart';

class GetMessageStatusStreamUseCase {
  final ChatRepository repository;

  GetMessageStatusStreamUseCase(this.repository);

  Stream<List<String>> execute() {
    return repository.messageStatusStream;
  }
}
