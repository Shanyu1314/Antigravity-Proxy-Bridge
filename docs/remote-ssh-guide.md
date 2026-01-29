# Remote-SSH 模式配置指南

> 如果你使用本地 Antigravity IDE 通过 SSH 连接到远程服务器，请阅读本指南。

## 🎯 重要说明

**在 Remote-SSH 模式下，你不需要在服务器上运行 `setup.sh` 脚本！**

### 为什么？

在 Remote-SSH 模式下：
- Antigravity **程序运行在本地 Windows/Mac**
- 通过 SSH 连接到远程服务器
- AI 功能的网络请求从**本地发出**，不是从服务器发出

因此，代理需要配置在**本地 Antigravity**，而不是服务器上。

## 📋 正确的配置方法

### 方案 1：配置本地 Antigravity 代理（推荐）

#### 步骤 1：打开 Antigravity 设置

1. 按 `Ctrl+,` (Windows/Linux) 或 `Cmd+,` (Mac)
2. 或点击左下角齿轮图标 → Settings

#### 步骤 2：切换到 User 设置

确保你在 **User** 标签，而不是 **Remote** 标签。

#### 步骤 3：配置代理

搜索 `proxy`，找到 `Http: Proxy` 设置，填入：

```
http://127.0.0.1:7890
```

或者直接编辑 `settings.json`：

```json
{
  "http.proxy": "http://127.0.0.1:7890",
  "http.proxyStrictSSL": false,
  "http.proxySupport": "on"
}
```

#### 步骤 4：配置本地代理服务

确保你的本地代理服务（Clash/V2Ray）正在运行：

**V2rayN 配置：**
1. 打开 V2rayN 设置
2. 进入 **Core: 基础设置** 标签
3. 开启 **允许来自局域网的连接**
4. 确认端口为 7890

**Clash 配置：**
1. 打开 Clash 设置
2. 确认 HTTP 代理端口为 7890
3. 开启 **Allow LAN**

#### 步骤 5：重启 Antigravity

完全关闭并重新启动 Antigravity IDE。

### 方案 2：SSH 端口转发（高级）

如果你的服务器在国外，可以通过 SSH 端口转发使用服务器的网络。

#### 配置 SSH Config

编辑 `~/.ssh/config` (Linux/Mac) 或 `C:\Users\你的用户名\.ssh\config` (Windows)：

```
Host your-server
    Hostname your-server-ip
    User your-username
    Port 22
    RemoteForward 7890 localhost:7890
```

这会将本地的 7890 端口转发到服务器，但通常不需要这样做。

## ❓ 常见问题

### Q: 我的服务器在美国，还需要配置代理吗？

A: 如果你的**本地网络**可以直接访问 Anthropic API，就不需要配置代理。

### Q: 如何判断我是否在使用 Remote-SSH？

A: 查看 Antigravity 窗口左下角：
- 如果显示 `SSH: 服务器名`，说明你在使用 Remote-SSH
- 如果没有显示，说明是本地模式

### Q: 我已经在服务器上运行了脚本，怎么办？

A: 运行卸载脚本恢复：

```bash
cd Antigravity-Proxy-Bridge
sudo ./uninstall.sh
```

### Q: 配置后 AI 功能还是不能用？

A: 检查以下几点：

1. **本地代理是否运行**
   ```powershell
   # Windows PowerShell
   Test-NetConnection -ComputerName 127.0.0.1 -Port 7890
   ```

2. **代理是否能访问外网**
   ```powershell
   curl -x http://127.0.0.1:7890 https://www.google.com
   ```

3. **Antigravity 设置是否正确**
   - 确认在 User 设置，不是 Remote 设置
   - 确认代理地址正确

4. **查看 Antigravity 输出日志**
   - 打开 Output 面板
   - 选择 "Antigravity" 频道
   - 查看是否有网络错误

## 📖 相关文档

- [SSH 连接配置指南](../antigravity-ssh连接记录/SSH连接配置指南.md)
- [故障排查](troubleshooting.md)
- [主 README](../README.md)

## 🎯 架构图

```
┌─────────────────────────────────┐
│  本地 Windows/Mac               │
│  ┌───────────────────────────┐  │
│  │ Antigravity IDE           │  │
│  │ (需要配置代理)            │  │
│  └───────────┬───────────────┘  │
│              │                   │
│  ┌───────────▼───────────────┐  │
│  │ 本地代理 (Clash/V2Ray)    │  │
│  │ Port: 7890                │  │
│  └───────────┬───────────────┘  │
└──────────────┼───────────────────┘
               │ SSH 连接
               ▼
┌─────────────────────────────────┐
│  远程服务器                     │
│  ┌───────────────────────────┐  │
│  │ 代码文件                  │  │
│  │ 执行环境                  │  │
│  │ (不需要配置代理)          │  │
│  └───────────────────────────┘  │
└─────────────────────────────────┘
```

---

**记住：Remote-SSH 模式下，代理配置在本地，不在服务器！**
