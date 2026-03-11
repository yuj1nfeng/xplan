/// 会话模型
class Conversation {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int messageCount;

  Conversation({
    required this.id,
    required this.title,
    required this.createdAt,
    this.updatedAt,
    this.messageCount = 0,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] ?? json['conversation_id'] ?? '',
      title: json['title'] ?? json['name'] ?? '新对话',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      messageCount: json['message_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'message_count': messageCount,
    };
  }

  /// 获取格式化的时间显示
  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inDays == 0) {
      return '今天';
    } else if (diff.inDays == 1) {
      return '昨天';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else {
      return '${createdAt.month}-${createdAt.day}';
    }
  }

  /// 获取截断的标题
  String get truncatedTitle {
    if (title.length <= 20) return title;
    return '${title.substring(0, 18)}...';
  }

  Conversation copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? messageCount,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messageCount: messageCount ?? this.messageCount,
    );
  }
}
