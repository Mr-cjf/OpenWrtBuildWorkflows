## OpenWrt 固件构建工作流

本仓库是在 **[P3TERX/Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt)** 的基础上改进的。由于原仓库已归档且无法提交PR，因此提供了一个新的仓库。

- - -

本项目修复了由于GitHub权限系统升级导致的原项目中的某些功能故障，并改进了自动编译源代码更新的功能。本仓库中的工作流不需要额外的令牌。

**2023/2/16:** 完全重构，解决了许多旧问题，提高了安全性和可靠性。

**2023/3/10:** 删除了加载 `feeds.conf.default` 的功能，因为在编译非默认分支或哈希的源代码时，这很容易无意中导致问题。
具体来说，依赖于特定分支或哈希的源代码的源feeds也需要指定分支或哈希。此时，如果我们仍然使用文件覆盖的方式引入自定义feeds，我们必须小心不要覆盖和丢失原始基础feed的分支或哈希信息。
因此，替代方案是使用 `CUSTOM_SCRIPT_1` 来修改 `feeds.conf.default`。请参阅 `example-custom-script-1.sh` 中的注释以获取详细信息。

- - -

### 使用方法:

1. 从本仓库生成您的工作流仓库，并从 `template.yaml` 生成工作流文件。您可以将 `template.yaml` 的副本重命名为任何名称，但请记住文件扩展名必须为
   `.yaml` 或 `.yml`。

2. 在您的工作流文件中，根据注释修改内容。
3. 然后您可以手动或定期启动工作流。
    + 在 Actions 页面选择工作流名称以手动运行。
    + 为了定期运行，您需要取消注释：

参考文章：[OpenWrt 固件构建指南](https://www.right.com.cn/forum/thread-8280628-1-1.html)