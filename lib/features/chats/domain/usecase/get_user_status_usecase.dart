import 'package:list_in/features/chats/domain/entity/user_status.dart';
import 'package:list_in/features/chats/domain/repository/chat_repository.dart';

class GetUserStatusStreamUseCase {
  final ChatRepository repository;

  GetUserStatusStreamUseCase(this.repository);

  Stream<UserConnectionInfo> execute() {
    return repository.userStatusStream;
  }
}
