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
import 'package:list_in/features/chats/domain/usecase/message_delivered_usecase.dart';
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
  final GetMessageDeliveredStreamUseCase getMessageDeliveredStreamUseCase;

  // Add a subscription for delivered messages
  StreamSubscription<ChatMessage>? _messageDeliveredSubscription;
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
    required this.getMessageDeliveredStreamUseCase,
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
    _messageDeliveredSubscription?.cancel();

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
    _messageDeliveredSubscription =
        getMessageDeliveredStreamUseCase.execute().listen(
      (deliveredMessage) {
        _handleDeliveredMessage(deliveredMessage);
      },
      onError: (error) {
        print('Message delivered stream error: $error');
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

  void _handleDeliveredMessage(ChatMessage deliveredMessage) {
    print('🚚 Processing delivered message: ${deliveredMessage.id}');
    print('🚚 Message content: ${deliveredMessage.content}');
    print('🚚 Message status: ${deliveredMessage.status}');

    // We need to update the message in both chat history and chat rooms
    bool chatHistoryUpdated = false;
    bool chatRoomsUpdated = false;
    print('🔍 Current messages in history:');

    // Update in chat history
    if (_historyState.messages.isNotEmpty) {
      for (var message in _historyState.messages) {
        print(
            '  - ID: ${message.id}, Content: ${message.content}, Status: ${message.status}');
      }
      final updatedMessages = _historyState.messages.map((message) {
        // Match by ID if available, otherwise try content matching
        if (message.id == deliveredMessage.id) {
          print('✅ Updating message status to DELIVERED: ${message.content}');
          chatHistoryUpdated = true;

          // Return the delivered message but keep our local ID if needed
          return ChatMessage(
            id: message.id,
            senderId: deliveredMessage.senderId,
            recipientId: deliveredMessage.recipientId,
            publicationId: deliveredMessage.publicationId,
            content: deliveredMessage.content,
            status: 'DELIVERED', // Update status to DELIVERED
            sentAt: deliveredMessage.sentAt,
            updatedAt: DateTime.now(),
          );
        }
        return message;
      }).toList();

      if (chatHistoryUpdated) {
        _historyState = _historyState.copyWith(messages: updatedMessages);
      }
    }

    // Update in chat rooms
    final updatedRooms = _roomsState.chatRooms.map((room) {
      if (room.lastMessage != null) {
        // Check if this is the last message in the room
        if ((room.lastMessage!.id == deliveredMessage.id) ||
            (room.lastMessage!.content == deliveredMessage.content &&
                room.lastMessage!.senderId == deliveredMessage.senderId &&
                room.lastMessage!.recipientId ==
                    deliveredMessage.recipientId)) {
          print(
              '✅ Updating last message status in room ${room.chatRoomId} to DELIVERED');
          chatRoomsUpdated = true;

          // Update the last message
          final updatedLastMessage = ChatMessage(
            id: room.lastMessage!.id,
            senderId: deliveredMessage.senderId,
            recipientId: deliveredMessage.recipientId,
            publicationId: deliveredMessage.publicationId,
            content: deliveredMessage.content,
            status: 'DELIVERED',
            sentAt: deliveredMessage.sentAt,
            updatedAt: DateTime.now(),
          );

          return room.copyWith(lastMessage: updatedLastMessage);
        }
      }
      return room;
    }).toList();

    if (chatRoomsUpdated) {
      _roomsState = _roomsState.copyWith(chatRooms: updatedRooms);
    }

    // Notify listeners if anything changed
    if (chatHistoryUpdated || chatRoomsUpdated) {
      notifyListeners();
    }
  }

  void _handleMessageStatusUpdate(List<String> viewedMessageIds) {
    if (viewedMessageIds.isEmpty) {
      print('📊 No message IDs to process');
      return;
    }

    print('🔍 Processing viewed status for messages: $viewedMessageIds');

    bool chatHistoryUpdated = false;
    bool chatRoomsUpdated = false;

    // 🧐 LAYER 1: Checking current chat history
    print('📱 LAYER 1: Checking chat history messages');
    print(
        '📱 Current chat history has ${_historyState.messages.length} messages');

    if (_historyState.messages.isNotEmpty) {
      // Print summary of current messages
      print('📱 Current messages statuses:');
      for (int i = 0; i < _historyState.messages.length; i++) {
        final msg = _historyState.messages[i];
        print(
            '📱 Message ${i + 1}: ID=${msg.id}, Status=${msg.status}, Sender=${msg.senderId}');
      }

      final updatedMessages = _historyState.messages.map((message) {
        if (viewedMessageIds.contains(message.id) &&
            message.status != 'VIEWED') {
          print('✅ FOUND message to update in history: ${message.id}');
          print('✅ Current status: ${message.status} -> Updating to: VIEWED');

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

        if (viewedMessageIds.contains(message.id)) {
          print(
              '⚠️ Message ${message.id} already has status: ${message.status}');
        }

        return message;
      }).toList();

      // Check if any messages were updated
      for (int i = 0; i < _historyState.messages.length; i++) {
        if (_historyState.messages[i].status != updatedMessages[i].status) {
          print(
              '🔄 Message at index $i was updated: ${_historyState.messages[i].status} -> ${updatedMessages[i].status}');
          chatHistoryUpdated = true;
        }
      }

      if (chatHistoryUpdated) {
        print('📝 Updating chat history state with new messages');
        _historyState = _historyState.copyWith(messages: updatedMessages);
      } else {
        print('⏩ No changes to chat history');
      }
    } else {
      print('📭 Chat history is empty, nothing to update');
    }

    // 🧐 LAYER 2: Checking chat rooms
    print('🏠 LAYER 2: Checking chat rooms');
    print('🏠 Current chat rooms count: ${_roomsState.chatRooms.length}');

    // First, log the current status of last messages in chat rooms
    for (final room in _roomsState.chatRooms) {
      if (room.lastMessage != null) {
        print(
            '🏠 Room ${room.chatRoomId}: LastMessageID=${room.lastMessage!.id}, Status=${room.lastMessage!.status}');
      }
    }

    // Update last message status in chat rooms
    final updatedRooms = _roomsState.chatRooms.map((room) {
      if (room.lastMessage != null &&
          viewedMessageIds.contains(room.lastMessage!.id) &&
          room.lastMessage!.status != 'VIEWED') {
        print('✅ FOUND room to update: ${room.chatRoomId}');
        print('✅ Last message ID: ${room.lastMessage!.id}');
        print(
            '✅ Current status: ${room.lastMessage!.status} -> Updating to: VIEWED');

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
        );
      }

      if (room.lastMessage != null &&
          viewedMessageIds.contains(room.lastMessage!.id)) {
        print(
            '⚠️ Room ${room.chatRoomId} last message already has status: ${room.lastMessage!.status}');
      }

      return room;
    }).toList();

    // Check if any rooms were updated
    for (int i = 0; i < _roomsState.chatRooms.length; i++) {
      final oldStatus = _roomsState.chatRooms[i].lastMessage?.status;
      final newStatus = updatedRooms[i].lastMessage?.status;

      if (oldStatus != newStatus) {
        print('🔄 Room at index $i was updated: $oldStatus -> $newStatus');
        chatRoomsUpdated = true;
      }
    }

    if (chatRoomsUpdated) {
      print('📝 Updating chat rooms state with new rooms');
      _roomsState = _roomsState.copyWith(chatRooms: updatedRooms);
    } else {
      print('⏩ No changes to chat rooms');
    }

    // 🧐 LAYER 3: Notifying UI
    if (chatHistoryUpdated || chatRoomsUpdated) {
      print('🔔 Changes detected, notifying listeners');
      notifyListeners();
    } else {
      print(
          '⏩ No changes detected, but notifying listeners anyway to ensure UI updates');
      notifyListeners();
    }

    // 🧐 LAYER 4: Final verification
    print('✓ Status update processing complete');
    print('✓ ChatHistoryUpdated: $chatHistoryUpdated');
    print('✓ ChatRoomsUpdated: $chatRoomsUpdated');
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
      // The message already has an ID from the UI layer
      print('📤 Sending message with ID: ${message.id}');
      final updatedMessages = List<ChatMessage>.from(_historyState.messages)
        ..add(message);
      _historyState = _historyState.copyWith(messages: updatedMessages);

      // Update chat room list state with the new last message
      _updateChatRoomWithLastMessage(message);

      notifyListeners();
      await sendMessageUseCase.execute(message);
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
      return message.senderId != _currentUserId && // Not sent by current user
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
        if (messageIds.contains(message.id)) {
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
    _messageDeliveredSubscription?.cancel();
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
          if (messageIds.contains(message.id)) {
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
