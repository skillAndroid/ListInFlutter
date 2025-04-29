import 'package:list_in/features/chats/domain/repository/chat_repository.dart';

class ClearLocalChatDataUseCase {
  final ChatRepository repository;

  ClearLocalChatDataUseCase(this.repository);

  Future<bool> execute(String userId) async {
    return await repository.clearLocalChatData(userId);
  }
}
