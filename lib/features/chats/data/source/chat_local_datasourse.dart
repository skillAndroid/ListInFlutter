// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:list_in/features/chats/data/model/chat_message_model.dart';
import 'package:list_in/features/chats/data/model/chat_room_model.dart';
import 'package:list_in/features/chats/domain/entity/user_status.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatLocalDataSource {
  final SharedPreferences sharedPreferences;

  ChatLocalDataSource({required this.sharedPreferences});

  static const String _chatRoomsKey = 'chat_rooms_';
  static const String _chatMessagesKey = 'chat_messages_';
  static const String _userStatusKey = 'user_status_';
  static const String _lastReadMessageKey = 'last_read_message_';
  static const String _unreadCountKey = 'unread_count_';

  Future<bool> saveChatRooms(
      String userId, List<ChatRoomModel> chatRooms) async {
    try {
      final List<Map<String, dynamic>> jsonList = chatRooms
          .map((room) => {
                'chatRoomId': room.chatRoomId,
                'publicationId': room.publicationId,
                'publicationImagePath': room.publicationImagePath,
                'publicationTitle': room.publicationTitle,
                'publicationPrice': room.publicationPrice,
                'recipientId': room.recipientId,
                'recipientImagePath': room.recipientImagePath,
                'recipientNickname': room.recipientNickname,
                'lastMessage': room.lastMessage != null
                    ? (room.lastMessage as ChatMessageModel).toJson()
                    : null,
              })
          .toList();

      final String jsonString = jsonEncode(jsonList);
      final result = await sharedPreferences.setString(
          '$_chatRoomsKey$userId', jsonString);
      print('Saved ${chatRooms.length} chat rooms locally for user $userId');
      return result;
    } catch (e) {
      print('Error saving chat rooms locally: $e');
      return false;
    }
  }

  Future<List<ChatRoomModel>> getChatRooms(String userId) async {
    try {
      final String? jsonString =
          sharedPreferences.getString('$_chatRoomsKey$userId');
      if (jsonString == null) {
        print('No chat rooms found locally for user $userId');
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      final rooms =
          jsonList.map((json) => ChatRoomModel.fromJson(json)).toList();
      print('Retrieved ${rooms.length} chat rooms locally for user $userId');
      return rooms;
    } catch (e) {
      print('Error getting chat rooms locally: $e');
      return [];
    }
  }

  Future<bool> saveChatMessages(
    String publicationId,
    String senderId,
    String recipientId,
    List<ChatMessageModel> messages,
  ) async {
    try {
      final String key =
          _getChatMessagesKey(publicationId, senderId, recipientId);
      final List<Map<String, dynamic>> jsonList =
          messages.map((msg) => msg.toJson()).toList();
      final String jsonString = jsonEncode(jsonList);
      final result = await sharedPreferences.setString(key, jsonString);
      print('Saved ${messages.length} messages locally for conversation $key');
      return result;
    } catch (e) {
      print('Error saving chat messages locally: $e');
      return false;
    }
  }

  // Get chat messages for a specific conversation with null safety
  Future<List<ChatMessageModel>> getChatMessages(
    String publicationId,
    String senderId,
    String recipientId,
  ) async {
    try {
      // Ensure none of the parameters are null
      if (publicationId.isEmpty || senderId.isEmpty || recipientId.isEmpty) {
        print(
            'Invalid parameters for getChatMessages: publicationId=$publicationId, senderId=$senderId, recipientId=$recipientId');
        return [];
      }

      final String key =
          _getChatMessagesKey(publicationId, senderId, recipientId);
      final String? jsonString = sharedPreferences.getString(key);

      if (jsonString == null || jsonString.isEmpty) {
        print('No chat messages found locally for conversation $key');
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      final messages = jsonList.map((json) {
        try {
          return ChatMessageModel.fromJson(json);
        } catch (e) {
          print('Error parsing message: $e');
          // Return a placeholder message if parsing fails
          return ChatMessageModel(
            id: 'error_parsing',
            senderId: senderId,
            recipientId: recipientId,
            publicationId: publicationId,
            content: 'Error loading message',
            status: 'ERROR',
            sentAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }
      }).toList();

      print(
          'Retrieved ${messages.length} messages locally for conversation $key');
      return messages;
    } catch (e) {
      print('Error getting chat messages locally: $e');
      return [];
    }
  }

  // Helper method to generate a consistent key for chat messages - with null safety
  String _getChatMessagesKey(
      String publicationId, String senderId, String recipientId) {
    // Ensure none of the parameters are null
    publicationId = publicationId.isEmpty ? 'empty_pub_id' : publicationId;
    senderId = senderId.isEmpty ? 'empty_sender_id' : senderId;
    recipientId = recipientId.isEmpty ? 'empty_recipient_id' : recipientId;

    // Sort IDs to ensure the same key regardless of sender/recipient order
    final List<String> sortedIds = [senderId, recipientId]..sort();
    return '$_chatMessagesKey${publicationId}_${sortedIds[0]}_${sortedIds[1]}';
  }

  // Save a single chat message (for adding new messages without fetching the entire history)
  Future<bool> saveChatMessage(ChatMessageModel message) async {
    try {
      final String key = _getChatMessagesKey(
          message.publicationId, message.senderId, message.recipientId);

      // Get existing messages
      List<ChatMessageModel> existingMessages = await getChatMessages(
          message.publicationId, message.senderId, message.recipientId);

      // Add the new message
      existingMessages.add(message);

      // Save the updated list
      return await saveChatMessages(message.publicationId, message.senderId,
          message.recipientId, existingMessages);
    } catch (e) {
      print('Error saving chat message locally: $e');
      return false;
    }
  }

  // Save user status
  Future<bool> saveUserStatus(String userId, UserStatus status) async {
    try {
      final result = await sharedPreferences.setString(
          '$_userStatusKey$userId', status.toString());
      return result;
    } catch (e) {
      print('Error saving user status locally: $e');
      return false;
    }
  }

  // Get user status
  Future<UserStatus?> getUserStatus(String userId) async {
    try {
      final String? status =
          sharedPreferences.getString('$_userStatusKey$userId');
      if (status == null) {
        print('No user status found locally for user $userId');
        return null;
      }

      return status == UserStatus.ONLINE.toString()
          ? UserStatus.ONLINE
          : UserStatus.OFFLINE;
    } catch (e) {
      print('Error getting user status locally: $e');
      return null;
    }
  }

  // Clear all chat data for a user
  Future<bool> clearUserChatData(String userId) async {
    try {
      // Get all keys
      final keys = sharedPreferences.getKeys();

      // Filter keys related to this user
      final userKeys = keys
          .where((key) =>
              key.startsWith('$_chatRoomsKey$userId') ||
              key.startsWith('$_userStatusKey$userId') ||
              key.contains(userId))
          .toList();

      // Remove each key
      for (final key in userKeys) {
        await sharedPreferences.remove(key);
      }

      print('Cleared all chat data for user $userId');
      return true;
    } catch (e) {
      print('Error clearing user chat data: $e');
      return false;
    }
  }

  // New methods for handling unread messages

  // Save the ID of the last read message in a conversation
  Future<bool> saveLastReadMessageId(
    String publicationId,
    String userId,
    String recipientId,
    String messageId,
  ) async {
    try {
      final String key =
          _getLastReadMessageKey(publicationId, userId, recipientId);
      final result = await sharedPreferences.setString(key, messageId);
      print('Saved last read message ID ($messageId) for conversation $key');
      return result;
    } catch (e) {
      print('Error saving last read message ID: $e');
      return false;
    }
  }

  // Get the ID of the last read message in a conversation
  Future<String?> getLastReadMessageId(
    String publicationId,
    String userId,
    String recipientId,
  ) async {
    try {
      final String key =
          _getLastReadMessageKey(publicationId, userId, recipientId);
      final String? messageId = sharedPreferences.getString(key);
      print(
          'Retrieved last read message ID ($messageId) for conversation $key');
      return messageId;
    } catch (e) {
      print('Error getting last read message ID: $e');
      return null;
    }
  }

  // Increment the unread count for a conversation
  Future<bool> incrementUnreadCount(
    String publicationId,
    String userId,
    String recipientId,
  ) async {
    try {
      final String key = _getUnreadCountKey(publicationId, userId, recipientId);
      final int currentCount = sharedPreferences.getInt(key) ?? 0;
      final result = await sharedPreferences.setInt(key, currentCount + 1);
      print(
          'Incremented unread count to ${currentCount + 1} for conversation $key');
      return result;
    } catch (e) {
      print('Error incrementing unread count: $e');
      return false;
    }
  }

  // Reset the unread count for a conversation
  Future<bool> resetUnreadCount(
    String publicationId,
    String userId,
    String recipientId,
  ) async {
    try {
      final String key = _getUnreadCountKey(publicationId, userId, recipientId);
      final result = await sharedPreferences.setInt(key, 0);
      print('Reset unread count to 0 for conversation $key');
      return result;
    } catch (e) {
      print('Error resetting unread count: $e');
      return false;
    }
  }

  // Get the unread count for a conversation
  Future<int> getUnreadCount(
    String publicationId,
    String userId,
    String recipientId,
  ) async {
    try {
      final String key = _getUnreadCountKey(publicationId, userId, recipientId);
      final int count = sharedPreferences.getInt(key) ?? 0;
      return count;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  // Helper methods for generating consistent keys
  String _getLastReadMessageKey(
    String publicationId,
    String userId,
    String recipientId,
  ) {
    final List<String> sortedIds = [userId, recipientId]..sort();
    return '$_lastReadMessageKey${publicationId}_${sortedIds[0]}_${sortedIds[1]}';
  }

  String _getUnreadCountKey(
    String publicationId,
    String userId,
    String recipientId,
  ) {
    final List<String> sortedIds = [userId, recipientId]..sort();
    return '$_unreadCountKey${publicationId}_${sortedIds[0]}_${sortedIds[1]}';
  }
}
