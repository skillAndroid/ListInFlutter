import 'package:list_in/features/chats/domain/entity/user_status.dart';
import 'package:list_in/features/chats/domain/repository/chat_repository.dart';

class DisconnectUserUseCase {
  final ChatRepository repository;

  DisconnectUserUseCase(this.repository);

  Future<void> execute(UserConnectionInfo connectionInfo) {
    return repository.disconnectUser(connectionInfo);
  }
}
