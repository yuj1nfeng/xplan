#!/bin/bash

echo "🚀 XPlan Flutter 项目启动脚本"
echo "=============================="
echo ""

# 检查 Flutter
if [ ! -f "/root/flutter/bin/flutter" ]; then
    echo "❌ Flutter 未安装，请先等待下载完成..."
    echo "下载命令：cd /root && git clone https://github.com/flutter/flutter.git -b stable --depth 1"
    exit 1
fi

# 设置环境变量
export PATH="$PATH:/root/flutter/bin"

# 检查 Flutter 版本
echo "✅ Flutter 版本检查..."
flutter --version

# 进入项目目录
cd /root/.copaw/xplan/flutter_app

# 安装依赖
echo ""
echo "📦 安装依赖..."
flutter pub get

# 运行应用
echo ""
echo "🚀 启动应用..."
flutter run -d linux
