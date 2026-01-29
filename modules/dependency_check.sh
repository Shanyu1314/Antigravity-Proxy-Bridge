#!/bin/bash

# ============================================================================
# 依赖检查模块
# ============================================================================

# --- 检查依赖 ---
check_dependencies() {
    log_info "🔍 检查依赖..."
    
    local all_ok=true
    
    # 检查 graftcp
    if command -v graftcp &> /dev/null; then
        local version=$(graftcp --version 2>&1 | head -n 1)
        log "${GREEN}✅ graftcp${NC} - $version"
    else
        log_error "❌ graftcp 未安装"
        all_ok=false
    fi
    
    # 检查 curl
    if command -v curl &> /dev/null; then
        log "${GREEN}✅ curl${NC}"
    else
        log_warn "⚠️  curl 未安装（推荐安装）"
    fi
    
    # 检查 nc (netcat)
    if command -v nc &> /dev/null; then
        log "${GREEN}✅ nc (netcat)${NC}"
    else
        log_warn "⚠️  nc 未安装（用于端口检测，可选）"
    fi
    
    # 检查 find
    if command -v find &> /dev/null; then
        log "${GREEN}✅ find${NC}"
    else
        log_error "❌ find 未安装"
        all_ok=false
    fi
    
    echo ""
    
    if [[ "$all_ok" == false ]]; then
        log_error "缺少必需的依赖"
        show_install_instructions
        exit 1
    fi
    
    log "${GREEN}✅ 所有必需依赖已安装${NC}"
}

# --- 显示安装说明 ---
show_install_instructions() {
    echo ""
    log_info "安装缺失的依赖："
    echo ""
    echo "Ubuntu/Debian:"
    echo "  sudo apt update"
    echo "  sudo apt install -y graftcp curl netcat-openbsd"
    echo ""
    echo "CentOS/RHEL:"
    echo "  sudo yum install -y graftcp curl nc"
    echo ""
    echo "Arch Linux:"
    echo "  sudo pacman -S graftcp curl gnu-netcat"
    echo ""
}

# --- 验证安装 ---
verify_installation() {
    log_info "🔍 验证安装..."
    
    # 检查文件是否存在
    if [[ ! -f "$LS_BIN" ]]; then
        log_error "Language Server 文件不存在"
        return 1
    fi
    
    if [[ ! -f "${LS_BIN}.bak" ]]; then
        log_error "Language Server 备份不存在"
        return 1
    fi
    
    if [[ ! -f "$MAIN_JS" ]]; then
        log_error "Main JS 文件不存在"
        return 1
    fi
    
    if [[ ! -f "${MAIN_JS}.bak" ]]; then
        log_error "Main JS 备份不存在"
        return 1
    fi
    
    # 检查权限
    if [[ ! -x "$LS_BIN" ]]; then
        log_error "Language Server 不可执行"
        return 1
    fi
    
    # 检查注入标记
    if ! grep -q "Antigravity-Proxy-Bridge" "$MAIN_JS"; then
        log_error "Main JS 代理配置未注入"
        return 1
    fi
    
    log "${GREEN}✅ 安装验证通过${NC}"
}

# --- 显示后续步骤 ---
show_next_steps() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_info "📋 后续步骤："
    echo ""
    echo "  1. 确保代理服务（Clash/V2Ray）正在运行"
    echo "  2. 重启 Antigravity 应用"
    echo "  3. 测试 AI 功能是否正常"
    echo ""
    log_info "📖 相关文档："
    echo "  - 故障排查: docs/troubleshooting.md"
    echo "  - 卸载方法: sudo ./uninstall.sh"
    echo ""
    log_info "📝 日志文件: $LOG_FILE"
    log_info "💾 备份目录: $BACKUP_DIR"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}
