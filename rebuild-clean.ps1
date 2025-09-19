# OrionTV 完全清理并重新构建脚本
Write-Host "🚀 OrionTV 完全重建流程开始..." -ForegroundColor Green

# 删除所有缓存和构建文件
Write-Host "🧹 清理所有缓存和构建文件..." -ForegroundColor Yellow

# 清理项目构建文件
Remove-Item -Path "android" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path ".expo" -Recurse -Force -ErrorAction SilentlyContinue

# 清理Gradle全局缓存
Remove-Item -Path "$env:USERPROFILE\.gradle" -Recurse -Force -ErrorAction SilentlyContinue

# 清理npm/yarn缓存
Write-Host "📦 清理包管理器缓存..." -ForegroundColor Yellow
yarn cache clean
npm cache clean --force 2>$null

# 重新安装依赖
Write-Host "📦 重新安装依赖包..." -ForegroundColor Blue
yarn install

# 设置环境变量
$env:EXPO_TV = "1"
$env:EXPO_USE_METRO_WORKSPACE_ROOT = "1"
$env:NODE_ENV = "production"

# 重新生成Android项目
Write-Host "🔧 重新生成Android项目..." -ForegroundColor Blue
Write-Output "Y" | npx expo prebuild --platform android --clean --no-install

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Android项目生成成功" -ForegroundColor Green
    
    # 复制TV配置
    Write-Host "📋 复制Android TV配置..." -ForegroundColor Blue
    Copy-Item "xml\AndroidManifest.xml" "android\app\src\main\AndroidManifest.xml" -Force
    
    # 构建APK
    Write-Host "🔨 开始构建APK..." -ForegroundColor Blue
    Set-Location "android"
    
    # 使用gradlew构建
    if (Test-Path "gradlew.bat") {
        Write-Host "使用 gradlew.bat 构建..." -ForegroundColor Cyan
        & .\gradlew.bat clean assembleDebug --no-daemon --stacktrace --info
    } else {
        Write-Host "❌ 找不到gradlew.bat" -ForegroundColor Red
        Set-Location ".."
        exit 1
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ APK构建成功！" -ForegroundColor Green
        Write-Host "📱 APK位置: android\app\build\outputs\apk\debug\app-debug.apk" -ForegroundColor Green
        
        if (Test-Path "app\build\outputs\apk\debug\app-debug.apk") {
            $apkFile = Get-Item "app\build\outputs\apk\debug\app-debug.apk"
            Write-Host "📊 APK大小: $([math]::Round($apkFile.Length / 1MB, 2)) MB" -ForegroundColor Green
            Write-Host "🗂️ 完整路径: $($apkFile.FullName)" -ForegroundColor Green
        }
    } else {
        Write-Host "❌ APK构建失败" -ForegroundColor Red
    }
    
    Set-Location ".."
} else {
    Write-Host "❌ Android项目生成失败" -ForegroundColor Red
    exit 1
}

Write-Host "🎉 构建流程完成！" -ForegroundColor Green
Read-Host "按Enter键退出..."