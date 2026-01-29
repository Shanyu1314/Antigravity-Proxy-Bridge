#!/bin/bash

# ============================================================================
# 代理注入模块
# ============================================================================

# --- 注入代理配置 ---
inject_proxy() {
    log_info "💉 开始注入代理配置..."
    
    check_existing_backup
    inject_language_server_wrapper
    inject_main_js_proxy
    
    log "${GREEN}✅ 代理配置注入完成${NC}"
}

# --- 注入 Language Server Wrapper ---
inject_language_server_wrapper() {
    log_info "配置 Language Server 代理..."
    
    if [[ "$DRY_RUN" == true ]]; then
        log_warn "[DRY RUN] 跳过实际修改"
        return
    fi
    
    # 确保 .bak 文件存在
    if [[ ! -f "${LS_BIN}.bak" ]]; then
        cp "$LS_BIN" "${LS_BIN}.bak"
        log "  已备份: ${LS_BIN}.bak"
    fi
    
    # 计算并记录文件哈希值（用于审计）
    if command -v sha256sum &> /dev/null; then
        local file_hash=$(sha256sum "${LS_BIN}.bak" | awk '{print $1}')
        log "  文件哈希 (SHA256): $file_hash"
        echo "[$(date)] Language Server Hash: $file_hash" >> "$LOG_FILE"
    fi
    
    # 解决文件占用冲突：先删除再创建
    # 这样可以避免 "Text file busy" 错误
    log_info "  移除旧文件以避免占用冲突..."
    rm -f "$LS_BIN"
    
    # 创建 wrapper 脚本
    cat > "$LS_BIN" << 'WRAPPER_EOF'
#!/usr/bin/env bash
# Antigravity-Proxy-Bridge 自动生成的 Wrapper 脚本
# 使用 graftcp 为 Language Server 提供代理支持

set -e

# 日志文件
LOG_FILE="${LOG_FILE:-/tmp/antigravity-proxy-wrapper.log}"
mkdir -p "$(dirname "$LOG_FILE")"

# 记录启动
echo "[$(date --rfc-3339=seconds)] Wrapper started: $0 $*" >> "$LOG_FILE" 2>/dev/null || true

# 查找 graftcp
GRAFTCP_BIN="${GRAFTCP_BIN:-$(which graftcp 2>/dev/null || true)}"

# 设置 GODEBUG 提高兼容性
if [ -n "${GODEBUG:-}" ]; then
    export GODEBUG="${GODEBUG},netdns=cgo,http2client=0,tls13=0"
else
    export GODEBUG="netdns=cgo,http2client=0,tls13=0"
fi

# 使用 graftcp 启动原始二进制
if [ -n "$GRAFTCP_BIN" ] && [ -x "$GRAFTCP_BIN" ]; then
    echo "[$(date --rfc-3339=seconds)] Executing with graftcp: $GRAFTCP_BIN $0.bak $*" >> "$LOG_FILE" 2>/dev/null || true
    exec "$GRAFTCP_BIN" "$0.bak" "$@"
else
    echo "[$(date --rfc-3339=seconds)] graftcp not found, fallback to original binary" >> "$LOG_FILE" 2>/dev/null || true
    if [ -x "$0.bak" ]; then
        exec "$0.bak" "$@"
    else
        echo "[$(date --rfc-3339=seconds)] ERROR: $0.bak not found or not executable" >> "$LOG_FILE" 2>/dev/null || true
        echo "ERROR: graftcp 和原始二进制均不可用" >&2
        exit 2
    fi
fi
WRAPPER_EOF
    
    # 设置权限
    chmod +x "$LS_BIN"
    chmod +x "${LS_BIN}.bak"
    
    log "  Language Server Wrapper 已创建"
}

# --- 注入 Main JS 代理配置 ---
inject_main_js_proxy() {
    log_info "配置 Main JS 代理..."
    
    if [[ "$DRY_RUN" == true ]]; then
        log_warn "[DRY RUN] 跳过实际修改"
        return
    fi
    
    # 检查是否已注入
    if grep -q "Antigravity-Proxy-Bridge" "$MAIN_JS"; then
        log_warn "检测到已注入代理配置，将重新注入"
        # 恢复原始文件
        if [[ -f "${MAIN_JS}.bak" ]]; then
            cp "${MAIN_JS}.bak" "$MAIN_JS"
        fi
    fi
    
    # 计算并记录文件哈希值（用于审计）
    if command -v sha256sum &> /dev/null; then
        local file_hash=$(sha256sum "${MAIN_JS}.bak" 2>/dev/null | awk '{print $1}')
        if [[ -n "$file_hash" ]]; then
            log "  文件哈希 (SHA256): $file_hash"
            echo "[$(date)] Main JS Hash: $file_hash" >> "$LOG_FILE"
        fi
    fi
    
    # 检测模块类型
    local module_type=$(detect_js_module_type "$MAIN_JS")
    log_info "检测到 JS 模块类型: $module_type"
    
    # 创建临时文件
    local temp_file=$(mktemp)
    
    # 根据模块类型生成注入代码
    if [[ "$module_type" == "esm" ]]; then
        generate_esm_proxy_code > "$temp_file"
    else
        generate_commonjs_proxy_code > "$temp_file"
    fi
    
    # 追加原始内容
    cat "$MAIN_JS" >> "$temp_file"
    
    # 替换原文件
    mv "$temp_file" "$MAIN_JS"
    chmod 644 "$MAIN_JS"
    
    log "  Main JS 代理配置已注入"
}

# --- 生成 ESM 代理代码 ---
generate_esm_proxy_code() {
    cat << EOF
// ========== Antigravity-Proxy-Bridge 代理配置 START ==========
// 自动生成时间: $(date)
// 代理地址: ${DEFAULT_PROXY}

import { createRequire } from 'module';
const require = createRequire(import.meta.url);

// 设置环境变量
process.env.HTTP_PROXY = '${DEFAULT_PROXY}';
process.env.HTTPS_PROXY = '${DEFAULT_PROXY}';
process.env.http_proxy = '${DEFAULT_PROXY}';
process.env.https_proxy = '${DEFAULT_PROXY}';
process.env.NO_PROXY = 'localhost,127.0.0.1';
process.env.no_proxy = 'localhost,127.0.0.1';

console.log('[Proxy Init] Environment variables set');

// 动态导入并配置 undici
(async () => {
    try {
        const undici = await import('undici');
        if (undici.setGlobalDispatcher && undici.ProxyAgent) {
            const proxyAgent = new undici.ProxyAgent('${DEFAULT_PROXY}');
            undici.setGlobalDispatcher(proxyAgent);
            console.log('[Proxy Init] undici ProxyAgent configured successfully');
        }
    } catch (error) {
        console.error('[Proxy Init] Failed to configure undici:', error.message);
    }
})();

console.log('[Proxy Init] Proxy configuration completed');
// ========== Antigravity-Proxy-Bridge 代理配置 END ==========

EOF
}

# --- 生成 CommonJS 代理代码 ---
generate_commonjs_proxy_code() {
    cat << EOF
// ========== Antigravity-Proxy-Bridge 代理配置 START ==========
// 自动生成时间: $(date)
// 代理地址: ${DEFAULT_PROXY}

// 设置环境变量
process.env.HTTP_PROXY = '${DEFAULT_PROXY}';
process.env.HTTPS_PROXY = '${DEFAULT_PROXY}';
process.env.http_proxy = '${DEFAULT_PROXY}';
process.env.https_proxy = '${DEFAULT_PROXY}';
process.env.NO_PROXY = 'localhost,127.0.0.1';
process.env.no_proxy = 'localhost,127.0.0.1';

console.log('[Proxy Init] Environment variables set');

// 配置 undici (如果可用)
try {
    const undici = require('undici');
    if (undici.setGlobalDispatcher && undici.ProxyAgent) {
        const proxyAgent = new undici.ProxyAgent('${DEFAULT_PROXY}');
        undici.setGlobalDispatcher(proxyAgent);
        console.log('[Proxy Init] undici ProxyAgent configured successfully');
    }
} catch (error) {
    console.error('[Proxy Init] Failed to configure undici:', error.message);
}

console.log('[Proxy Init] Proxy configuration completed');
// ========== Antigravity-Proxy-Bridge 代理配置 END ==========

EOF
}
