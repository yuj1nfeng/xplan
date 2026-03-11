/// 消息类型枚举
enum MessageType {
  text,     // 文本消息
  voice,    // 语音消息
  image,    // 图片消息
  video,    // 视频消息
  file,     // 文件消息
  link,     // 链接消息
}

/// 链接卡片信息
class LinkCard {
  final String url;
  final String? title;
  final String? description;
  final String? image;
  final String? siteName;

  LinkCard({
    required this.url,
    this.title,
    this.description,
    this.image,
    this.siteName,
  });

  factory LinkCard.fromJson(Map<String, dynamic> json) {
    return LinkCard(
      url: json['url'] ?? '',
      title: json['title'],
      description: json['description'],
      image: json['image'],
      siteName: json['siteName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'title': title,
      'description': description,
      'image': image,
      'siteName': siteName,
    };
  }
}

/// 语音消息信息
class VoiceInfo {
  final String audioPath;  // 本地路径或URL
  final int duration;      // 时长（秒）

  VoiceInfo({
    required this.audioPath,
    required this.duration,
  });

  factory VoiceInfo.fromJson(Map<String, dynamic> json) {
    return VoiceInfo(
      audioPath: json['audioPath'] ?? '',
      duration: json['duration'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'audioPath': audioPath,
      'duration': duration,
    };
  }
}

/// 文件信息
class FileInfo {
  final String name;       // 文件名
  final String path;       // 本地路径或URL
  final int size;          // 文件大小（字节）
  final String? mimeType;  // MIME类型

  FileInfo({
    required this.name,
    required this.path,
    required this.size,
    this.mimeType,
  });

  factory FileInfo.fromJson(Map<String, dynamic> json) {
    return FileInfo(
      name: json['name'] ?? 'unknown',
      path: json['path'] ?? '',
      size: json['size'] ?? 0,
      mimeType: json['mimeType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'size': size,
      'mimeType': mimeType,
    };
  }

  /// 格式化文件大小
  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// 消息模型
class Message {
  final String id;
  final String content;
  final String role; // 'user' or 'assistant'
  final DateTime timestamp;
  final MessageType type;

  // 附加信息（根据类型不同）
  final LinkCard? linkCard;
  final VoiceInfo? voiceInfo;
  final FileInfo? fileInfo;
  final String? mediaPath; // 图片/视频路径

  Message({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.type = MessageType.text,
    this.linkCard,
    this.voiceInfo,
    this.fileInfo,
    this.mediaPath,
  });

  /// 创建文本消息
  factory Message.text({
    required String id,
    required String content,
    required String role,
    required DateTime timestamp,
  }) {
    return Message(
      id: id,
      content: content,
      role: role,
      timestamp: timestamp,
      type: MessageType.text,
    );
  }

  /// 创建链接消息
  factory Message.link({
    required String id,
    required String url,
    required String role,
    required DateTime timestamp,
    LinkCard? card,
  }) {
    return Message(
      id: id,
      content: url,
      role: role,
      timestamp: timestamp,
      type: MessageType.link,
      linkCard: card,
    );
  }

  /// 创建语音消息
  factory Message.voice({
    required String id,
    required String audioPath,
    required int duration,
    required String role,
    required DateTime timestamp,
  }) {
    return Message(
      id: id,
      content: '🎤 语音消息 ${_formatDuration(duration)}',
      role: role,
      timestamp: timestamp,
      type: MessageType.voice,
      voiceInfo: VoiceInfo(audioPath: audioPath, duration: duration),
    );
  }

  /// 创建图片消息
  factory Message.image({
    required String id,
    required String imagePath,
    required String role,
    required DateTime timestamp,
    String? caption,
  }) {
    return Message(
      id: id,
      content: caption ?? '📷 图片',
      role: role,
      timestamp: timestamp,
      type: MessageType.image,
      mediaPath: imagePath,
    );
  }

  /// 创建视频消息
  factory Message.video({
    required String id,
    required String videoPath,
    required String role,
    required DateTime timestamp,
    String? caption,
  }) {
    return Message(
      id: id,
      content: caption ?? '🎬 视频',
      role: role,
      timestamp: timestamp,
      type: MessageType.video,
      mediaPath: videoPath,
    );
  }

  /// 创建文件消息
  factory Message.file({
    required String id,
    required String name,
    required String path,
    required int size,
    required String role,
    required DateTime timestamp,
    String? mimeType,
  }) {
    return Message(
      id: id,
      content: '📎 $name',
      role: role,
      timestamp: timestamp,
      type: MessageType.file,
      fileInfo: FileInfo(name: name, path: path, size: size, mimeType: mimeType),
    );
  }

  static String _formatDuration(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      content: json['content'] ?? json['message'] ?? '',
      role: json['role'] ?? 'assistant',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      type: MessageType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => MessageType.text,
      ),
      linkCard: json['linkCard'] != null
          ? LinkCard.fromJson(json['linkCard'])
          : null,
      voiceInfo: json['voiceInfo'] != null
          ? VoiceInfo.fromJson(json['voiceInfo'])
          : null,
      fileInfo: json['fileInfo'] != null
          ? FileInfo.fromJson(json['fileInfo'])
          : null,
      mediaPath: json['mediaPath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'role': role,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'linkCard': linkCard?.toJson(),
      'voiceInfo': voiceInfo?.toJson(),
      'fileInfo': fileInfo?.toJson(),
      'mediaPath': mediaPath,
    };
  }

  /// 复制并修改
  Message copyWith({
    String? id,
    String? content,
    String? role,
    DateTime? timestamp,
    MessageType? type,
    LinkCard? linkCard,
    VoiceInfo? voiceInfo,
    FileInfo? fileInfo,
    String? mediaPath,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      linkCard: linkCard ?? this.linkCard,
      voiceInfo: voiceInfo ?? this.voiceInfo,
      fileInfo: fileInfo ?? this.fileInfo,
      mediaPath: mediaPath ?? this.mediaPath,
    );
  }
}