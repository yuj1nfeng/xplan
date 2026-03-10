#!/bin/bash

# XPlan Release 邮件通知脚本
# 使用方法：./send_release_email.sh <邮箱地址> <版本号>

RECIPIENT=$1
VERSION=$2

if [ -z "$RECIPIENT" ] || [ -z "$VERSION" ]; then
    echo "用法：$0 <邮箱地址> <版本号>"
    echo "示例：$0 user@example.com v1.0.0"
    exit 1
fi

SUBJECT="[XPlan Release] $VERSION - $(date +%Y-%m-%d)"

echo "准备发送邮件到：$RECIPIENT"
echo "主题：$SUBJECT"
echo ""

# 检查可用的邮件工具
if command -v himalaya &> /dev/null; then
    echo "使用 himalaya 发送邮件..."
    cat << EOF | himalaya send --to "$RECIPIENT" --subject "$SUBJECT"
<html>
<body>
<h2>🎉 XPlan $VERSION 发布通知</h2>
<p>XPlan Flutter 跨平台客户端 <strong>$VERSION</strong> 已发布！</p>
<p>GitHub Actions 将自动编译所有平台版本。</p>
<p>推送 tag 触发：<code>git tag $VERSION && git push origin $VERSION</code></p>
<hr>
<p><strong>XPlan Team</strong></p>
</body>
</html>
EOF
    echo "✅ 邮件已发送"
elif command -v mail &> /dev/null; then
    echo "使用 mail 发送邮件..."
    echo "XPlan $VERSION 已发布" | mail -s "$SUBJECT" "$RECIPIENT"
    echo "✅ 邮件已发送"
else
    echo "⚠️  未找到邮件工具"
    echo ""
    echo "请安装 himalaya:"
    echo "  curl --proto '=https' --tlsv1.2 -sSf https://himalaya-rs.github.io/cli/install.sh | sh"
    echo ""
    echo "或配置 SMTP 使用 Python 发送"
fi
