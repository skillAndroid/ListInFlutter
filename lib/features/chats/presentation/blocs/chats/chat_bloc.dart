// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/features/chats/domain/entity/chat_message.dart';
import 'package:list_in/features/chats/domain/entity/user_status.dart';
import 'package:list_in/features/chats/domain/usecase/connect_user_usecase.dart';
import 'package:list_in/features/chats/domain/usecase/disconnect_user_usecase.dart';
import 'package:list_in/features/chats/domain/usecase/get_chat_history_usecase.dart';
import 'package:list_in/features/chats/domain/usecase/get_chat_rooms_usecase.dart';
import 'package:list_in/features/chats/domain/usecase/get_messages_stream_usecase.dart';
import 'package:list_in/features/chats/domain/usecase/get_user_status_usecase.dart';
import 'package:list_in/features/chats/domain/usecase/send_message_usecase.dart';

import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetChatRoomsUseCase getChatRoomsUseCase;
  final GetChatHistoryUseCase getChatHistoryUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final ConnectUserUseCase connectUserUseCase;
  final DisconnectUserUseCase disconnectUserUseCase;
  final GetMessageStreamUseCase getMessageStreamUseCase;
  final GetUserStatusStreamUseCase getUserStatusStreamUseCase;

  StreamSubscription<ChatMessage>? _messageSubscription;
  StreamSubscription<UserConnectionInfo>? _userStatusSubscription;

  final Map<String, UserStatus> userStatuses = {};
  bool _isInitialized = false;
  bool _isInitializing = false;

  // Store current chat context to filter messages

  ChatBloc({
    required this.getChatRoomsUseCase,
    required this.getChatHistoryUseCase,
    required this.sendMessageUseCase,
    required this.connectUserUseCase,
    required this.disconnectUserUseCase,
    required this.getMessageStreamUseCase,
    required this.getUserStatusStreamUseCase,
  }) : super(ChatInitial()) {
    on<InitializeChatEvent>(_onInitializeChat);
    on<WebSocketConnectedEvent>(_onWebSocketConnected);
    on<ConnectUserEvent>(_onConnectUser);
    on<DisconnectUserEvent>(_onDisconnectUser);
    on<LoadChatRoomsEvent>(_onLoadChatRooms);
    on<LoadChatHistoryEvent>(_onLoadChatHistory);
    on<SendMessageEvent>(_onSendMessage);
    on<MessageReceivedEvent>(_onMessageReceived);
    on<UserStatusUpdatedEvent>(_onUserStatusUpdated);
  }
  void _subscribeToStreams() {
    _messageSubscription?.cancel();
    _userStatusSubscription?.cancel();

    // Add delay to ensure WebSocket is ready
    Future.delayed(Duration(milliseconds: 500), () {
      _messageSubscription = getMessageStreamUseCase.execute().listen(
        (message) {
          print('💋💋Message received: ${message.content}');
          print('💋💋From: ${message.senderId}, To: ${message.recipientId}');
          print('💋💋Publication ID: ${message.publicationId}');
          add(MessageReceivedEvent(message));
        },
        onError: (error) {
          print('Message stream error: $error');
          // Reconnect logic
          _subscribeToStreams();
        },
      );

      _userStatusSubscription = getUserStatusStreamUseCase.execute().listen(
        (userStatus) {
          add(UserStatusUpdatedEvent(userStatus));
        },
        onError: (error) {
          print('User status stream error: $error');
          // Reconnect logic
          _subscribeToStreams();
        },
      );
    });
  }

  Future<void> _onInitializeChat(
    InitializeChatEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (_isInitialized || _isInitializing) return;

    _isInitializing = true;
    emit(ChatLoading());

    try {
      // First connect to WebSocket
      await connectUserUseCase.execute(UserConnectionInfo(
        email: event.userId,
        nickName: '', // Add appropriate values
        status: UserStatus.ONLINE,
      ));

      // Then subscribe to streams
      _subscribeToStreams();

      _isInitialized = true;
      _isInitializing = false;
      emit(ChatInitialized());
    } catch (e) {
      // Error handling
    }
  }

  void _onWebSocketConnected(
    WebSocketConnectedEvent event,
    Emitter<ChatState> emit,
  ) {
    // WebSocket connected, update state if needed
    print('Bloc: WebSocket connected successfully');
  }

  Future<void> _onConnectUser(
    ConnectUserEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      print('Bloc: Connecting user: ${event.userInfo.email}');
      await connectUserUseCase.execute(event.userInfo);

      // Update local state
      userStatuses[event.userInfo.email] = UserStatus.ONLINE;

      // Update UI if in chat history view
      if (state is ChatHistoryLoaded) {
        final currentState = state as ChatHistoryLoaded;
        emit(currentState.copyWith(userStatuses: Map.from(userStatuses)));
      }
    } catch (e) {
      print('Bloc: Failed to connect user: $e');
      emit(ChatError('Failed to connect user: ${e.toString()}'));

      // Retry logic
      Future.delayed(Duration(seconds: 3), () {
        add(ConnectUserEvent(event.userInfo));
      });
    }
  }

  Future<void> _onDisconnectUser(
    DisconnectUserEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      print('Bloc: Disconnecting user: ${event.userInfo.email}');
      await disconnectUserUseCase.execute(event.userInfo);

      // Update local state
      userStatuses[event.userInfo.email] = UserStatus.OFFLINE;

      // Update UI if in chat history view
      if (state is ChatHistoryLoaded) {
        final currentState = state as ChatHistoryLoaded;
        emit(currentState.copyWith(userStatuses: Map.from(userStatuses)));
      }
    } catch (e) {
      print('Bloc: Failed to disconnect user: $e');
      emit(ChatError('Failed to disconnect user: ${e.toString()}'));
    }
  }

  Future<void> _onLoadChatRooms(
    LoadChatRoomsEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      print('Bloc: Loading chat rooms for user: ${event.userId}');
      final chatRooms = await getChatRoomsUseCase.execute(event.userId);
      emit(ChatRoomsLoaded(chatRooms));
      print('Bloc: Loaded ${chatRooms.length} chat rooms');
    } catch (e) {
      print('Bloc: Failed to load chat rooms: $e');
      emit(ChatError('Failed to load chat rooms: ${e.toString()}'));

      // Retry logic after delay
      Future.delayed(Duration(seconds: 3), () {
        add(LoadChatRoomsEvent(event.userId));
      });
    }
  }

  Future<void> _onLoadChatHistory(
    LoadChatHistoryEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      print(
          'Bloc: Loading chat history for publication: ${event.publicationId}, ' +
              'sender: ${event.senderId}, recipient: ${event.recipientId}');

      // Store current chat context for message filtering

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
      print('Bloc: Loaded ${messages.length} messages');
    } catch (e) {
      print('Bloc: Failed to load chat history: $e');
      emit(ChatError('Failed to load chat history: ${e.toString()}'));

      // Retry logic after delay
      Future.delayed(Duration(seconds: 3), () {
        add(LoadChatHistoryEvent(
          publicationId: event.publicationId,
          senderId: event.senderId,
          recipientId: event.recipientId,
        ));
      });
    }
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await sendMessageUseCase.execute(event.message);

      // Update UI immediately with the sent message
      if (state is ChatHistoryLoaded) {
        final currentState = state as ChatHistoryLoaded;
        final updatedMessages = List<ChatMessage>.from(currentState.messages)
          ..add(event.message);

        emit(currentState.copyWith(messages: updatedMessages));
      }
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onMessageReceived(
    MessageReceivedEvent event,
    Emitter<ChatState> emit,
  ) {
    if (state is ChatHistoryLoaded) {
      final currentState = state as ChatHistoryLoaded;

      // Simplified filtering - just check publication ID
      if (event.message.publicationId == currentState.publicationId) {
        final updatedMessages = List<ChatMessage>.from(currentState.messages)
          ..add(event.message);
        emit(currentState.copyWith(messages: updatedMessages));
      }
    }
  }

  void _onUserStatusUpdated(
    UserStatusUpdatedEvent event,
    Emitter<ChatState> emit,
  ) {
    userStatuses[event.userStatus.email] = event.userStatus.status;

    if (state is ChatHistoryLoaded) {
      final currentState = state as ChatHistoryLoaded;
      emit(currentState.copyWith(userStatuses: userStatuses));
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    _userStatusSubscription?.cancel();
    return super.close();
  }
}
