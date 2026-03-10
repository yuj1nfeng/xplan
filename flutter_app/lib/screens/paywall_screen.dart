import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/wechat_pay_service.dart';
import '../providers/subscription_provider.dart';

/// 付费墙页面 - 展示订阅套餐
class PaywallScreen extends StatelessWidget {
  final String userId;

  const PaywallScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 顶部关闭按钮
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
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
                    // 标题
                    const Icon(
                      Icons.auto_awesome,
                      size: 64,
                      color: Color(0xFF667EEA),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '升级高级会员',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '解锁所有高级功能，提升写作效率',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),

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
                      child: const Text('恢复购买'),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF667EEA).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildFeatureItem('✨ 无限次生成', '每天不限次数，尽情创作'),
          const Divider(height: 24),
          _buildFeatureItem('✨ 5000 字长文', '支持长篇文章生成'),
          const Divider(height: 24),
          _buildFeatureItem('✨ 高级润色', '智能优化文章表达'),
          const Divider(height: 24),
          _buildFeatureItem('✨ 多语言翻译', '支持全球主流语言'),
          const Divider(height: 24),
          _buildFeatureItem('✨ 优先客服支持', '专属客服快速响应'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.check_circle,
          color: Color(0xFF667EEA),
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
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
      children: WeChatPayService.subscriptionPlans.map((plan) {
        final isPopular = plan['popular'] as bool? ?? false;
        final isYearly = plan['id'] == 'wechat_yearly';
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isYearly ? const Color(0xFF667EEA) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isYearly ? const Color(0xFF667EEA) : Colors.grey[300]!,
              width: isYearly ? 2 : 1,
            ),
            boxShadow: isPopular
                ? [
                    BoxShadow(
                      color: const Color(0xFF667EEA).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              // 套餐头部
              Container(
                padding: const EdgeInsets.all(16),
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
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isYearly ? Colors.white : Colors.black,
                                ),
                              ),
                              if (isPopular) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
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
                                fontSize: 14,
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
                            const Text(
                              '¥',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              plan['price'].toString(),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: isYearly ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                        if (plan['originalPrice'] != null)
                          Text(
                            '原价 ¥${plan['originalPrice']}',
                            style: TextStyle(
                              fontSize: 12,
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: isYearly
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey[50],
                child: Column(
                  children: (plan['features'] as List).map((feature) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check,
                            size: 18,
                            color: isYearly
                                ? Colors.white
                                : const Color(0xFF667EEA),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            feature as String,
                            style: TextStyle(
                              fontSize: 14,
                              color: isYearly
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              // 购买按钮
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => _purchasePlan(context, plan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isYearly
                          ? Colors.white
                          : const Color(0xFF667EEA),
                      foregroundColor: isYearly
                          ? const Color(0xFF667EEA)
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      '立即开通',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
