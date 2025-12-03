#!/usr/bin/bash

set -e

# 显示帮助信息
show_help() {
    cat << EOF
用法: $0 [选项]

选项:
  icon         执行 flutter_launcher_icons 图标生成
  splash       执行 flutter_native_splash 启动页生成
  build_runner 执行 build_runner 代码生成
  build        执行 Flutter 构建（会自动更新构建号）
  all          执行所有任务（默认行为）
  help         显示此帮助信息

示例:
  $0 icon                    # 只生成应用图标
  $0 splash                  # 只生成启动页
  $0 build_runner            # 只运行代码生成
  $0 build                   # 只执行 Flutter 构建
  $0 all                     # 执行所有任务
  $0                         # 默认执行所有任务

注意: 只有在执行 'build' 或 'all' 命令时才会自动更新构建号。
EOF
}

# 检查必要的命令是否存在
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo "❌ 错误: 命令 '$1' 未找到，请安装后重试"
        exit 1
    fi
}

# 检查Flutter和Dart命令
check_flutter_commands() {
    if ! command -v flutter &> /dev/null; then
        echo "❌ 错误: flutter命令未找到，请确保Flutter已正确安装并配置PATH"
        exit 1
    fi
    
    if ! command -v dart &> /dev/null; then
        echo "❌ 错误: dart命令未找到，请确保Dart已正确安装并配置PATH"
        exit 1
    fi
}

# 更新版本构建号
update_build_number() {
    echo "🔧 开始更新构建号..."
    
    # 检查sed命令
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v gsed &> /dev/null; then
            SED_CMD="gsed"
        else
            SED_CMD="sed"
            check_command "sed"
        fi
    else
        SED_CMD="sed"
        check_command "sed"
    fi

    # 检查其他必要命令
    check_command "date"
    check_command "grep"
    check_command "cp"
    check_command "rm"

    # 检查pubspec.yaml文件是否存在
    if [[ ! -f "pubspec.yaml" ]]; then
        echo "❌ 错误: pubspec.yaml文件未找到"
        exit 1
    fi

    # 获取当前版本信息
    if ! CURRENT_VERSION_LINE=$(grep -E '^version: [0-9]+\.[0-9]+\.[0-9]+(\+[0-9]+)?$' pubspec.yaml); then
        echo "❌ 错误: 无法从pubspec.yaml中读取版本号"
        exit 1
    fi

    # 提取主版本号和构建号
    CURRENT_VERSION=$(echo "$CURRENT_VERSION_LINE" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    CURRENT_BUILD=$(echo "$CURRENT_VERSION_LINE" | grep -oE '\+[0-9]+' | sed 's/\+//' || echo "")

    # 获取当前日期，格式为YYYYMMDD
    CURRENT_DATE=$(date +%Y%m%d)
    echo "当前版本: $CURRENT_VERSION, 当前构建号: $CURRENT_BUILD, 新构建号: $CURRENT_DATE"

    # 备份原始pubspec.yaml文件
    cp pubspec.yaml pubspec.yaml.backup
    echo "✅ 已备份pubspec.yaml文件"

    # 构建新的版本字符串
    NEW_VERSION="$CURRENT_VERSION+$CURRENT_DATE"

    # 使用适当的sed命令进行替换
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if [[ "$SED_CMD" == "gsed" ]]; then
            $SED_CMD -i "s/version: $CURRENT_VERSION\(\+[0-9]*\)\?/version: $NEW_VERSION/" pubspec.yaml
        else
            $SED_CMD -i '' "s/version: $CURRENT_VERSION\(\+[0-9]*\)\?/version: $NEW_VERSION/" pubspec.yaml
        fi
    else
        $SED_CMD -i "s/version: $CURRENT_VERSION\(\+[0-9]*\)\?/version: $NEW_VERSION/" pubspec.yaml
    fi

    # 验证更新是否成功
    if grep -q "version: $NEW_VERSION" pubspec.yaml; then
        echo "✅ 版本构建号已成功更新为: $NEW_VERSION"
    else
        echo "❌ 版本构建号更新失败，恢复备份文件"
        cp pubspec.yaml.backup pubspec.yaml
        rm pubspec.yaml.backup
        exit 1
    fi
}

# 恢复构建号（在构建完成后）
restore_build_number() {
    if [[ -f "pubspec.yaml.backup" ]]; then
        echo "🔄 恢复原始构建号..."
        cp pubspec.yaml.backup pubspec.yaml
        rm pubspec.yaml.backup
        echo "✅ 构建号已恢复"
    fi
}

# 生成应用图标
generate_icons() {
    echo "🎨 生成应用图标..."
    dart run flutter_launcher_icons
    echo "✅ 应用图标生成完成"
}

# 生成启动页
generate_splash() {
    echo "🌅 生成启动页..."
    dart run flutter_native_splash:create
    echo "✅ 启动页生成完成"
}

# 运行代码生成
run_build_runner() {
    echo "🔨 运行代码生成..."
    dart run build_runner build --delete-conflicting-outputs
    echo "✅ 代码生成完成"
}

# 执行Flutter构建
run_flutter_build() {
    echo "🏗️  执行Flutter构建..."
    
    # 获取应用名称、版本号和构建号
    APP_NAME=$(grep -E '^name: ' pubspec.yaml | sed 's/name: //' | tr -d ' ')
    VERSION_INFO=$(grep -E '^version: ' pubspec.yaml | sed 's/version: //')
    VERSION=$(echo "$VERSION_INFO" | cut -d'+' -f1)
    BUILD_NUMBER=$(echo "$VERSION_INFO" | cut -d'+' -f2)
    
    # 构建输出文件名
    OUTPUT_NAME="${APP_NAME}_${VERSION}_${BUILD_NUMBER}.apk"
    
    echo "应用名称: $APP_NAME"
    echo "版本号: $VERSION"
    echo "构建号: $BUILD_NUMBER"
    echo "目标输出文件名: $OUTPUT_NAME"
    
    # 执行构建（使用默认输出路径）
    flutter build apk --release --no-tree-shake-icons
    
    # 查找生成的APK文件
    DEFAULT_APK="build/app/outputs/flutter-apk/app-release.apk"
    
    if [[ -n "$DEFAULT_APK" && -f "$DEFAULT_APK" ]]; then
        echo "✅ Flutter构建完成，找到默认输出文件: $(basename "$DEFAULT_APK")"
        
        # 重命名文件
        OUTPUT_PATH="build/app/outputs/flutter-apk/$OUTPUT_NAME"
        cp "$DEFAULT_APK" "$OUTPUT_PATH"
        
        if [[ -f "$OUTPUT_PATH" ]]; then
            echo "✅ 文件已重命名为: $OUTPUT_NAME"
            echo "📁 文件位置: $OUTPUT_PATH"
            echo "📊 文件大小: $(du -h "$OUTPUT_PATH" | cut -f1)"
        else
            echo "❌ 文件重命名失败"
            echo "📁 原始文件位置: $DEFAULT_APK"
        fi
    
    else
        echo "❌ Flutter构建失败，未找到输出文件"
        # 尝试查找其他可能的输出位置
        echo "🔍 搜索其他可能的输出位置..."
        find build/ -name "*.apk" 2>/dev/null | head -5
        exit 1
    fi
}

# 获取参数
ACTION="${1:-all}"

case "$ACTION" in
    icon)
        check_flutter_commands
        flutter pub get
        generate_icons
        ;;
        
    splash)
        check_flutter_commands
        flutter pub get
        generate_splash
        ;;
        
    build_runner)
        check_flutter_commands
        flutter pub get
        run_build_runner
        ;;
        
    build)
        check_flutter_commands
        update_build_number
        flutter pub get
        run_flutter_build
        restore_build_number
        ;;
        
    all|"")
        check_flutter_commands
        update_build_number
        flutter pub get
        generate_icons
        generate_splash
        run_build_runner
        run_flutter_build
        restore_build_number
        echo "✅ 所有构建任务已完成！"
        ;;
        
    help|--help|-h)
        show_help
        ;;
        
    *)
        echo "❌ 错误: 未知参数 '$ACTION'"
        echo ""
        show_help
        exit 1
        ;;
esac