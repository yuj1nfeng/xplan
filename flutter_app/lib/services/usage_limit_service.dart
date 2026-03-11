import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 使用限制服务 - 管理免费用户的使用额度
class UsageLimitService {
  static final UsageLimitService _instance = UsageLimitService._internal();
  factory UsageLimitService() => _instance;
  UsageLimitService._internal();

  /// 免费用户每日生成次数限制
  static const int freeDailyLimit = 5;
  
  /// 免费用户单次字数限制
  static const int freeWordLimit = 300;
  
  /// 高级会员单次字数限制
  static const int premiumWordLimit = 5000;
  
  /// 企业版单次字数限制
  static const int enterpriseWordLimit = 10000;

  /// 获取今日已使用次数
  Future<int> getTodayUsage(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _getTodayKey();
      final key = 'usage_${userId}_$today';
      return prefs.getInt(key) ?? 0;
    } catch (e) {
      debugPrint('获取使用次数失败：$e');
      return 0;
    }
  }

  /// 增加使用次数
  Future<void> incrementUsage(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _getTodayKey();
      final key = 'usage_${userId}_$today';
      final current = prefs.getInt(key) ?? 0;
      await prefs.setInt(key, current + 1);
    } catch (e) {
      debugPrint('增加使用次数失败：$e');
    }
  }

  /// 检查是否可以生成
  Future<UsageCheckResult> canGenerate({
    required String userId,
    required bool isPremium,
    required int wordCount,
  }) async {
    // 检查字数限制
    final wordLimit = isPremium ? premiumWordLimit : freeWordLimit;
    if (wordCount > wordLimit) {
      return UsageCheckResult(
        canUse: false,
        reason: '字数超限',
        message: '免费用户单次最多$freeWordLimit字，升级高级会员可支持$premiumWordLimit字',
        requireUpgrade: true,
      );
    }

    // 免费用户检查次数限制
    if (!isPremium) {
      final todayUsage = await getTodayUsage(userId);
      if (todayUsage >= freeDailyLimit) {
        return UsageCheckResult(
          canUse: false,
          reason: '次数用尽',
          message: '免费用户每日仅限$freeDailyLimit次，升级高级会员无限次使用',
          requireUpgrade: true,
        );
      }
    }

    return UsageCheckResult(
      canUse: true,
      reason: null,
      message: null,
      requireUpgrade: false,
    );
  }

  /// 重置使用次数（用于测试）
  Future<void> resetUsage(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _getTodayKey();
      final key = 'usage_${userId}_$today';
      await prefs.remove(key);
    } catch (e) {
      debugPrint('重置使用次数失败：$e');
    }
  }

  /// 获取今日键值
  String _getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// 获取使用统计
  Future<UsageStats> getUsageStats(String userId, bool isPremium) async {
    final todayUsage = await getTodayUsage(userId);
    
    return UsageStats(
      todayUsage: todayUsage,
      dailyLimit: isPremium ? null : freeDailyLimit,
      wordLimit: isPremium ? premiumWordLimit : freeWordLimit,
      isPremium: isPremium,
    );
  }
}

/// 使用检查结果
class UsageCheckResult {
  final bool canUse;
  final String? reason;
  final String? message;
  final bool requireUpgrade;

  UsageCheckResult({
    required this.canUse,
    this.reason,
    this.message,
    this.requireUpgrade = false,
  });
}

/// 使用统计
class UsageStats {
  final int todayUsage;
  final int? dailyLimit;
  final int wordLimit;
  final bool isPremium;

  UsageStats({
    required this.todayUsage,
    this.dailyLimit,
    required this.wordLimit,
    required this.isPremium,
  });

  String get usageText {
    if (isPremium) {
      return '今日已使用 $todayUsage 次（无限次）';
    } else {
      return '今日已使用 $todayUsage/$dailyLimit 次';
    }
  }
}
