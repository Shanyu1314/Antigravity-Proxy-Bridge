# Antigravity-Proxy-Bridge 快速上手指南

> 面向国内用户的完整配置教程 - 从零开始让 Antigravity AI 在国内服务器上正常工作

## 📋 目录

- [前置准备](#前置准备)
- [第一步：配置本地代理](#第一步配置本地代理)
- [第二步：配置 SSH 连接](#第二步配置-ssh-连接)
- [第三步：首次连接服务器](#第三步首次连接服务器)
- [第四步：运行配置脚本](#第四步运行配置脚本)
- [第五步：测试 AI 功能](#第五步测试-ai-功能)
- [常见问题](#常见问题)
- [故障排查](#故障排查)

---

## 前置准备

### 你需要准备

1. **一台国内 VPS 服务器**
   - 操作系统：Ubuntu 20.04+ / Debian 11+ / CentOS 8+
   - 已获得 root 权限或 sudo 权限
   - 知道服务器的 IP 地址、用户名、密码

2. **本地 Windows 电脑**
   - 已安装 Antigravity IDE
   - 已安装代理软件（Clash / V2Ray / Shadowsocks）
   - 代理软件能够正常访问国外网站

3. **基础知识**
   - 知道如何使用 SSH 连接服务器
   - 了解基本的命令行操作

### 工作原理

```
┌─────────────────┐
│  本地 Windows   │
│  Antigravity IDE│
│  Clash (7890)   │ ← 开启 TUN 模式 + 允许局域网连接
└────────┬────────┘
         │ SSH + RemoteForward
         ↓
┌─────────────────┐
│  国内 VPS       │
│  Antigravity    │
│  Server         │ → 通过 localhost:7890 访问 API
└─────────────────┘
         ↓
    转发到本地代理
         ↓
    成功访问 Anthropic API ✅
```

---

## 第一步：配置本地代理

### 1.1 打开 Clash（或其他代理软件）

确保代理软件正在运行，并且能够访问国外网站。

### 1.2 开启 TUN 模式

**Clash for Windows**：
1. 打开 Clash
2. 点击 "General" 标签
3. 找到 "TUN Mode"
4. 开启 TUN 模式

**为什么需要 TUN 模式？**
- TUN 模式可以让本地 Antigravity IDE 的所有网络请求都走代理
- 这样才能正常使用 AI 功能

### 1.3 允许局域网连接

**Clash for Windows**：
1. 在 "General" 标签
2. 找到 "Allow LAN"（允许局域网连接）
3. 开启此选项

**为什么需要允许局域网？**
- 服务器需要通过 SSH 隧道访问本地的代理端口（7890）
- 如果不开启，服务器无法连接到本地代理

### 1.4 确认代理端口

**Clash for Windows**：
1. 在 "General" 标签
2. 查看 "Port" 端口号
3. 默认是 `7890`，记住这个端口号

**其他代理软件**：
- V2Ray：通常是 `10808`
- Shadowsocks：通常是 `1080`

---

## 第二步：配置 SSH 连接

### 2.1 生成 SSH 密钥（如果还没有）

**在 Windows 上打开 PowerShell 或 CMD**：

```powershell
# 生成 SSH 密钥
ssh-keygen -t ed25519 -C "your_email@example.com"

# 按提示操作：
# - 保存位置：直接回车（使用默认位置 C:\Users\你的用户名\.ssh\id_ed25519）
# - 密码：可以留空（直接回车）
```

### 2.2 复制公钥到服务器

**方法 1：使用 ssh-copy-id（推荐）**

```powershell
# 替换为你的服务器信息
ssh-copy-id root@你的服务器IP
```

**方法 2：手动复制**

```powershell
# 1. 查看公钥内容
type C:\Users\你的用户名\.ssh\id_ed25519.pub

# 2. 复制输出的内容

# 3. SSH 登录到服务器
ssh root@你的服务器IP

# 4. 在服务器上执行
mkdir -p ~/.ssh
echo "粘贴刚才复制的公钥内容" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh
```

### 2.3 配置 SSH Config 文件

**在 Windows 上**：

1. 打开文件：`C:\Users\你的用户名\.ssh\config`
   - 如果文件不存在，创建一个新文件（无扩展名）

2. 添加以下内容：

```
Host my-vps
    Hostname 你的服务器IP
    User root
    Port 22
    IdentityFile ~/.ssh/id_ed25519
    RemoteForward 7890 localhost:7890
```

**参数说明**：
- `Host my-vps`：连接别名，可以自定义
- `Hostname`：服务器 IP 地址
- `User`：登录用户名（通常是 root）
- `Port`：SSH 端口（默认 22）
- `IdentityFile`：SSH 私钥路径
- `RemoteForward 7890 localhost:7890`：**关键配置**，将服务器的 7890 端口转发到本地

**RemoteForward 的作用**：
```
服务器访问 localhost:7890
         ↓
通过 SSH 隧道转发
         ↓
本地 Windows 的 127.0.0.1:7890（Clash）
         ↓
成功访问国外 API ✅
```

### 2.4 测试 SSH 连接

```powershell
# 使用别名连接
ssh my-vps

# 如果成功，你应该能登录到服务器
# 输入 exit 退出
```

---

## 第三步：首次连接服务器

### 3.1 在 Antigravity IDE 中配置 SSH

1. 打开 Antigravity IDE
2. 按 `F1` 或 `Ctrl+Shift+P` 打开命令面板
3. 输入 `Remote-SSH: Connect to Host`
4. 选择 `my-vps`（你在 config 中配置的别名）
5. 等待连接和安装 Antigravity Server

**首次连接会做什么？**
- Antigravity 会自动在服务器上安装 Antigravity Server
- 安装位置：`~/.antigravity-server/`
- 这个过程需要几分钟，请耐心等待

### 3.2 验证连接成功

连接成功后，你应该能看到：
- 左下角显示 `SSH: my-vps`
- 可以打开服务器上的文件夹
- 终端可以执行命令

### 3.3 测试 AI 功能（预期会失败）

尝试使用 AI 功能（如 Chat 或 Code completion）：
- ❌ 预期会失败或超时
- 这是正常的，因为还没有配置代理

---

## 第四步：运行配置脚本

### 4.1 在服务器上克隆项目

**在 Antigravity IDE 的终端中执行**：

```bash
# 进入 home 目录
cd ~

# 克隆项目
git clone https://github.com/Shanyu1314/Antigravity-Proxy-Bridge.git

# 进入项目目录
cd Antigravity-Proxy-Bridge

# 查看文件
ls -la
```

### 4.2 运行配置脚本

```bash
sudo ./setup.sh
```

### 4.3 按照提示操作

#### 提示 1：网络检测

```
[INFO] 🔍 正在检测网络环境...
[WARN] ❌ 服务器无法访问国际网络
[INFO] 需要配置代理

是否继续配置？(y/N)
```

**输入**：`y`（继续）

#### 提示 2：场景确认

```
[INFO] 🔍 智能探测使用场景...
[INFO] ✅ 自动检测到: Antigravity Server 版本
[INFO]   安装路径: /root/.antigravity-server

确认使用检测到的场景？(Y/n)
```

**输入**：`y` 或直接回车（确认）

#### 提示 3：选择配置方式

```
请选择代理配置方式：
  1) 环境变量方式（推荐，更稳定）
  2) graftcp 强制代理（兼容性可能有问题）
  3) 两者都配置（最大兼容性）

请选择 (1/2/3，默认 1):
```

**推荐选择**：`1`（环境变量方式）

**为什么选择 1？**
- ✅ 最稳定，兼容性最好
- ✅ 不需要安装额外依赖
- ✅ 适合大多数场景

**什么时候选择 2 或 3？**
- 选项 1 不工作时
- 网络环境特别复杂时
- 需要强制代理所有请求时

### 4.4 等待安装完成

```
[INFO] 💉 开始注入代理配置...
[INFO] 配置 Main JS 代理...
[INFO] ✅ 代理配置注入完成
[INFO] ✅ 配置完成！

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[INFO] 📋 后续步骤：

  1. 确保代理服务（Clash/V2Ray）正在运行
  2. 重启 Antigravity 应用
  3. 测试 AI 功能是否正常
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 第五步：测试 AI 功能

### 5.1 重启 Antigravity IDE

**重要**：必须重启才能让配置生效！

1. 关闭 Antigravity IDE（完全退出）
2. 确保本地 Clash 正在运行（TUN 模式 + 允许局域网）
3. 重新打开 Antigravity IDE
4. 重新连接到服务器（`Remote-SSH: Connect to Host` → `my-vps`）

### 5.2 测试 AI Chat

1. 按 `Ctrl+Shift+P` 打开命令面板
2. 输入 `Antigravity: Open Chat`
3. 发送一条消息，如 "Hello"
4. 等待 AI 回复

**预期结果**：
- ✅ AI 正常回复
- ✅ 没有超时错误
- ✅ 响应速度正常

### 5.3 测试 Code Completion

1. 打开一个代码文件（如 `.py` 或 `.js`）
2. 开始输入代码
3. 观察是否有 AI 代码补全提示

**预期结果**：
- ✅ 出现代码补全建议
- ✅ 补全质量正常

---

## 常见问题

### Q1: AI 功能还是不工作怎么办？

**检查清单**：

1. **本地 Clash 是否正在运行？**
   ```powershell
   # 在本地 Windows 上测试
   curl -I https://api.anthropic.com
   # 应该能访问
   ```

2. **TUN 模式是否开启？**
   - 打开 Clash，检查 TUN Mode 是否开启

3. **允许局域网连接是否开启？**
   - 打开 Clash，检查 Allow LAN 是否开启

4. **SSH Config 是否配置了 RemoteForward？**
   ```powershell
   # 查看配置
   type C:\Users\你的用户名\.ssh\config
   # 应该有 RemoteForward 7890 localhost:7890
   ```

5. **服务器上端口是否监听？**
   ```bash
   # 在服务器上执行
   ss -tlnp | grep 7890
   # 应该能看到监听的端口
   ```

6. **是否重启了 Antigravity IDE？**
   - 必须完全退出并重新打开

### Q2: 提示 "graftcp 未安装" 怎么办？

**如果选择了选项 1（环境变量）**：
- 不应该出现这个错误
- 如果出现，请更新到最新版本脚本

**如果选择了选项 2 或 3**：
```bash
# 安装 graftcp
sudo apt update
sudo apt install -y graftcp

# 重新运行脚本
sudo ./setup.sh
```

### Q3: 如何卸载配置？

```bash
cd ~/Antigravity-Proxy-Bridge
sudo ./uninstall.sh
```

卸载后：
- 所有修改会被恢复
- 备份文件会被删除
- Antigravity Server 恢复到原始状态

### Q4: 更新脚本后如何重新配置？

```bash
# 1. 进入项目目录
cd ~/Antigravity-Proxy-Bridge

# 2. 拉取最新代码
git pull

# 3. 卸载旧配置
sudo ./uninstall.sh

# 4. 重新安装
sudo ./setup.sh
```

### Q5: 可以在多台服务器上使用吗？

可以！每台服务器都需要：

1. 在 SSH Config 中添加配置：
   ```
   Host server1
       Hostname IP1
       RemoteForward 7890 localhost:7890
   
   Host server2
       Hostname IP2
       RemoteForward 7890 localhost:7890
   ```

2. 分别连接并运行脚本

### Q6: 代理端口不是 7890 怎么办？

**如果你的 Clash 端口是其他的（如 10808）**：

1. 修改 SSH Config：
   ```
   RemoteForward 7890 localhost:10808
   ```

2. 运行脚本时指定端口：
   ```bash
   sudo ./setup.sh --proxy http://127.0.0.1:7890
   ```

---

## 故障排查

### 问题 1：SSH 连接失败

**错误信息**：`Connection refused` 或 `Connection timed out`

**解决方法**：
1. 检查服务器 IP 是否正确
2. 检查服务器 SSH 端口（默认 22）
3. 检查服务器防火墙是否允许 SSH
4. 尝试用密码登录：`ssh root@服务器IP`

### 问题 2：RemoteForward 不工作

**症状**：服务器上 `ss -tlnp | grep 7890` 没有输出

**解决方法**：
1. 检查 SSH Config 中的 RemoteForward 配置
2. 断开并重新连接 SSH
3. 检查服务器 sshd 配置：
   ```bash
   sudo nano /etc/ssh/sshd_config
   # 确保有：
   # AllowTcpForwarding yes
   # GatewayPorts no
   
   # 重启 sshd
   sudo systemctl restart sshd
   ```

### 问题 3：AI 请求超时

**症状**：AI 功能加载很久，最后超时

**可能原因**：
1. 本地代理没有运行
2. TUN 模式没有开启
3. RemoteForward 没有生效
4. 脚本配置没有生效

**排查步骤**：
```bash
# 1. 在服务器上测试代理
curl --proxy http://127.0.0.1:7890 -I https://api.anthropic.com
# 应该返回 200 OK

# 2. 检查配置是否注入
head -30 ~/.antigravity-server/bin/*/out/server-main.js
# 应该能看到 HTTP_PROXY 配置

# 3. 查看日志
cat ~/Antigravity-Proxy-Bridge/install.log
```

### 问题 4：脚本运行失败

**错误信息**：`Permission denied`

**解决方法**：
```bash
# 使用 sudo 运行
sudo ./setup.sh
```

**错误信息**：`未找到 language_server_linux_x64`

**解决方法**：
1. 确保已经用 Antigravity IDE 连接过服务器
2. 等待 Antigravity Server 安装完成
3. 检查 `~/.antigravity-server/` 目录是否存在

---

## 📞 获取帮助

如果遇到问题：

1. **查看文档**：
   - [故障排查](docs/troubleshooting.md)
   - [技术架构](docs/architecture.md)

2. **查看日志**：
   ```bash
   cat ~/Antigravity-Proxy-Bridge/install.log
   ```

3. **提交 Issue**：
   - GitHub: https://github.com/Shanyu1314/Antigravity-Proxy-Bridge/issues
   - 请提供：
     - 操作系统版本
     - 错误信息
     - 日志文件内容

---

## 🎉 成功！

如果一切正常，你现在应该可以：
- ✅ 在国内服务器上使用 Antigravity AI
- ✅ AI Chat 正常工作
- ✅ Code Completion 正常工作
- ✅ 所有 AI 功能都可用

享受 AI 编程的乐趣吧！🚀

---

**最后更新**：2026-01-30  
**版本**：v1.2.0
