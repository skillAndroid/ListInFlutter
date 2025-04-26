import 'package:list_in/features/chats/data/source/chat_remote_datasource.dart';
import 'package:list_in/features/chats/domain/entity/chat_message.dart';
import 'package:list_in/features/chats/domain/entity/chat_room.dart';
import 'package:list_in/features/chats/domain/entity/user_status.dart';
import 'package:list_in/features/chats/domain/repository/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final String currentUserId;

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.currentUserId,
  }) {
    // Initialize WebSocket connection when repository is created
    remoteDataSource.initializeWebSocket(currentUserId);
  }

  @override
  Future<List<ChatRoom>> getChatRooms(String userId) async {
    return await remoteDataSource.getChatRooms(userId);
  }

  @override
  Future<List<ChatMessage>> getChatHistory(
    String publicationId,
    String senderId,
    String recipientId,
  ) async {
    return await remoteDataSource.getChatHistory(
      publicationId,
      senderId,
      recipientId,
    );
  }

  @override
  Future<void> connectUser(UserConnectionInfo connectionInfo) async {
    await remoteDataSource.connectUser(connectionInfo);
  }

  @override
  Future<void> disconnectUser(UserConnectionInfo connectionInfo) async {
    await remoteDataSource.disconnectUser(connectionInfo);
  }

  @override
  Future<void> sendMessage(ChatMessage message) async {
    await remoteDataSource.sendMessage(
      id: message.id,
      senderId: message.senderId,
      recipientId: message.recipientId,
      publicationId: message.publicationId,
      content: message.content,
    );
  }

  @override
  Stream<ChatMessage> get messageStream => remoteDataSource.messageStream;

  @override
  Stream<UserConnectionInfo> get userStatusStream =>
      remoteDataSource.userStatusStream;
}
