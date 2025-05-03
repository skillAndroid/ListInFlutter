// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:collection';

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
import 'package:list_in/features/chats/domain/usecase/message_delivered_usecase.dart';
import 'package:list_in/features/chats/domain/usecase/send_message_usecase.dart';
import 'package:list_in/features/chats/domain/usecase/send_message_viewed_usecase.dart';
import 'package:list_in/features/chats/presentation/provider/chats/chat_history_state.dart';
import 'package:list_in/features/chats/presentation/provider/chats/chat_rooms_state.dart';

class ChatProvider extends ChangeNotifier {
  final GetChatRoomsUseCase getChatRoomsUseCase;
  final GetChatHistoryUseCase getChatHistoryUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final ConnectUserUseCase connectUserUseCase;
  final DisconnectUserUseCase disconnectUserUseCase;
  final GetMessageStreamUseCase getMessageStreamUseCase;
  final GetUserStatusStreamUseCase getUserStatusStreamUseCase;
  final SendMessageViewedStatusUseCase sendMessageViewedStatusUseCase;
  final GetMessageStatusStreamUseCase getMessageStatusStreamUseCase;
  final GetMessageDeliveredStreamUseCase getMessageDeliveredStreamUseCase;

  // States
  ChatRoomsState _roomsState = const ChatRoomsState();
  ChatHistoryState _historyState = const ChatHistoryState();

  // Getters
  ChatRoomsState get roomsState => _roomsState;
  ChatHistoryState get historyState => _historyState;

  // Stream subscriptions
  StreamSubscription<ChatMessage>? _messageSubscription;
  StreamSubscription<ChatMessage>? _messageDeliveredSubscription;
  StreamSubscription<UserConnectionInfo>? _userStatusSubscription;
  StreamSubscription<List<String>>? _messageStatusSubscription;

  // Tracking
  bool _isInitialized = false;
  String? _currentUserId;
  String? _currentChatRecipientId;
  String? _currentPublicationId;

  // Keep track of message statuses to avoid duplicate processing
  final Set<String> _messageViewedProcessingQueue = HashSet<String>();
  final Map<String, UserStatus> _userStatuses = {};

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
    required this.getMessageDeliveredStreamUseCase,
  });

  // Initialize chat system with current user ID
  Future<void> initializeChat(String userId) async {
    if (_isInitialized && _currentUserId == userId) {
      print('Chat already initialized for user $userId');
      return;
    }

    _currentUserId = userId;

    try {
      // Connect user as online
      await connectUserUseCase.execute(UserConnectionInfo(
        email: userId,
        nickName: '',
        status: UserStatus.ONLINE,
      ));

      // Initialize message subscriptions
      _subscribeToMessageStreams();

      _isInitialized = true;
      print('Chat initialized for user $userId');
    } catch (e) {
      print('Failed to initialize chat: $e');
      // We don't rethrow to prevent UI crashes, but we set the error in state if needed
    }
  }

  // Subscribe to all message-related streams
  void _subscribeToMessageStreams() {
    // Cancel any existing subscriptions first
    _unsubscribeFromStreams();

    // 1. Subscribe to incoming messages
    _messageSubscription = getMessageStreamUseCase.execute().listen(
      (message) {
        print('📩 Received message: ${message.id} - ${message.content}');
        _handleIncomingMessage(message);
      },
      onError: (error) {
        print('❌ Message stream error: $error');
      },
    );

    // 2. Subscribe to message delivery confirmations
    _messageDeliveredSubscription =
        getMessageDeliveredStreamUseCase.execute().listen(
      (deliveredMessage) {
        print('🚚 Message delivered: ${deliveredMessage.id}');
        _handleMessageDeliveryStatus(deliveredMessage);
      },
      onError: (error) {
        print('❌ Message delivery stream error: $error');
      },
    );

    // 3. Subscribe to message read status updates
    _messageStatusSubscription = getMessageStatusStreamUseCase.execute().listen(
      (viewedMessageIds) {
        _handleMessageViewedStatus(viewedMessageIds);
      },
      onError: (error) {
        print('❌ Message status stream error: $error');
      },
    );

    // 4. Subscribe to user status updates
    _userStatusSubscription = getUserStatusStreamUseCase.execute().listen(
      (userStatus) {
        print(
            '👤 User status update: ${userStatus.email} is ${userStatus.status}');
        _handleUserStatusUpdate(userStatus);
      },
      onError: (error) {
        print('❌ User status stream error: $error');
      },
    );
  }

  // Clean up subscriptions
  void _unsubscribeFromStreams() {
    _messageSubscription?.cancel();
    _messageDeliveredSubscription?.cancel();
    _messageStatusSubscription?.cancel();
    _userStatusSubscription?.cancel();

    _messageSubscription = null;
    _messageDeliveredSubscription = null;
    _messageStatusSubscription = null;
    _userStatusSubscription = null;
  }

  // Load chat rooms list
  Future<void> loadChatRooms(String userId) async {
    if (!_isInitialized) {
      await initializeChat(userId);
    }

    _roomsState = _roomsState.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      final chatRooms = await getChatRoomsUseCase.execute(userId);
      _roomsState = _roomsState.copyWith(
        isLoading: false,
        chatRooms: chatRooms,
      );
    } catch (e) {
      print('Failed to load chat rooms: $e');
      _roomsState = _roomsState.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load chat rooms: $e',
      );
    }

    notifyListeners();
  }

  Future<void> loadChatHistory({
    required String publicationId,
    required String senderId,
    required String recipientId,
  }) async {
    if (!_isInitialized) {
      await initializeChat(senderId);
    }

    _currentChatRecipientId = recipientId;
    _currentPublicationId = publicationId;

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

      messages.sort((a, b) => a.sentAt.compareTo(b.sentAt));

      _historyState = _historyState.copyWith(
        isLoading: false,
        messages: messages,
        userStatuses: Map.from(_userStatuses),
      );

      notifyListeners();

      // Mark unread messages as viewed when history loads
      _markUnreadMessagesAsViewed(messages);
    } catch (e) {
      print('Failed to load chat history: $e');
      _historyState = _historyState.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load chat history: $e',
      );
      notifyListeners();
    }
  }

// Add this helper method to mark unread messages as viewed
  void _markUnreadMessagesAsViewed(List<ChatMessage> messages) {
    // Find messages from the other user that aren't viewed yet
    final unreadMessages = messages
        .where(
            (msg) => msg.senderId != _currentUserId && msg.status != 'VIEWED')
        .toList();

    if (unreadMessages.isEmpty) return;

    // Get IDs of messages to mark as viewed
    final messageIds = unreadMessages.map((msg) => msg.id).toList();

    // Add to processing queue to avoid duplicates
    final newMessageIds = messageIds
        .where((id) => !_messageViewedProcessingQueue.contains(id))
        .toList();

    if (newMessageIds.isEmpty) return;

    newMessageIds.forEach(_messageViewedProcessingQueue.add);

    // Send viewed status to server
    sendMessageViewedStatus(_currentUserId!, newMessageIds);
  }

  Future<void> sendMessage(ChatMessage message) async {
    if (!_isInitialized) {
      await initializeChat(message.senderId);
    }

    try {
      final optimisticMessage = message.copyWith(status: 'SENDING');
      final updatedMessages = List<ChatMessage>.from(_historyState.messages)
        ..add(optimisticMessage);

      _historyState = _historyState.copyWith(messages: updatedMessages);

      _updateChatRoomWithLastMessage(optimisticMessage);

      notifyListeners();

      await sendMessageUseCase.execute(message);

      final sentMessage = optimisticMessage.copyWith(status: 'SENT');
      _updateMessageStatus(sentMessage);
    } catch (e) {
      print('Failed to send message: $e');

      // Update message with error status
      final errorMessage = message.copyWith(status: 'ERROR');
      _updateMessageStatus(errorMessage);

      _historyState = _historyState.copyWith(
        errorMessage: 'Failed to send message: $e',
      );
      notifyListeners();
    }
  }

  // HANDLE INCOMING EVENTS

// Process incoming new messages
  void _handleIncomingMessage(ChatMessage message) {
    // 1. Add message to current chat if we're in the right conversation
    final bool isInRelevantChat = _isInRelevantChatContext(message);

    if (isInRelevantChat) {
      final updatedMessages = List<ChatMessage>.from(_historyState.messages)
        ..add(message);
      _historyState = _historyState.copyWith(messages: updatedMessages);
    }

    final updatedRooms = _roomsState.chatRooms.map((room) {
      // Find the relevant room
      if (_isRelevantChatRoom(room, message)) {
        int newUnreadCount = room.unreadMessages;
        if (message.senderId != _currentUserId && !isInRelevantChat) {
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

  // Process delivery status updates
  void _handleMessageDeliveryStatus(ChatMessage deliveredMessage) {
    // Only process if this message was sent by current user
    if (deliveredMessage.senderId != _currentUserId) return;

    final updatedMessage = deliveredMessage.copyWith(status: 'DELIVERED');
    _updateMessageStatus(updatedMessage);
  }

  // Process message viewed status updates
  void _handleMessageViewedStatus(List<String> viewedMessageIds) {
    if (viewedMessageIds.isEmpty) return;
    print('👁️ Messages viewed: $viewedMessageIds');
    // Update messages in current chat history
    if (_historyState.messages.isNotEmpty) {
      final updatedMessages = _historyState.messages.map((message) {
        if (viewedMessageIds.contains(message.id) &&
            message.status != 'VIEWED') {
          return message.copyWith(status: 'VIEWED');
        }
        return message;
      }).toList();

      _historyState = _historyState.copyWith(messages: updatedMessages);
    }

    final updatedRooms = _roomsState.chatRooms.map((room) {
      if (room.lastMessage != null &&
          viewedMessageIds.contains(room.lastMessage!.id)) {
        final updatedLastMessage = room.lastMessage!.copyWith(status: 'VIEWED');
        return room.copyWith(
          lastMessage: updatedLastMessage,
          // Also reset unread count for this room if appropriate
          unreadMessages:
              room.recipientId == _currentUserId ? 0 : room.unreadMessages,
        );
      }
      return room;
    }).toList();

    _roomsState = _roomsState.copyWith(chatRooms: updatedRooms);
    notifyListeners();
  }

  void _handleUserStatusUpdate(UserConnectionInfo userStatus) {
    _userStatuses[userStatus.email] = userStatus.status;
    if (_historyState.recipientId == userStatus.email) {
      _historyState = _historyState.copyWith(
        userStatuses: Map.from(_userStatuses),
      );
      notifyListeners();
    }
  }

  void _updateMessageStatus(ChatMessage updatedMessage) {
    // 1. Update in current chat history
    if (_historyState.messages.isNotEmpty) {
      final updatedMessages = _historyState.messages.map((message) {
        if (message.id == updatedMessage.id) {
          return updatedMessage;
        }
        return message;
      }).toList();

      _historyState = _historyState.copyWith(messages: updatedMessages);
    }

    // 2. Update in chat rooms list if this is the last message
    final updatedRooms = _roomsState.chatRooms.map((room) {
      if (room.lastMessage != null &&
          room.lastMessage!.id == updatedMessage.id) {
        return room.copyWith(lastMessage: updatedMessage);
      }
      return room;
    }).toList();

    _roomsState = _roomsState.copyWith(chatRooms: updatedRooms);
    notifyListeners();
  }

  void _updateChatRoomWithLastMessage(ChatMessage message) {
    final updatedRooms = _roomsState.chatRooms.map((room) {
      if (_isRelevantChatRoom(room, message)) {
        return room.copyWith(lastMessage: message);
      }
      return room;
    }).toList();

    _roomsState = _roomsState.copyWith(chatRooms: updatedRooms);
  }

  bool _isInRelevantChatContext(ChatMessage message) {
    return _currentPublicationId == message.publicationId &&
        (_currentChatRecipientId == message.senderId ||
            _currentChatRecipientId == message.recipientId);
  }

  bool _isRelevantChatRoom(ChatRoom room, ChatMessage message) {
    return room.publicationId == message.publicationId &&
        ((room.recipientId == message.recipientId &&
                message.senderId == _currentUserId) ||
            (room.recipientId == message.senderId &&
                message.recipientId == _currentUserId));
  }

  Future<void> sendMessageViewedStatus(
      String senderId, List<String> messageIds) async {
    if (messageIds.isEmpty) return;
    try {
      await sendMessageViewedStatusUseCase.execute(senderId, messageIds);

      if (_currentPublicationId != null && _currentChatRecipientId != null) {
        final updatedRooms = _roomsState.chatRooms.map((room) {
          if (room.publicationId == _currentPublicationId &&
              (room.recipientId == _currentChatRecipientId ||
                  room.recipientId == senderId)) {
            return room.copyWith(unreadMessages: 0);
          }
          return room;
        }).toList();

        _roomsState = _roomsState.copyWith(chatRooms: updatedRooms);
        notifyListeners();
      }
    } catch (e) {
      print('Error marking messages as viewed: $e');
    } finally {
      messageIds.forEach(_messageViewedProcessingQueue.remove);
    }
  }

  void leaveCurrentChat() {
    _currentChatRecipientId = null;
    _currentPublicationId = null;
  }

  Future<void> connectUser(UserConnectionInfo userInfo) async {
    try {
      await connectUserUseCase.execute(userInfo);
      _userStatuses[userInfo.email] = UserStatus.ONLINE;

      if (_historyState.recipientId == userInfo.email) {
        _historyState = _historyState.copyWith(
          userStatuses: Map.from(_userStatuses),
        );
        notifyListeners();
      }
    } catch (e) {
      print('Failed to connect user: $e');
    }
  }

  Future<void> disconnectUser(UserConnectionInfo userInfo) async {
    try {
      await disconnectUserUseCase.execute(userInfo);
      _userStatuses[userInfo.email] = UserStatus.OFFLINE;

      if (_historyState.recipientId == userInfo.email) {
        _historyState = _historyState.copyWith(
          userStatuses: Map.from(_userStatuses),
        );
        notifyListeners();
      }
    } catch (e) {
      print('Failed to disconnect user: $e');
    }
  }

  @override
  void dispose() {
    _unsubscribeFromStreams();
    super.dispose();
  }
}

// Extension for ChatMessage for better immutability
extension ChatMessageExtension on ChatMessage {
  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? recipientId,
    String? publicationId,
    String? content,
    String? status,
    DateTime? sentAt,
    DateTime? updatedAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      recipientId: recipientId ?? this.recipientId,
      publicationId: publicationId ?? this.publicationId,
      content: content ?? this.content,
      status: status ?? this.status,
      sentAt: sentAt ?? this.sentAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
