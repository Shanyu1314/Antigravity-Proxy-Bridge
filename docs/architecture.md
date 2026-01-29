# 技术架构文档

本文档详细说明 Antigravity-Proxy-Bridge 的技术实现和工作原理。

## 📐 整体架构

```
┌─────────────────────────────────────────────────────────────┐
│                    Antigravity Application                   │
│  ┌────────────────────┐         ┌─────────────────────────┐ │
│  │  Language Server   │         │      Main Process       │ │
│  │  (Go Binary)       │         │      (Node.js)          │ │
│  └─────────┬──────────┘         └───────────┬─────────────┘ │
│            │                                 │               │
│            │ Wrapped by                      │ Injected      │
│            │ Shell Script                    │ Proxy Code    │
│            ▼                                 ▼               │
│  ┌────────────────────┐         ┌─────────────────────────┐ │
│  │  graftcp Wrapper   │         │  process.env.HTTP_PROXY │ │
│  │  + GODEBUG         │         │  + undici ProxyAgent    │ │
│  └─────────┬──────────┘         └───────────┬─────────────┘ │
└────────────┼──────────────────────────────────┼─────────────┘
             │                                  │
             └──────────────┬───────────────────┘
                            │
                            ▼
                ┌───────────────────────┐
                │   graftcp-local       │
                │   (Transparent Proxy) │
                └───────────┬───────────┘
                            │
                            ▼
                ┌───────────────────────┐
                │   Proxy Service       │
                │   (Clash/V2Ray)       │
                │   Port: 7890          │
                └───────────┬───────────┘
                            │
                            ▼
                      Internet
                   (Anthropic API)
```

## 🔧 核心组件

### 1. Language Server Wrapper

**位置**: 替换原始的 `language_server_linux_x64`

**功能**: 
- 使用 `graftcp` 包装原始二进制文件
- 设置 `GODEBUG` 环境变量提高兼容性
- 记录启动日志

**实现**:
```bash
#!/usr/bin/env bash
# 查找 graftcp
GRAFTCP_BIN=$(which graftcp)

# 设置环境变量
export GODEBUG="netdns=cgo,http2client=0,tls13=0"

# 使用 graftcp 启动原始二进制
exec "$GRAFTCP_BIN" "$0.bak" "$@"
```

**工作流程**:
1. Antigravity 启动 Language Server
2. 实际执行的是 wrapper 脚本
3. Wrapper 调用 graftcp
4. graftcp 启动原始二进制 (.bak)
5. 所有网络请求通过 graftcp-local 转发

### 2. Main.js 代理注入

**位置**: `main.js` 或 `server-main.js` 文件开头

**功能**:
- 设置 Node.js 环境变量
- 配置 undici 库的全局代理

**实现 (ESM)**:
```javascript
import { createRequire } from 'module';
const require = createRequire(import.meta.url);

// 环境变量
process.env.HTTP_PROXY = 'http://127.0.0.1:7890';
process.env.HTTPS_PROXY = 'http://127.0.0.1:7890';

// undici 配置
(async () => {
    const undici = await import('undici');
    const proxyAgent = new undici.ProxyAgent('http://127.0.0.1:7890');
    undici.setGlobalDispatcher(proxyAgent);
})();
```

**工作流程**:
1. Node.js 启动时执行注入的代码
2. 设置全局环境变量
3. 配置 undici 代理
4. 后续所有 HTTP 请求自动使用代理

### 3. graftcp 透明代理

**工作原理**:
- 使用 `LD_PRELOAD` 劫持系统调用
- 拦截 `connect()` 等网络函数
- 将流量重定向到 graftcp-local

**优势**:
- 无需修改应用程序代码
- 支持任何使用标准 socket 的程序
- 透明且高效

## 📂 文件结构

```
Antigravity-Proxy-Bridge/
├── setup.sh                    # 主安装脚本
├── uninstall.sh                # 卸载脚本
├── modules/                    # 模块化脚本
│   ├── network_check.sh        # 网络检测
│   ├── path_detector.sh        # 路径探测
│   ├── backup_manager.sh       # 备份管理
│   ├── proxy_injector.sh       # 代理注入
│   └── dependency_check.sh     # 依赖检查
├── docs/                       # 文档
├── config/                     # 配置文件
├── tests/                      # 测试脚本
└── examples/                   # 示例配置
```

## 🔄 执行流程

### 安装流程

```
1. 解析命令行参数
   ├── --proxy: 自定义代理地址
   ├── --dry-run: 试运行模式
   └── --check-only: 仅检查

2. 检查 root 权限

3. 加载模块
   └── source modules/*.sh

4. 网络环境检测
   ├── 测试 Google 连通性
   ├── 检测代理服务状态
   └── 询问用户是否继续

5. 使用场景识别
   ├── 1) 桌面版
   ├── 2) 服务器版
   └── 3) Remote-SSH (退出并引导)

6. 依赖检查
   ├── graftcp
   ├── curl
   ├── nc
   └── find

7. 路径探测
   ├── 桌面版: /usr/share/antigravity
   ├── 服务器版: ~/.antigravity-server
   └── 使用 find 搜索哈希路径

8. 备份文件
   ├── language_server_linux_x64 -> .bak
   ├── main.js -> .bak
   └── 复制到 backup/ 目录

9. 注入代理配置
   ├── 创建 Language Server wrapper
   ├── 注入 Main.js 代理代码
   └── 设置正确的权限

10. 验证安装
    ├── 检查文件存在性
    ├── 检查权限
    └── 检查注入标记

11. 显示后续步骤
```

### 卸载流程

```
1. 检查 root 权限

2. 查找备份文件
   └── find **/*.bak

3. 恢复备份
   ├── .bak -> 原文件
   └── 删除 .bak

4. 清理注入代码
   └── 删除包含标记的代码块

5. 验证恢复
```

## 🎯 关键技术点

### 1. 路径探测算法

**挑战**: Antigravity Server 使用哈希值作为目录名

**解决方案**:
```bash
# 使用 find 递归搜索
LS_BIN=$(find "$HOME/.antigravity-server" \
    -name "language_server_linux_x64" \
    -type f 2>/dev/null | head -n 1)
```

**优势**:
- 支持任意深度的目录结构
- 支持哈希值目录名
- 自动找到第一个匹配项

### 2. 模块类型检测

**挑战**: JS 文件可能是 ESM 或 CommonJS

**解决方案**:
```bash
detect_js_module_type() {
    if grep -q "import.*from" "$1" || grep -q "export.*{" "$1"; then
        echo "esm"
    else
        echo "commonjs"
    fi
}
```

**影响**:
- ESM 使用 `import` 语法
- CommonJS 使用 `require` 语法
- 注入代码需要匹配模块类型

### 3. 备份策略

**设计**:
- 原地备份: `.bak` 后缀
- 集中备份: `backup/时间戳/` 目录
- 备份信息: `backup_info.txt`

**优势**:
- 快速恢复（原地备份）
- 历史记录（集中备份）
- 可追溯性（备份信息）

### 4. 错误处理

**策略**:
```bash
set -euo pipefail
```

- `-e`: 命令失败立即退出
- `-u`: 使用未定义变量报错
- `-o pipefail`: 管道中任何命令失败都报错

**日志记录**:
- 所有操作记录到 `install.log`
- 使用颜色区分日志级别
- 包含时间戳

## 🔐 安全考虑

### 1. 权限管理

- 需要 root 权限修改系统文件
- 恢复原始文件权限
- 不修改用户数据

### 2. 备份保护

- 修改前强制备份
- 多重备份策略
- 备份完整性检查

### 3. 代码注入

- 使用明确的标记
- 可逆的注入方式
- 不破坏原始逻辑

## 📊 性能影响

### 代理开销

- graftcp: 约 1-2ms 延迟
- undici ProxyAgent: 约 5-10ms 延迟
- 总体影响: < 1% CPU 使用率

### 内存占用

- Wrapper 脚本: < 1MB
- 注入代码: < 100KB
- 总体影响: 可忽略

## 🧪 测试策略

### 单元测试

- 网络检测模块
- 路径探测模块
- 备份恢复模块

### 集成测试

- 完整安装流程
- 卸载恢复流程
- 多场景测试

### 兼容性测试

- Ubuntu 20.04/22.04/24.04
- Debian 11/12
- CentOS 8/9

## 📚 参考资料

- [graftcp 项目](https://github.com/hmgle/graftcp)
- [undici 文档](https://undici.nodejs.org/)
- [Bash 最佳实践](https://google.github.io/styleguide/shellguide.html)
- [原项目 antissh](https://github.com/ccpopy/antissh)

---

**本架构设计注重模块化、可维护性和用户体验。**
