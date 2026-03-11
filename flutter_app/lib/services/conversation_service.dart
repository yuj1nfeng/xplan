import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/conversation.dart';

/// 会话服务 - 管理会话列表（本地存储）
/// OpenAI 兼容 API 不需要服务端会话管理，会话完全在本地管理
class ConversationService {
  static final ConversationService _instance = ConversationService._internal();
  factory ConversationService() => _instance;
  ConversationService._internal();

  static const String _localKey = 'conversations';

  /// 获取会话列表（从本地加载）
  Future<List<Conversation>> getConversations() async {
    return _loadFromLocal();
  }

  /// 创建新会话
  Future<Conversation?> createConversation() async {
    final conversation = Conversation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '新对话',
      createdAt: DateTime.now(),
    );

    // 添加到本地列表
    final list = await _loadFromLocal();
    list.insert(0, conversation);
    await _saveToLocal(list);

    return conversation;
  }

  /// 删除会话
  Future<bool> deleteConversation(String conversationId) async {
    final list = await _loadFromLocal();
    list.removeWhere((c) => c.id == conversationId);
    await _saveToLocal(list);
    return true;
  }

  /// 更新会话标题
  Future<bool> updateConversationTitle(String conversationId, String title) async {
    final list = await _loadFromLocal();
    final index = list.indexWhere((c) => c.id == conversationId);
    if (index != -1) {
      list[index] = list[index].copyWith(title: title);
      await _saveToLocal(list);
      return true;
    }
    return false;
  }

  /// 从本地加载
  Future<List<Conversation>> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_localKey);
      if (jsonStr != null) {
        final List<dynamic> jsonList = jsonDecode(jsonStr);
        return jsonList.map((json) => Conversation.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('从本地加载会话失败：$e');
    }
    return [];
  }

  /// 保存到本地
  Future<void> _saveToLocal(List<Conversation> conversations) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = conversations.map((c) => c.toJson()).toList();
      await prefs.setString(_localKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('保存会话到本地失败：$e');
    }
  }

  /// 清空本地缓存
  Future<void> clearLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_localKey);
    } catch (e) {
      debugPrint('清空缓存失败：$e');
    }
  }
}