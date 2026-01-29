#!/bin/bash

# ============================================================================
# 路径自动探测模块
# ============================================================================

# --- 探测使用场景 ---
detect_scenario() {
    echo ""
    log_info "请选择你的使用场景："
    echo ""
    echo "  1) 本地安装的 Antigravity 桌面版 (/usr/share/antigravity)"
    echo "  2) 服务器上安装的 Antigravity Server (~/.antigravity-server)"
    echo "  3) Remote-SSH 模式（本地 Antigravity 连接远程服务器）"
    echo ""
    
    read -p "请输入选项 (1/2/3): " -n 1 -r scenario_choice
    echo ""
    echo ""
    
    case $scenario_choice in
        1)
            SCENARIO="desktop"
            log "选择场景: 桌面版"
            ;;
        2)
            SCENARIO="server"
            log "选择场景: 服务器版"
            ;;
        3)
            SCENARIO="remote-ssh"
            log_error "❌ Remote-SSH 模式不需要在服务器上运行此脚本！"
            echo ""
            log_info "💡 正确的配置方法："
            echo ""
            echo "  1. 在本地 Windows 打开 Antigravity 设置 (Ctrl+,)"
            echo "  2. 切换到 'User' 标签"
            echo "  3. 搜索 'proxy'"
            echo "  4. 设置 'Http: Proxy' 为: http://127.0.0.1:7890"
            echo "  5. 重启 Antigravity"
            echo ""
            log_info "📖 详细指南: docs/remote-ssh-guide.md"
            echo ""
            exit 0
            ;;
        *)
            log_error "无效的选项"
            exit 1
            ;;
    esac
}

# --- 自动探测 Antigravity 路径 ---
detect_paths() {
    log_info "🔍 正在探测 Antigravity 安装路径..."
    
    case $SCENARIO in
        desktop)
            detect_desktop_paths
            ;;
        server)
            detect_server_paths
            ;;
    esac
    
    # 验证路径
    if [[ -z "$LS_BIN" ]] || [[ ! -f "$LS_BIN" ]]; then
        log_error "未找到 language_server_linux_x64"
        log_info "请确认 Antigravity 已正确安装"
        exit 1
    fi
    
    if [[ -z "$MAIN_JS" ]] || [[ ! -f "$MAIN_JS" ]]; then
        log_error "未找到 main.js 或 server-main.js"
        log_info "请确认 Antigravity 已正确安装"
        exit 1
    fi
    
    log "${GREEN}✅ 路径探测成功${NC}"
    log "  Language Server: $LS_BIN"
    log "  Main JS: $MAIN_JS"
}

# --- 探测桌面版路径 ---
detect_desktop_paths() {
    local base_path="/usr/share/antigravity"
    
    log_info "探测桌面版路径: $base_path"
    
    # 查找 language_server
    LS_BIN="$base_path/resources/app/extensions/antigravity/bin/language_server_linux_x64"
    
    # 查找 main.js
    MAIN_JS="$base_path/resources/app/out/main.js"
    
    if [[ ! -f "$LS_BIN" ]]; then
        log_warn "在标准路径未找到，尝试搜索..."
        LS_BIN=$(find "$base_path" -name "language_server_linux_x64" 2>/dev/null | head -n 1)
    fi
    
    if [[ ! -f "$MAIN_JS" ]]; then
        log_warn "在标准路径未找到 main.js，尝试搜索..."
        MAIN_JS=$(find "$base_path" -name "main.js" 2>/dev/null | head -n 1)
    fi
}

# --- 探测服务器版路径 ---
detect_server_paths() {
    local base_path="$HOME/.antigravity-server"
    
    log_info "探测服务器版路径: $base_path"
    
    if [[ ! -d "$base_path" ]]; then
        log_error "未找到 $base_path 目录"
        log_info "请确认 Antigravity Server 已安装"
        exit 1
    fi
    
    # 使用 find 命令搜索（支持哈希路径）
    log_info "搜索 language_server_linux_x64..."
    LS_BIN=$(find "$base_path" -name "language_server_linux_x64" -type f 2>/dev/null | head -n 1)
    
    log_info "搜索 server-main.js 或 main.js..."
    MAIN_JS=$(find "$base_path" -name "server-main.js" -type f 2>/dev/null | head -n 1)
    
    if [[ -z "$MAIN_JS" ]]; then
        MAIN_JS=$(find "$base_path" -name "main.js" -type f 2>/dev/null | head -n 1)
    fi
    
    if [[ -n "$LS_BIN" ]]; then
        log_info "找到 Language Server: $LS_BIN"
    fi
    
    if [[ -n "$MAIN_JS" ]]; then
        log_info "找到 Main JS: $MAIN_JS"
    fi
}

# --- 检测文件类型（ESM 或 CommonJS）---
detect_js_module_type() {
    local js_file="$1"
    
    if grep -q "import.*from" "$js_file" || grep -q "export.*{" "$js_file"; then
        echo "esm"
    else
        echo "commonjs"
    fi
}
