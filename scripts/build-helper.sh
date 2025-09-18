#!/bin/bash

# OrionTV 构建辅助脚本
# 使用说明：./scripts/build-helper.sh [action]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 函数：打印带颜色的消息
print_message() {
    echo -e "${2}${1}${NC}"
}

# 函数：检查必要工具
check_requirements() {
    print_message "🔍 检查必要工具..." $BLUE
    
    if ! command -v gh &> /dev/null; then
        print_message "❌ GitHub CLI (gh) 未安装" $RED
        print_message "请访问: https://cli.github.com/" $YELLOW
        exit 1
    fi
    
    if ! gh auth status &> /dev/null; then
        print_message "❌ GitHub CLI 未登录" $RED
        print_message "请运行: gh auth login" $YELLOW
        exit 1
    fi
    
    print_message "✅ 检查通过" $GREEN
}

# 函数：获取当前版本
get_current_version() {
    if [ -f "package.json" ]; then
        node -p "require('./package.json').version"
    else
        echo "unknown"
    fi
}

# 函数：验证版本格式
validate_version() {
    if [[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}

# 函数：显示帮助信息
show_help() {
    echo -e "${BLUE}🚀 OrionTV 构建辅助脚本${NC}"
    echo ""
    echo "用法: $0 [action]"
    echo ""
    echo "可用操作:"
    echo "  debug     - 触发 Debug 构建"
    echo "  release   - 触发 Release 构建"
    echo "  create    - 创建新版本发布"
    echo "  status    - 查看最近的构建状态"
    echo "  help      - 显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 debug                    # 构建 Debug 版本"
    echo "  $0 release                  # 构建 Release 版本"
    echo "  $0 create                   # 交互式创建新版本"
    echo ""
}

# 函数：触发构建
trigger_build() {
    local build_type=$1
    print_message "🏗️ 触发 $build_type 构建..." $BLUE
    
    gh workflow run "build-tv.yml" \
        --field build_type="$build_type" \
        --field upload_to_release="false"
    
    print_message "✅ 构建已触发" $GREEN
    print_message "查看状态: gh run list --workflow=build-tv.yml" $YELLOW
}

# 函数：创建发布
create_release() {
    print_message "🎉 创建新版本发布" $BLUE
    
    current_version=$(get_current_version)
    print_message "当前版本: $current_version" $YELLOW
    
    echo ""
    read -p "请输入新版本号 (格式: x.y.z): " new_version
    
    if ! validate_version "$new_version"; then
        print_message "❌ 版本号格式无效" $RED
        exit 1
    fi
    
    echo ""
    read -p "请输入更新说明 (可选): " release_notes
    
    print_message "🚀 创建版本 $new_version..." $BLUE
    
    gh workflow run "release.yml" \
        --field version="$new_version" \
        --field release_notes="$release_notes"
    
    print_message "✅ 发布流程已启动" $GREEN
    print_message "查看进度: gh run list --workflow=release.yml" $YELLOW
}

# 函数：查看状态
show_status() {
    print_message "📊 最近的构建状态" $BLUE
    echo ""
    
    print_message "📱 主构建流程 (build-tv.yml):" $YELLOW
    gh run list --workflow=build-tv.yml --limit=5
    
    echo ""
    print_message "🎉 发布流程 (release.yml):" $YELLOW
    gh run list --workflow=release.yml --limit=3
}

# 主逻辑
main() {
    case "${1:-help}" in
        "debug")
            check_requirements
            trigger_build "debug"
            ;;
        "release")
            check_requirements
            trigger_build "release"
            ;;
        "create")
            check_requirements
            create_release
            ;;
        "status")
            check_requirements
            show_status
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            print_message "❌ 未知操作: $1" $RED
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"