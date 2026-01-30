#!/bin/bash

# ============================================================================
# Antigravity-Proxy-Bridge - 智能代理配置工具
# 版本: 1.2.0
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
readonly LOG_FILE="${SCRIPT_DIR}/install.log"
readonly BACKUP_DIR="${SCRIPT_DIR}/backup"
DEFAULT_PROXY="http://127.0.0.1:7890"
DRY_RUN=false
CHECK_ONLY=false

# Antigravity 路径变量
LS_BIN=""
MAIN_JS=""
SCENARIO=""

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
    ____                        ____       _     _            
   |  _ \ _ __ _____  ___   _  | __ ) _ __(_) __| | __ _  ___ 
   | |_) | '__/ _ \ \/ / | | | |  _ \| '__| |/ _` |/ _` |/ _ \
   |  __/| | | (_) >  <| |_| | | |_) | |  | | (_| | (_| |  __/
   |_|   |_|  \___/_/\_\\__, | |____/|_|  |_|\__,_|\__, |\___|
                        |___/                      |___/      

EOF
    echo -e "${GREEN}=== Antigravity 智能代理配置工具 v1.2.0 ===${NC}"
    echo ""
}

# --- 帮助信息 ---
show_help() {
    cat << EOF
用法: sudo ./setup.sh [选项]

选项:
    --proxy <url>       指定代理地址 (默认: http://127.0.0.1:7890)
    --dry-run           试运行模式，不做实际修改
    --check-only        仅检查环境和依赖
    --help              显示此帮助信息
    --version           显示版本信息

示例:
    sudo ./setup.sh                              # 标准安装
    sudo ./setup.sh --proxy http://127.0.0.1:1080  # 自定义代理
    sudo ./setup.sh --dry-run                    # 试运行
    sudo ./setup.sh --check-only                 # 仅检查

更多信息: https://github.com/Shanyu1314/Antigravity-Proxy-Bridge
EOF
}

# --- 解析参数 ---
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --proxy)
                DEFAULT_PROXY="$2"
                shift 2
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --check-only)
                CHECK_ONLY=true
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            --version)
                echo "Antigravity-Proxy-Bridge v1.2.0"
                exit 0
                ;;
            *)
                log_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# --- 检查 root 权限 ---
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "此脚本需要 root 权限运行"
        echo "请使用: sudo ./setup.sh"
        exit 1
    fi
}

# --- 加载模块 ---
load_modules() {
    local modules_dir="${SCRIPT_DIR}/modules"
    
    if [[ -d "$modules_dir" ]]; then
        for module in "$modules_dir"/*.sh; do
            if [[ -f "$module" ]]; then
                # shellcheck source=/dev/null
                source "$module"
            fi
        done
    fi
}

# --- 主函数 ---
main() {
    # 初始化
    mkdir -p "$BACKUP_DIR"
    : > "$LOG_FILE"  # 清空日志文件
    
    show_banner
    parse_args "$@"
    check_root
    load_modules
    
    log "开始执行 Antigravity 代理配置..."
    log "工作目录: $SCRIPT_DIR"
    log "备份目录: $BACKUP_DIR"
    log "代理地址: $DEFAULT_PROXY"
    
    if [[ "$DRY_RUN" == true ]]; then
        log_warn "试运行模式：不会做任何实际修改"
    fi
    
    # 执行检查和配置流程
    check_network_access
    check_dependencies
    
    if [[ "$CHECK_ONLY" == true ]]; then
        log "仅检查模式，退出"
        exit 0
    fi
    
    detect_scenario
    detect_paths
    backup_files
    inject_proxy
    verify_installation
    
    log "${GREEN}✅ 配置完成！${NC}"
    show_next_steps
}

# 运行主函数
main "$@"
