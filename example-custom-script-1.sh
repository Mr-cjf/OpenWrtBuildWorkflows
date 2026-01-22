#!/bin/bash
# 版权所有 (c) 2022-2023 好奇心 <https://www.curious.host>
#
# 这是自由软件，遵循 MIT 许可证。
# 请参阅 /LICENSE 获取更多信息。
# 
# https://github.com/Curious-r/OpenWrtBuildWorkflows
# 描述: 自动检查 OpenWrt 源代码更新并构建它。无需额外的密钥。
#-------------------------------------------------------------------------------------------------------
#
#
# 该脚本将在 feeds 更新之前运行，您希望在那一刻执行的操作应写在这里。
# 该脚本的一个常见功能是修改克隆的 OpenWrt 源代码。
#
# 例如，您可以编辑 feeds.conf.default 以引入您需要的包。
# 以下是编辑示例。
# === 全自动识别版本逻辑 ===
# 优先从环境变量获取，如果没有，则尝试从源码目录识别
if [ -n "$VERSION_INFO" ]; then
    VERSION_STR="$VERSION_INFO"
    echo "📌 从环境变量识别到版本: $VERSION_STR"
elif [ -f "include/version.mk" ]; then
    # 从源码配置文件中提取主版本号
    VERSION_STR=$(grep "VERSION_NUMBER:=" include/version.mk | cut -d'=' -f2 | tr -d ' ')
    echo "📌 从源码文件识别到版本: $VERSION_STR"
else
    VERSION_STR="master"
    echo "⚠️ 无法识别版本，默认使用: master"
fi

# 格式化分支名称 (例如将 v24.10.0 或 24.10.0 转换为 openwrt-24.10)
if [[ "$VERSION_STR" == "master" ]]; then
    FEED_BRANCH="master"
else
    # 提取前两个数字部分 (例如 24.10)
    MAJOR_VERSION=$(echo "$VERSION_STR" | grep -oP '\d+\.\d+' | head -1)
    FEED_BRANCH="openwrt-$MAJOR_VERSION"
fi

echo "🚀 自动配置 Feed 分支为: $FEED_BRANCH"

# === 动态更新软件源 ===
cat <<EOF > feeds.conf.default
src-git packages https://git.openwrt.org/feed/packages.git;$FEED_BRANCH
src-git luci https://git.openwrt.org/project/luci.git;$FEED_BRANCH
src-git routing https://git.openwrt.org/feed/routing.git;$FEED_BRANCH
src-git telephony https://git.openwrt.org/feed/telephony.git;$FEED_BRANCH
src-git core https://git.openwrt.org/openwrt/openwrt.git;$FEED_BRANCH
src-git base https://git.openwrt.org/openwrt/openwrt.git;$FEED_BRANCH
EOF
# 提示：这里直接使用了 src-git 以提高克隆速度

#
# 您还可以通过打补丁来修改源代码。
# # 以下是一个补丁模板：
#touch example.patch
#cat>example.patch<<EOF
#补丁内容
#EOF
#git apply example.patch