# 故障排查指南

本文档帮助你解决使用 Antigravity-Proxy-Bridge 时可能遇到的问题。

## 🔍 常见问题

### 1. 安装相关

#### Q: 提示 "graftcp 未安装"

**原因**: 缺少必需的依赖工具

**解决方案**:

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y graftcp

# CentOS/RHEL
sudo yum install -y graftcp

# Arch Linux
sudo pacman -S graftcp
```

#### Q: 提示 "未找到 Antigravity 安装路径"

**原因**: Antigravity 未安装或安装在非标准路径

**解决方案**:

1. 确认 Antigravity 已安装：
   ```bash
   # 桌面版
   ls -la /usr/share/antigravity
   
   # 服务器版
   ls -la ~/.antigravity-server
   ```

2. 如果安装在其他路径，手动搜索：
   ```bash
   find / -name "language_server_linux_x64" 2>/dev/null
   ```

#### Q: 提示 "权限被拒绝"

**原因**: 没有使用 sudo 运行

**解决方案**:

```bash
sudo ./setup.sh
```

### 2. 网络相关

#### Q: 配置后 AI 功能还是不能用

**诊断步骤**:

1. **检查代理服务是否运行**:
   ```bash
   # 检查端口是否监听
   netstat -tlnp | grep 7890
   # 或
   ss -tlnp | grep 7890
   ```

2. **测试代理连接**:
   ```bash
   curl -x http://127.0.0.1:7890 https://www.google.com
   ```

3. **检查 graftcp 是否工作**:
   ```bash
   graftcp curl https://www.google.com
   ```

4. **查看 Antigravity 日志**:
   ```bash
   tail -f /tmp/antigravity-proxy-wrapper.log
   ```

#### Q: 提示 "无法连接到代理服务"

**原因**: 代理服务未运行或端口不正确

**解决方案**:

1. 启动代理服务（Clash/V2Ray）

2. 确认端口配置：
   ```bash
   # Clash
   cat ~/.config/clash/config.yaml | grep port
   
   # V2Ray
   cat /etc/v2ray/config.json | grep port
   ```

3. 如果端口不是 7890，重新运行脚本：
   ```bash
   sudo ./setup.sh --proxy http://127.0.0.1:你的端口
   ```

#### Q: 美国服务器配置后反而变慢

**原因**: 美国服务器本身可以直连，不需要代理

**解决方案**:

卸载配置：
```bash
sudo ./uninstall.sh
```

### 3. Remote-SSH 相关

#### Q: 我使用 Remote-SSH，配置后没效果

**原因**: Remote-SSH 模式不需要在服务器配置

**解决方案**:

1. 卸载服务器上的配置：
   ```bash
   sudo ./uninstall.sh
   ```

2. 在本地 Antigravity 配置代理：
   - 打开设置 (Ctrl+,)
   - 切换到 User 标签
   - 搜索 proxy
   - 设置为 `http://127.0.0.1:7890`

详见: [Remote-SSH 配置指南](remote-ssh-guide.md)

### 4. 备份和恢复

#### Q: 如何恢复到原始状态？

**解决方案**:

```bash
sudo ./uninstall.sh
```

或手动恢复：
```bash
# 恢复 language_server
sudo cp /path/to/language_server_linux_x64.bak /path/to/language_server_linux_x64

# 恢复 main.js
sudo cp /path/to/main.js.bak /path/to/main.js
```

#### Q: 备份文件丢失了怎么办？

**解决方案**:

1. 检查 backup 目录：
   ```bash
   ls -la backup/
   ```

2. 如果备份丢失，重新安装 Antigravity：
   ```bash
   # 桌面版
   sudo apt reinstall antigravity
   
   # 服务器版
   # 重新下载安装包
   ```

### 5. 更新相关

#### Q: Antigravity 更新后配置失效

**原因**: 更新覆盖了修改的文件

**解决方案**:

重新运行配置脚本：
```bash
cd Antigravity-Proxy-Bridge
sudo ./setup.sh
```

#### Q: 脚本更新后出现问题

**解决方案**:

1. 先卸载旧配置：
   ```bash
   sudo ./uninstall.sh
   ```

2. 更新脚本：
   ```bash
   git pull
   ```

3. 重新安装：
   ```bash
   sudo ./setup.sh
   ```

## 🔧 高级诊断

### 检查文件完整性

```bash
# 检查 wrapper 脚本
cat /path/to/language_server_linux_x64 | head -20

# 检查 main.js 注入
grep "Antigravity-Proxy-Bridge" /path/to/main.js
```

### 查看详细日志

```bash
# 安装日志
cat install.log

# Wrapper 日志
tail -f /tmp/antigravity-proxy-wrapper.log

# 系统日志
journalctl -u antigravity -f
```

### 测试 graftcp

```bash
# 测试基本功能
graftcp curl https://www.google.com

# 测试 DNS 解析
graftcp nslookup google.com

# 查看 graftcp 配置
cat ~/.graftcp/graftcp.conf
```

### 网络抓包

```bash
# 安装 tcpdump
sudo apt install tcpdump

# 抓取代理端口流量
sudo tcpdump -i lo port 7890 -w proxy.pcap

# 分析
tcpdump -r proxy.pcap
```

## 📝 收集诊断信息

如果问题仍未解决，收集以下信息提交 Issue：

```bash
# 创建诊断报告
cat > diagnostic_report.txt << EOF
=== 系统信息 ===
$(uname -a)
$(lsb_release -a 2>/dev/null)

=== Antigravity 版本 ===
$(antigravity --version 2>/dev/null || echo "未找到")

=== 依赖检查 ===
graftcp: $(which graftcp)
graftcp version: $(graftcp --version 2>&1)
curl: $(which curl)

=== 网络测试 ===
Google 直连: $(curl -s --connect-timeout 5 https://www.google.com > /dev/null 2>&1 && echo "成功" || echo "失败")
代理测试: $(curl -s --connect-timeout 5 -x http://127.0.0.1:7890 https://www.google.com > /dev/null 2>&1 && echo "成功" || echo "失败")

=== 端口检查 ===
$(netstat -tlnp | grep 7890 || echo "端口 7890 未监听")

=== 安装日志 ===
$(tail -50 install.log 2>/dev/null || echo "日志文件不存在")

=== Wrapper 日志 ===
$(tail -50 /tmp/antigravity-proxy-wrapper.log 2>/dev/null || echo "日志文件不存在")
EOF

cat diagnostic_report.txt
```

## 🆘 获取帮助

如果以上方法都无法解决问题：

1. **查看文档**:
   - [安装指南](installation.md)
   - [Remote-SSH 指南](remote-ssh-guide.md)
   - [技术架构](architecture.md)

2. **提交 Issue**:
   - GitHub: https://github.com/Shanyu1314/Antigravity-Proxy-Bridge/issues
   - 附上诊断报告
   - 描述详细的复现步骤

3. **社区讨论**:
   - GitHub Discussions
   - 相关论坛

## 💡 预防措施

- 定期备份重要文件
- 更新前先运行 `--dry-run`
- 保留安装日志
- 记录自定义配置
- 测试环境先验证

---

**记住：遇到问题不要慌，按步骤排查，大部分问题都能解决！**
