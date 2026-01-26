#!/bin/bash
# 动态生成 OpenWrt 配置说明的脚本
# 该脚本会解析 example.config 文件并提取关键配置信息

CONFIG_FILE="example.config"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "错误: 找不到 $CONFIG_FILE 文件"
    exit 1
fi

echo "正在解析 $CONFIG_FILE 文件..."

# 提取目标架构信息
TARGET_ARCH=$(grep "^CONFIG_TARGET_" "$CONFIG_FILE" | grep "=y" | head -5 | tr '\n' ',' | sed 's/,$//')
echo "目标架构配置: $TARGET_ARCH"

# 提取内核版本
KERNEL_VERSION=$(grep "^CONFIG_LINUX_" "$CONFIG_FILE" | grep "=y" | head -3 | tr '\n' ',' | sed 's/,$//')
echo "内核版本: $KERNEL_VERSION"

# 提取默认包配置（前10个）
DEFAULT_PACKAGES=$(grep "^CONFIG_DEFAULT_" "$CONFIG_FILE" | grep "=y" | sed 's/CONFIG_DEFAULT_//' | sed 's/=y//' | head -10 | tr '\n' ',' | sed 's/,$//')
echo "默认包配置: $DEFAULT_PACKAGES"

# 提取网络相关包
NETWORK_PACKAGES=$(grep -E "^CONFIG_DEFAULT_(dnsmasq|firewall4|dropbear|ppp|odhcpd|odhcp6c)" "$CONFIG_FILE" | grep "=y" | sed 's/CONFIG_DEFAULT_//' | sed 's/=y//' | tr '\n' ',' | sed 's/,$//')
echo "网络服务: $NETWORK_PACKAGES"

# 提取驱动相关包
DRIVER_PACKAGES=$(grep -E "^CONFIG_DEFAULT_kmod-(e1000|igb|r8169|tg3|bnx2|forcedeth|usb-net|sdhci)" "$CONFIG_FILE" | grep "=y" | sed 's/CONFIG_DEFAULT_//' | sed 's/=y//' | tr '\n' ',' | sed 's/,$//')
echo "网络驱动: $DRIVER_PACKAGES"

echo "配置分析完成。"