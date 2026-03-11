/// 应用设置模型
class AppSettings {
  /// 主题模式：'system', 'light', 'dark'
  final String themeMode;

  /// API 基础地址 (OpenAI 兼容)
  final String apiBaseUrl;

  /// 默认模型
  final String defaultModel;

  /// 是否启用测试模式
  final bool testMode;

  /// 用户 ID
  final String? userId;

  /// 是否是高级会员
  final bool isPremium;

  /// 会员过期时间
  final DateTime? premiumExpiresAt;

  AppSettings({
    this.themeMode = 'system',
    this.apiBaseUrl = 'https://ollama.laidanbao.cn/v1',
    this.defaultModel = 'qwen3.5:9b',
    this.testMode = false,
    this.userId,
    this.isPremium = false,
    this.premiumExpiresAt,
  });

  AppSettings copyWith({
    String? themeMode,
    String? apiBaseUrl,
    String? defaultModel,
    bool? testMode,
    String? userId,
    bool? isPremium,
    DateTime? premiumExpiresAt,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      defaultModel: defaultModel ?? this.defaultModel,
      testMode: testMode ?? this.testMode,
      userId: userId ?? this.userId,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode,
      'apiBaseUrl': apiBaseUrl,
      'defaultModel': defaultModel,
      'testMode': testMode,
      'userId': userId,
      'isPremium': isPremium,
      'premiumExpiresAt': premiumExpiresAt?.toIso8601String(),
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: json['themeMode'] ?? 'system',
      apiBaseUrl: json['apiBaseUrl'] ?? 'https://ollama.laidanbao.cn/v1',
      defaultModel: json['defaultModel'] ?? 'qwen3.5:9b',
      testMode: json['testMode'] ?? false,
      userId: json['userId'],
      isPremium: json['isPremium'] ?? false,
      premiumExpiresAt: json['premiumExpiresAt'] != null
          ? DateTime.parse(json['premiumExpiresAt'])
          : null,
    );
  }
}
