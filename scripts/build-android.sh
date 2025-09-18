#!/bin/bash

# OrionTV Android构建脚本
# 适用于CI/CD环境

set -e  # 遇到错误立即退出

echo "🚀 开始OrionTV Android TV构建..."

# 设置环境变量
export EXPO_TV=1
export EXPO_USE_METRO_WORKSPACE_ROOT=1
export NODE_ENV=production

echo "📦 环境变量设置:"
echo "EXPO_TV=$EXPO_TV"
echo "NODE_ENV=$NODE_ENV"

# 检查Node.js版本
echo "🔍 检查Node.js版本..."
node --version
npm --version

# 检查Java版本
echo "🔍 检查Java版本..."
java -version

# 安装依赖
echo "📦 安装项目依赖..."
if [ -f "yarn.lock" ]; then
    yarn install --frozen-lockfile --network-timeout 300000
else
    npm ci
fi

# 清理旧的构建文件
echo "🧹 清理旧的构建文件..."
rm -rf android/

# 生成Android项目
echo "🏗️ 生成Android项目文件..."
npx expo prebuild --platform android --clean --no-install

# 复制TV配置
echo "📄 复制Android TV配置..."
if [ -f "xml/AndroidManifest.xml" ]; then
    cp xml/AndroidManifest.xml android/app/src/main/AndroidManifest.xml
    echo "✅ AndroidManifest.xml 复制成功"
else
    echo "⚠️ 警告: xml/AndroidManifest.xml 不存在"
fi

# 设置Gradle权限
echo "🔧 设置Gradle执行权限..."
chmod +x android/gradlew

# 进入Android目录
cd android

# 检查Gradle版本
echo "🔍 检查Gradle版本..."
./gradlew --version

# 构建APK
BUILD_TYPE=${1:-debug}
echo "🔨 开始构建 $BUILD_TYPE APK..."

if [ "$BUILD_TYPE" = "release" ]; then
    echo "🏗️ 构建Release APK..."
    ./gradlew assembleRelease --no-daemon --stacktrace
    
    echo "📦 Release APK构建完成:"
    ls -lh app/build/outputs/apk/release/app-release.apk
    
elif [ "$BUILD_TYPE" = "debug" ]; then
    echo "🏗️ 构建Debug APK..."
    ./gradlew assembleDebug --no-daemon --stacktrace
    
    echo "📦 Debug APK构建完成:"
    ls -lh app/build/outputs/apk/debug/app-debug.apk
    
else
    echo "❌ 错误: 无效的构建类型 '$BUILD_TYPE'"
    echo "使用方法: $0 [debug|release]"
    exit 1
fi

echo "✅ OrionTV Android TV构建成功完成!"
echo "📱 APK文件位置:"
find app/build/outputs/apk -name "*.apk" -exec ls -lh {} \;