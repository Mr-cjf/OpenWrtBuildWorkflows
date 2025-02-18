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
# # 清除 feeds.conf.default 并逐个添加所需的源：
#cat /dev/null > a.txt
#echo 'src-git-full packages https://git.openwrt.org/feed/packages.git;openwrt-22.03' >> feeds.conf.default
#echo 'src-git-full luci https://git.openwrt.org/project/luci.git;openwrt-22.03' >> feeds.conf.default
#echo 'src-git-full routing https://git.openwrt.org/feed/routing.git;openwrt-22.03' >> feeds.conf.default
#echo 'src-git-full telephony https://git.openwrt.org/feed/telephony.git;openwrt-22.03' >> feeds.conf.default
# # 替换一个源：
#sed '/feeds-name/'d feeds.conf.default
#echo 'method feed-name path/URL' >> feeds.conf.default
# # 取消注释一个源：
#sed -i 's/^#\(.*feed-name\)/\1/' feeds.conf.default
# # 将 src-git-full 替换为 src-git 以减少克隆深度：
#sed -i 's/src-git-full/src-git/g' feeds.conf.default
#
# 您还可以通过打补丁来修改源代码。
# # 以下是一个补丁模板：
#touch example.patch
#cat>example.patch<<EOF
#补丁内容
#EOF
#git apply example.patch