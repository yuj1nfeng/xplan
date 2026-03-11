import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

/// 用户认证服务 - 管理用户登录状态
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _userKey = 'current_user';
  static const String _tokenKey = 'auth_token';

  /// 获取当前登录用户
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_userKey);
      if (jsonStr != null) {
        final json = jsonDecode(jsonStr);
        return User.fromJson(json);
      }
    } catch (e) {
      debugPrint('获取当前用户失败：$e');
    }
    return null;
  }

  /// 保存用户登录信息
  Future<void> saveUser(User user, {String? token}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      if (token != null) {
        await prefs.setString(_tokenKey, token);
      }
    } catch (e) {
      debugPrint('保存用户信息失败：$e');
      rethrow;
    }
  }

  /// 更新用户信息
  Future<void> updateUser(User user) async {
    await saveUser(user);
  }

  /// 获取认证 Token
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      debugPrint('获取 Token 失败：$e');
      return null;
    }
  }

  /// 清除登录信息（登出）
  Future<void> clearUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_tokenKey);
    } catch (e) {
      debugPrint('清除用户信息失败：$e');
    }
  }

  /// 检查是否已登录
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  /// 模拟登录（实际项目中需要调用后端 API）
  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    try {
      // TODO: 调用后端登录 API
      // final response = await http.post(
      //   Uri.parse('$_baseUrl/api/auth/login'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({'email': email, 'password': password}),
      // );

      // 模拟登录成功
      await Future.delayed(const Duration(seconds: 1));

      final user = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        username: email.split('@').first,
        email: email,
        isPremium: false,
        createdAt: DateTime.now(),
      );

      await saveUser(user, token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}');

      return LoginResult(
        success: true,
        user: user,
        message: '登录成功',
      );
    } catch (e) {
      return LoginResult(
        success: false,
        message: '登录失败：$e',
      );
    }
  }

  /// 模拟注册（实际项目中需要调用后端 API）
  Future<LoginResult> register({
    required String email,
    required String password,
    String? username,
  }) async {
    try {
      // TODO: 调用后端注册 API
      // final response = await http.post(
      //   Uri.parse('$_baseUrl/api/auth/register'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({'email': email, 'password': password, 'username': username}),
      // );

      // 模拟注册成功
      await Future.delayed(const Duration(seconds: 1));

      final user = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        username: username ?? email.split('@').first,
        email: email,
        isPremium: false,
        createdAt: DateTime.now(),
      );

      await saveUser(user, token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}');

      return LoginResult(
        success: true,
        user: user,
        message: '注册成功',
      );
    } catch (e) {
      return LoginResult(
        success: false,
        message: '注册失败：$e',
      );
    }
  }

  /// 登出
  Future<void> logout() async {
    await clearUser();
  }
}

/// 登录结果
class LoginResult {
  final bool success;
  final User? user;
  final String? message;

  LoginResult({
    required this.success,
    this.user,
    this.message,
  });
}
