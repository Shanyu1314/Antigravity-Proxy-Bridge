#!/bin/bash

# ============================================================================
# 网络环境检测模块
# ============================================================================

# --- 检测网络访问能力 ---
check_network_access() {
    log_info "🔍 正在检测网络环境..."
    
    # 测试是否能访问 Google
    if curl -s --connect-timeout 5 https://www.google.com > /dev/null 2>&1; then
        echo ""
        log "${GREEN}✅ 检测到可以直接访问国际网络${NC}"
        log_info "💡 你的服务器（可能在美国/欧洲）通常不需要配置代理！"
        echo ""
        
        read -p "是否仍要继续配置？(y/N) " -n 1 -r
        echo ""
        
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log "用户选择取消配置"
            echo ""
            log_info "如果你在使用 Remote-SSH 模式，请查看文档："
            log_info "  docs/remote-ssh-guide.md"
            echo ""
            exit 0
        fi
        
        log "用户选择继续配置..."
    else
        echo ""
        log_warn "⚠️  检测到无法访问国际网络（可能是国内 VPS）"
        log_info "📦 需要配置代理以使用 Antigravity AI 功能"
        echo ""
    fi
    
    # 测试代理是否可用
    check_proxy_availability
}

# --- 检测代理服务是否运行 ---
check_proxy_availability() {
    local proxy_host proxy_port
    
    # 从代理 URL 提取主机和端口
    if [[ $DEFAULT_PROXY =~ http://([^:]+):([0-9]+) ]]; then
        proxy_host="${BASH_REMATCH[1]}"
        proxy_port="${BASH_REMATCH[2]}"
    else
        log_warn "无法解析代理地址: $DEFAULT_PROXY"
        return 1
    fi
    
    log_info "检测代理服务: $proxy_host:$proxy_port"
    
    # 检测端口是否开放
    if command -v nc &> /dev/null; then
        if nc -z -w2 "$proxy_host" "$proxy_port" 2>/dev/null; then
            log "${GREEN}✅ 代理服务运行正常${NC}"
            return 0
        else
            log_warn "⚠️  无法连接到代理服务 $proxy_host:$proxy_port"
            log_info "请确保 Clash/V2Ray 等代理服务正在运行"
            
            read -p "是否继续配置？(y/N) " -n 1 -r
            echo ""
            
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                log "用户选择取消"
                exit 0
            fi
        fi
    else
        log_warn "未安装 nc 工具，跳过代理检测"
    fi
}

# --- 测试代理连接 ---
test_proxy_connection() {
    log_info "测试通过代理访问 Google..."
    
    if curl -s --connect-timeout 5 --proxy "$DEFAULT_PROXY" https://www.google.com > /dev/null 2>&1; then
        log "${GREEN}✅ 代理连接测试成功${NC}"
        return 0
    else
        log_warn "⚠️  代理连接测试失败"
        log_info "请检查代理配置是否正确"
        return 1
    fi
}
