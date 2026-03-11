# XPlan Release 创建指南

## 当前状态

- ✅ **v1.1.1** - GitHub Actions 编译成功（7m 11s）
- ✅ **v1.1.0** - GitHub Actions 编译成功（6m 31s）
- ⚠️ **Release 未自动创建** - 需要手动操作

---

## 为什么 Release 没有自动创建？

GitHub Actions 的 `create-release` job 配置正确，但可能由于以下原因未执行：

1. **条件判断** - `if: startsWith(github.ref, 'refs/tags/')` 可能未触发
2. **artifacts 路径** - artifacts 名称可能不匹配
3. **权限问题** - GitHub Token 权限不足

---

## 手动创建 Release 步骤

### 方法 1：通过 GitHub 网页创建（推荐）

1. **访问 Releases 页面**
   - 打开 https://github.com/yuj1nfeng/xplan/releases

2. **创建新 Release**
   - 点击 "Draft a new release"
   - Tag version: 输入 `v1.1.1`
   - Release title: 输入 `v1.1.1 - 完整功能版本`

3. **填写发布说明**
   - 复制 `RELEASE_NOTES_v1.1.1.md` 的内容

4. **上传构建产物**
   - 从 GitHub Actions 下载 artifacts
   - 访问 https://github.com/yuj1nfeng/xplan/actions/runs/13845915843（或最新成功运行）
   - 下载所有 artifacts（Web、Linux、Android、macOS、Windows、iOS）
   - 上传到 Release

5. **发布**
   - 点击 "Publish release"

---

### 方法 2：通过 GitHub CLI 创建

```bash
# 安装 GitHub CLI（如果未安装）
# macOS: brew install gh
# Windows: winget install GitHub.cli
# Linux: sudo apt install gh

# 登录 GitHub
gh auth login

# 创建 Release
gh release create v1.1.1 \
  --title "v1.1.1 - 完整功能版本" \
  --notes-file RELEASE_NOTES_v1.1.1.md \
  --generate-notes
```

---

## 从 Actions 下载构建产物

1. **访问 Actions 页面**
   - https://github.com/yuj1nfeng/xplan/actions

2. **找到最新成功运行**
   - 查找 "Build All Platforms" 工作流
   - 状态为 "Success" 的运行（#4）

3. **下载 artifacts**
   - 滚动到页面底部 "Artifacts" 部分
   - 点击下载：
     - `xplan-web-v1.1.1` - Web 版本
     - `xplan-linux-v1.1.1` - Linux 版本
     - `xplan-android-v1.1.1` - Android APK
     - `xplan-macos-v1.1.1` - macOS DMG
     - `xplan-windows-v1.1.1` - Windows ZIP
     - `xplan-ios-v1.1.1` - iOS IPA

---

## 修复自动 Release 的建议

如果需要修复自动 Release 功能，可以：

1. **检查 workflow 日志**
   - 查看 `create-release` job 是否运行
   - 检查是否有错误信息

2. **更新 workflow 配置**
   ```yaml
   create-release:
     name: Create GitHub Release
     needs: [build-web, build-linux, build-android, build-macos, build-windows, build-ios]
     runs-on: ubuntu-latest
     if: github.event_name == 'push' && startsWith(github.ref, 'refs/tags/')
     permissions:
       contents: write
     steps:
       - uses: actions/checkout@v4
       
       - name: Download All Artifacts
         uses: actions/download-artifact@v4
         with:
           path: artifacts
       
       - name: Create GitHub Release
         uses: softprops/action-gh-release@v2
         with:
           files: artifacts/*
           body_path: release-notes.md
           generate_release_notes: true
   ```

3. **添加 release-notes.md 生成步骤**
   ```yaml
   - name: Generate Release Notes
     run: |
       echo "# XPlan ${{ github.ref_name }}" > release-notes.md
       echo "" >> release-notes.md
       echo "## 下载" >> release-notes.md
   ```

---

## 联系支持

如果遇到问题，请查看：
- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [GitHub Releases 文档](https://docs.github.com/en/repositories/releasing-projects-on-github)
- [softprops/action-gh-release](https://github.com/softprops/action-gh-release)

---

**最后更新**: 2026 年 3 月 11 日
