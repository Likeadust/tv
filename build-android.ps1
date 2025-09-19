# OrionTV Android APK 构建脚本
Write-Host "🚀 开始构建 OrionTV Android APK..." -ForegroundColor Green

# 设置环境变量
$env:EXPO_TV = "1"
$env:EXPO_USE_METRO_WORKSPACE_ROOT = "1"
$env:NODE_ENV = "production"

try {
    Write-Host "🧹 清理旧的构建文件..." -ForegroundColor Yellow
    if (Test-Path "android") {
        Remove-Item -Path "android" -Recurse -Force
    }

    Write-Host "📦 第一步: 生成 Android 项目..." -ForegroundColor Blue
    $result = & npx expo prebuild --platform android --clean --no-install 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Prebuild 失败: $result"
    }

    Write-Host "📋 第二步: 复制 TV 配置文件..." -ForegroundColor Blue
    if (-not (Test-Path "android\app\src\main\")) {
        throw "Android 项目结构不正确"
    }
    Copy-Item "xml\AndroidManifest.xml" "android\app\src\main\AndroidManifest.xml" -Force

    Write-Host "🔨 第三步: 构建 Debug APK..." -ForegroundColor Blue
    Set-Location "android"
    
    if (Test-Path "gradlew.bat") {
        Write-Host "📋 使用 gradlew.bat 构建..." -ForegroundColor Cyan
        & .\gradlew.bat assembleDebug --no-daemon --stacktrace
    } elseif (Test-Path "gradlew") {
        Write-Host "📋 使用 gradlew 构建..." -ForegroundColor Cyan
        & .\gradlew assembleDebug --no-daemon --stacktrace
    } else {
        throw "Gradle wrapper 不存在"
    }

    if ($LASTEXITCODE -ne 0) {
        throw "APK 构建失败"
    }

    Write-Host "✅ APK 构建成功！" -ForegroundColor Green
    Write-Host "📱 APK 文件位置: android\app\build\outputs\apk\debug\app-debug.apk" -ForegroundColor Green
    
    if (Test-Path "app\build\outputs\apk\debug\app-debug.apk") {
        $apkInfo = Get-Item "app\build\outputs\apk\debug\app-debug.apk"
        Write-Host "📊 APK 文件大小: $([math]::Round($apkInfo.Length / 1MB, 2)) MB" -ForegroundColor Green
    }

} catch {
    Write-Host "❌ 构建失败: $_" -ForegroundColor Red
    exit 1
} finally {
    Set-Location ".."
}

Write-Host "✅ 构建完成！" -ForegroundColor Green
Read-Host "按 Enter 继续..."