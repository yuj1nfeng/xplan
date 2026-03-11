/// 用户模型
class User {
  final String id;
  final String? username;
  final String? email;
  final String? avatar;
  final bool isPremium;
  final DateTime? createdAt;
  final DateTime? premiumExpiresAt;

  User({
    required this.id,
    this.username,
    this.email,
    this.avatar,
    this.isPremium = false,
    this.createdAt,
    this.premiumExpiresAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['user_id'] ?? '',
      username: json['username'] ?? json['name'],
      email: json['email'],
      avatar: json['avatar'],
      isPremium: json['is_premium'] ?? json['isPremium'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      premiumExpiresAt: json['premium_expires_at'] != null
          ? DateTime.parse(json['premium_expires_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar': avatar,
      'is_premium': isPremium,
      'created_at': createdAt?.toIso8601String(),
      'premium_expires_at': premiumExpiresAt?.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? avatar,
    bool? isPremium,
    DateTime? createdAt,
    DateTime? premiumExpiresAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
      premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
    );
  }

  /// 获取用户头像的首字母
  String get avatarInitials {
    if (username != null && username!.isNotEmpty) {
      return username![0].toUpperCase();
    }
    if (email != null && email!.isNotEmpty) {
      return email![0].toUpperCase();
    }
    return 'U';
  }

  /// 是否是有效的高级会员
  bool get isValidPremium {
    return isPremium &&
        (premiumExpiresAt == null || premiumExpiresAt!.isAfter(DateTime.now()));
  }
}
