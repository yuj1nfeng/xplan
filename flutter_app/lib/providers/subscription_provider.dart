import 'package:flutter/material.dart';
import '../services/wechat_pay_service.dart';

/// 订阅管理 Provider
class SubscriptionProvider extends ChangeNotifier {
  final WeChatPayService _payService = WeChatPayService();

  SubscriptionStatus _subscriptionStatus = SubscriptionStatus(
    isPremium: false,
    expiresAt: null,
    planId: null,
  );
  
  bool _isLoading = false;
  String? _errorMessage;

  SubscriptionStatus get subscriptionStatus => _subscriptionStatus;
  bool get isPremium => _subscriptionStatus.isActive;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 初始化
  Future<void> init(String userId) async {
    await checkSubscriptionStatus(userId);
  }

  /// 检查订阅状态
  Future<void> checkSubscriptionStatus(String userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _subscriptionStatus = await _payService.checkSubscriptionStatus(userId);
    } catch (e) {
      _errorMessage = '检查订阅状态失败：$e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 购买订阅
  Future<bool> purchaseSubscription({
    required String planId,
    required String userId,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // 生成订单 ID
      final orderId = 'ORDER_${DateTime.now().millisecondsSinceEpoch}';

      // 发起支付
      final result = await _payService.pay(
        planId: planId,
        userId: userId,
        orderId: orderId,
      );

      if (result.success) {
        // 支付成功，刷新订阅状态
        await checkSubscriptionStatus(userId);
        return true;
      } else {
        _errorMessage = result.message;
        return false;
      }
    } catch (e) {
      _errorMessage = '购买失败：$e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 恢复购买
  Future<void> restorePurchase(String userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _payService.restorePurchase(userId);
      await checkSubscriptionStatus(userId);
    } catch (e) {
      _errorMessage = '恢复购买失败：$e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
