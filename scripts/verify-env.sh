#!/bin/bash

# GitHub Actions 环境验证脚本

echo "🔍 验证GitHub Actions构建环境..."

# 检查必要的环境变量
echo "📋 检查环境变量:"
echo "EXPO_TV: ${EXPO_TV:-❌ 未设置}"
echo "NODE_ENV: ${NODE_ENV:-❌ 未设置}"
echo "CI: ${CI:-❌ 未设置}"

# 检查必要的工具
echo ""
echo "🛠️ 检查必要工具:"

# Node.js
if command -v node >/dev/null 2>&1; then
    echo "✅ Node.js: $(node --version)"
else
    echo "❌ Node.js 未安装"
    exit 1
fi

# npm/yarn
if command -v yarn >/dev/null 2>&1; then
    echo "✅ Yarn: $(yarn --version)"
elif command -v npm >/dev/null 2>&1; then
    echo "✅ npm: $(npm --version)"
else
    echo "❌ npm/yarn 未安装"
    exit 1
fi

# Java
if command -v java >/dev/null 2>&1; then
    echo "✅ Java: $(java -version 2>&1 | head -n 1)"
else
    echo "❌ Java 未安装"
    exit 1
fi

# Android SDK
if [ -n "$ANDROID_HOME" ] || [ -n "$ANDROID_SDK_ROOT" ]; then
    echo "✅ Android SDK: ${ANDROID_HOME:-$ANDROID_SDK_ROOT}"
else
    echo "❌ Android SDK 环境变量未设置"
fi

# 检查必要文件
echo ""
echo "📁 检查项目文件:"

if [ -f "package.json" ]; then
    echo "✅ package.json 存在"
else
    echo "❌ package.json 不存在"
    exit 1
fi

if [ -f "app.json" ]; then
    echo "✅ app.json 存在"
else
    echo "❌ app.json 不存在"
    exit 1
fi

if [ -f "xml/AndroidManifest.xml" ]; then
    echo "✅ AndroidManifest.xml 存在"
else
    echo "⚠️ xml/AndroidManifest.xml 不存在"
fi

# 检查磁盘空间
echo ""
echo "💾 检查磁盘空间:"
df -h . | tail -1 | awk '{print "可用空间: " $4}'

echo ""
echo "✅ 环境验证完成!"