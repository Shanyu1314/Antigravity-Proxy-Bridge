#!/bin/bash

# 网络测试脚本

echo "=== 网络连接测试 ==="
echo ""

# 测试 Google 连接
echo "1. 测试 Google 直连..."
if curl -s --connect-timeout 5 https://www.google.com > /dev/null 2>&1; then
    echo "   ✅ 成功"
else
    echo "   ❌ 失败"
fi

# 测试代理端口
echo ""
echo "2. 测试代理端口 7890..."
if nc -z -w2 127.0.0.1 7890 2>/dev/null; then
    echo "   ✅ 端口开放"
else
    echo "   ❌ 端口未开放"
fi

# 测试通过代理访问
echo ""
echo "3. 测试通过代理访问 Google..."
if curl -s --connect-timeout 5 -x http://127.0.0.1:7890 https://www.google.com > /dev/null 2>&1; then
    echo "   ✅ 成功"
else
    echo "   ❌ 失败"
fi

# 测试 graftcp
echo ""
echo "4. 测试 graftcp..."
if command -v graftcp &> /dev/null; then
    if graftcp curl -s --connect-timeout 5 https://www.google.com > /dev/null 2>&1; then
        echo "   ✅ graftcp 工作正常"
    else
        echo "   ❌ graftcp 无法访问网络"
    fi
else
    echo "   ❌ graftcp 未安装"
fi

echo ""
echo "=== 测试完成 ==="
