import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';

/// 消息历史服务 - 管理消息的本地存储和加载
class MessageHistoryService {
  static final MessageHistoryService _instance = MessageHistoryService._internal();
  factory MessageHistoryService() => _instance;
  MessageHistoryService._internal();

  /// 保存消息到指定会话
  Future<void> saveMessages(String conversationId, List<Message> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'messages_$conversationId';
      final jsonList = messages.map((m) => m.toJson()).toList();
      await prefs.setString(key, jsonEncode(jsonList));
      
      // 更新会话的消息计数
      await prefs.setInt('messages_count_$conversationId', messages.length);
      
      // 更新最后活跃时间
      await prefs.setString('messages_updated_$conversationId', DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('保存消息失败：$e');
    }
  }

  /// 从指定会话加载消息
  Future<List<Message>> loadMessages(String conversationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'messages_$conversationId';
      final jsonStr = prefs.getString(key);
      
      if (jsonStr != null) {
        final List<dynamic> jsonList = jsonDecode(jsonStr);
        return jsonList.map((json) => Message.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('加载消息失败：$e');
    }
    return [];
  }

  /// 添加单条消息
  Future<void> appendMessage(String conversationId, Message message) async {
    try {
      final messages = await loadMessages(conversationId);
      messages.add(message);
      await saveMessages(conversationId, messages);
    } catch (e) {
      debugPrint('添加消息失败：$e');
    }
  }

  /// 删除指定会话的所有消息
  Future<void> deleteMessages(String conversationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'messages_$conversationId';
      await prefs.remove(key);
      await prefs.remove('messages_count_$conversationId');
      await prefs.remove('messages_updated_$conversationId');
    } catch (e) {
      debugPrint('删除消息失败：$e');
    }
  }

  /// 获取所有有消息的会话 ID
  Future<List<String>> getConversationsWithMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      return keys
          .where((k) => k.startsWith('messages_') && !k.contains('_count') && !k.contains('_updated'))
          .map((k) => k.replaceFirst('messages_', ''))
          .toList();
    } catch (e) {
      debugPrint('获取会话列表失败：$e');
      return [];
    }
  }

  /// 清空所有消息缓存
  Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final messageKeys = keys.where((k) => k.startsWith('messages_'));
      
      for (final key in messageKeys) {
        await prefs.remove(key);
      }
    } catch (e) {
      debugPrint('清空缓存失败：$e');
    }
  }

  /// 获取会话的消息数量
  Future<int> getMessageCount(String conversationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('messages_count_$conversationId') ?? 0;
    } catch (e) {
      debugPrint('获取消息数量失败：$e');
      return 0;
    }
  }

  /// 获取会话的最后更新时间
  Future<DateTime?> getLastUpdatedTime(String conversationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeStr = prefs.getString('messages_updated_$conversationId');
      if (timeStr != null) {
        return DateTime.parse(timeStr);
      }
    } catch (e) {
      debugPrint('获取更新时间失败：$e');
    }
    return null;
  }
}
