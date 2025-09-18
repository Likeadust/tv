# 🚀 GitHub Actions 构建说明

这个文档说明如何使用 GitHub Actions 自动构建 OrionTV Android APK。

## 📁 工作流文件说明

| 文件名 | 用途 | 触发条件 |
|--------|------|----------|
| `build-tv.yml` | 主要构建流程 | Push/PR/手动触发 |
| `build-android.yml` | 基础构建流程 | Push/PR/手动触发 |
| `build-apk.yml` | 简化构建流程 | 仅手动触发 |
| `release.yml` | 正式版本发布 | 仅手动触发 |

## 🔄 自动构建

### 触发条件
- **推送代码** 到 `main`、`master` 或 `develop` 分支
- **创建 Pull Request** 到 `main` 或 `master` 分支  
- **创建版本标签** (如 `v1.3.10`)

### 构建输出
- **Debug APK**: 开发版本，用于测试
- **Release APK**: 发布版本，用于生产环境

## 🎯 手动构建

### 方法1：使用主构建流程

1. 进入 GitHub 仓库页面
2. 点击 **Actions** 标签
3. 选择 **"Build OrionTV for Android TV"**
4. 点击 **"Run workflow"**
5. 选择参数：
   - **Build type**: `debug` 或 `release`
   - **Upload to Release**: 是否上传到 GitHub Release

### 方法2：创建正式发布

1. 进入 GitHub 仓库页面
2. 点击 **Actions** 标签  
3. 选择 **"Create Release"**
4. 点击 **"Run workflow"**
5. 填写参数：
   - **Version**: 版本号 (如 `1.3.11`)
   - **Release notes**: 更新说明 (可选)

## 📥 下载构建产物

### 从 Actions 下载

1. 进入对应的 Action 运行页面
2. 在 **Artifacts** 部分找到 APK 文件
3. 点击下载

### 从 Releases 下载

1. 进入仓库的 **Releases** 页面
2. 找到对应版本
3. 下载 APK 文件

## 🔧 本地构建命令

如果需要在本地构建，可以使用以下命令：

```bash
# 安装依赖
yarn install

# 构建 Debug APK
yarn ci:build

# 构建 Release APK  
yarn ci:prebuild && yarn ci:copy-config && yarn ci:build-release
```

## 📋 环境要求

GitHub Actions 使用以下环境：
- **Ubuntu Latest**
- **Node.js 20**
- **Java JDK 17**
- **Android SDK API Level 34**

## 🚨 常见问题

### 构建失败怎么办？

1. 检查 **Actions** 页面的错误日志
2. 确认 `package.json` 版本格式正确
3. 验证 `xml/AndroidManifest.xml` 文件存在
4. 检查依赖版本兼容性

### APK 文件在哪里？

- **自动构建**: 在 Actions 的 Artifacts 部分
- **发布版本**: 在 Releases 页面
- **本地构建**: `android/app/build/outputs/apk/` 目录

### 如何修改构建配置？

编辑对应的 `.github/workflows/*.yml` 文件，修改：
- 触发条件 (`on` 部分)
- 环境变量 (`env` 部分)  
- 构建步骤 (`steps` 部分)

## 🔄 版本管理

建议的版本发布流程：

1. **开发阶段**: 推送到 `develop` 分支，自动构建 Debug APK
2. **测试阶段**: 创建 PR 到 `main`，自动构建测试版本
3. **发布阶段**: 使用 "Create Release" 工作流创建正式版本

---

📝 **提示**: 所有构建都会自动设置 `EXPO_TV=1` 环境变量以启用 TV 模式。