import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings.dart';

/// 设置服务 - 管理应用设置的持久化
class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  static const String _settingsKey = 'app_settings';

  /// 加载设置
  Future<AppSettings> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_settingsKey);
      if (jsonStr != null) {
        final json = jsonDecode(jsonStr);
        return AppSettings.fromJson(json);
      }
    } catch (e) {
      debugPrint('加载设置失败：$e');
    }
    return AppSettings();
  }

  /// 保存设置
  Future<void> saveSettings(AppSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = settings.toJson();
      await prefs.setString(_settingsKey, jsonEncode(json));
    } catch (e) {
      debugPrint('保存设置失败：$e');
      rethrow;
    }
  }

  /// 更新 API 地址
  Future<void> updateApiBaseUrl(String url) async {
    final settings = await loadSettings();
    await saveSettings(settings.copyWith(apiBaseUrl: url));
  }

  /// 更新主题模式
  Future<void> updateThemeMode(String mode) async {
    final settings = await loadSettings();
    await saveSettings(settings.copyWith(themeMode: mode));
  }

  /// 更新测试模式
  Future<void> updateTestMode(bool enabled) async {
    final settings = await loadSettings();
    await saveSettings(settings.copyWith(testMode: enabled));
  }

  /// 更新用户信息
  Future<void> updateUser({String? userId, bool? isPremium, DateTime? expiresAt}) async {
    final settings = await loadSettings();
    await saveSettings(settings.copyWith(
      userId: userId ?? settings.userId,
      isPremium: isPremium ?? settings.isPremium,
      premiumExpiresAt: expiresAt ?? settings.premiumExpiresAt,
    ));
  }

  /// 重置设置
  Future<void> resetSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_settingsKey);
    } catch (e) {
      debugPrint('重置设置失败：$e');
    }
  }

  /// 获取应用版本
  Future<String> getAppVersion() async {
    // 在实际项目中，可以使用 package_info_plus 包获取
    return '1.0.1';
  }
}
