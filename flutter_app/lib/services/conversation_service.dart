import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/conversation.dart';
import 'copaw_service.dart';

/// 会话服务 - 管理会话列表和本地存储
class ConversationService {
  static final ConversationService _instance = ConversationService._internal();
  factory ConversationService() => _instance;
  ConversationService._internal();

  final CopawService _copawService = CopawService();

  static const String _localKey = 'conversations';

  /// 获取会话列表（优先从 API，失败则从本地）
  Future<List<Conversation>> getConversations() async {
    try {
      // 尝试从 API 获取
      final list = await _copawService.getConversations();
      final conversations = list
          .map((json) => Conversation.fromJson(json))
          .toList();
      
      // 保存到本地缓存
      await _saveToLocal(conversations);
      return conversations;
    } catch (e) {
      debugPrint('从 API 获取会话失败：$e');
      // 从本地加载
      return _loadFromLocal();
    }
  }

  /// 创建新会话
  Future<Conversation?> createConversation() async {
    try {
      final conversationId = await _copawService.createConversation();
      if (conversationId.isNotEmpty) {
        final conversation = Conversation(
          id: conversationId,
          title: '新对话',
          createdAt: DateTime.now(),
        );
        
        // 添加到本地列表
        final list = await _loadFromLocal();
        list.insert(0, conversation);
        await _saveToLocal(list);
        
        return conversation;
      }
    } catch (e) {
      debugPrint('创建会话失败：$e');
    }
    return null;
  }

  /// 删除会话
  Future<bool> deleteConversation(String conversationId) async {
    try {
      // TODO: 调用 API 删除
      // await _copawService.deleteConversation(conversationId);
      
      // 从本地删除
      final list = await _loadFromLocal();
      list.removeWhere((c) => c.id == conversationId);
      await _saveToLocal(list);
      
      return true;
    } catch (e) {
      debugPrint('删除会话失败：$e');
      return false;
    }
  }

  /// 更新会话标题
  Future<bool> updateConversationTitle(String conversationId, String title) async {
    try {
      // TODO: 调用 API 更新
      // await _copawService.updateConversation(conversationId, title: title);
      
      // 更新本地
      final list = await _loadFromLocal();
      final index = list.indexWhere((c) => c.id == conversationId);
      if (index != -1) {
        list[index] = list[index].copyWith(title: title);
        await _saveToLocal(list);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('更新会话失败：$e');
      return false;
    }
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
