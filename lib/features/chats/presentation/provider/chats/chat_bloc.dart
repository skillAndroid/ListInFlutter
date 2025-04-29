import 'dart:async';

import 'package:flutter/material.dart';
import 'package:list_in/features/chats/domain/entity/chat_message.dart';
import 'package:list_in/features/chats/domain/entity/chat_room.dart';
import 'package:list_in/features/chats/domain/entity/user_status.dart';
import 'package:list_in/features/chats/domain/usecase/connect_user_usecase.dart';
import 'package:list_in/features/chats/domain/usecase/disconnect_user_usecase.dart';
import 'package:list_in/features/chats/domain/usecase/get_chat_history_usecase.dart';
import 'package:list_in/features/chats/domain/usecase/get_chat_rooms_usecase.dart';
import 'package:list_in/features/chats/domain/usecase/get_messages_stream_usecase.dart';
import 'package:list_in/features/chats/domain/usecase/get_user_status_usecase.dart';
import 'package:list_in/features/chats/domain/usecase/send_message_usecase.dart';

class ChatRoomsState {
  final bool isLoading;
  final List<ChatRoom> chatRooms;
  final String? errorMessage;

  ChatRoomsState({
    this.isLoading = false,
    this.chatRooms = const [],
    this.errorMessage,
  });

  ChatRoomsState copyWith({
    bool? isLoading,
    List<ChatRoom>? chatRooms,
    String? errorMessage,
  }) {
    return ChatRoomsState(
      isLoading: isLoading ?? this.isLoading,
      chatRooms: chatRooms ?? this.chatRooms,
      errorMessage: errorMessage,
    );
  }
}

class ChatHistoryState {
  final bool isLoading;
  final String publicationId;
  final String recipientId;
  final List<ChatMessage> messages;
  final Map<String, UserStatus> userStatuses;
  final String? errorMessage;

  ChatHistoryState({
    this.isLoading = false,
    this.publicationId = '',
    this.recipientId = '',
    this.messages = const [],
    this.userStatuses = const {},
    this.errorMessage,
  });

  ChatHistoryState copyWith({
    bool? isLoading,
    String? publicationId,
    String? recipientId,
    List<ChatMessage>? messages,
    Map<String, UserStatus>? userStatuses,
    String? errorMessage,
  }) {
    return ChatHistoryState(
      isLoading: isLoading ?? this.isLoading,
      publicationId: publicationId ?? this.publicationId,
      recipientId: recipientId ?? this.recipientId,
      messages: messages ?? this.messages,
      userStatuses: userStatuses ?? this.userStatuses,
      errorMessage: errorMessage,
    );
  }
}

class ChatProvider extends ChangeNotifier {
  // Dependencies
  final GetChatRoomsUseCase getChatRoomsUseCase;
  final GetChatHistoryUseCase getChatHistoryUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final ConnectUserUseCase connectUserUseCase;
  final DisconnectUserUseCase disconnectUserUseCase;
  final GetMessageStreamUseCase getMessageStreamUseCase;
  final GetUserStatusStreamUseCase getUserStatusStreamUseCase;

  // States
  ChatRoomsState _roomsState = ChatRoomsState();
  ChatHistoryState _historyState = ChatHistoryState();

  // Getters
  ChatRoomsState get roomsState => _roomsState;
  ChatHistoryState get historyState => _historyState;

  // Stream subscriptions
  StreamSubscription<ChatMessage>? _messageSubscription;
  StreamSubscription<UserConnectionInfo>? _userStatusSubscription;

  // Helper fields
  bool _isInitialized = false;
  bool _isSubscribed = false;
  final Map<String, UserStatus> _userStatuses = {};
  String? _currentUserId;

  // Constructor
  ChatProvider({
    required this.getChatRoomsUseCase,
    required this.getChatHistoryUseCase,
    required this.sendMessageUseCase,
    required this.connectUserUseCase,
    required this.disconnectUserUseCase,
    required this.getMessageStreamUseCase,
    required this.getUserStatusStreamUseCase,
  });

  // Initialize chat system
  Future<void> initializeChat(String userId) async {
    if (_isInitialized) return;

    _currentUserId = userId;

    try {
      // Connect to WebSocket
      await connectUserUseCase.execute(UserConnectionInfo(
        email: userId,
        nickName: '',
        status: UserStatus.ONLINE,
      ));

      // Subscribe to message and status streams
      _subscribeToStreams();

      _isInitialized = true;
    } catch (e) {
      print('Failed to initialize chat: $e');
    }
  }

  // Subscribe to WebSocket streams
  void _subscribeToStreams() {
    if (_isSubscribed) return;

    // Cancel existing subscriptions
    _messageSubscription?.cancel();
    _userStatusSubscription?.cancel();

    // Subscribe to message stream
    _messageSubscription = getMessageStreamUseCase.execute().listen(
      (message) {
        _handleIncomingMessage(message);
      },
      onError: (error) {
        print('Message stream error: $error');
      },
    );

    // Subscribe to user status stream
    _userStatusSubscription = getUserStatusStreamUseCase.execute().listen(
      (userStatus) {
        _handleUserStatusUpdate(userStatus);
      },
      onError: (error) {
        print('User status stream error: $error');
      },
    );

    _isSubscribed = true;
  }

  // Load chat rooms
  Future<void> loadChatRooms(String userId) async {
    _roomsState = _roomsState.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      final chatRooms = await getChatRoomsUseCase.execute(userId);
      _roomsState = _roomsState.copyWith(
        isLoading: false,
        chatRooms: chatRooms,
      );
    } catch (e) {
      _roomsState = _roomsState.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load chat rooms: $e',
      );

      // Retry logic
      Future.delayed(const Duration(seconds: 3), () {
        loadChatRooms(userId);
      });
    }

    notifyListeners();
  }

  // Load chat history
  Future<void> loadChatHistory({
    required String publicationId,
    required String senderId,
    required String recipientId,
  }) async {
    _historyState = _historyState.copyWith(
      isLoading: true,
      errorMessage: null,
      publicationId: publicationId,
      recipientId: recipientId,
    );
    notifyListeners();

    try {
      final messages = await getChatHistoryUseCase.execute(
        publicationId,
        senderId,
        recipientId,
      );

      _historyState = _historyState.copyWith(
        isLoading: false,
        messages: messages,
        userStatuses: Map.from(_userStatuses),
      );
    } catch (e) {
      _historyState = _historyState.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load chat history: $e',
      );

      // Retry logic
      Future.delayed(const Duration(seconds: 3), () {
        loadChatHistory(
          publicationId: publicationId,
          senderId: senderId,
          recipientId: recipientId,
        );
      });
    }

    notifyListeners();
  }

  // Send a message
  Future<void> sendMessage(ChatMessage message) async {
    try {
      await sendMessageUseCase.execute(message);

      // Update chat history state with the new message
      final updatedMessages = List<ChatMessage>.from(_historyState.messages)
        ..add(message);
      _historyState = _historyState.copyWith(messages: updatedMessages);

      // Update chat room list state with the new last message
      _updateChatRoomWithLastMessage(message);

      notifyListeners();
    } catch (e) {
      _historyState = _historyState.copyWith(
        errorMessage: 'Failed to send message: $e',
      );
      notifyListeners();
    }
  }

  // Update a chat room with a new last message
  void _updateChatRoomWithLastMessage(ChatMessage message) {
    final updatedRooms = _roomsState.chatRooms.map((room) {
      if (room.publicationId == message.publicationId &&
          (room.recipientId == message.recipientId ||
              room.recipientId == message.senderId)) {
        return room.copyWith(lastMessage: message);
      }
      return room;
    }).toList();

    _roomsState = _roomsState.copyWith(chatRooms: updatedRooms);
  }

  // Handle incoming messages from WebSocket
  void _handleIncomingMessage(ChatMessage message) {
    // Update chat history if we're in the relevant chat
    if (_historyState.publicationId == message.publicationId &&
        _historyState.recipientId == message.senderId) {
      final updatedMessages = List<ChatMessage>.from(_historyState.messages)
        ..add(message);
      _historyState = _historyState.copyWith(messages: updatedMessages);
    }

    // Update chat room list with the new last message
    _updateChatRoomWithLastMessage(message);

    notifyListeners();
  }

  // Handle user status updates
  void _handleUserStatusUpdate(UserConnectionInfo userStatus) {
    _userStatuses[userStatus.email] = userStatus.status;

    // Update chat history state if needed
    if (_historyState.userStatuses.containsKey(userStatus.email)) {
      _historyState = _historyState.copyWith(
        userStatuses: Map.from(_userStatuses),
      );
      notifyListeners();
    }
  }

  // Connect a user
  Future<void> connectUser(UserConnectionInfo userInfo) async {
    try {
      await connectUserUseCase.execute(userInfo);
      _userStatuses[userInfo.email] = UserStatus.ONLINE;

      // Update UI if in chat history view
      if (_historyState.recipientId.isNotEmpty) {
        _historyState = _historyState.copyWith(
          userStatuses: Map.from(_userStatuses),
        );
        notifyListeners();
      }
    } catch (e) {
      print('Failed to connect user: $e');

      // Retry logic
      Future.delayed(const Duration(seconds: 3), () {
        connectUser(userInfo);
      });
    }
  }

  // Disconnect a user
  Future<void> disconnectUser(UserConnectionInfo userInfo) async {
    try {
      await disconnectUserUseCase.execute(userInfo);
      _userStatuses[userInfo.email] = UserStatus.OFFLINE;

      // Update UI if in chat history view
      if (_historyState.recipientId.isNotEmpty) {
        _historyState = _historyState.copyWith(
          userStatuses: Map.from(_userStatuses),
        );
        notifyListeners();
      }
    } catch (e) {
      print('Failed to disconnect user: $e');
    }
  }

  // Clean up resources
  @override
  void dispose() {
    _messageSubscription?.cancel();
    _userStatusSubscription?.cancel();
    super.dispose();
  }
}
