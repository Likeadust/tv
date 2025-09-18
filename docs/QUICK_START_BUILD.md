# 🚀 快速开始：GitHub Actions 构建 Android APK

本指南将帮助你快速使用 GitHub Actions 构建 OrionTV 的 Android APK。

## 📋 前提条件

1. **GitHub 账号** 并拥有本仓库的权限
2. **GitHub CLI** (可选，用于命令行操作)

## 🎯 快速构建

### 方法1：Web 界面操作 (推荐新手)

1. **进入 Actions 页面**
   - 访问：`https://github.com/你的用户名/OrionTV/actions`
   - 或点击仓库顶部的 "Actions" 标签

2. **选择工作流**
   - 点击左侧的 "Build OrionTV for Android TV"

3. **运行构建**
   - 点击右侧的 "Run workflow" 按钮
   - 选择分支 (通常是 `main`)
   - 选择构建类型：
     - `debug` - 用于测试，体积大但包含调试信息
     - `release` - 用于发布，体积小且优化过
   - 点击绿色的 "Run workflow" 按钮

4. **等待构建完成**
   - 构建通常需要 5-10 分钟
   - 可以点击构建任务查看实时日志

5. **下载 APK**
   - 构建完成后，滚动到页面底部
   - 在 "Artifacts" 部分找到 APK 文件
   - 点击下载（注意：需要登录 GitHub）

### 方法2：创建正式版本

1. **访问 Actions 页面**
2. **选择 "Create Release" 工作流**
3. **点击 "Run workflow"**
4. **填写信息**：
   - **Version**: 输入版本号（如 `1.3.11`）
   - **Release notes**: 输入更新说明（可选）
5. **点击 "Run workflow"**
6. **等待完成后访问 Releases 页面下载**

### 方法3：命令行操作 (高级用户)

如果安装了 GitHub CLI：

```bash
# 触发 Debug 构建
gh workflow run "build-tv.yml" --field build_type="debug"

# 触发 Release 构建
gh workflow run "build-tv.yml" --field build_type="release"

# 创建新版本发布
gh workflow run "release.yml" --field version="1.3.11" --field release_notes="修复了播放问题"

# 查看构建状态
gh run list --workflow="build-tv.yml"
```

或使用项目提供的辅助脚本：

```bash
# Linux/macOS
./scripts/build-helper.sh debug

# Windows
scripts\build-helper.bat debug
```

## 📥 APK 安装

### 下载到手机/电脑
1. 从 GitHub 下载 APK 文件
2. 通过 USB、网络传输等方式复制到 Android TV 设备

### 直接在 Android TV 下载
1. 在 Android TV 上打开浏览器
2. 访问 GitHub Releases 页面
3. 直接下载 APK 文件

### 安装步骤
1. 在 Android TV 的设置中启用"未知来源"应用安装
2. 使用文件管理器找到 APK 文件
3. 点击安装

## 🔧 故障排除

### 构建失败
- 检查 Actions 页面的错误日志
- 确认 `package.json` 中的版本号格式正确
- 验证依赖项是否最新

### APK 无法安装
- 确认已启用"未知来源"安装
- 检查 Android TV 系统版本兼容性
- 尝试清除设备缓存后重新安装

### 下载速度慢
- 使用代理或 VPN
- 选择合适的时间段下载
- 使用第三方 GitHub 加速服务

## 🎉 构建成功！

构建成功后，你将得到：
- **Debug APK**: 约 50-80MB，包含调试信息
- **Release APK**: 约 30-50MB，已优化的生产版本

现在你可以在 Android TV 上安装并使用 OrionTV 了！

---

💡 **提示**: 构建过程完全在 GitHub 服务器上进行，不需要本地安装任何开发工具。