# Antigravity-Proxy-Bridge 中文文档

## 📖 目录

- [项目简介](#项目简介)
- [核心特性](#核心特性)
- [使用场景](#使用场景)
- [安装指南](#安装指南)
- [使用说明](#使用说明)
- [常见问题](#常见问题)
- [技术架构](#技术架构)
- [贡献指南](#贡献指南)
- [许可证](#许可证)

## 项目简介

Antigravity-Proxy-Bridge 是一个智能化的代理配置工具，专为 Antigravity AI 编程助手设计，解决在受限网络环境（特别是中国大陆 VPS）下无法正常使用 AI 功能的问题。

### 为什么需要这个工具？

Antigravity 需要连接到 Anthropic 的 API 服务器（位于国外），在某些网络环境下可能无法直接访问。本工具通过配置透明代理，让 Antigravity 能够正常工作。

### 与原项目的区别

本项目基于 [ccpopy/antissh](https://github.com/ccpopy/antissh) 改进，主要增强：

1. **智能路径探测** - 支持 `~/.antigravity-server/` 下的动态哈希路径
2. **场景识别** - 自动识别三种使用场景并提供正确引导
3. **智能模式检测** - 自动区分 Antigravity Server 和 Remote-SSH 模式
4. **灵活配置选项** - 可选择环境变量、graftcp 或两者结合
5. **网络检测** - 自动判断是否需要配置代理
6. **模块化设计** - 代码结构清晰，易于维护和扩展
5. **完善文档** - 中英双语，包含详细的使用指南

## 核心特性

### 🔍 智能检测

- **网络环境检测** - 自动判断服务器是否能直连国际网络
- **路径自动探测** - 支持标准路径和哈希值路径
- **场景识别** - 区分桌面版、服务器版和 Remote-SSH 模式
- **依赖检查** - 自动检查所需工具是否安装

### 💾 安全可靠

- **无损备份** - 修改前自动备份所有文件
- **多重备份** - 原地备份 + 集中备份
- **一键恢复** - 完整恢复到原始状态
- **详细日志** - 记录所有操作便于排查

### 🎨 用户友好

- **彩色输出** - 清晰的视觉反馈
- **交互式** - 友好的提示和确认
- **试运行模式** - 安全地预览将要执行的操作
- **详细文档** - 完善的中英文文档

### 🔧 灵活配置

- **自定义代理** - 支持任意代理地址和端口
- **模块化** - 各功能独立，易于扩展
- **兼容性强** - 支持多种 Linux 发行版

## 使用场景

### 场景 1：本地桌面版

**适用情况**：
- 在 Linux 桌面直接安装了 Antigravity
- 安装路径：`/usr/share/antigravity/`

**操作**：
```bash
sudo ./setup.sh
```

### 场景 2：服务器版

**适用情况**：
- 在远程服务器上安装了 Antigravity Server
- 安装路径：`~/.antigravity-server/`

**操作**：
```bash
sudo ./setup.sh
```

### 场景 3：Remote-SSH 模式

**适用情况**：
- 本地 Antigravity IDE 通过 SSH 连接远程服务器
- Antigravity 程序运行在本地

**重要**：❌ **不要在服务器上运行此脚本！**

**正确做法**：
1. 在本地 Antigravity 设置中配置代理
2. 查看 [Remote-SSH 配置指南](docs/remote-ssh-guide.md)

## 安装指南

### 前置要求

#### 系统要求
- Ubuntu 20.04+ / Debian 11+ / CentOS 8+
- Root 或 sudo 权限
- 至少 100MB 可用磁盘空间

#### 软件依赖
- `graftcp` - 透明代理工具（必需）
- `curl` - 网络测试（推荐）
- `nc` - 端口检测（推荐）

#### 代理服务
- Clash / V2Ray / Shadowsocks 等
- 默认端口：7890

### 快速安装

```bash
# 1. 安装依赖
sudo apt update
sudo apt install -y graftcp curl netcat-openbsd

# 2. 克隆仓库
git clone https://github.com/Shanyu1314/Antigravity-Proxy-Bridge.git
cd Antigravity-Proxy-Bridge

# 3. 运行安装脚本
chmod +x setup.sh
sudo ./setup.sh

# 4. 按照提示操作
```

### 详细安装步骤

查看 [完整安装指南](docs/installation.md)

## 使用说明

### 基本用法

```bash
# 标准安装
sudo ./setup.sh

# 试运行（推荐先执行）
sudo ./setup.sh --dry-run

# 自定义代理地址
sudo ./setup.sh --proxy http://127.0.0.1:1080

# 仅检查环境
sudo ./setup.sh --check-only

# 查看帮助
./setup.sh --help
```

### 卸载

```bash
sudo ./uninstall.sh
```

### 配置代理服务

#### Clash 配置

```yaml
# ~/.config/clash/config.yaml
port: 7890
socks-port: 7891
allow-lan: true

rules:
  - DOMAIN,antigravity-unleash.goog,PROXY
  - IP-CIDR,216.239.32.0/19,PROXY
  # 更多规则见 config/clash_rules.yaml
```

#### V2Ray 配置

```json
{
  "inbounds": [{
    "port": 7890,
    "protocol": "http"
  }]
}
```

完整配置示例见 `examples/` 目录。

## 常见问题

### Q1: 我的服务器在美国，需要运行吗？

**A**: 通常不需要。脚本会自动检测网络环境：
- 如果能直连 Google，会提示你不需要配置
- 如果仍想配置，可以选择继续

### Q2: 我使用 Remote-SSH 模式，怎么配置？

**A**: Remote-SSH 模式不需要在服务器运行脚本！

正确做法：
1. 在本地 Antigravity 设置中配置代理
2. 查看 [Remote-SSH 配置指南](docs/remote-ssh-guide.md)

### Q3: 配置后 AI 功能还是不能用？

**A**: 按以下步骤排查：

1. 检查代理服务是否运行
   ```bash
   netstat -tlnp | grep 7890
   ```

2. 测试代理连接
   ```bash
   curl -x http://127.0.0.1:7890 https://www.google.com
   ```

3. 查看日志
   ```bash
   cat install.log
   tail -f /tmp/antigravity-proxy-wrapper.log
   ```

4. 查看 [故障排查指南](docs/troubleshooting.md)

### Q4: Antigravity 更新后失效了？

**A**: 重新运行配置脚本：
```bash
cd Antigravity-Proxy-Bridge
sudo ./setup.sh
```

### Q5: 如何完全卸载？

**A**: 运行卸载脚本：
```bash
sudo ./uninstall.sh
```

这会：
- 恢复所有备份文件
- 删除注入的代理配置
- 清理生成的 wrapper 脚本

更多问题查看 [完整 FAQ](docs/troubleshooting.md)

## 技术架构

### 工作原理

```
Antigravity Application
    ├── Language Server (Go) → graftcp wrapper → graftcp-local
    └── Main Process (Node.js) → HTTP_PROXY env → undici ProxyAgent
                                                        ↓
                                                  Proxy Service
                                                  (Clash/V2Ray)
                                                        ↓
                                                    Internet
```

### 核心技术

1. **graftcp 透明代理**
   - 使用 LD_PRELOAD 劫持系统调用
   - 拦截网络连接并重定向到代理

2. **环境变量注入**
   - 设置 HTTP_PROXY / HTTPS_PROXY
   - 配置 Node.js undici 库

3. **智能路径探测**
   - 使用 find 命令递归搜索
   - 支持动态哈希值目录名

详见 [技术架构文档](docs/architecture.md)

## 文档

- [安装指南](docs/installation.md) - 详细的安装步骤
- [Remote-SSH 指南](docs/remote-ssh-guide.md) - Remote-SSH 模式配置
- [故障排查](docs/troubleshooting.md) - 常见问题解决
- [技术架构](docs/architecture.md) - 技术实现细节

## 贡献指南

欢迎贡献！请遵循以下步骤：

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

### 代码规范

- 遵循 [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- 添加清晰的中文注释
- 包含必要的错误处理
- 更新相关文档

## 致谢

- 感谢 [ccpopy/antissh](https://github.com/ccpopy/antissh) 提供灵感
- 感谢 [graftcp](https://github.com/hmgle/graftcp) 项目
- 感谢所有贡献者

## 许可证

MIT License - 详见 [LICENSE](LICENSE)

## 联系方式

- GitHub Issues: https://github.com/Shanyu1314/Antigravity-Proxy-Bridge/issues
- GitHub Discussions: https://github.com/Shanyu1314/Antigravity-Proxy-Bridge/discussions

---

**如果这个项目对你有帮助，请给个 Star ⭐**
