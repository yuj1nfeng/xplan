import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isPremium => _currentUser?.isValidPremium ?? false;
  bool get isInitialized => _isInitialized;

  AuthProvider() {
    _initialize();
  }

  /// 初始化 - 加载已登录用户
  Future<void> _initialize() async {
    if (_isInitialized) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.getCurrentUser();
    } catch (e) {
      _error = '加载用户信息失败：$e';
      debugPrint(_error!);
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// 登录
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.login(
        email: email,
        password: password,
      );

      if (result.success && result.user != null) {
        _currentUser = result.user;
        notifyListeners();
        return true;
      } else {
        _error = result.message;
        return false;
      }
    } catch (e) {
      _error = '登录失败：$e';
      debugPrint(_error!);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 注册
  Future<bool> register({
    required String email,
    required String password,
    String? username,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.register(
        email: email,
        password: password,
        username: username,
      );

      if (result.success && result.user != null) {
        _currentUser = result.user;
        notifyListeners();
        return true;
      } else {
        _error = result.message;
        return false;
      }
    } catch (e) {
      _error = '注册失败：$e';
      debugPrint(_error!);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 登出
  Future<void> logout() async {
    try {
      await _authService.logout();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _error = '登出失败：$e';
      debugPrint(_error!);
    }
  }

  /// 刷新用户信息
  Future<void> refreshUser() async {
    try {
      _currentUser = await _authService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      _error = '刷新用户信息失败：$e';
      debugPrint(_error!);
    }
  }

  /// 更新用户会员状态
  void updatePremiumStatus({required bool isPremium, DateTime? expiresAt}) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        isPremium: isPremium,
        premiumExpiresAt: expiresAt,
      );
      notifyListeners();
    }
  }

  /// 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
