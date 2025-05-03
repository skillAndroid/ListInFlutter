// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:collection';

import 'package:connectivity_plus/connectivity_plus.dart';
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

class ChatProvider extends ChangeNotifier with WidgetsBindingObserver {
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

  // Auto-reconnection fields
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isReconnecting = false;
  Timer? _reconnectionTimer;

  // Repository connection monitoring
  StreamSubscription<bool>? _repositoryConnectionSubscription;
  bool _repositoryIsConnected = false;

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
  }) {
    // Register lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    // Initialize connectivity listener
    _initializeConnectivityListener();

    // Monitor repository connection status
    _initializeRepositoryMonitoring();
  }

  // Initialize connectivity monitoring
  void _initializeConnectivityListener() {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((results) {
      _handleConnectivityChange(results);
    });
  }

  // Initialize repository connection monitoring
  void _initializeRepositoryMonitoring() {
    // If you have access to repository connection status, uncomment this:
    // _repositoryConnectionSubscription = getChatRoomsUseCase.repository.connectionStatusStream.listen(
    //   (isConnected) {
    //     _repositoryIsConnected = isConnected;
    //
    //     if (!isConnected) {
    //       print('Repository connection lost, attempting reconnection...');
    //       _handleRepositoryDisconnection();
    //     } else {
    //       print('Repository connection restored');
    //     }
    //   },
    // );
  }

  // Handle connectivity changes
  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final hasConnection = results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet ||
        result == ConnectivityResult.vpn);

    if (hasConnection && _isInitialized && !_isReconnecting) {
      print('🌐 Internet connection restored, attempting to reconnect...');
      _attemptReconnection();
    }
  }

  // Handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        print('📱 App resumed from background');
        if (_isInitialized && !_isReconnecting) {
          _attemptReconnection();
        }
        break;
      case AppLifecycleState.paused:
        print('📱 App going to background');
        // Optionally disconnect or mark user as away
        if (_currentUserId != null) {
          connectUserUseCase
              .execute(UserConnectionInfo(
                email: _currentUserId!,
                nickName: '',
                status: UserStatus.OFFLINE,
              ))
              .catchError((e) => print('Error setting away status: $e'));
        }
        break;
      case AppLifecycleState.detached:
        print('📱 App detached');
        _cleanupConnections();
        break;
      default:
        break;
    }
  }

  // Attempt to reconnect
  Future<void> _attemptReconnection() async {
    if (_isReconnecting || _currentUserId == null) return;

    _isReconnecting = true;
    print('🔄 Attempting to reconnect...');

    try {
      // 1. Unsubscribe from all streams
      _unsubscribeFromStreams();

      // 2. Mark the chat as not initialized
      _isInitialized = false;

      // 3. Wait a short delay for connection to stabilize
      await Future.delayed(Duration(seconds: 2));

      // 4. Re-initialize chat
      await initializeChat(_currentUserId!);

      // 5. Reload chat rooms
      await loadChatRooms(_currentUserId!);

      // 6. If we were in a specific chat, reload its history
      if (_currentPublicationId != null && _currentChatRecipientId != null) {
        await loadChatHistory(
          publicationId: _currentPublicationId!,
          senderId: _currentUserId!,
          recipientId: _currentChatRecipientId!,
        );
      }

      print('✅ Successfully reconnected');
    } catch (e) {
      print('❌ Reconnection failed: $e');
      _scheduleReconnectionRetry();
    } finally {
      _isReconnecting = false;
    }
  }

  // Schedule a reconnection retry with exponential backoff
  void _scheduleReconnectionRetry() {
    _reconnectionTimer?.cancel();

    // Exponential backoff: start with 5 seconds, max 60 seconds
    final delay = Duration(seconds: 5);

    print('⏱️ Scheduling reconnection retry in ${delay.inSeconds} seconds');

    _reconnectionTimer = Timer(delay, () {
      if (_currentUserId != null && !_isReconnecting) {
        _attemptReconnection();
      }
    });
  }

  // Add method to manually trigger reconnection
  Future<void> forceReconnect() async {
    if (_currentUserId != null) {
      _attemptReconnection();
    }
  }

  // Initialize chat system with current user ID
  Future<void> initializeChat(String userId) async {
    if (_isInitialized && _currentUserId == userId && !_isReconnecting) {
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

      // Clear any scheduled reconnection
      _reconnectionTimer?.cancel();
    } catch (e) {
      print('Failed to initialize chat: $e');
      _isInitialized = false;

      // Try to reconnect after a delay
      _scheduleReconnectionRetry();
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
        _scheduleReconnectionRetry();
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
        _scheduleReconnectionRetry();
      },
    );

    // 3. Subscribe to message read status updates
    _messageStatusSubscription = getMessageStatusStreamUseCase.execute().listen(
      (viewedMessageIds) {
        _handleMessageViewedStatus(viewedMessageIds);
      },
      onError: (error) {
        print('❌ Message status stream error: $error');
        _scheduleReconnectionRetry();
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
        _scheduleReconnectionRetry();
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
      // Check if history was empty before sending
      final bool wasHistoryEmpty = _historyState.messages.isEmpty;

      final optimisticMessage = message.copyWith(status: 'SENDING');
      final updatedMessages = List<ChatMessage>.from(_historyState.messages)
        ..add(optimisticMessage);

      _historyState = _historyState.copyWith(messages: updatedMessages);

      _updateChatRoomWithLastMessage(optimisticMessage);

      notifyListeners();

      await sendMessageUseCase.execute(message);

      final sentMessage = optimisticMessage.copyWith(status: 'SENT');
      _updateMessageStatus(sentMessage);

      // If history was empty before sending, reload rooms when message is delivered
      if (wasHistoryEmpty) {
        _waitForDeliveryAndReloadRooms(sentMessage.id, message.senderId);
      }
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

  // Helper method to wait for delivery and reload rooms
  void _waitForDeliveryAndReloadRooms(String messageId, String userId) {
    // Store current delivery subscription if needed
    StreamSubscription<ChatMessage>? deliverySubscription;

    deliverySubscription = getMessageDeliveredStreamUseCase.execute().listen(
      (deliveredMessage) {
        if (deliveredMessage.id == messageId) {
          print('📫 Message delivered, reloading rooms...');
          loadChatRooms(userId);
          deliverySubscription?.cancel();
        }
      },
      onError: (error) {
        print('❌ Delivery tracking error: $error');
        deliverySubscription?.cancel();
      },
    );

    // Cancel after 30 seconds if not delivered
    Future.delayed(Duration(seconds: 30), () {
      deliverySubscription?.cancel();
    });
  }

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

  // Enhanced cleanup method
  void _cleanupConnections() {
    if (_currentUserId != null) {
      // Mark user as offline before cleaning up
      disconnectUserUseCase
          .execute(UserConnectionInfo(
            email: _currentUserId!,
            nickName: '',
            status: UserStatus.OFFLINE,
          ))
          .catchError((e) => print('Error setting offline status: $e'));
    }

    _unsubscribeFromStreams();
    _isInitialized = false;
  }

  @override
  void dispose() {
    // Clean up everything
    _cleanupConnections();
    _connectivitySubscription.cancel();
    _reconnectionTimer?.cancel();
    _repositoryConnectionSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
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
