# OrionTV 📺

[![Build Android APK](https://github.com/zimplexing/OrionTV/actions/workflows/build-tv.yml/badge.svg)](https://github.com/zimplexing/OrionTV/actions/workflows/build-tv.yml)

一个基于 React Native TVOS 和 Expo 构建的播放器，旨在提供流畅的视频观看体验。

## ✨ 功能特性

- **框架跨平台支持**: 同时支持构建 Apple TV 和 Android TV。
- **现代化前端**: 使用 Expo、React Native TVOS 和 TypeScript 构建，性能卓越。
- **Expo Router**: 基于文件系统的路由，使导航逻辑清晰简单。
- **TV 优化的 UI**: 专为电视遥控器交互设计的用户界面。

## 🛠️ 技术栈

- **前端**:
  - [React Native TVOS](https://github.com/react-native-tvos/react-native-tvos)
  - [Expo](https://expo.dev/) (~51.0)
  - [Expo Router](https://docs.expo.dev/router/introduction/)
  - [Expo AV](https://docs.expo.dev/versions/latest/sdk/av/)
  - TypeScript

## 📂 项目结构

本项目采用类似 monorepo 的结构：

```
.
├── app/              # Expo Router 路由和页面
├── assets/           # 静态资源 (字体, 图片, TV 图标)
├── components/       # React 组件
├── constants/        # 应用常量 (颜色, 样式)
├── hooks/            # 自定义 Hooks
├── services/         # 服务层 (API, 存储)
├── package.json      # 前端依赖和脚本
└── ...
```

## 🚀 快速开始

### 环境准备

请确保您的开发环境中已安装以下软件：

- [Node.js](https://nodejs.org/) (LTS 版本)
- [Yarn](https://yarnpkg.com/)
- [Expo CLI](https://docs.expo.dev/get-started/installation/)
- [Xcode](https://developer.apple.com/xcode/) (用于 Apple TV 开发)
- [Android Studio](https://developer.android.com/studio) (用于 Android TV 开发)

### 项目启动

接下来，在项目根目录运行前端应用：

```sh

# 安装依赖
yarn

# [首次运行或依赖更新后] 生成原生项目文件
# 这会根据 app.json 中的配置修改原生代码以支持 TV
yarn prebuild-tv

# 运行在 Apple TV 模拟器或真机上
yarn ios-tv

# 运行在 Android TV 模拟器或真机上
yarn android-tv
```

## 🏗️ 自动构建

### GitHub Actions 构建

本项目已配置 GitHub Actions 自动构建 Android TV APK，支持多种触发方式：

#### 🔄 自动触发
- 推送代码到 `main`、`master` 或 `develop` 分支
- 创建 Pull Request 到 `main` 或 `master` 分支
- 创建版本标签（如 `v1.3.11`）

#### 🎯 手动触发

**方式一：标准构建**
1. 访问 [Actions 页面](../../actions)
2. 选择 "Build OrionTV for Android TV" 工作流
3. 点击 "Run workflow" 按钮
4. 选择构建类型（debug/release）

**方式二：创建正式版本**
1. 访问 [Actions 页面](../../actions)
2. 选择 "Create Release" 工作流
3. 输入新版本号和更新说明
4. 自动构建并发布到 Releases

**方式三：使用辅助脚本** (推荐)
```bash
# Linux/macOS
./scripts/build-helper.sh debug     # 构建测试版
./scripts/build-helper.sh release   # 构建发布版
./scripts/build-helper.sh create    # 创建新版本
./scripts/build-helper.sh status    # 查看构建状态

# Windows
scripts\build-helper.bat debug     # 构建测试版
scripts\build-helper.bat release   # 构建发布版
scripts\build-helper.bat create    # 创建新版本
scripts\build-helper.bat status    # 查看构建状态
```

#### 📥 下载 APK
- **开发版本**: 在 Actions 运行页面的 Artifacts 部分下载
- **正式版本**: 在 [Releases 页面](../../releases) 下载
- **文件命名**: `OrionTV-v{版本号}.apk`

#### 🔍 构建状态
可通过以下徽章查看最新构建状态：

[![Build Status](https://github.com/zimplexing/OrionTV/actions/workflows/build-tv.yml/badge.svg)](https://github.com/zimplexing/OrionTV/actions/workflows/build-tv.yml)

详细说明请参考：[GitHub Actions 构建指南](docs/GITHUB_ACTIONS.md)

### 本地构建

如果需要在本地构建 APK：

```bash
# 安装依赖
yarn install

# 构建 Debug APK (推荐用于测试)
yarn ci:build

# 构建 Release APK (用于生产环境)
yarn ci:prebuild && yarn ci:copy-config && yarn ci:build-release

# 清理构建缓存 (解决构建问题时使用)
yarn clean
```

**构建要求**:
- Node.js 18+
- Java JDK 17
- Android SDK (API Level 34)
- 足够的磁盘空间 (约 2GB)

## 使用

- 1.2.x 以上版本需配合 [MoonTV](https://github.com/senshinya/MoonTV) 使用。


## 📜 主要脚本

### 开发脚本
- `yarn start-tv`: 在 TV 模式下启动 Metro Bundler
- `yarn ios-tv`: 在 Apple TV 上构建并运行应用
- `yarn android-tv`: 在 Android TV 上构建并运行应用
- `yarn prebuild-tv`: 为 TV 构建生成原生项目文件

### 构建脚本
- `yarn ci:build`: 构建 Debug APK（CI 环境）
- `yarn ci:build-release`: 构建 Release APK（CI 环境）
- `yarn ci:prebuild`: 生成 Android 项目（CI 环境）
- `yarn ci:copy-config`: 复制 Android 配置文件

### 工具脚本
- `yarn lint`: 检查代码风格
- `yarn typecheck`: TypeScript 类型检查
- `yarn test`: 运行单元测试
- `yarn clean`: 清理缓存和构建文件
- `yarn reset-project`: 重置项目到初始状态

### 辅助脚本
- `scripts/build-helper.sh` (Linux/macOS): 构建辅助脚本
- `scripts/build-helper.bat` (Windows): 构建辅助脚本

## 📝 License

本项目采用 MIT 许可证。

## ⚠️ 免责声明

OrionTV 仅作为视频搜索工具，不存储、上传或分发任何视频内容。所有视频均来自第三方 API 接口提供的搜索结果。如有侵权内容，请联系相应的内容提供方。

本项目开发者不对使用本项目产生的任何后果负责。使用本项目时，您必须遵守当地的法律法规。

## 🌟 Star History

[![Star History Chart](https://api.star-history.com/svg?repos=zimplexing/OrionTV&type=Date)](https://www.star-history.com/#zimplexing/OrionTV&Date)

## 🙏 致谢

本项目受到以下开源项目的启发：

- [MoonTV](https://github.com/senshinya/MoonTV) - 一个基于 Next.js 的视频聚合应用
- [LibreTV](https://github.com/LibreSpark/LibreTV) - 一个开源的视频流媒体应用

感谢以下项目提供 API Key 的赞助

- [gpt-load](https://github.com/tbphp/gpt-load) - 一个高性能的 OpenAI 格式 API 多密钥轮询代理服务器，支持负载均衡，使用 Go 语言开发
