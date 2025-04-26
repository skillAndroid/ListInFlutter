import 'package:list_in/features/chats/domain/entity/user_status.dart';
import 'package:list_in/features/chats/domain/repository/chat_repository.dart';

class ConnectUserUseCase {
  final ChatRepository repository;

  ConnectUserUseCase(this.repository);

  Future<void> execute(UserConnectionInfo connectionInfo) {
    return repository.connectUser(connectionInfo);
  }
}
