# OrionTV Windows PowerShell 构建脚本
# 基于项目记忆优化的本地构建方案

param(
    [Parameter(Position=0)]
    [ValidateSet("debug", "release", "clean", "help")]
    [string]$Action = "help"
)

function Write-ColorText {
    param([string]$Text, [string]$Color = "White")
    Write-Host $Text -ForegroundColor $Color
}

function Test-Prerequisites {
    Write-ColorText "🔍 检查构建环境..." "Cyan"
    
    # 检查Node.js
    try {
        $nodeVersion = node --version 2>$null
        Write-ColorText "✅ Node.js: $nodeVersion" "Green"
    } catch {
        Write-ColorText "❌ Node.js 未安装或不在PATH中" "Red"
        return $false
    }
    
    # 检查Yarn
    try {
        $yarnVersion = yarn --version 2>$null
        Write-ColorText "✅ Yarn: v$yarnVersion" "Green"
    } catch {
        Write-ColorText "❌ Yarn 未安装" "Red"
        return $false
    }
    
    # 检查Java
    try {
        $javaVersion = java -version 2>&1 | Select-String "version"
        Write-ColorText "✅ Java: $javaVersion" "Green"
    } catch {
        Write-ColorText "❌ Java 未安装或配置不正确" "Red"
        return $false
    }
    
    return $true
}

function Invoke-CleanBuild {
    Write-ColorText "🧹 执行完全清理..." "Yellow"
    
    # 清理项目构建文件
    @("android", ".expo", "node_modules") | ForEach-Object {
        if (Test-Path $_) {
            Write-ColorText "  清理 $_..." "DarkYellow"
            Remove-Item -Path $_ -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    
    # 清理Gradle缓存（谨慎操作）
    $gradleCache = "$env:USERPROFILE\.gradle\caches"
    if (Test-Path $gradleCache) {
        Write-ColorText "  清理Gradle缓存..." "DarkYellow"
        Remove-Item -Path $gradleCache -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    # 清理包管理器缓存
    Write-ColorText "  清理包管理器缓存..." "DarkYellow"
    yarn cache clean 2>$null
    npm cache clean --force 2>$null
    
    Write-ColorText "✅ 清理完成" "Green"
}

function Install-Dependencies {
    Write-ColorText "📦 安装项目依赖..." "Blue"
    
    try {
        yarn install --frozen-lockfile --network-timeout 300000
        if ($LASTEXITCODE -ne 0) {
            throw "Yarn安装失败"
        }
        Write-ColorText "✅ 依赖安装成功" "Green"
        return $true
    } catch {
        Write-ColorText "❌ 依赖安装失败: $_" "Red"
        return $false
    }
}

function Invoke-Prebuild {
    Write-ColorText "🔧 生成Android原生项目..." "Blue"
    
    # 设置环境变量
    $env:EXPO_TV = "1"
    $env:EXPO_USE_METRO_WORKSPACE_ROOT = "1"
    $env:NODE_ENV = "production"
    
    try {
        # 使用echo来自动确认
        $process = Start-Process -FilePath "npx" -ArgumentList @("expo", "prebuild", "--platform", "android", "--clean", "--no-install") -NoNewWindow -PassThru
        
        # 等待进程启动，然后发送确认
        Start-Sleep -Seconds 2
        
        # 如果进程还在运行（等待输入），则结束它并用管道方式重新启动
        if (!$process.HasExited) {
            $process.Kill()
            Write-ColorText "  使用自动确认模式..." "DarkCyan"
            
            # 使用PowerShell的输入重定向
            $prebuildScript = @"
Write-Output 'Y' | npx expo prebuild --platform android --clean --no-install
"@
            $result = Invoke-Expression $prebuildScript
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorText "✅ Android项目生成成功" "Green"
            return $true
        } else {
            throw "Prebuild失败，退出码: $LASTEXITCODE"
        }
    } catch {
        Write-ColorText "❌ Prebuild失败: $_" "Red"
        return $false
    }
}

function Copy-TVConfiguration {
    Write-ColorText "📋 复制Android TV配置..." "Blue"
    
    $sourceManifest = "xml\AndroidManifest.xml"
    $targetManifest = "android\app\src\main\AndroidManifest.xml"
    
    if (!(Test-Path $sourceManifest)) {
        Write-ColorText "❌ 源配置文件不存在: $sourceManifest" "Red"
        return $false
    }
    
    if (!(Test-Path "android\app\src\main")) {
        Write-ColorText "❌ Android项目结构不完整" "Red"
        return $false
    }
    
    try {
        Copy-Item $sourceManifest $targetManifest -Force
        Write-ColorText "✅ TV配置复制成功" "Green"
        return $true
    } catch {
        Write-ColorText "❌ 配置复制失败: $_" "Red"
        return $false
    }
}

function Invoke-GradleBuild {
    param([string]$BuildType = "debug")
    
    Write-ColorText "🔨 开始构建$BuildType APK..." "Blue"
    
    if (!(Test-Path "android")) {
        Write-ColorText "❌ android目录不存在，请先运行prebuild" "Red"
        return $false
    }
    
    Push-Location "android"
    
    try {
        $gradleWrapper = if (Test-Path "gradlew.bat") { ".\gradlew.bat" } else { ".\gradlew" }
        
        if (!(Test-Path $gradleWrapper.TrimStart('.\\'))) {
            Write-ColorText "❌ Gradle wrapper不存在" "Red"
            return $false
        }
        
        Write-ColorText "  使用 $gradleWrapper 构建..." "Cyan"
        
        $gradleTask = if ($BuildType -eq "release") { "assembleRelease" } else { "assembleDebug" }
        
        # 执行Gradle构建
        & $gradleWrapper $gradleTask --no-daemon --stacktrace --info
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorText "✅ APK构建成功！" "Green"
            
            # 查找并显示APK信息
            $apkPattern = "app\build\outputs\apk\$BuildType\*.apk"
            $apkFiles = Get-ChildItem -Path $apkPattern -ErrorAction SilentlyContinue
            
            if ($apkFiles) {
                foreach ($apk in $apkFiles) {
                    $sizeMB = [math]::Round($apk.Length / 1MB, 2)
                    Write-ColorText "📱 APK文件: $($apk.Name) (${sizeMB}MB)" "Green"
                    Write-ColorText "📂 完整路径: $($apk.FullName)" "Green"
                }
            }
            return $true
        } else {
            Write-ColorText "❌ Gradle构建失败，退出码: $LASTEXITCODE" "Red"
            return $false
        }
    } catch {
        Write-ColorText "❌ 构建过程出错: $_" "Red"
        return $false
    } finally {
        Pop-Location
    }
}

function Show-Help {
    Write-ColorText "🚀 OrionTV Windows PowerShell 构建脚本" "Green"
    Write-ColorText ""
    Write-ColorText "用法: .\build-helper.ps1 [action]" "White"
    Write-ColorText ""
    Write-ColorText "可用操作:" "Yellow"
    Write-ColorText "  debug    - 构建Debug APK（完整流程）" "White"
    Write-ColorText "  release  - 构建Release APK（完整流程）" "White"
    Write-ColorText "  clean    - 仅执行清理操作" "White"
    Write-ColorText "  help     - 显示此帮助信息" "White"
    Write-ColorText ""
    Write-ColorText "示例:" "Yellow"
    Write-ColorText "  .\build-helper.ps1 debug" "Cyan"
    Write-ColorText "  .\build-helper.ps1 release" "Cyan"
    Write-ColorText ""
}

# 主执行逻辑
switch ($Action) {
    "help" {
        Show-Help
        exit 0
    }
    
    "clean" {
        if (!(Test-Prerequisites)) {
            exit 1
        }
        Invoke-CleanBuild
        Write-ColorText "🎉 清理完成！" "Green"
        exit 0
    }
    
    { $_ -in @("debug", "release") } {
        Write-ColorText "🚀 开始 OrionTV $Action 构建流程..." "Green"
        Write-ColorText ""
        
        # 1. 检查环境
        if (!(Test-Prerequisites)) {
            Write-ColorText "❌ 环境检查失败，请安装必要的工具" "Red"
            exit 1
        }
        
        # 2. 清理环境
        Invoke-CleanBuild
        
        # 3. 安装依赖
        if (!(Install-Dependencies)) {
            exit 1
        }
        
        # 4. 生成Android项目
        if (!(Invoke-Prebuild)) {
            exit 1
        }
        
        # 5. 复制TV配置
        if (!(Copy-TVConfiguration)) {
            exit 1
        }
        
        # 6. 构建APK
        if (!(Invoke-GradleBuild -BuildType $Action)) {
            exit 1
        }
        
        Write-ColorText ""
        Write-ColorText "🎉 $Action APK 构建完成！" "Green"
    }
    
    default {
        Write-ColorText "❌ 未知操作: $Action" "Red"
        Show-Help
        exit 1
    }
}