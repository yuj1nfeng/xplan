import 'package:flutter/material.dart';
import '../models/settings.dart';
import '../services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();

  AppSettings _settings = AppSettings();
  bool _isLoading = true;
  String _appVersion = '';

  AppSettings get settings => _settings;
  String get themeMode => _settings.themeMode;
  String get apiBaseUrl => _settings.apiBaseUrl;
  bool get testMode => _settings.testMode;
  String? get userId => _settings.userId;
  bool get isPremium => _settings.isPremium;
  DateTime? get premiumExpiresAt => _settings.premiumExpiresAt;
  bool get isLoading => _isLoading;
  String get appVersion => _appVersion;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _settings = await _settingsService.loadSettings();
      _appVersion = await _settingsService.getAppVersion();
    } catch (e) {
      debugPrint('加载设置失败：$e');
      _settings = AppSettings();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(String mode) async {
    try {
      await _settingsService.updateThemeMode(mode);
      _settings = _settings.copyWith(themeMode: mode);
      notifyListeners();
    } catch (e) {
      debugPrint('设置主题失败：$e');
      rethrow;
    }
  }

  Future<void> setApiBaseUrl(String url) async {
    try {
      await _settingsService.updateApiBaseUrl(url);
      _settings = _settings.copyWith(apiBaseUrl: url);
      notifyListeners();
    } catch (e) {
      debugPrint('设置 API 地址失败：$e');
      rethrow;
    }
  }

  Future<void> setTestMode(bool enabled) async {
    try {
      await _settingsService.updateTestMode(enabled);
      _settings = _settings.copyWith(testMode: enabled);
      notifyListeners();
    } catch (e) {
      debugPrint('设置测试模式失败：$e');
      rethrow;
    }
  }

  Future<void> setUser({String? userId, bool? isPremium, DateTime? expiresAt}) async {
    try {
      await _settingsService.updateUser(
        userId: userId,
        isPremium: isPremium,
        expiresAt: expiresAt,
      );
      _settings = _settings.copyWith(
        userId: userId ?? _settings.userId,
        isPremium: isPremium ?? _settings.isPremium,
        premiumExpiresAt: expiresAt ?? _settings.premiumExpiresAt,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('设置用户信息失败：$e');
      rethrow;
    }
  }

  Future<void> reloadSettings() async {
    await _loadSettings();
  }
}
