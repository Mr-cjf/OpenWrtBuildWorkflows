#!/bin/bash

# 模拟测试 GitHub Actions 工作流中的版本检测逻辑

echo "=========================================="
echo "OpenWrt 版本检测模拟测试"
echo "=========================================="
echo ""

# 模拟环境变量
REPO_URL="https://github.com/openwrt/openwrt.git"
REPO_BRANCH="v24.10.0"

echo "📋 测试配置:"
echo "  仓库URL: $REPO_URL"
echo "  默认版本: $REPO_BRANCH"
echo ""

# 获取 OpenWrt 仓库的所有可用分支和标签
echo "🔍 正在获取 OpenWrt 仓库的可用版本..."

# 先获取所有标签
echo "  正在从 GitHub API 获取所有标签..."
ALL_TAGS=$(curl -s "https://api.github.com/repos/openwrt/openwrt/tags" | \
  grep '"name"' | \
  grep -oP 'v\d+\.\d+\.\d+' | \
  sort -V -r)

echo "  找到 $(echo "$ALL_TAGS" | wc -l) 个候选版本"
echo ""

# 验证标签是否真的存在于远程仓库
LATEST_VERSION=""
VALID_TAGS=0
CHECKED_TAGS=0

echo "🔎 开始验证标签..."
echo ""

for tag in $ALL_TAGS; do
  CHECKED_TAGS=$((CHECKED_TAGS + 1))
  echo "  [$CHECKED_TAGS] 检查标签: $tag"
  
  if git ls-remote --exit-code --tags $REPO_URL refs/tags/$tag > /dev/null 2>&1; then
    LATEST_VERSION="$tag"
    VALID_TAGS=$((VALID_TAGS + 1))
    echo "      ✅ 找到有效标签: $LATEST_VERSION"
    echo ""
    break
  else
    echo "      ❌ 标签不存在或无效"
  fi
  
  # 只检查前10个标签,避免测试时间过长
  if [ $CHECKED_TAGS -ge 10 ]; then
    echo "  已检查前10个标签,停止验证..."
    echo ""
    break
  fi
done

# 如果获取失败，使用默认版本
if [ -z "$LATEST_VERSION" ]; then
  LATEST_VERSION="$REPO_BRANCH"
  echo "⚠️  无法获取最新版本，使用默认版本: $LATEST_VERSION"
  echo "❌ 测试失败: 没有找到有效的版本标签"
else
  echo "✅ 检测到最新版本: $LATEST_VERSION"
  echo "✅ 测试成功: 找到 $VALID_TAGS 个有效标签"
fi

echo ""
echo "=========================================="
echo "测试结果汇总"
echo "=========================================="
echo "  检查的标签数: $CHECKED_TAGS"
echo "  有效的标签数: $VALID_TAGS"
echo "  最终使用的版本: $LATEST_VERSION"
echo "=========================================="
echo ""

# 尝试克隆验证
echo "🧪 验证版本是否可以克隆..."
echo "  尝试克隆 $LATEST_VERSION ..."
if git clone --depth 1 --branch $LATEST_VERSION --single-branch $REPO_URL /tmp/test-openwrt-clone 2>&1 | head -5; then
  echo "  ✅ 克隆成功!"
  rm -rf /tmp/test-openwrt-clone
  echo "  ✅ 最终验证通过"
else
  echo "  ❌ 克隆失败!"
  echo "  ❌ 最终验证失败"
fi

echo ""
echo "=========================================="
echo "测试完成"
echo "=========================================="