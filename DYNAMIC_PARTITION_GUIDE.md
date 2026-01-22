# OpenWrt 动态分区和 Overlay2 配置指南

本文档说明如何使用本项目实现 OpenWrt 固件的动态分区扩展和 Overlay2 支持。

## 功能概述

本项目现在支持以下功能：

1. **动态分区大小配置** - 在编译时自定义根文件系统分区大小
2. **自动分区扩展** - 安装后自动扩展分区以利用全部可用空间
3. **Overlay2 支持** - 使用 BTRFS 文件系统实现动态存储扩展

## 功能 1: 动态分区大小配置

### 在 GitHub Actions 中设置

在触发工作流时，可以设置以下参数：

- **rootfs_size**: 根文件系统分区大小（MB）
  - 范围：256MB - 8192MB
  - 默认值：1024MB
  - 示例：2048（创建 2GB 的根分区）

- **enable_overlay2**: 启用 Overlay2 文件系统支持
  - 类型：布尔值
  - 默认：false
  - 启用后会自动配置 BTRFS 相关依赖

### 使用示例

1. 进入 GitHub Actions 页面
2. 选择 "openwrt-build固件云编译" 工作流
3. 点击 "Run workflow"
4. 填写参数：
   ```
   固件默认地址: 192.168.1.77
   根文件系统分区大小(MB): 2048
   启用Overlay2文件系统支持: ✅
   ```
5. 点击运行

### 配置文件说明

在 `example.config` 文件中，分区配置如下：

```bash
CONFIG_TARGET_KERNEL_PARTSIZE=100      # 内核分区：100MB
CONFIG_TARGET_ROOTFS_PARTSIZE=1024     # 根文件系统分区：1024MB (1GB)
```

当启用动态分区时，工作流会自动修改 `CONFIG_TARGET_ROOTFS_PARTSIZE` 的值。

## 功能 2: 自动分区扩展

### 使用 openwrtTool.sh 脚本

在 OpenWrt 系统中运行：

```bash
sudo /files/bin/openwrtTool.sh
```

选择选项 **2. 扩展根分区和文件系统**

### 扩展选项

脚本提供三种扩展方式：

1. **自动扩展到最大可用空间**
   - 自动检测磁盘剩余空间
   - 将分区扩展到磁盘末尾

2. **手动指定扩展大小**
   - 输入要扩展的具体大小（MB）
   - 例如：扩展 1024MB

3. **扩展到指定总大小**
   - 输入目标总大小（MB）
   - 例如：扩展到 4096MB

### 支持的文件系统

- ext4（推荐）
- ext3
- ext2
- btrfs

### 使用示例

```bash
# 运行工具脚本
sudo /files/bin/openwrtTool.sh

# 选择选项 2
请输入选项 (1-6): 2

# 查看当前状态
当前根分区设备: /dev/sda2
磁盘设备: /dev/sda
分区号: 2
当前分区大小: 1024MB
磁盘总大小: 16384MB
可用空间: 15360MB

# 选择扩展方式
请输入选项 (1-4): 1

# 确认操作
确认继续? (yes/no): yes

# 等待扩展完成
✅ 文件系统扩展成功!
新分区大小: 16384MB
扩展大小: 15360MB
```

## 功能 3: Overlay2 支持

### 启用 Overlay2

在编译固件时启用 `enable_overlay2` 参数，系统会自动安装：

- `kmod-loop` - 循环设备支持
- `kmod-fs-btrfs` - BTRFS 文件系统支持
- `btrfs-progs` - BTRFS 工具集
- `block-mount` - 块设备挂载支持
- `blockd` - 块设备守护进程

### 配置 Overlay2 存储

在 OpenWrt 系统中运行：

```bash
sudo /files/bin/openwrtTool.sh
```

选择选项 **6. 配置Overlay2动态存储**

### Overlay2 配置选项

1. **创建 BTRFS 格式的外部 Overlay 存储**
   - 使用独立的磁盘或分区
   - 创建 BTRFS 文件系统
   - 配置为 Overlay 存储层

2. **扩展现有 Overlay 分区**
   - 扩展当前使用的 Overlay 分区
   - 自动检测并利用可用空间

3. **查看当前存储使用情况**
   - 显示磁盘使用情况
   - 显示 Overlay 详细信息

### 创建外部 Overlay 存储示例

```bash
# 运行工具脚本
sudo /files/bin/openwrtTool.sh

# 选择选项 6
请输入选项 (1-6): 6

# 选择创建外部存储
请输入选项 (1-4): 1

# 查看可用磁盘
可用磁盘设备:
NAME   SIZE TYPE MOUNTPOINT
sda    16G  disk 
sdb    100G disk 

# 输入要使用的磁盘
请输入要使用的磁盘设备 (例如: /dev/sdb): /dev/sdb

# 确认创建
将使用整个磁盘创建BTRFS文件系统，确认继续? (yes/no): yes

# 等待完成
✅ Overlay2 BTRFS存储配置完成!
存储位置: /dev/sdb
挂载点: /mnt/overlay2

建议重启系统以应用更改
```

### 扩展现有 Overlay 分区示例

```bash
# 选择扩展现有分区
请输入选项 (1-4): 2

# 查看当前状态
当前Overlay设备: /dev/sda2
父磁盘: /dev/sda
磁盘总大小: 16384MB
当前分区大小: 1024MB
可用空间: 15360MB

# 确认扩展
扩展到最大可用空间? (yes/no): yes

# 等待完成
✅ Overlay分区扩展成功!
```

## 常见问题

### Q1: 分区扩展后空间没有增加？

**A:** 检查以下几点：
1. 确认文件系统扩展成功：`df -h /`
2. 检查是否有错误信息
3. 重启系统后再检查

### Q2: Overlay2 存储创建失败？

**A:** 可能的原因：
1. 磁盘设备已被挂载或使用
2. 磁盘空间不足
3. 缺少必要的内核模块

解决方法：
```bash
# 检查磁盘状态
lsblk

# 检查内核模块
lsmod | grep btrfs

# 安装缺失的包
opkg install kmod-fs-btrfs btrfs-progs
```

### Q3: 如何验证 Overlay2 是否正常工作？

**A:** 运行以下命令：

```bash
# 检查挂载点
mount | grep overlay

# 查看 Overlay 目录
ls -la /overlay

# 检查存储使用情况
df -h /overlay
```

### Q4: 分区大小设置多少合适？

**A:** 根据实际需求：

- **最小配置**: 256MB（仅基础系统）
- **推荐配置**: 1024-2048MB（标准使用）
- **大型配置**: 4096-8192MB（安装大量软件包）

注意：分区大小不能超过磁盘总容量。

### Q5: 支持哪些文件系统？

**A:** 
- 分区扩展：ext2, ext3, ext4, btrfs
- Overlay2：推荐使用 BTRFS，也支持 ext4

## 注意事项

1. **备份重要数据**
   - 分区操作有风险，操作前请备份重要数据
   - 建议在测试环境先验证

2. **磁盘空间规划**
   - 确保磁盘有足够空间
   - 考虑系统更新和软件包安装的空间需求

3. **文件系统选择**
   - ext4：稳定、兼容性好
   - btrfs：支持快照、压缩、动态扩展

4. **性能考虑**
   - SSD 建议使用 ext4
   - 机械硬盘可以考虑 btrfs 的压缩功能
   - Overlay2 会增加一层文件系统开销

5. **系统重启**
   - 某些操作需要重启系统才能完全生效
   - 建议在维护窗口进行分区扩展

## 技术细节

### 分区大小限制

- 最小：256MB（OpenWrt 系统要求）
- 最大：8192MB（8GB，可修改工作流调整）
- 推荐：1024-2048MB

### Overlay2 工作原理

Overlay2 使用分层存储：

```
OverlayFS (默认)
├── Lower Layer (只读基础系统)
└── Upper Layer (可读写修改)

BTRFS Overlay2
├── Root Subvolume (根卷)
├── Upper Subvolume (上层卷)
└── Work Subvolume (工作卷)
```

### 自动扩展流程

1. 检测根分区和磁盘信息
2. 计算可用空间
3. 使用 parted 扩展分区表
4. 使用 resize2fs/btrfs 扩展文件系统
5. 验证扩展结果

## 更新日志

### v1.0 (2024)
- ✅ 添加动态分区大小配置
- ✅ 实现自动分区扩展功能
- ✅ 添加 Overlay2 支持
- ✅ 改进安装脚本交互体验

## 支持和反馈

如有问题或建议，请提交 Issue 或 Pull Request。

---

**免责声明**: 分区操作有一定风险，请谨慎操作并在操作前备份重要数据。作者不对数据丢失负责。