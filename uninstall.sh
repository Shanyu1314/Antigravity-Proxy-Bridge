#!/bin/bash

# ============================================================================
# Antigravity-Proxy-Bridge - 卸载脚本
# 版本: 1.0.0
# 作者: Shanyu1314
# 许可: MIT License
# ============================================================================

set -euo pipefail

# --- 颜色定义 ---
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# --- 全局变量 ---
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="${SCRIPT_DIR}/uninstall.log"

# --- 日志函数 ---
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $*" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" | tee -a "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*" | tee -a "$LOG_FILE"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*" | tee -a "$LOG_FILE"
}

# --- 显示横幅 ---
show_banner() {
    cat << "EOF"
    _          _   _                       _ _         
   / \   _ __ | |_(_) __ _ _ __ __ ___   _(_) |_ _   _ 
  / _ \ | '_ \| __| |/ _` | '__/ _` \ \ / / | __| | | |
 / ___ \| | | | |_| | (_| | | | (_| |\ V /| | |_| |_| |
/_/   \_\_| |_|\__|_|\__, |_|  \__,_| \_/ |_|\__|\__, |
                     |___/                       |___/ 
    ____       _     _            
   | __ ) _ __(_) __| | __ _  ___ 
   |  _ \| '__| |/ _` |/ _` |/ _ \
   | |_) | |  | | (_| | (_| |  __/
   |____/|_|  |_|\__,_|\__, |\___|
                       |___/      
    _   _       _           _        _ _ 
   | | | |_ __ (_)_ __  ___| |_ __ _| | |
   | | | | '_ \| | '_ \/ __| __/ _` | | |
   | |_| | | | | | | | \__ \ || (_| | | |
    \___/|_| |_|_|_| |_|___/\__\__,_|_|_|

EOF
    echo -e "${YELLOW}=== Antigravity 代理配置卸载工具 v1.0.0 ===${NC}"
    echo ""
}

# --- 检查 root 权限 ---
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "此脚本需要 root 权限运行"
        echo "请使用: sudo ./uninstall.sh"
        exit 1
    fi
}

# --- 查找备份文件 ---
find_backup_files() {
    log_info "🔍 查找备份文件..."
    
    local found_files=()
    
    # 搜索所有可能的路径
    local search_paths=(
        "/usr/share/antigravity"
        "$HOME/.antigravity-server"
    )
    
    for base_path in "${search_paths[@]}"; do
        if [[ -d "$base_path" ]]; then
            while IFS= read -r -d '' file; do
                found_files+=("$file")
            done < <(find "$base_path" -name "*.bak" -type f -print0 2>/dev/null)
        fi
    done
    
    if [[ ${#found_files[@]} -eq 0 ]]; then
        log_warn "未找到任何备份文件"
        log_info "可能原因："
        echo "  1. 从未运行过安装脚本"
        echo "  2. 备份文件已被删除"
        echo "  3. Antigravity 未安装在标准路径"
        return 1
    fi
    
    log "找到 ${#found_files[@]} 个备份文件："
    for file in "${found_files[@]}"; do
        log "  $file"
    done
    
    echo "${found_files[@]}"
}

# --- 恢复备份（增强版：解决文件占用） ---
restore_backups() {
    log_info "🔄 开始恢复备份..."
    
    local backup_files
    backup_files=$(find_backup_files)
    
    if [[ -z "$backup_files" ]]; then
        return 1
    fi
    
    local restored_count=0
    
    for backup_file in $backup_files; do
        local original_file="${backup_file%.bak}"
        
        if [[ -f "$original_file" ]]; then
            log_info "恢复: $original_file"
            
            # 使用 rm + mv 方式避免 "Text file busy" 错误
            # 这样即使文件正在运行也能成功替换
            rm -f "$original_file"
            mv "$backup_file" "$original_file"
            
            # 恢复可执行权限（如果是二进制文件）
            if [[ "$original_file" == *"language_server"* ]]; then
                chmod +x "$original_file"
            fi
            
            ((restored_count++))
        else
            log_warn "原文件不存在: $original_file"
            # 即使原文件不存在，也尝试恢复
            mv "$backup_file" "$original_file"
            if [[ "$original_file" == *"language_server"* ]]; then
                chmod +x "$original_file"
            fi
            ((restored_count++))
        fi
    done
    
    log "${GREEN}✅ 已恢复 $restored_count 个文件${NC}"
}

# --- 清理注入的代码 ---
clean_injected_code() {
    log_info "🧹 清理注入的代理配置..."
    
    # 搜索包含注入标记的文件
    local search_paths=(
        "/usr/share/antigravity"
        "$HOME/.antigravity-server"
    )
    
    local cleaned_count=0
    
    for base_path in "${search_paths[@]}"; do
        if [[ -d "$base_path" ]]; then
            while IFS= read -r -d '' js_file; do
                if grep -q "Antigravity-Proxy-Bridge" "$js_file"; then
                    log_info "清理: $js_file"
                    
                    # 如果有备份，直接恢复
                    if [[ -f "${js_file}.bak" ]]; then
                        cp "${js_file}.bak" "$js_file"
                        rm "${js_file}.bak"
                    else
                        # 否则尝试删除注入的代码块
                        sed -i '/Antigravity-Proxy-Bridge.*START/,/Antigravity-Proxy-Bridge.*END/d' "$js_file"
                    fi
                    
                    ((cleaned_count++))
                fi
            done < <(find "$base_path" -name "*.js" -type f -print0 2>/dev/null)
        fi
    done
    
    if [[ $cleaned_count -gt 0 ]]; then
        log "${GREEN}✅ 已清理 $cleaned_count 个文件${NC}"
    else
        log_info "未找到需要清理的文件"
    fi
}

# --- 主函数 ---
main() {
    : > "$LOG_FILE"  # 清空日志文件
    
    show_banner
    check_root
    
    log "开始卸载 Antigravity-Proxy-Bridge..."
    
    echo ""
    log_warn "⚠️  此操作将："
    echo "  1. 恢复所有备份文件"
    echo "  2. 删除注入的代理配置"
    echo "  3. 清理生成的 wrapper 脚本"
    echo ""
    
    read -p "确认继续？(y/N) " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "用户取消卸载"
        exit 0
    fi
    
    echo ""
    
    # 执行卸载
    restore_backups
    clean_injected_code
    
    echo ""
    log "${GREEN}✅ 卸载完成！${NC}"
    echo ""
    log_info "📋 后续步骤："
    echo "  1. 重启 Antigravity 应用"
    echo "  2. 验证功能是否恢复正常"
    echo ""
    log_info "📝 卸载日志: $LOG_FILE"
    echo ""
}

# 运行主函数
main "$@"
