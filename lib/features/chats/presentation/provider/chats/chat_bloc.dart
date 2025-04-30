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
import 'package:list_in/features/chats/domain/usecase/get_message_status_usecase.dart';
import 'package:list_in/features/chats/domain/usecase/get_messages_stream_usecase.dart';
import 'package:list_in/features/chats/domain/usecase/get_user_status_usecase.dart';
import 'package:list_in/features/chats/domain/usecase/send_message_usecase.dart';
import 'package:list_in/features/chats/domain/usecase/send_message_viewed_usecase.dart';

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
  final SendMessageViewedStatusUseCase sendMessageViewedStatusUseCase;
  final GetMessageStatusStreamUseCase getMessageStatusStreamUseCase;

  // States
  ChatRoomsState _roomsState = ChatRoomsState();
  ChatHistoryState _historyState = ChatHistoryState();

  // Getters
  ChatRoomsState get roomsState => _roomsState;
  ChatHistoryState get historyState => _historyState;

  // Stream subscriptions
  StreamSubscription<ChatMessage>? _messageSubscription;
  StreamSubscription<UserConnectionInfo>? _userStatusSubscription;
  StreamSubscription<List<String>>? _messageStatusSubscription;
  final Set<String> _processingViewedMessages = {};

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
    required this.sendMessageViewedStatusUseCase,
    required this.getMessageStatusStreamUseCase,
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

  void _subscribeToStreams() {
    if (_isSubscribed) return;

    // Cancel existing subscriptions
    _messageSubscription?.cancel();
    _userStatusSubscription?.cancel();
    _messageStatusSubscription?.cancel();

    // Subscribe to message stream
    _messageSubscription = getMessageStreamUseCase.execute().listen(
      (message) {
        print("Provider received message: ${message.content}");
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

    // Subscribe to message status stream
    _messageStatusSubscription = getMessageStatusStreamUseCase.execute().listen(
      (viewedMessageIds) {
        _handleMessageStatusUpdate(viewedMessageIds);
      },
      onError: (error) {
        print('Message status stream error: $error');
      },
    );

    _isSubscribed = true;
  }

  // Add new method to handle message status updates
  void _handleMessageStatusUpdate(List<String> viewedMessageIds) {
    bool chatHistoryUpdated = false;
    bool chatRoomsUpdated = false;

    // Update messages in current chat history
    if (_historyState.messages.isNotEmpty) {
      final updatedMessages = _historyState.messages.map((message) {
        if (message.id != null &&
            viewedMessageIds.contains(message.id) &&
            message.status != 'VIEWED') {
          // Create a new message with updated status
          return ChatMessage(
            id: message.id,
            senderId: message.senderId,
            recipientId: message.recipientId,
            publicationId: message.publicationId,
            content: message.content,
            status: 'VIEWED',
            sentAt: message.sentAt,
            updatedAt: DateTime.now(),
          );
        }
        return message;
      }).toList();

      // Check if any messages were updated
      for (int i = 0; i < _historyState.messages.length; i++) {
        if (_historyState.messages[i].status != updatedMessages[i].status) {
          chatHistoryUpdated = true;
          break;
        }
      }

      if (chatHistoryUpdated) {
        _historyState = _historyState.copyWith(messages: updatedMessages);
      }
    }

    // Update last message status in chat rooms
    final updatedRooms = _roomsState.chatRooms.map((room) {
      if (room.lastMessage != null &&
          room.lastMessage!.id != null &&
          viewedMessageIds.contains(room.lastMessage!.id) &&
          room.lastMessage!.status != 'VIEWED') {
        // Create a new message with updated status
        final updatedLastMessage = ChatMessage(
          id: room.lastMessage!.id,
          senderId: room.lastMessage!.senderId,
          recipientId: room.lastMessage!.recipientId,
          publicationId: room.lastMessage!.publicationId,
          content: room.lastMessage!.content,
          status: 'VIEWED',
          sentAt: room.lastMessage!.sentAt,
          updatedAt: DateTime.now(),
        );

        // Create a new room with updated unread count
        return room.copyWith(
          lastMessage: updatedLastMessage,
          // Update unread count only if the room has unread messages
          unreadMessages: room.unreadMessages > 0 ? room.unreadMessages - 1 : 0,
        );
      }
      return room;
    }).toList();

    // Check if any rooms were updated
    for (int i = 0; i < _roomsState.chatRooms.length; i++) {
      if (_roomsState.chatRooms[i].unreadMessages !=
              updatedRooms[i].unreadMessages ||
          (_roomsState.chatRooms[i].lastMessage?.status !=
              updatedRooms[i].lastMessage?.status)) {
        chatRoomsUpdated = true;
        break;
      }
    }

    if (chatRoomsUpdated) {
      _roomsState = _roomsState.copyWith(chatRooms: updatedRooms);
    }

    // Notify listeners if anything changed
    if (chatHistoryUpdated || chatRoomsUpdated) {
      notifyListeners();
    }
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

      // Automatically mark unviewed messages as viewed when loading chat history
      final unviewedMessages = messages
          .where((message) =>
              message.senderId != _currentUserId && message.status != 'VIEWED')
          .toList();

      if (unviewedMessages.isNotEmpty) {
        // Mark messages as viewed
        _markMessagesAsViewed(unviewedMessages);

        // Update unread count in the relevant chat room
        _updateUnreadMessageCount(publicationId, recipientId);
      }
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

  // Update unread message count for a specific chat room
  void _updateUnreadMessageCount(String publicationId, String recipientId) {
    final updatedRooms = _roomsState.chatRooms.map((room) {
      if (room.publicationId == publicationId &&
          room.recipientId == recipientId) {
        return room.copyWith(unreadMessages: 0);
      }
      return room;
    }).toList();

    _roomsState = _roomsState.copyWith(chatRooms: updatedRooms);
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

  // Update _handleIncomingMessage to increment unread count
  void _handleIncomingMessage(ChatMessage message) {
    // Update chat history if we're in the relevant chat
    bool inRelevantChat = _historyState.recipientId == message.senderId &&
        _historyState.publicationId == message.publicationId;

    if (inRelevantChat) {
      final updatedMessages = List<ChatMessage>.from(_historyState.messages)
        ..add(message);
      _historyState = _historyState.copyWith(messages: updatedMessages);

      // Mark message as viewed since we're in the chat
      _markMessagesAsViewed([message]);
    }

    // Update chat room list with the new last message
    final updatedRooms = _roomsState.chatRooms.map((room) {
      if (room.publicationId == message.publicationId &&
          (room.recipientId == message.recipientId ||
              room.recipientId == message.senderId)) {
        // If the message is from someone else and we're not in that chat, increment unread count
        int newUnreadCount = room.unreadMessages;
        if (message.senderId != _currentUserId && !inRelevantChat) {
          newUnreadCount += 1;
        }

        return room.copyWith(
          lastMessage: message,
          unreadMessages: newUnreadCount,
        );
      }
      return room;
    }).toList();

    _roomsState = _roomsState.copyWith(chatRooms: updatedRooms);
    notifyListeners();
  }

  // Add new method to mark messages as viewed
  Future<void> _markMessagesAsViewed(List<ChatMessage> messages) async {
    // Filter messages that need to be marked as viewed
    final messagesToMark = messages.where((message) {
      return message.id != null &&
          message.senderId != _currentUserId && // Not sent by current user
          message.status != 'VIEWED' && // Not already viewed
          !_processingViewedMessages
              .contains(message.id); // Not already being processed
    }).toList();

    if (messagesToMark.isEmpty) return;

    // Extract message IDs
    final messageIds = messagesToMark.map((message) => message.id!).toList();

    // Add to processing set to avoid duplicate requests
    messageIds.forEach(_processingViewedMessages.add);

    try {
      // Send viewed status to backend
      await sendMessageViewedStatusUseCase.execute(
          messagesToMark.first.senderId, messageIds);

      // Update local message status
      final updatedMessages = _historyState.messages.map((message) {
        if (message.id != null && messageIds.contains(message.id)) {
          return ChatMessage(
            id: message.id,
            senderId: message.senderId,
            recipientId: message.recipientId,
            publicationId: message.publicationId,
            content: message.content,
            status: 'VIEWED',
            sentAt: message.sentAt,
            updatedAt: DateTime.now(),
          );
        }
        return message;
      }).toList();

      _historyState = _historyState.copyWith(messages: updatedMessages);
      notifyListeners();
    } catch (e) {
      print('Failed to mark messages as viewed: $e');
    } finally {
      // Remove from processing set regardless of success/failure
      messageIds.forEach(_processingViewedMessages.remove);
    }
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
    _messageStatusSubscription?.cancel();
    super.dispose();
  }
}

// Add this method to your ChatProvider class

extension MessageStatusManagement on ChatProvider {
  // Method to send message viewed status
  Future<void> sendMessageViewedStatus(
      String senderId, List<String> messageIds) async {
    if (messageIds.isEmpty) return;

    try {
      // Use the use case to send the viewed status
      await sendMessageViewedStatusUseCase.execute(senderId, messageIds);

      // Update the messages in the current chat
      if (_historyState.messages.isNotEmpty) {
        final updatedMessages = _historyState.messages.map((message) {
          if (message.id != null && messageIds.contains(message.id)) {
            return ChatMessage(
              id: message.id,
              senderId: message.senderId,
              recipientId: message.recipientId,
              publicationId: message.publicationId,
              content: message.content,
              status: 'VIEWED',
              sentAt: message.sentAt,
              updatedAt: DateTime.now(),
            );
          }
          return message;
        }).toList();

        _historyState = _historyState.copyWith(messages: updatedMessages);
      }

      // Update the chat rooms to reflect the new unread count
      if (_roomsState.chatRooms.isNotEmpty) {
        final updatedRooms = _roomsState.chatRooms.map((room) {
          if (room.recipientId == senderId &&
              room.publicationId == _historyState.publicationId) {
            // Reset unread messages for this room
            return room.copyWith(unreadMessages: 0);
          }
          return room;
        }).toList();

        _roomsState = _roomsState.copyWith(chatRooms: updatedRooms);
      }

      notifyListeners();
    } catch (e) {
      print('Error marking messages as viewed: $e');
    }
  }
}
