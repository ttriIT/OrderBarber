import '../../core/api/api_client.dart';
import '../models/message_model.dart';

class ChatService {
  final ApiClient _client;

  ChatService({ApiClient? client}) : _client = client ?? apiClient;

  /// Get messages between two users
  Future<List<MessageModel>> getMessages(String userId1, String userId2) async {
    try {
      final response = await _client.get('/chat/messages', queryParameters: {
        'userId1': userId1,
        'userId2': userId2,
      });
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => MessageModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Send a message
  Future<MessageModel> sendMessage({
    required String senderId,
    required String senderName,
    required String receiverId,
    required String content,
  }) async {
    try {
      final response = await _client.post('/chat/send', data: {
        'senderId': senderId,
        'senderName': senderName,
        'receiverId': receiverId,
        'content': content,
      });
      return MessageModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get all conversations for a user
  Future<List<ConversationModel>> getConversations(String userId) async {
    try {
      final response = await _client.get('/chat/conversations', queryParameters: {'userId': userId});
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ConversationModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Mark messages as read
  Future<void> markAsRead(String senderId, String receiverId) async {
    try {
      await _client.post('/chat/read', data: {
        'senderId': senderId,
        'receiverId': receiverId,
      });
    } catch (e) {
      // Ignore errors
    }
  }
}
