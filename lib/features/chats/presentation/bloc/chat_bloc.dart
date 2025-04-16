// BLoC
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/features/chats/data/model/chat_message.dart';
import 'package:list_in/features/chats/data/model/chat_room.dart';
import 'package:list_in/features/chats/domain/repository/chat_rep.dart';
import 'package:list_in/features/chats/presentation/bloc/chat_event.dart';
import 'package:list_in/features/chats/presentation/bloc/chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _roomUpdateSubscription;

  final Map<String, List<ChatMessage>> _roomMessages = {};
  List<ChatRoom> _rooms = [];

  ChatBloc({required ChatRepository chatRepository})
      : _chatRepository = chatRepository,
        super(ChatInitialState()) {
    on<ChatConnectEvent>(_onConnect);
    on<ChatDisconnectEvent>(_onDisconnect);
    on<ChatLoadRoomsEvent>(_onLoadRooms);
    on<ChatLoadMessagesEvent>(_onLoadMessages);
    on<ChatSendMessageEvent>(_onSendMessage);
    on<ChatCreateRoomEvent>(_onCreateRoom);
    on<ChatJoinRoomEvent>(_onJoinRoom);
    on<ChatLeaveRoomEvent>(_onLeaveRoom);
    on<ChatNewMessageReceivedEvent>(_onNewMessageReceived);
    on<ChatRoomUpdatedEvent>(_onRoomUpdated);

    // Subscribe to message and room updates
    _messageSubscription = _chatRepository.onMessage.listen((message) {
      add(ChatNewMessageReceivedEvent(message: message));
    });

    _roomUpdateSubscription = _chatRepository.onRoomUpdate.listen((room) {
      add(ChatRoomUpdatedEvent(room: room));
    });
  }

  Future<void> _onConnect(
      ChatConnectEvent event, Emitter<ChatState> emit) async {
    emit(ChatConnectingState());
    try {
      await _chatRepository.connect(token: event.token);
      emit(ChatConnectedState());
    } catch (e) {
      emit(ChatErrorState(error: 'Failed to connect: $e'));
    }
  }

  Future<void> _onDisconnect(
      ChatDisconnectEvent event, Emitter<ChatState> emit) async {
    _chatRepository.disconnect();
    emit(ChatDisconnectedState());
  }

  Future<void> _onLoadRooms(
      ChatLoadRoomsEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoadingRoomsState());
    try {
      final rooms = await _chatRepository.getRooms();
      _rooms = rooms;
      emit(ChatRoomsLoadedState(rooms: rooms));
    } catch (e) {
      emit(ChatErrorState(error: 'Failed to load rooms: $e'));
    }
  }

  Future<void> _onLoadMessages(
      ChatLoadMessagesEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoadingMessagesState(roomId: event.roomId));
    try {
      final messages = await _chatRepository.getMessages(
        event.roomId,
        limit: event.limit,
        lastMessageId: event.lastMessageId,
      );

      // Update the local cache
      if (event.lastMessageId == null) {
        // Initial load
        _roomMessages[event.roomId] = messages;
      } else {
        // Pagination load (older messages)
        final existingMessages = _roomMessages[event.roomId] ?? [];
        _roomMessages[event.roomId] = [...existingMessages, ...messages];
      }

      emit(ChatMessagesLoadedState(
        roomId: event.roomId,
        messages: _roomMessages[event.roomId] ?? [],
        hasMore: messages.length == (event.limit ?? 20),
      ));
    } catch (e) {
      emit(ChatErrorState(error: 'Failed to load messages: $e'));
    }
  }

  Future<void> _onSendMessage(
      ChatSendMessageEvent event, Emitter<ChatState> emit) async {
    emit(ChatSendingMessageState(roomId: event.roomId));
    try {
      await _chatRepository.sendMessage(event.roomId, event.content);
      emit(ChatMessageSentState(roomId: event.roomId));
    } catch (e) {
      emit(ChatErrorState(error: 'Failed to send message: $e'));
    }
  }

  Future<void> _onCreateRoom(
      ChatCreateRoomEvent event, Emitter<ChatState> emit) async {
    emit(ChatCreatingRoomState());
    try {
      final room =
          await _chatRepository.createRoom(event.name, event.participants);
      _rooms.add(room);
      emit(ChatRoomCreatedState(room: room));
      emit(ChatRoomsLoadedState(rooms: _rooms));
    } catch (e) {
      emit(ChatErrorState(error: 'Failed to create room: $e'));
    }
  }

  Future<void> _onJoinRoom(
      ChatJoinRoomEvent event, Emitter<ChatState> emit) async {
    try {
      await _chatRepository.joinRoom(event.roomId);
      // State will be updated via the room update subscription
    } catch (e) {
      emit(ChatErrorState(error: 'Failed to join room: $e'));
    }
  }

  Future<void> _onLeaveRoom(
      ChatLeaveRoomEvent event, Emitter<ChatState> emit) async {
    try {
      await _chatRepository.leaveRoom(event.roomId);
      // State will be updated via the room update subscription
    } catch (e) {
      emit(ChatErrorState(error: 'Failed to leave room: $e'));
    }
  }

  void _onNewMessageReceived(
      ChatNewMessageReceivedEvent event, Emitter<ChatState> emit) {
    final roomId = event.message.roomId;
    final messages = _roomMessages[roomId] ?? [];

    // Add the new message to the list (if not already there)
    if (!messages.any((m) => m.id == event.message.id)) {
      messages.insert(
          0, event.message); // Add to beginning of list (newest first)
      _roomMessages[roomId] = messages;

      // If we're currently showing this room's messages, update the state
      if (state is ChatMessagesLoadedState &&
          (state as ChatMessagesLoadedState).roomId == roomId) {
        emit(ChatMessagesLoadedState(
          roomId: roomId,
          messages: messages,
          hasMore: (state as ChatMessagesLoadedState).hasMore,
        ));
      }
    }
  }

  void _onRoomUpdated(ChatRoomUpdatedEvent event, Emitter<ChatState> emit) {
    // Update the room in the list
    final index = _rooms.indexWhere((r) => r.id == event.room.id);
    if (index >= 0) {
      _rooms[index] = event.room;
    } else {
      _rooms.add(event.room);
    }

    // If we're showing the rooms list, update it
    if (state is ChatRoomsLoadedState) {
      emit(ChatRoomsLoadedState(rooms: _rooms));
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    _roomUpdateSubscription?.cancel();
    return super.close();
  }
}
