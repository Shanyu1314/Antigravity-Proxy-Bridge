# Antigravity-Proxy-Bridge

[English](#english) | [中文](#中文)

---

## English

### 🚀 One-Click Proxy Configuration for Antigravity AI Coding Assistant

Automatically configure network proxy for Antigravity to solve connection issues in restricted network environments (especially for China mainland VPS).

### ✨ Features

- 🔍 **Smart Network Detection** - Automatically detects if proxy is needed
- 🎯 **Scenario Recognition** - Identifies 3 usage scenarios and provides correct guidance
- 📂 **Intelligent Path Discovery** - Supports dynamic hash paths in `~/.antigravity-server/`
- 💾 **Lossless Backup** - Automatic backup before any modifications
- 🔄 **One-Click Uninstall** - Complete restoration to original state
- 📝 **Detailed Logging** - Records all operations for troubleshooting
- 🎨 **User-Friendly** - Colorful output and clear prompts

### 🎯 Usage Scenarios

#### Scenario 1: Local Desktop Version
- **Path**: `/usr/share/antigravity/`
- **Use Case**: Antigravity installed directly on Linux desktop
- **Action**: Run this script to configure proxy

#### Scenario 2: Server Version
- **Path**: `~/.antigravity-server/`
- **Use Case**: Antigravity Server installed on remote server
- **Action**: Run this script to configure proxy

#### Scenario 3: Remote-SSH Mode
- **Setup**: Local Antigravity IDE connecting to remote server via SSH
- **Action**: ❌ **DO NOT run this script on server!**
- **Solution**: Configure proxy in local Antigravity settings
- **Guide**: See [Remote-SSH Configuration Guide](docs/remote-ssh-guide.md)

### 📋 Prerequisites

- **Operating System**: Ubuntu 20.04+ / Debian 11+ / CentOS 8+
- **Dependencies**: `graftcp` (will be checked automatically)
- **Proxy Service**: Clash / V2Ray / other SOCKS5/HTTP proxy
- **Permissions**: Root or sudo access

### 🚀 Quick Start

```bash
# Clone repository
git clone https://github.com/Shanyu1314/Antigravity-Proxy-Bridge.git
cd Antigravity-Proxy-Bridge

# Run installation script
chmod +x setup.sh
sudo ./setup.sh

# Follow the interactive prompts
```

### 🛠 Advanced Usage

```bash
# Dry run (check only, no modifications)
sudo ./setup.sh --dry-run

# Custom proxy address
sudo ./setup.sh --proxy http://127.0.0.1:1080

# Check dependencies only
sudo ./setup.sh --check-only

# Uninstall and restore
sudo ./uninstall.sh
```

### ❓ FAQ

**Q: Do I need this if my server is in the US/Europe?**  
A: Probably not. The script will detect if you can access Google directly and prompt you.

**Q: I'm using Remote-SSH mode, should I run this?**  
A: No! Configure proxy in your local Antigravity settings instead. See [this guide](docs/remote-ssh-guide.md).

**Q: How to uninstall?**  
A: Run `sudo ./uninstall.sh` to restore all backups.

**Q: What if Antigravity updates?**  
A: Simply run the script again, it will detect and reconfigure automatically.

### 📖 Documentation

- [Installation Guide](docs/installation.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Remote-SSH Guide](docs/remote-ssh-guide.md)
- [Architecture](docs/architecture.md)

### 🙏 Credits

This project is inspired by [ccpopy/antissh](https://github.com/ccpopy/antissh). Special thanks!

### 📄 License

MIT License - see [LICENSE](LICENSE) for details

---

## 中文

### 🚀 Antigravity AI 编程助手一键代理配置工具

自动为 Antigravity 配置网络代理，解决国内 VPS 等受限网络环境下的连接问题。

### ✨ 功能特性

- 🔍 **智能网络检测** - 自动判断是否需要配置代理
- 🎯 **场景识别** - 识别 3 种使用场景并提供正确引导
- 📂 **智能路径探测** - 支持 `~/.antigravity-server/` 下的动态哈希路径
- 💾 **无损备份** - 修改前自动备份所有文件
- 🔄 **一键卸载** - 完整恢复到原始状态
- 📝 **详细日志** - 记录所有操作便于排查问题
- 🎨 **交互友好** - 彩色输出和清晰提示

### 🎯 使用场景

#### 场景 1：本地桌面版
- **路径**: `/usr/share/antigravity/`
- **适用**: 在 Linux 桌面直接安装 Antigravity
- **操作**: 运行本脚本配置代理

#### 场景 2：服务器版
- **路径**: `~/.antigravity-server/`
- **适用**: 在远程服务器上安装 Antigravity Server
- **操作**: 运行本脚本配置代理

#### 场景 3：Remote-SSH 模式
- **说明**: 本地 Antigravity IDE 通过 SSH 连接远程服务器
- **操作**: ❌ **不要在服务器上运行本脚本！**
- **解决方案**: 在本地 Antigravity 设置中配置代理
- **指南**: 查看 [Remote-SSH 配置指南](docs/remote-ssh-guide.md)

### 📋 前置要求

- **操作系统**: Ubuntu 20.04+ / Debian 11+ / CentOS 8+
- **依赖工具**: `graftcp`（脚本会自动检查）
- **代理服务**: Clash / V2Ray / 其他 SOCKS5/HTTP 代理
- **权限**: Root 或 sudo 权限

### 🚀 快速开始

```bash
# 克隆仓库
git clone https://github.com/Shanyu1314/Antigravity-Proxy-Bridge.git
cd Antigravity-Proxy-Bridge

# 运行安装脚本
chmod +x setup.sh
sudo ./setup.sh

# 按照交互提示操作
```

### 🛠 高级用法

```bash
# 试运行（仅检查，不做修改）
sudo ./setup.sh --dry-run

# 自定义代理地址
sudo ./setup.sh --proxy http://127.0.0.1:1080

# 仅检查依赖
sudo ./setup.sh --check-only

# 卸载并恢复
sudo ./uninstall.sh
```

### ❓ 常见问题

**Q: 我的服务器在美国/欧洲，需要运行吗？**  
A: 通常不需要。脚本会检测你是否能直接访问 Google 并提示你。

**Q: 我使用 Remote-SSH 模式，需要运行吗？**  
A: 不需要！请在本地 Antigravity 设置中配置代理。查看[这个指南](docs/remote-ssh-guide.md)。

**Q: 如何卸载？**  
A: 运行 `sudo ./uninstall.sh` 即可恢复所有备份。

**Q: Antigravity 更新后失效了怎么办？**  
A: 重新运行一次脚本即可，它会自动检测并重新配置。

### 📖 文档

- [安装指南](docs/installation.md)
- [故障排查](docs/troubleshooting.md)
- [Remote-SSH 指南](docs/remote-ssh-guide.md)
- [技术架构](docs/architecture.md)

### 🙏 致谢

本项目受 [ccpopy/antissh](https://github.com/ccpopy/antissh) 启发，特此感谢！

### 📄 许可证

MIT License - 详见 [LICENSE](LICENSE)

---

**Star ⭐ this repo if you find it helpful!**
