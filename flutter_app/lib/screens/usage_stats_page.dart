import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/usage_limit_service.dart';

class UsageStatsPage extends StatelessWidget {
  const UsageStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('使用统计'),
        elevation: 0,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          final userId = auth.currentUser?.id ?? 'anonymous';
          final isPremium = auth.isPremium;

          return FutureBuilder<UsageStats>(
            future: UsageLimitService().getUsageStats(userId, isPremium),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final stats = snapshot.data ?? UsageStats(
                todayUsage: 0,
                dailyLimit: isPremium ? null : UsageLimitService.freeDailyLimit,
                wordLimit: isPremium
                    ? UsageLimitService.premiumWordLimit
                    : UsageLimitService.freeWordLimit,
                isPremium: isPremium,
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 今日使用卡片
                    _buildUsageCard(context, stats),
                    const SizedBox(height: 16),

                    // 字数限制卡片
                    _buildWordLimitCard(context, stats),
                    const SizedBox(height: 16),

                    // 会员状态卡片
                    _buildPremiumCard(context, auth),
                    const SizedBox(height: 16),

                    // 使用说明
                    _buildTipsCard(context),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildUsageCard(BuildContext context, UsageStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                const Text(
                  '今日使用',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  icon: Icons.check_circle,
                  color: Colors.green,
                  value: '${stats.todayUsage}',
                  label: stats.isPremium ? '次（无限次）' : '次',
                ),
                if (!stats.isPremium)
                  _buildStatItem(
                    context,
                    icon: Icons.hourglass_empty,
                    color: Colors.orange,
                    value: '${stats.dailyLimit}',
                    label: '次限额',
                  ),
              ],
            ),
            if (!stats.isPremium) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: stats.dailyLimit != null
                      ? stats.todayUsage / stats.dailyLimit!
                      : 0,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    stats.todayUsage >= stats.dailyLimit!
                        ? Colors.red
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${stats.todayUsage}/${stats.dailyLimit} 次',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWordLimitCard(BuildContext context, UsageStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.text_fields,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                const Text(
                  '字数限制',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '单次最多',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${stats.wordLimit.toLocaleString()} 字',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: stats.isPremium
                        ? Colors.amber.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    stats.isPremium ? '高级会员' : '免费用户',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: stats.isPremium
                          ? Colors.amber[700]
                          : Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumCard(BuildContext context, AuthProvider auth) {
    return Card(
      color: auth.isPremium
          ? Colors.amber.withOpacity(0.1)
          : Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  auth.isPremium ? Icons.star : Icons.workspace_premium,
                  color: auth.isPremium ? Colors.amber : Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  auth.isPremium ? '高级会员' : '升级高级会员',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (auth.isPremium) ...[
              const Text('感谢您的订阅，享受所有高级功能！'),
              if (auth.currentUser?.premiumExpiresAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  '有效期至：${_formatDate(auth.currentUser!.premiumExpiresAt!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ] else ...[
              const Text('升级高级会员，享受更多功能：'),
              const SizedBox(height: 12),
              _buildPremiumFeature('无限次每日使用'),
              _buildPremiumFeature('5000 字单次生成'),
              _buildPremiumFeature('优先客服支持'),
              _buildPremiumFeature('新功能抢先体验'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: 跳转到订阅页面
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('订阅功能开发中...')),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('立即升级'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumFeature(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check, size: 18, color: Colors.green),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTipsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                const Text(
                  '使用说明',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTipItem(context, '免费用户每日限 5 次，高级会员无限次'),
            _buildTipItem(context, '免费用户单次最多 300 字，高级会员 5000 字'),
            _buildTipItem(context, '使用次数每日 0 点重置'),
            _buildTipItem(context, '升级会员可立即解除所有限制'),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// 扩展 int 类型，添加千分位格式化方法
extension IntExtension on int {
  String toLocaleString() {
    return toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
