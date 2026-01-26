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
echo "6. 配置Overlay2动态存储"

# 读取用户选择
read -r -p "请输入选项编号 (1-6): " choice

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
      read -r -p "请输入选项编号 (1-5): " mirror_choice

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
      # 扩展根分区和文件系统
      echo "========================================"
      echo "   扩展根分区和文件系统"
      echo "========================================"
      
      # 检测根分区
      ROOT_DEV=$(df / | tail -1 | awk '{print $1}')
      if [[ $ROOT_DEV == /dev/loop* ]]; then
        ROOT_DEV=$(losetup -n -O BACK-FILE "$ROOT_DEV" | head -1)
      fi
      
      DISK_DEV=${ROOT_DEV%%[0-9]*}
      PART_NUM=${ROOT_DEV##*[^0-9]}
      
      echo "当前根分区设备: $ROOT_DEV"
      echo "磁盘设备: $DISK_DEV"
      echo "分区号: $PART_NUM"
      echo ""
      
      # 检查并安装必要工具
      echo "检查并安装必要工具..."
      opkg update
      opkg install parted losetup resize2fs e2fsprogs fdisk cfdisk
      
      # 显示当前磁盘信息
      echo ""
      echo "当前磁盘信息:"
      parted -l -s "$DISK_DEV" 2>/dev/null | grep -E "Disk|Number"
      df -h / | grep -E "Filesystem|$ROOT_DEV"
      echo ""
      
      # 获取当前分区大小
      CURRENT_SIZE=$(parted -s "$DISK_DEV" unit MB print | grep "^ $PART_NUM" | awk '{print $3}' | sed 's/MB//')
      DISK_SIZE=$(parted -s "$DISK_DEV" unit MB print | grep "^Disk" | awk '{print $3}' | sed 's/MB//')
      
      echo "当前分区大小: ${CURRENT_SIZE}MB"
      echo "磁盘总大小: ${DISK_SIZE}MB"
      echo ""
      
      # 扩展选项
      echo "请选择扩展方式:"
      echo "1. 自动扩展到最大可用空间"
      echo "2. 手动指定扩展大小 (MB)"
      echo "3. 扩展到指定总大小 (MB)"
      echo "4. 取消"
      read -r -p "请输入选项 (1-4): " expand_choice
      
      case $expand_choice in
        1)
          echo "将扩展分区到磁盘末尾 (100%)..."
          TARGET_SIZE="100%"
          ;;
        2)
          read -r -p "请输入要扩展的大小 (MB): " expand_mb
          TARGET_SIZE="$((CURRENT_SIZE + expand_mb))MB"
          echo "将扩展分区 ${expand_mb}MB，目标大小: $TARGET_SIZE"
          ;;
        3)
          read -r -p "请输入目标总大小 (MB): " target_mb
          TARGET_SIZE="${target_mb}MB"
          echo "将扩展分区到 $TARGET_SIZE"
          ;;
        4)
          echo "取消扩展操作"
          ;;
        *)
          echo "无效选择，取消操作"
          ;;
      esac
      
      if [ "$expand_choice" != "4" ] && [ -n "$TARGET_SIZE" ]; then
        echo ""
        echo "警告: 分区操作有风险，请确保已备份重要数据！"
        read -r -p "确认继续? (yes/no): " confirm
        
        if [ "$confirm" = "yes" ]; then
          echo "正在扩展分区..."
          if parted -f -s "$DISK_DEV" resizepart "$PART_NUM" "$TARGET_SIZE"; then
            echo "✅ 分区扩展成功！"
            echo ""
            echo "正在扩展文件系统..."
            
            # 检测文件系统类型
            FS_TYPE=$(df -T / | tail -1 | awk '{print $2}')
            echo "检测到文件系统类型: $FS_TYPE"
            
            # 扩展文件系统
            FS_RESIZE_SUCCESS=false
            case $FS_TYPE in
              ext4|ext3|ext2)
                # 尝试直接扩展
                if ! resize2fs "$ROOT_DEV" 2>/dev/null; then
                  # 如果失败，使用 loop 设备
                  echo "使用 loop 设备扩展..."
                  losetup /dev/loop0 "$ROOT_DEV" 2>/dev/null
                  resize2fs -f /dev/loop0 && FS_RESIZE_SUCCESS=true
                  losetup -d /dev/loop0 2>/dev/null
                else
                  FS_RESIZE_SUCCESS=true
                fi
                ;;
              btrfs)
                if btrfs filesystem resize max /; then
                  FS_RESIZE_SUCCESS=true
                fi
                ;;
              *)
                echo "不支持的文件系统类型: $FS_TYPE"
                ;;
            esac
            
            if [ "$FS_RESIZE_SUCCESS" = "true" ]; then
              echo "✅ 文件系统扩展成功！"
              echo ""
              echo "扩展后的磁盘信息:"
              df -h / | grep -E "Filesystem|$ROOT_DEV"
              echo ""
              echo "建议重启系统以确保所有更改生效"
              read -r -p "是否立即重启? (yes/no): " reboot_confirm
              if [ "$reboot_confirm" = "yes" ]; then
                reboot
              fi
            else
              echo "❌ 文件系统扩展失败，请检查错误信息"
            fi
          else
            echo "❌ 分区扩展失败，请检查错误信息"
          fi
        else
          echo "操作已取消"
        fi
      fi
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
    6)
      # 配置 Overlay2 动态存储
      echo "========================================"
      echo "   配置 Overlay2 动态存储"
      echo "========================================"
      
      echo "请选择操作:"
      echo "1. 创建 BTRFS 格式的外部 Overlay 存储"
      echo "2. 扩展现有 Overlay 分区"
      echo "3. 查看当前存储使用情况"
      echo "4. 返回主菜单"
      read -r -p "请输入选项 (1-4): " overlay_choice
      
      case $overlay_choice in
        1)
          # 创建外部 Overlay 存储
          echo ""
          echo "检查并安装必要的软件包..."
          opkg update
          opkg install kmod-loop kmod-fs-btrfs btrfs-progs block-mount blockd
          
          echo ""
          echo "可用磁盘设备:"
          lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | grep -E "NAME|disk"
          echo ""
          
          read -r -p "请输入要使用的磁盘设备 (例如: /dev/sdb): " overlay_disk
          
          if [ ! -b "$overlay_disk" ]; then
            echo "❌ 设备 $overlay_disk 不存在"
            break
          fi
          
          echo ""
          echo "警告: 将清空 $overlay_disk 上的所有数据！"
          read -r -p "确认继续? (yes/no): " confirm_overlay
          
          if [ "$confirm_overlay" = "yes" ]; then
            echo "正在创建 BTRFS 文件系统..."
            if mkfs.btrfs -f "$overlay_disk"; then
              echo "✅ BTRFS 文件系统创建成功"
              
              # 创建挂载点
              mkdir -p /mnt/overlay2
              
              # 挂载
              if mount "$overlay_disk" /mnt/overlay2; then
                echo "✅ 已挂载到 /mnt/overlay2"
                
                # 创建子卷
                btrfs subvolume create /mnt/overlay2/upper
                btrfs subvolume create /mnt/overlay2/work
                
                echo ""
                echo "配置自动挂载..."
                
                # 获取 UUID
                UUID=$(blkid -s UUID -o value "$overlay_disk")
                
                # 添加到 fstab
                if ! grep -q "$UUID" /etc/fstab; then
                  echo "UUID=$UUID /mnt/overlay2 btrfs defaults 0 0" >> /etc/fstab
                  echo "✅ 已添加到 /etc/fstab"
                fi
                
                echo ""
                echo "✅ Overlay2 BTRFS 存储配置完成！"
                echo "存储位置: $overlay_disk"
                echo "挂载点: /mnt/overlay2"
                echo ""
                echo "建议重启系统以应用更改"
                read -r -p "是否立即重启? (yes/no): " reboot_confirm
                if [ "$reboot_confirm" = "yes" ]; then
                  reboot
                fi
              else
                echo "❌ 挂载失败"
              fi
            else
              echo "❌ BTRFS 文件系统创建失败"
            fi
          else
            echo "操作已取消"
          fi
          ;;
        2)
          # 扩展现有 Overlay 分区
          echo ""
          echo "检测当前 Overlay 配置..."
          
          OVERLAY_DEV=$(df /overlay | tail -1 | awk '{print $1}')
          
          if [ -z "$OVERLAY_DEV" ]; then
            echo "❌ 未检测到 Overlay 分区"
            break
          fi
          
          echo "当前 Overlay 设备: $OVERLAY_DEV"
          
          # 获取父磁盘
          OVERLAY_DISK=${OVERLAY_DEV%%[0-9]*}
          OVERLAY_PART=${OVERLAY_DEV##*[^0-9]}
          
          echo "父磁盘: $OVERLAY_DISK"
          echo "分区号: $OVERLAY_PART"
          echo ""
          
          # 显示当前大小
          df -h /overlay
          echo ""
          
          read -r -p "扩展到最大可用空间? (yes/no): " expand_overlay
          
          if [ "$expand_overlay" = "yes" ]; then
            echo "正在扩展分区..."
            if parted -f -s "$OVERLAY_DISK" resizepart "$OVERLAY_PART" 100%; then
              echo "✅ 分区扩展成功"
              
              # 检测文件系统类型并扩展
              FS_TYPE=$(df -T /overlay | tail -1 | awk '{print $2}')
              
              # 扩展文件系统
              OVERLAY_RESIZE_SUCCESS=false
              case $FS_TYPE in
                ext4|ext3|ext2)
                  if resize2fs "$OVERLAY_DEV"; then
                    OVERLAY_RESIZE_SUCCESS=true
                  fi
                  ;;
                btrfs)
                  if btrfs filesystem resize max /overlay; then
                    OVERLAY_RESIZE_SUCCESS=true
                  fi
                  ;;
                *)
                  echo "不支持的文件系统: $FS_TYPE"
                  ;;
              esac
              
              if [ "$OVERLAY_RESIZE_SUCCESS" = "true" ]; then
                echo "✅ Overlay 分区扩展成功！"
                echo ""
                df -h /overlay
              else
                echo "❌ 文件系统扩展失败"
              fi
            else
              echo "❌ 分区扩展失败"
            fi
          fi
          ;;
        3)
          # 查看存储使用情况
          echo ""
          echo "========== 磁盘使用情况 =========="
          df -h
          echo ""
          echo "========== Overlay 详细信息 =========="
          if [ -d /overlay ]; then
            df -h /overlay
            echo ""
            du -sh /overlay/* 2>/dev/null
          else
            echo "Overlay 目录不存在"
          fi
          echo ""
          echo "========== 块设备信息 =========="
          lsblk
          ;;
        4)
          echo "返回主菜单"
          ;;
        *)
          echo "无效选择"
          ;;
      esac
      ;;
    *)
      echo "无效选择，退出脚本。"
      exit 1
      ;;
  esac

  # 打印菜单
  echo ""
  echo "请选择要执行的操作:"
  echo "1. 切换 OpenWrt 软件源"
  echo "2. 扩展根分区和文件系统"
  echo "3. 安装中文语言包"
  echo "4. 安装istore"
  echo "5. 安装主题Argon"
  echo "6. 配置Overlay2动态存储"

  # 读取用户选择
  read -r -p "请输入选项编号 (1-6): " choice
done
