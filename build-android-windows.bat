@echo off
setlocal

echo 🚀 开始构建 OrionTV Android APK...

REM 设置环境变量
set EXPO_TV=1
set EXPO_USE_METRO_WORKSPACE_ROOT=1
set NODE_ENV=production

echo 🧹 清理旧的构建文件...
if exist android (
    rmdir /s /q android 2>nul
)

echo 📦 第一步: 生成 Android 项目...
call npx expo prebuild --platform android --clean --no-install
if errorlevel 1 (
    echo ❌ Prebuild 失败
    pause
    exit /b 1
)

echo 📋 第二步: 复制 TV 配置文件...
if not exist android\app\src\main\ (
    echo ❌ Android 项目结构不正确
    pause
    exit /b 1
)
copy xml\AndroidManifest.xml android\app\src\main\AndroidManifest.xml
if errorlevel 1 (
    echo ❌ 配置文件复制失败
    pause
    exit /b 1
)

echo 🔨 第三步: 构建 Debug APK...
cd android
if exist gradlew.bat (
    echo 📋 使用 gradlew.bat 构建...
    call gradlew.bat assembleDebug --no-daemon --stacktrace --info
) else if exist gradlew (
    echo 📋 使用 gradlew 构建...
    call gradlew assembleDebug --no-daemon --stacktrace --info
) else (
    echo ❌ Gradle wrapper 不存在
    pause
    exit /b 1
)

if errorlevel 1 (
    echo ❌ APK 构建失败
    cd ..
    pause
    exit /b 1
) else (
    echo ✅ APK 构建成功！
    echo 📱 APK 文件位置: android\app\build\outputs\apk\debug\app-debug.apk
    if exist app\build\outputs\apk\debug\app-debug.apk (
        echo 📊 APK 文件大小:
        dir app\build\outputs\apk\debug\app-debug.apk
    )
)

cd ..
echo ✅ 构建完成！
pause