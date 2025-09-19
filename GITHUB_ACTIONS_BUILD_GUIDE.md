# OrionTV GitHub Actions 构建指南

## 快速开始

### 1. 检查工作流状态
```bash
# 查看最近的构建状态
gh run list --workflow=build-tv.yml

# 查看特定运行的详细信息
gh run view [运行ID]
```

### 2. 触发新的构建

#### 方法一：通过命令行触发
```bash
# Debug 构建
gh workflow run "build-tv.yml" --field build_type="debug" --field upload_to_release="false"

# Release 构建
gh workflow run "build-tv.yml" --field build_type="release" --field upload_to_release="false"
```

#### 方法二：通过网页界面
1. 访问 GitHub 仓库
2. 点击 "Actions" 标签
3. 选择 "Build OrionTV for Android TV" 工作流
4. 点击 "Run workflow"
5. 选择构建类型（debug/release）
6. 点击 "Run workflow" 按钮

### 3. 下载构建的APK

#### 通过命令行下载
```bash
# 列出最新运行的artifacts
gh run list --workflow=build-tv.yml --limit=1

# 下载指定运行的artifacts  
gh run download [运行ID]
```

#### 通过网页下载
1. 在 Actions 页面找到成功的构建
2. 点击进入构建详情
3. 在 "Artifacts" 部分下载APK文件

## 构建输出说明

### Debug APK
- **文件名**: `OrionTV-Debug-v[版本号]-[commit哈希].zip`
- **内容**: `app-debug.apk`
- **用途**: 开发测试，包含调试信息
- **安装**: 需要在设备上启用"未知来源安装"

### Release APK  
- **文件名**: `OrionTV-Release-v[版本号]-[commit哈希].zip`
- **内容**: `app-release.apk`
- **用途**: 正式发布，经过优化和混淆
- **安装**: 生产环境使用

## 自动发布到GitHub Release

如果需要自动发布，可以：

```bash
# 创建标签触发自动发布
git tag v1.3.11
git push origin v1.3.11

# 或使用工作流手动触发带发布功能的构建
gh workflow run "build-tv.yml" --field build_type="release" --field upload_to_release="true"
```

## 故障排除

### 构建失败
1. 检查工作流运行日志：`gh run view [运行ID] --log`
2. 常见问题：
   - 依赖版本冲突
   - Android SDK版本不匹配
   - 内存不足

### 权限问题
确保GitHub Token有足够权限：
- `repo` (完整仓库访问)
- `workflow` (工作流权限)

### 网络问题
GitHub Actions在以下情况可能较慢：
- 第一次构建（需要下载依赖）
- 依赖更新后
- GitHub服务器负载高时

通常构建时间：5-15分钟