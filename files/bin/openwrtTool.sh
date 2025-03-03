#!/bin/bash
# 检查是否以 root 用户运行
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (use sudo)"
  exit 1
fi

# 获取 OpenWrt 版本号
if [ -f /etc/openwrt_release ]; then
  . /etc/openwrt_release
  RELEASE=$DISTRIB_RELEASE
else
  echo "无法找到 OpenWrt 版本信息。请确保 /etc/openwrt_release 文件存在。"
  exit 1
fi

echo "OpenWrt 版本号 $RELEASE"

# 打印菜单
echo "请选择要执行的操作:"
echo "1. 切换 OpenWrt 软件源"
echo "2. 扩展根分区和文件系统"
echo "3. 安装中文语言包"
echo "4. 安装istore"
echo "5. 安装主题Argon"

# 读取用户选择
read -p "请输入选项编号 (1-5): " choice

# 函数：备份官方源（如果尚未备份）
backup_official_src() {
  local official_backup="/etc/opkg/distfeeds.conf.official"
  local config_file="/etc/opkg/distfeeds.conf"
  if [ ! -f "$official_backup" ]; then
    echo "备份原始官方源配置..."
    cp "$config_file" "$official_backup"
  fi
}

# 函数：直接替换软件源
replace_src() {
  local package_type="$1"
  local new_url="$2"
  local config_file="$3"
  if grep -q "^src/gz ${package_type}" "$config_file"; then
    sed -i "s|^src/gz ${package_type}.*|src/gz ${package_type} ${new_url}|" "$config_file"
  else
    echo "src/gz ${package_type} ${new_url}" >> "$config_file"
  fi
}

# 函数：恢复官方源
restore_official_src() {
  echo "恢复原始官方源配置..."
  local official_backup="/etc/opkg/distfeeds.conf.official"
  local config_file="/etc/opkg/distfeeds.conf"
  if [ -f "$official_backup" ]; then
    cp "$official_backup" "$config_file"
    echo "已恢复原始官方源配置文件 $config_file"
  else
    echo "未找到原始官方源备份文件，无法恢复。"
  fi
}

# 函数：安装中文语言包
install_chinese_lang() {
  echo "正在安装中文语言包..."
  opkg update
  opkg install luci-i18n-base-zh-cn luci-i18n-opkg-zh-cn luci-i18n-firewall-zh-cn
  echo "中文语言包安装完成。"
}

# 根据选择执行操作
while true; do
  case $choice in
    1)
      echo "请选择要切换的 OpenWrt 软件源:"
      echo "1. 官方源"
      echo "2. 清华大学开源镜像站"
      echo "3. 中科大开源镜像站"
      echo "4. 阿里云镜像站"
      echo "5. 恢复原始官方源"
      echo ""

      # 读取用户选择
      read -p "请输入选项编号 (1-5): " mirror_choice

      # 备份官方源（如果尚未备份）
      backup_official_src

      case $mirror_choice in
        1)
          echo "切换到官方源..."
          replace_src "openwrt_core" "https://downloads.openwrt.org/releases/${RELEASE}/targets/x86/64/packages" "/etc/opkg/distfeeds.conf"
          replace_src "openwrt_base" "https://downloads.openwrt.org/releases/${RELEASE}/packages/x86_64/base" "/etc/opkg/distfeeds.conf"
          replace_src "openwrt_luci" "https://downloads.openwrt.org/releases/${RELEASE}/packages/x86_64/luci" "/etc/opkg/distfeeds.conf"
          replace_src "openwrt_packages" "https://downloads.openwrt.org/releases/${RELEASE}/packages/x86_64/packages" "/etc/opkg/distfeeds.conf"
          replace_src "openwrt_routing" "https://downloads.openwrt.org/releases/${RELEASE}/packages/x86_64/routing" "/etc/opkg/distfeeds.conf"
          replace_src "openwrt_telephony" "https://downloads.openwrt.org/releases/${RELEASE}/packages/x86_64/telephony" "/etc/opkg/distfeeds.conf"
          replace_src "openwrt_kmods" "https://downloads.openwrt.org/releases/${RELEASE}/targets/x86/64/kmods/6.6.73-1-a21259e4f338051d27a6443a3a7f7f1f" "/etc/opkg/distfeeds.conf"
          ;;
        2)
          echo "切换到清华大学开源镜像站..."
          replace_src "openwrt_core" "https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/${RELEASE}/targets/x86/64/packages" "/etc/opkg/distfeeds.conf"
          replace_src "openwrt_base" "https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/${RELEASE}/packages/x86_64/base" "/etc/opkg/distfeeds.conf"
          replace_src "openwrt_luci" "https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/${RELEASE}/packages/x86_64/luci" "/etc/opkg/distfeeds.conf"
          replace_src "openwrt_packages" "https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/${RELEASE}/packages/x86_64/packages" "/etc/opkg/distfeeds.conf"
          replace_src "openwrt_routing" "https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/${RELEASE}/packages/x86_64/routing" "/etc/opkg/distfeeds.conf"
          replace_src "openwrt_telephony" "https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/${RELEASE}/packages/x86_64/telephony" "/etc/opkg/distfeeds.conf"
          replace_src "openwrt_kmods" "https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/${RELEASE}/targets/x86/64/kmods/6.6.73-1-a21259e4f338051d27a6443a3a7f7f1f" "/etc/opkg/distfeeds.conf"
          ;;
        3)
          echo "切换到中科大开源镜像站..."
          replace_src "openwrt_core" "https://mirrors.ustc.edu.cn/openwrt/releases/${RELEASE}/targets/x86/64/packages" "/etc/opkg/distfeeds.conf"
          replace_src "openwrt_base" "https://mirrors.ustc.edu.cn/openwrt/releases/${RELEASE}/packages/x86_64/base" "/etc/opkg/distfeeds.conf"
          replace_src "openwrt_luci" "https://mirrors.ustc.edu.cn/openwrt/releases/${RELEASE}/packages/x86_64/luci" "/etc/opkg/distfeeds.conf"
          replace_src "openwrt_packages" "https://mirrors.ustc.edu.cn/openwrt/releases/${RELEASE}/packages/x86_64/packages" "/etc/opkg/distfeeds.conf"
          replace_src "openwrt_routing" "https://mirrors.ustc.edu.cn/openwrt/releases/${RELEASE}/packages/x86_64/routing" "/etc/opkg/distfeeds.conf"
          replace_src "openwrt_telephony" "https://mirrors.ustc.edu.cn/openwrt/releases/${RELEASE}/packages/x86_64/telephony" "/etc/opkg/distfeeds.conf"
          replace_src "openwrt_kmods" "https://mirrors.ustc.edu.cn/openwrt/releases/${RELEASE}/targets/x86/64/kmods/6.6.73-1-a21259e4f338051d27a6443a3a7f7f1f" "/etc/opkg/distfeeds.conf"
          ;;
        4)
          echo "切换到阿里云镜像站..."
          replace_src "openwrt_core" "https://mirrors.aliyun.com/openwrt/releases/${RELEASE}/targets/x86/64/packages" "/etc/opkg/distfeeds.conf"
          replace_src "openwrt_base" "https://mirrors.aliyun.com/openwrt/releases/${RELEASE}/packages/x86_64/base" "/etc/opkg/distfeeds.conf"
          replace_src "openwrt_luci" "https://mirrors.aliyun.com/openwrt/releases/${RELEASE}/packages/x86_64/luci" "/etc/opkg/distfeeds.conf"
          replace_src "openwrt_packages" "https://mirrors.aliyun.com/openwrt/releases/${RELEASE}/packages/x86_64/packages" "/etc/opkg/distfeeds.conf"
          replace_src "openwrt_routing" "https://mirrors.aliyun.com/openwrt/releases/${RELEASE}/packages/x86_64/routing" "/etc/opkg/distfeeds.conf"
          replace_src "openwrt_telephony" "https://mirrors.aliyun.com/openwrt/releases/${RELEASE}/packages/x86_64/telephony" "/etc/opkg/distfeeds.conf"
          replace_src "openwrt_kmods" "https://mirrors.aliyun.com/openwrt/releases/${RELEASE}/targets/x86/64/kmods/6.6.73-1-a21259e4f338051d27a6443a3a7f7f1f" "/etc/opkg/distfeeds.conf"
          ;;
        5)
          echo "恢复原始官方源..."
          restore_official_src
          ;;
        *)
          echo "无效选择，退出脚本。"
          exit 1
          ;;
      esac

      # 更新软件包列表
      echo "正在更新软件包列表..."
      opkg update
      echo "切换软件源完成！"
      ;;
    2)
      # Step 1: 扩展根分区和文件系统
      echo "Updating package list and installing required packages..."
      opkg update
      opkg install parted losetup resize2fs

      echo "Identifying disk and partition information..."
      parted -l -s

      echo "Expanding the root partition to 100%..."
      parted -f -s /dev/sda resizepart 2 100%

      echo "Rebooting the system to apply partition changes..."
      reboot

      # The script execution will stop here as the system will reboot.
      # After reboot, continue with the rest of the steps.

      echo "Mapping loop device to the root partition..."
      losetup /dev/loop0 /dev/sda2 2> /dev/null

      echo "Expanding the root filesystem..."
      resize2fs -f /dev/loop0

      echo "Rebooting the system to apply filesystem changes..."
      reboot
      ;;
    3)
      # Step 2: 安装中文语言包
      install_chinese_lang
      ;;
    4)
      echo "正在安装istore..."
      opkg update || exit 1
      opkg install ca-certificates
      # 确保 wget 已经安装
      opkg install wget
      wget --no-check-certificate -O /tmp/istore-reinstall.run https://github.com/linkease/openwrt-app-actions/raw/main/applications/luci-app-systools/root/usr/share/systools/istore-reinstall.run
      chmod 755 /tmp/istore-reinstall.run
      ./tmp/istore-reinstall.run
      echo "istore安装完成。"
      ;;
    5)
      echo "正在安装主题Argon..."
      opkg update
      opkg install luci-lua-runtime  # 新增安装 luci-lua-runtime
      opkg install luci-compat
      opkg install luci-lib-ipkg
      wget --no-check-certificate -O /tmp/luci-theme-argon_2.3.2-r20250207_all.ipk https://github.com/jerrykuku/luci-theme-argon/releases/download/v2.3.2/luci-theme-argon_2.3.2-r20250207_all.ipk
      opkg install /tmp/luci-theme-argon_2.3.2-r20250207_all.ipk
      wget --no-check-certificate -O /tmp/luci-app-argon-config_0.9_all.ipk https://github.com/jerrykuku/luci-app-argon-config/releases/download/v0.9/luci-app-argon-config_0.9_all.ipk
      opkg install /tmp/luci-app-argon-config_0.9_all.ipk
      echo "主题Argon安装完成。"
      ;;
    *)
      echo "无效选择，退出脚本。"
      exit 1
      ;;
  esac

  # 打印菜单
  echo "请选择要执行的操作:"
  echo "1. 切换 OpenWrt 软件源"
  echo "2. 扩展根分区和文件系统"
  echo "3. 安装中文语言包"
  echo "4. 安装istore"
  echo "5. 安装主题Argon"

  # 读取用户选择
  read -p "请输入选项编号 (1-5): " choice
done
