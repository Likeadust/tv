@echo off
setlocal EnableDelayedExpansion

REM OrionTV 构建辅助脚本 (Windows版本)
REM 使用说明：scripts\build-helper.bat [action]

set "action=%~1"
if "%action%"=="" set "action=help"

REM 检查 GitHub CLI
where gh >nul 2>nul
if errorlevel 1 (
    echo ❌ GitHub CLI (gh) 未安装
    echo 请访问: https://cli.github.com/
    exit /b 1
)

REM 检查登录状态
gh auth status >nul 2>nul
if errorlevel 1 (
    echo ❌ GitHub CLI 未登录
    echo 请运行: gh auth login
    exit /b 1
)

REM 获取当前版本
for /f "tokens=*" %%i in ('node -p "require('./package.json').version" 2^>nul') do set "current_version=%%i"
if "%current_version%"=="" set "current_version=unknown"

goto %action% 2>nul || goto help

:debug
echo 🏗️ 触发 Debug 构建...
gh workflow run "build-tv.yml" --field build_type="debug" --field upload_to_release="false"
echo ✅ 构建已触发
echo 查看状态: gh run list --workflow=build-tv.yml
goto :eof

:release
echo 🏗️ 触发 Release 构建...
gh workflow run "build-tv.yml" --field build_type="release" --field upload_to_release="false"
echo ✅ 构建已触发
echo 查看状态: gh run list --workflow=build-tv.yml
goto :eof

:create
echo 🎉 创建新版本发布
echo 当前版本: %current_version%
echo.
set /p "new_version=请输入新版本号 (格式: x.y.z): "
if "%new_version%"=="" (
    echo ❌ 版本号不能为空
    exit /b 1
)

echo.
set /p "release_notes=请输入更新说明 (可选): "

echo 🚀 创建版本 %new_version%...
gh workflow run "release.yml" --field version="%new_version%" --field release_notes="%release_notes%"
echo ✅ 发布流程已启动
echo 查看进度: gh run list --workflow=release.yml
goto :eof

:status
echo 📊 最近的构建状态
echo.
echo 📱 主构建流程 (build-tv.yml):
gh run list --workflow=build-tv.yml --limit=5
echo.
echo 🎉 发布流程 (release.yml):
gh run list --workflow=release.yml --limit=3
goto :eof

:help
echo 🚀 OrionTV 构建辅助脚本
echo.
echo 用法: %~nx0 [action]
echo.
echo 可用操作:
echo   debug     - 触发 Debug 构建
echo   release   - 触发 Release 构建
echo   create    - 创建新版本发布
echo   status    - 查看最近的构建状态
echo   help      - 显示此帮助信息
echo.
echo 示例:
echo   %~nx0 debug                    # 构建 Debug 版本
echo   %~nx0 release                  # 构建 Release 版本
echo   %~nx0 create                   # 交互式创建新版本
echo.
goto :eof