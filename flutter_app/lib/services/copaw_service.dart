import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class CopawService {
  // COPAW 本地服务地址
  static const String baseUrl = 'http://localhost:18789';
  
  final http.Client _client = http.Client();

  // 健康检查
  Future<bool> healthCheck() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/health'),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      print('健康检查失败：$e');
      return false;
    }
  }

  // 发送消息
  Future<Message> sendMessage(String message, {String? conversationId}) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': message,
          if (conversationId != null) 'conversation_id': conversationId,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Message.fromJson({
          'role': 'assistant',
          'content': data['message'] ?? data['content'] ?? data['reply'] ?? '收到消息',
        });
      } else {
        throw Exception('请求失败：${response.statusCode}');
      }
    } catch (e) {
      print('发送消息失败：$e');
      rethrow;
    }
  }

  // 获取会话列表
  Future<List<dynamic>> getConversations() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/conversations'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('获取会话列表失败：$e');
      return [];
    }
  }

  // 创建新会话
  Future<String> createConversation() async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/conversations'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['id'] ?? data['conversation_id'] ?? '';
      }
      return '';
    } catch (e) {
      print('创建会话失败：$e');
      return '';
    }
  }

  // 获取会话历史
  Future<List<Message>> getConversationHistory(String conversationId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/conversations/$conversationId/messages'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Message.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('获取历史消息失败：$e');
      return [];
    }
  }

  void dispose() {
    _client.close();
  }
}
