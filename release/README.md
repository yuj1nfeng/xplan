# XPlan COPAW Client - Tauri Linux 版本

## 编译信息
- 编译时间：2026-03-10
- Rust 版本：1.94.0
- Tauri 版本：2.10.3
- 编译服务器：121.41.122.68

## 运行要求
需要安装以下系统依赖：
```bash
# Ubuntu/Debian
sudo apt-get install libwebkit2gtk-4.1-dev libgtk-3-dev libayatana-appindicator3-dev librsvg2-dev

# CentOS/RHEL
sudo yum install webkit2gtk3-devel gtk3-devel libappindicator-gtk3-devel librsvg2-devel
```

## 运行方式
```bash
./xplan-linux
```

## 文件说明
- xplan-linux: 主程序二进制文件
- dist/: 前端资源文件
- README.md: 本文件
