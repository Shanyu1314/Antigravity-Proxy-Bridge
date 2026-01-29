#!/bin/bash

# 路径检测测试脚本

echo "=== Antigravity 路径检测测试 ==="
echo ""

# 测试桌面版路径
echo "1. 检测桌面版路径..."
DESKTOP_PATH="/usr/share/antigravity"
if [[ -d "$DESKTOP_PATH" ]]; then
    echo "   ✅ 找到桌面版目录: $DESKTOP_PATH"
    
    LS_BIN="$DESKTOP_PATH/resources/app/extensions/antigravity/bin/language_server_linux_x64"
    if [[ -f "$LS_BIN" ]]; then
        echo "   ✅ 找到 Language Server: $LS_BIN"
    else
        echo "   ❌ 未找到 Language Server"
    fi
    
    MAIN_JS="$DESKTOP_PATH/resources/app/out/main.js"
    if [[ -f "$MAIN_JS" ]]; then
        echo "   ✅ 找到 Main JS: $MAIN_JS"
    else
        echo "   ❌ 未找到 Main JS"
    fi
else
    echo "   ℹ️  未安装桌面版"
fi

# 测试服务器版路径
echo ""
echo "2. 检测服务器版路径..."
SERVER_PATH="$HOME/.antigravity-server"
if [[ -d "$SERVER_PATH" ]]; then
    echo "   ✅ 找到服务器版目录: $SERVER_PATH"
    
    LS_BIN=$(find "$SERVER_PATH" -name "language_server_linux_x64" -type f 2>/dev/null | head -n 1)
    if [[ -n "$LS_BIN" ]]; then
        echo "   ✅ 找到 Language Server: $LS_BIN"
    else
        echo "   ❌ 未找到 Language Server"
    fi
    
    MAIN_JS=$(find "$SERVER_PATH" -name "server-main.js" -o -name "main.js" -type f 2>/dev/null | head -n 1)
    if [[ -n "$MAIN_JS" ]]; then
        echo "   ✅ 找到 Main JS: $MAIN_JS"
    else
        echo "   ❌ 未找到 Main JS"
    fi
else
    echo "   ℹ️  未安装服务器版"
fi

echo ""
echo "=== 测试完成 ==="
