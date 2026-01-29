# 安装指南

本文档提供详细的安装步骤和说明。

## 📋 前置要求

### 系统要求

- **操作系统**: Ubuntu 20.04+ / Debian 11+ / CentOS 8+
- **权限**: Root 或 sudo 权限
- **磁盘空间**: 至少 100MB 可用空间

### 软件依赖

#### 必需依赖

- `graftcp` - 透明代理工具
- `bash` 4.0+
- `find`
- `grep`
- `sed`

#### 推荐依赖

- `curl` - 用于网络检测
- `nc` (netcat) - 用于端口检测

### 代理服务

需要一个运行中的代理服务：
- Clash
- V2Ray
- Shadowsocks
- 其他 SOCKS5/HTTP 代理

## 🚀 安装步骤

### 步骤 1：安装依赖

#### Ubuntu/Debian

```bash
sudo apt update
sudo apt install -y graftcp curl netcat-openbsd
```

#### CentOS/RHEL

```bash
sudo yum install -y graftcp curl nc
```

#### Arch Linux

```bash
sudo pacman -S graftcp curl gnu-netcat
```

### 步骤 2：克隆仓库

```bash
git clone https://github.com/Shanyu1314/Antigravity-Proxy-Bridge.git
cd Antigravity-Proxy-Bridge
```

### 步骤 3：配置代理服务

确保你的代理服务正在运行。

#### Clash 配置示例

```yaml
# config.yaml
port: 7890
socks-port: 7891
allow-lan: true

# 添加 Antigravity 相关规则
rules:
  - DOMAIN,antigravity-unleash.goog,PROXY
  - IP-CIDR,216.239.32.0/19,PROXY
  - IP-CIDR,64.233.160.0/19,PROXY
  - IP-CIDR,74.125.0.0/16,PROXY
  - IP-CIDR,108.177.0.0/16,PROXY
  - IP-CIDR,142.250.0.0/15,PROXY
  - IP-CIDR,209.85.128.0/17,PROXY
```

#### V2Ray 配置示例

```json
{
  "inbounds": [{
    "port": 7890,
    "protocol": "http",
    "settings": {}
  }]
}
```

### 步骤 4：运行安装脚本

#### 标准安装

```bash
chmod +x setup.sh
sudo ./setup.sh
```

#### 试运行（推荐先执行）

```bash
sudo ./setup.sh --dry-run
```

这会显示将要执行的操作，但不会实际修改文件。

#### 自定义代理地址

```bash
sudo ./setup.sh --proxy http://127.0.0.1:1080
```

### 步骤 5：按照提示操作

脚本会：
1. 检测网络环境
2. 询问使用场景
3. 检查依赖
4. 探测 Antigravity 路径
5. 备份原始文件
6. 注入代理配置

### 步骤 6：重启 Antigravity

配置完成后，重启 Antigravity 应用使配置生效。

## 🔍 验证安装

### 检查备份文件

```bash
ls -la /usr/share/antigravity/resources/app/extensions/antigravity/bin/
# 应该看到 language_server_linux_x64.bak

ls -la /usr/share/antigravity/resources/app/out/
# 应该看到 main.js.bak
```

### 检查日志

```bash
cat install.log
```

### 测试 AI 功能

1. 打开 Antigravity
2. 尝试使用 AI 功能（如代码补全、Chat）
3. 检查是否能正常工作

## 🛠 高级选项

### 仅检查环境

```bash
sudo ./setup.sh --check-only
```

这会检查：
- 网络连接
- 依赖安装情况
- Antigravity 安装路径
- 代理服务状态

但不会做任何修改。

### 查看帮助

```bash
./setup.sh --help
```

### 查看版本

```bash
./setup.sh --version
```

## 📂 文件结构

安装后的文件结构：

```
Antigravity-Proxy-Bridge/
├── backup/                    # 备份目录
│   └── 20260129_153000/      # 带时间戳的备份
│       ├── language_server_linux_x64
│       ├── main.js
│       └── backup_info.txt
├── install.log                # 安装日志
└── ...
```

## ⚠️ 注意事项

### 1. 权限问题

脚本需要 root 权限来修改系统文件。如果遇到权限错误：

```bash
sudo chown -R root:root /usr/share/antigravity
```

### 2. 路径问题

如果 Antigravity 安装在非标准路径，脚本会尝试自动搜索。如果搜索失败，请手动指定路径（未来版本会支持）。

### 3. 代理端口

默认代理端口是 7890。如果你的代理使用其他端口，使用 `--proxy` 参数指定。

### 4. 防火墙

确保防火墙允许访问代理端口：

```bash
sudo ufw allow 7890/tcp
```

## 🔄 更新

如果 Antigravity 更新后配置失效：

```bash
cd Antigravity-Proxy-Bridge
git pull
sudo ./setup.sh
```

脚本会自动检测并重新配置。

## 📖 相关文档

- [故障排查](troubleshooting.md)
- [Remote-SSH 指南](remote-ssh-guide.md)
- [技术架构](architecture.md)
- [主 README](../README.md)

## 💡 提示

- 首次安装建议使用 `--dry-run` 先检查
- 保留 `backup/` 目录以便恢复
- 定期查看 `install.log` 了解详细信息
- 遇到问题先查看[故障排查文档](troubleshooting.md)
