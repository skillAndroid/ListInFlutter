import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/features/chats/domain/entity/user_status.dart';
import 'package:list_in/features/chats/domain/usecase/connect_user_usecase.dart';
import 'package:list_in/features/chats/domain/usecase/disconnect_user_usecase.dart';
import 'package:list_in/features/chats/domain/usecase/get_chat_history_usecase.dart';
import 'package:list_in/features/chats/domain/usecase/get_chat_rooms_usecase.dart';
import 'package:list_in/features/chats/domain/usecase/send_message_usecase.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetChatRoomsUseCase getChatRoomsUseCase;
  final GetChatHistoryUseCase getChatHistoryUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final ConnectUserUseCase connectUserUseCase;
  final DisconnectUserUseCase disconnectUserUseCase;

  late StreamSubscription _messageSubscription;
  late StreamSubscription _userStatusSubscription;

  final Map<String, UserStatus> userStatuses = {};

  ChatBloc({
    required this.getChatRoomsUseCase,
    required this.getChatHistoryUseCase,
    required this.sendMessageUseCase,
    required this.connectUserUseCase,
    required this.disconnectUserUseCase,
  }) : super(ChatInitial()) {
    on<InitializeChatEvent>(_onInitializeChat);
    on<ConnectUserEvent>(_onConnectUser);
    on<DisconnectUserEvent>(_onDisconnectUser);
    on<LoadChatRoomsEvent>(_onLoadChatRooms);
    on<LoadChatHistoryEvent>(_onLoadChatHistory);
    on<SendMessageEvent>(_onSendMessage);
    on<MessageReceivedEvent>(_onMessageReceived);
    on<UserStatusUpdatedEvent>(_onUserStatusUpdated);
  }

  Future<void> _onInitializeChat(
    InitializeChatEvent event,
    Emitter<ChatState> emit,
  ) async {
    // This would be handled in the repository implementation to initialize WebSocket
    // _messageSubscription and _userStatusSubscription would be set up there
  }

  Future<void> _onConnectUser(
    ConnectUserEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await connectUserUseCase.execute(event.userInfo);
    } catch (e) {
      emit(ChatError('Failed to connect user: ${e.toString()}'));
    }
  }

  Future<void> _onDisconnectUser(
    DisconnectUserEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await disconnectUserUseCase.execute(event.userInfo);
    } catch (e) {
      emit(ChatError('Failed to disconnect user: ${e.toString()}'));
    }
  }

  Future<void> _onLoadChatRooms(
    LoadChatRoomsEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      final chatRooms = await getChatRoomsUseCase.execute(event.userId);
      emit(ChatRoomsLoaded(chatRooms));
    } catch (e) {
      emit(ChatError('Failed to load chat rooms: ${e.toString()}'));
    }
  }

  Future<void> _onLoadChatHistory(
    LoadChatHistoryEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      final messages = await getChatHistoryUseCase.execute(
        event.publicationId,
        event.senderId,
        event.recipientId,
      );

      emit(ChatHistoryLoaded(
        messages: messages,
        publicationId: event.publicationId,
        recipientId: event.recipientId,
        userStatuses: userStatuses,
      ));
    } catch (e) {
      emit(ChatError('Failed to load chat history: ${e.toString()}'));
    }
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await sendMessageUseCase.execute(event.message);
      emit(MessageSent(event.message));

      // Update chat history if currently viewing a chat
      if (state is ChatHistoryLoaded) {
        final currentState = state as ChatHistoryLoaded;
        if (currentState.publicationId == event.message.publicationId &&
            currentState.recipientId == event.message.recipientId) {
          emit(currentState.copyWith(
            messages: [...currentState.messages, event.message],
          ));
        }
      }
    } catch (e) {
      emit(ChatError('Failed to send message: ${e.toString()}'));
    }
  }

  void _onMessageReceived(
    MessageReceivedEvent event,
    Emitter<ChatState> emit,
  ) {
    // Update chat history if currently viewing this chat
    if (state is ChatHistoryLoaded) {
      final currentState = state as ChatHistoryLoaded;
      if (currentState.publicationId == event.message.publicationId &&
          (currentState.recipientId == event.message.senderId)) {
        emit(currentState.copyWith(
          messages: [...currentState.messages, event.message],
        ));
      }
    }
  }

  void _onUserStatusUpdated(
    UserStatusUpdatedEvent event,
    Emitter<ChatState> emit,
  ) {
    userStatuses[event.userStatus.email] = event.userStatus.status;

    // Update state if we're in a chat view to show updated status
    if (state is ChatHistoryLoaded) {
      final currentState = state as ChatHistoryLoaded;
      emit(currentState.copyWith(
        userStatuses: Map.from(userStatuses),
      ));
    }
  }

  @override
  Future<void> close() {
    _messageSubscription.cancel();
    _userStatusSubscription.cancel();
    return super.close();
  }
}
