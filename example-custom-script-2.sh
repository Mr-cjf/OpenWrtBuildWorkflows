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
# 通常建议进行补丁。
# # 以下是一个补丁模板：
#touch example.patch
#cat>example.patch<<EOF
#补丁内容
#EOF
#git apply example.patch
ln -s /bin/openwrtTool.sh files/bin/openwrtTool
chmod +x files/bin/openwrtTool.sh