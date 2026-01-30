#!/bin/bash

# ============================================================================
# 备份管理模块
# ============================================================================

# --- 备份文件 ---
backup_files() {
    log_info "📦 开始备份原始文件..."
    
    # 创建带时间戳的备份目录
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_subdir="${BACKUP_DIR}/${timestamp}"
    mkdir -p "$backup_subdir"
    
    # 备份 language_server
    if [[ -f "$LS_BIN" ]]; then
        if [[ ! -f "${LS_BIN}.bak" ]]; then
            log_info "备份 Language Server..."
            if [[ "$DRY_RUN" == false ]]; then
                cp "$LS_BIN" "${LS_BIN}.bak"
                cp "$LS_BIN" "${backup_subdir}/language_server_linux_x64"
            fi
            log "  ${LS_BIN} -> ${LS_BIN}.bak"
        else
            log_warn "Language Server 备份已存在，跳过"
        fi
    fi
    
    # 备份 main.js
    if [[ -f "$MAIN_JS" ]]; then
        if [[ ! -f "${MAIN_JS}.bak" ]]; then
            log_info "备份 Main JS..."
            if [[ "$DRY_RUN" == false ]]; then
                cp "$MAIN_JS" "${MAIN_JS}.bak"
                cp "$MAIN_JS" "${backup_subdir}/$(basename "$MAIN_JS")"
            fi
            log "  ${MAIN_JS} -> ${MAIN_JS}.bak"
        else
            log_warn "Main JS 备份已存在，跳过"
        fi
    fi
    
    # 记录备份信息
    cat > "${backup_subdir}/backup_info.txt" << EOF
备份时间: $(date)
场景: $SCENARIO
Language Server: $LS_BIN
Main JS: $MAIN_JS
代理地址: $DEFAULT_PROXY
EOF
    
    log "${GREEN}✅ 备份完成${NC}"
    log "  备份位置: $backup_subdir"
}

# --- 检查是否已备份 ---
check_existing_backup() {
    if [[ -f "${LS_BIN}.bak" ]] || [[ -f "${MAIN_JS}.bak" ]]; then
        log_warn "检测到已存在备份文件"
        log_info "这可能意味着："
        echo "  1. 之前已经运行过此脚本"
        echo "  2. 文件已被修改"
        echo ""
        
        read -p "是否覆盖现有配置？(y/N) " -n 1 -r
        echo ""
        
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log "用户选择取消"
            exit 0
        fi
        
        log "用户选择覆盖..."
    fi
}

# --- 恢复备份 ---
restore_backup() {
    log_info "🔄 正在恢复备份..."
    
    local restored=false
    
    # 恢复 language_server
    if [[ -f "${LS_BIN}.bak" ]]; then
        log_info "恢复 Language Server..."
        cp "${LS_BIN}.bak" "$LS_BIN"
        rm "${LS_BIN}.bak"
        log "  ${LS_BIN}.bak -> ${LS_BIN}"
        restored=true
    fi
    
    # 恢复 main.js
    if [[ -f "${MAIN_JS}.bak" ]]; then
        log_info "恢复 Main JS..."
        cp "${MAIN_JS}.bak" "$MAIN_JS"
        rm "${MAIN_JS}.bak"
        log "  ${MAIN_JS}.bak -> ${MAIN_JS}"
        restored=true
    fi
    
    if [[ "$restored" == true ]]; then
        log "${GREEN}✅ 恢复完成${NC}"
    else
        log_warn "未找到备份文件"
    fi
}
