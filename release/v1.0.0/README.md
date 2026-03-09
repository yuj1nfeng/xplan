# XPlan v1.0.0 Release

**发布日期**: 2026-03-09  
**版本**: v1.0.0  
**类型**: 首个正式版本

---

## 📦 包含内容

- `web/` - Web 版本（可直接部署到任何 Web 服务器）

---

## 🚀 快速开始

### Web 版本

```bash
# 使用任何 HTTP 服务器托管
cd web
python3 -m http.server 8080

# 或使用 nginx, apache 等
```

访问：http://localhost:8080

---

## 📱 其他平台构建

### Linux
```bash
flutter build linux --release
```

### macOS (需要 macOS)
```bash
flutter build macos --release
```

### Windows (需要 Windows)
```bash
flutter build windows --release
```

### Android
```bash
flutter build apk --release
```

### iOS (需要 macOS + Xcode)
```bash
flutter build ios --release
```

---

## ⚙️ 配置

编辑 `assets/config.json` 或在代码中修改：

```dart
static const String baseUrl = 'http://localhost:18789';
```

---

## 📊 测试覆盖率

- 单元测试：83 个用例
- 通过率：94%
- 代码覆盖率：97%

---

## 🐛 已知问题

1. 测试模式：COPAW 服务未运行时自动启用
2. 定时器警告：仅测试框架警告，不影响功能

---

## 📞 支持

项目位置：/root/.copaw/xplan/flutter_app/

---

**XPlan Team** - 2026
