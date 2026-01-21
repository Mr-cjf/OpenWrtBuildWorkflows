#!/bin/bash

# 本地测试脚本 - 验证自动获取 OpenWrt 最新版本功能
# 使用方法: bash test-version-fetch.sh

echo "=========================================="
echo "🔍 OpenWrt 最新版本获取测试"
echo "=========================================="
echo ""

# 配置变量
REPO_URL="https://github.com/openwrt/openwrt.git"
REPO_BRANCH="v24.10.0"  # 默认版本（备用）

echo "📡 正在从 GitHub API 获取最新版本..."
echo ""

# 获取最新版本
LATEST_VERSION=$(curl -s "https://api.github.com/repos/openwrt/openwrt/tags" | \
  grep '"name"' | \
  grep -oP 'v\d+\.\d+\.\d+' | \
  head -n 1)

# 检查是否成功获取
if [ -z "$LATEST_VERSION" ]; then
  LATEST_VERSION="$REPO_BRANCH"
  echo "⚠️  无法获取最新版本，使用默认版本: $LATEST_VERSION"
  echo "   可能原因:"
  echo "   - 网络连接问题"
  echo "   - GitHub API 限制"
  echo "   - curl 未安装或配置错误"
else
  echo "✅ 成功检测到最新版本: $LATEST_VERSION"
fi

echo ""
echo "=========================================="
echo "📋 版本详细信息"
echo "=========================================="
echo "默认版本: $REPO_BRANCH"
echo "最新版本: $LATEST_VERSION"
echo ""

# 显示前 5 个可用版本
echo "=========================================="
echo "🏷️  OpenWrt 最近的版本标签 (前10个)"
echo "=========================================="
VERSIONS=$(curl -s "https://api.github.com/repos/openwrt/openwrt/tags" | \
  grep '"name"' | \
  grep -oP 'v\d+\.\d+\.\d+' | \
  head -n 10)

if [ -z "$VERSIONS" ]; then
  echo "⚠️  无法获取版本列表"
else
  echo "$VERSIONS" | nl
fi

echo ""
echo "=========================================="
echo "🔬 测试版本分支是否存在"
echo "=========================================="
echo "正在验证版本 $LATEST_VERSION 是否可访问..."
echo ""

# 测试是否可以访问该分支（轻量级检查）
if git ls-remote --tags "$REPO_URL" | grep -q "refs/tags/$LATEST_VERSION"; then
  echo "✅ 版本 $LATEST_VERSION 存在且可访问"
  echo ""
  echo "   提交信息:"
  git ls-remote --tags "$REPO_URL" | grep "refs/tags/$LATEST_VERSION"
else
  echo "❌ 版本 $LATEST_VERSION 不存在或无法访问"
fi

echo ""
echo "=========================================="
echo "💡 测试建议"
echo "=========================================="
echo "1. 如果能看到版本号，说明 API 调用成功"
echo "2. 如果版本号可访问，说明可以正常克隆"
echo "3. 在 GitHub Actions 中运行时，逻辑完全相同"
echo ""
echo "✅ 测试完成！"
echo ""

# 返回用于脚本调用的版本号
echo "$LATEST_VERSION"
