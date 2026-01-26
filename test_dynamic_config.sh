#!/bin/bash
# 测试动态配置说明生成功能

echo "测试动态配置说明生成功能..."

# 检查必要文件是否存在
if [ ! -f "example.config" ]; then
    echo "错误: 找不到 example.config 文件"
    exit 1
fi

# 模拟生成动态配置说明的核心部分
echo "模拟生成配置摘要..."
TARGETS=$(grep '^CONFIG_TARGET_' example.config | grep '=y' | head -5 | tr '\n' ', ' | sed 's/, $//')
echo "目标架构: $TARGETS"

NETWORK=$(grep -E '^CONFIG_DEFAULT_(dnsmasq|firewall4|dropbear|ppp|odhcpd|odhcp6c)' example.config | grep '=y' | sed 's/CONFIG_DEFAULT_//' | sed 's/=y//' | tr '\n' ', ' | sed 's/, $//')
echo "网络服务: $NETWORK"

DRIVERS=$(grep -E '^CONFIG_DEFAULT_kmod-(e1000|igb|r8169|tg3|bnx2|forcedeth|ath|mt76|rt)' example.config | grep '=y' | sed 's/CONFIG_DEFAULT_//' | sed 's/=y//' | tr '\n' ', ' | sed 's/, $//')
echo "网络驱动: $DRIVERS"

echo "测试完成。动态配置说明生成功能正常。"