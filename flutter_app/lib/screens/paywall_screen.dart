import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../services/wechat_pay_service.dart';
import '../providers/subscription_provider.dart';

/// 付费墙页面 - 展示订阅套餐（优化版）
class PaywallScreen extends StatefulWidget {
  final String userId;

  const PaywallScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF667EEA),
              const Color(0xFF764BA2),
              Colors.white,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(_slideAnimation),
              child: _buildContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // 顶部关闭按钮
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),

        // 内容区域
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // 标题和图标
                _buildHeader(),

                const SizedBox(height: 32),

                // 功能列表
                _buildFeaturesSection(),

                const SizedBox(height: 32),

                // 订阅套餐
                _buildPlansSection(context),

                const SizedBox(height: 24),

                // 恢复购买
                TextButton(
                  onPressed: () => _restorePurchase(context),
                  child: Text(
                    '恢复购买',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // 动态图标
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: child,
            );
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 64,
              color: Color(0xFF667EEA),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '升级高级会员',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '解锁所有高级功能，提升写作效率',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildFeatureItem('✨ 无限次生成', '每天不限次数，尽情创作'),
          const Divider(height: 32),
          _buildFeatureItem('✨ 5000 字长文', '支持长篇文章生成'),
          const Divider(height: 32),
          _buildFeatureItem('✨ 高级润色', '智能优化文章表达'),
          const Divider(height: 32),
          _buildFeatureItem('✨ 多语言翻译', '支持全球主流语言'),
          const Divider(height: 32),
          _buildFeatureItem('✨ 优先客服支持', '专属客服快速响应'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Color(0xFF667EEA),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlansSection(BuildContext context) {
    return Column(
      children: WeChatPayService.subscriptionPlans.asMap().entries.map((entry) {
        final index = entry.key;
        final plan = entry.value;
        final isPopular = plan['popular'] as bool? ?? false;
        final isYearly = plan['id'] == 'wechat_yearly';
        
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 400 + index * 150),
          builder: (context, value, child) {
            return Transform.scale(
              scaleY: value,
              child: child,
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: isYearly ? Colors.white : Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isYearly ? const Color(0xFF667EEA) : Colors.white.withOpacity(0.3),
                width: isYearly ? 3 : 1,
              ),
              boxShadow: isPopular
                  ? [
                      BoxShadow(
                        color: const Color(0xFF667EEA).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
            ),
            child: Column(
              children: [
                // 套餐头部
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: isYearly
                        ? const LinearGradient(
                            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                          )
                        : null,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  plan['name'] as String,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: isYearly ? Colors.white : Colors.black87,
                                  ),
                                ),
                                if (isPopular) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      '热门',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            if (plan['discount'] != null)
                              Text(
                                plan['discount'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isYearly
                                      ? Colors.white.withOpacity(0.9)
                                      : Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                      // 价格
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '¥',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isYearly ? Colors.white : Colors.black87,
                                ),
                              ),
                              Text(
                                plan['price'].toString(),
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: isYearly ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          if (plan['originalPrice'] != null)
                            Text(
                              '原价¥${plan['originalPrice']}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isYearly
                                    ? Colors.white.withOpacity(0.7)
                                    : Colors.grey[600],
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 功能列表
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  color: isYearly
                      ? const Color(0xFF667EEA).withOpacity(0.05)
                      : Colors.grey[50],
                  child: Column(
                    children: (plan['features'] as List).asMap().entries.map((featureEntry) {
                      final featureIndex = featureEntry.key;
                      final feature = featureEntry.value as String;
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: -10.0, end: 0.0),
                        duration: Duration(milliseconds: 300 + featureIndex * 100),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(value, 0),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: isYearly
                                          ? const Color(0xFF667EEA)
                                          : Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    feature,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isYearly
                                          ? Colors.black87
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),

                // 购买按钮
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 1.0, end: 1.05),
                      duration: const Duration(milliseconds: 1500),
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: isPopular ? (1 + 0.05 * math.sin(DateTime.now().millisecondsSinceEpoch / 500)) : 1.0,
                          child: child,
                        );
                      },
                      child: ElevatedButton(
                        onPressed: () => _purchasePlan(context, plan),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isYearly
                              ? const Color(0xFF667EEA)
                              : const Color(0xFF667EEA),
                          foregroundColor: Colors.white,
                          elevation: isPopular ? 8 : 4,
                          shadowColor: const Color(0xFF667EEA).withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        child: const Text(
                          '立即开通',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _purchasePlan(
    BuildContext context,
    Map<String, dynamic> plan,
  ) async {
    final subscriptionProvider =
        Provider.of<SubscriptionProvider>(context, listen: false);

    // 显示加载对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final success = await subscriptionProvider.purchaseSubscription(
        planId: plan['id'] as String,
        userId: userId,
      );

      if (context.mounted) {
        Navigator.of(context).pop(); // 关闭加载对话框

        if (success) {
          // 支付成功
          _showSuccessDialog(context);
        } else {
          // 支付失败
          _showErrorDialog(
            context,
            subscriptionProvider.errorMessage ?? '支付失败',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        _showErrorDialog(context, '支付异常：$e');
      }
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('支付成功'),
        content: const Text('恭喜您成为高级会员，所有功能已解锁！'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('支付失败'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Future<void> _restorePurchase(BuildContext context) async {
    final subscriptionProvider =
        Provider.of<SubscriptionProvider>(context, listen: false);

    await subscriptionProvider.restorePurchase(userId);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            subscriptionProvider.errorMessage ?? '恢复购买成功',
          ),
        ),
      );
    }
  }
}
