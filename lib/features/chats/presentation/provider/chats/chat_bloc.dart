// ignore_for_file: avoid_print

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
import 'package:list_in/features/chats/domain/usecase/local/get_last_read_message_id_usecase.dart';
import 'package:list_in/features/chats/domain/usecase/local/get_local_chat_history_usecase.dart';
import 'package:list_in/features/chats/domain/usecase/local/get_unread_count_usecase.dart';
import 'package:list_in/features/chats/domain/usecase/local/reset_unread_count_usecase.dart';
import 'package:list_in/features/chats/domain/usecase/local/save_last_read_message_id_usecase.dart';
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
  final String? lastReadMessageId; // Track the last read message ID
  final int unreadCount; // Number of unread messages
  final String? errorMessage;

  ChatHistoryState({
    this.isLoading = false,
    this.publicationId = '',
    this.recipientId = '',
    this.messages = const [],
    this.userStatuses = const {},
    this.lastReadMessageId,
    this.unreadCount = 0,
    this.errorMessage,
  });

  ChatHistoryState copyWith({
    bool? isLoading,
    String? publicationId,
    String? recipientId,
    List<ChatMessage>? messages,
    Map<String, UserStatus>? userStatuses,
    String? lastReadMessageId,
    int? unreadCount,
    String? errorMessage,
  }) {
    return ChatHistoryState(
      isLoading: isLoading ?? this.isLoading,
      publicationId: publicationId ?? this.publicationId,
      recipientId: recipientId ?? this.recipientId,
      messages: messages ?? this.messages,
      userStatuses: userStatuses ?? this.userStatuses,
      lastReadMessageId: lastReadMessageId ?? this.lastReadMessageId,
      unreadCount: unreadCount ?? this.unreadCount,
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
  final GetLastReadMessageIdUseCase getLastReadMessageIdUseCase;
  final SaveLastReadMessageIdUseCase saveLastReadMessageIdUseCase;
  final GetUnreadCountUseCase getUnreadCountUseCase;
  final ResetUnreadCountUseCase resetUnreadCountUseCase;
  final GetLocalChatHistoryUseCase getLocalChatHistoryUseCase;

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
    required this.getLastReadMessageIdUseCase,
    required this.saveLastReadMessageIdUseCase,
    required this.getUnreadCountUseCase,
    required this.resetUnreadCountUseCase,
    required this.getLocalChatHistoryUseCase,
  });

  // Initialize chat system
  Future<void> initializeChat(String userId) async {
    if (_isInitialized && _currentUserId == userId) return;

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

  // Load chat rooms with unread counts
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

  // Load chat history with optimized background loading
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
      // First, immediately get and display local messages
      final localMessages = await getLocalChatHistoryUseCase.execute(
        publicationId: publicationId,
        senderId: senderId,
        recipientId: recipientId,
      );

      // Get the last read message ID
      final lastReadMessageId = await getLastReadMessageIdUseCase.execute(
        publicationId,
        senderId,
        recipientId,
      );

      // Get unread count
      final unreadCount = await getUnreadCountUseCase.execute(
        publicationId,
        senderId,
        recipientId,
      );

      // If we have local messages, immediately show them and stop the loading indicator
      if (localMessages.isNotEmpty) {
        _historyState = _historyState.copyWith(
          isLoading: false,
          messages: localMessages,
          userStatuses: Map.from(_userStatuses),
          lastReadMessageId: lastReadMessageId,
          unreadCount: unreadCount,
        );
        notifyListeners();
      }

      // In background, fetch remote messages
      getChatHistoryUseCase
          .execute(
        publicationId,
        senderId,
        recipientId,
      )
          .then((remoteMessages) {
        // If remote messages are different from local, update the UI
        if (remoteMessages.length != localMessages.length) {
          _historyState = _historyState.copyWith(
            isLoading: false,
            messages: remoteMessages,
            userStatuses: Map.from(_userStatuses),
            lastReadMessageId: lastReadMessageId,
            unreadCount: unreadCount,
          );
          notifyListeners();
        }

        // Mark messages as read regardless
        if (remoteMessages.isNotEmpty && remoteMessages.last.id != null) {
          markMessagesAsRead(
            publicationId: publicationId,
            senderId: senderId,
            recipientId: recipientId,
          );
        }
      }).catchError((e) {
        // If remote fetch fails, we've already shown local messages, so no need to show error
        print('Error fetching remote messages: $e');
      });
    } catch (e) {
      // This will only show if we couldn't get local messages
      _historyState = _historyState.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load chat history: $e',
      );
      notifyListeners();
    }
  }

  // Mark all messages as read
  Future<void> markMessagesAsRead({
    required String publicationId,
    required String senderId,
    required String recipientId,
  }) async {
    if (_historyState.messages.isEmpty) return;

    final lastMessage = _historyState.messages.last;
    if (lastMessage.id == null) return;

    try {
      // Save the last message ID as the last read message
      await saveLastReadMessageIdUseCase.execute(
        publicationId,
        senderId,
        recipientId,
        lastMessage.id!,
      );

      // Reset unread count
      await resetUnreadCountUseCase.execute(
        publicationId,
        senderId,
        recipientId,
      );

      // Update the chat history state
      _historyState = _historyState.copyWith(
        lastReadMessageId: lastMessage.id,
        unreadCount: 0,
      );

      // Update the chat rooms state with the new unread count
      if (_roomsState.chatRooms.isNotEmpty) {
        final updatedRooms = _roomsState.chatRooms.map((room) {
          if (room.publicationId == publicationId &&
              (room.recipientId == recipientId ||
                  room.recipientId == senderId)) {
            return room.copyWith(unreadCount: 0);
          }
          return room;
        }).toList();

        _roomsState = _roomsState.copyWith(chatRooms: updatedRooms);
      }

      notifyListeners();
    } catch (e) {
      print('Failed to mark messages as read: $e');
    }
  }

  // Send a message
  Future<void> sendMessage(ChatMessage message) async {
    try {
      await sendMessageUseCase.execute(message);

      // Update chat history state with the new message
      final updatedMessages = List<ChatMessage>.from(_historyState.messages)
        ..add(message);
      _historyState = _historyState.copyWith(
        messages: updatedMessages,
        lastReadMessageId: message.id, // Mark this message as read
      );

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
  void _handleIncomingMessage(ChatMessage message) async {
    // Determine if this message is for the current user
    final isForCurrentUser = message.recipientId == _currentUserId;
    final isFromCurrentUser = message.senderId == _currentUserId;

    // If we're currently viewing a chat with this sender
    final isInRelevantChat =
        _historyState.publicationId == message.publicationId &&
            (_historyState.recipientId == message.senderId ||
                _historyState.recipientId == message.recipientId);

    // Update chat history if we're in the relevant chat
    if (isInRelevantChat) {
      final updatedMessages = List<ChatMessage>.from(_historyState.messages)
        ..add(message);

      // Mark as read if we're viewing the chat
      if (isForCurrentUser && message.id != null) {
        await markMessagesAsRead(
          publicationId: message.publicationId,
          senderId: _currentUserId!,
          recipientId: message.senderId,
        );
      }

      _historyState = _historyState.copyWith(
        messages: updatedMessages,
        lastReadMessageId: isFromCurrentUser || isInRelevantChat
            ? message.id
            : _historyState.lastReadMessageId,
        unreadCount: isInRelevantChat ? 0 : _historyState.unreadCount,
      );
    }
    // If the message is for the current user but we're not viewing the chat
    else if (isForCurrentUser) {
      // Find the appropriate room and update it
      final updatedRooms = _roomsState.chatRooms.map((room) async {
        if (room.publicationId == message.publicationId &&
            (room.recipientId == message.senderId)) {
          // Get the current unread count
          int unreadCount = await getUnreadCountUseCase.execute(
            message.publicationId,
            _currentUserId!,
            message.senderId,
          );

          // Return updated room with new unread count
          return room.copyWith(
            lastMessage: message,
            unreadCount: unreadCount,
          );
        }
        return room;
      }).toList();

      // Wait for all rooms to be updated
      final resolvedRooms = await Future.wait(updatedRooms);

      _roomsState = _roomsState.copyWith(chatRooms: resolvedRooms);
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

  // Get unread count for a chat room
  int getUnreadCountForRoom(String chatRoomId) {
    try {
      final room = _roomsState.chatRooms.firstWhere(
        (room) => room.chatRoomId == chatRoomId,
      );
      return room.unreadCount;
    } catch (e) {
      return 0;
    }
  }

  // Find index of last read message in the current chat history
  int getLastReadMessageIndex() {
    if (_historyState.lastReadMessageId == null ||
        _historyState.messages.isEmpty) {
      return -1;
    }

    for (int i = _historyState.messages.length - 1; i >= 0; i--) {
      if (_historyState.messages[i].id == _historyState.lastReadMessageId) {
        return i;
      }
    }

    return -1;
  }

  // Clean up resources
  @override
  void dispose() {
    _messageSubscription?.cancel();
    _userStatusSubscription?.cancel();
    super.dispose();
  }
}
