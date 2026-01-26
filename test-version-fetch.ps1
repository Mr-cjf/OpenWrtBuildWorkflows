# PowerShell 测试脚本 - 验证自动获取 OpenWrt 最新版本功能
# 使用方法: .\test-version-fetch.ps1

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "🔍 OpenWrt 最新版本获取测试" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 配置变量
$REPO_URL = "https://github.com/openwrt/openwrt.git"
$REPO_BRANCH = "v24.10.0"  # 默认版本（备用）

Write-Host "📡 正在从 GitHub API 获取最新版本..." -ForegroundColor Yellow
Write-Host ""

try {
    # 获取最新版本
    $response = Invoke-RestMethod -Uri "https://api.github.com/repos/openwrt/openwrt/tags" -Method Get
    $versions = $response | Where-Object { $_.name -match '^v\d+\.\d+\.\d+$' }
    
    if ($versions.Count -gt 0) {
        $LATEST_VERSION = $versions[0].name
        Write-Host "✅ 成功检测到最新版本: $LATEST_VERSION" -ForegroundColor Green
    } else {
        $LATEST_VERSION = $REPO_BRANCH
        Write-Host "⚠️  无法获取最新版本，使用默认版本: $LATEST_VERSION" -ForegroundColor Yellow
    }
} catch {
    $LATEST_VERSION = $REPO_BRANCH
    Write-Host "⚠️  API 调用失败，使用默认版本: $LATEST_VERSION" -ForegroundColor Yellow
    Write-Host "   错误信息: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   可能原因:" -ForegroundColor Yellow
    Write-Host "   - 网络连接问题" -ForegroundColor Yellow
    Write-Host "   - GitHub API 限制" -ForegroundColor Yellow
    Write-Host "   - 防火墙阻止" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "📋 版本详细信息" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "默认版本: $REPO_BRANCH"
Write-Host "最新版本: $LATEST_VERSION"
Write-Host ""

# 显示前 10 个可用版本
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "🏷️  OpenWrt 最近的版本标签 (前10个)" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod -Uri "https://api.github.com/repos/openwrt/openwrt/tags" -Method Get
    $versions = $response | Where-Object { $_.name -match '^v\d+\.\d+\.\d+$' } | Select-Object -First 10
    
    if ($versions.Count -gt 0) {
        $counter = 1
        foreach ($version in $versions) {
            Write-Host "$counter. $($version.name)" -ForegroundColor White
            $counter++
        }
    } else {
        Write-Host "⚠️  无法获取版本列表" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️  无法获取版本列表" -ForegroundColor Yellow
    Write-Host "   错误: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "🔬 测试版本分支是否存在" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "正在验证版本 $LATEST_VERSION 是否可访问..." -ForegroundColor Yellow
Write-Host ""

# 测试 git 是否可用
try {
    $gitVersion = git --version 2>&1
    Write-Host "Git 已安装: $gitVersion" -ForegroundColor Green
    
    # 测试是否可以访问该分支
    $remoteTags = git ls-remote --tags $REPO_URL 2>&1 | Select-String "refs/tags/$LATEST_VERSION"
    
    if ($remoteTags) {
        Write-Host "✅ 版本 $LATEST_VERSION 存在且可访问" -ForegroundColor Green
        Write-Host ""
        Write-Host "   提交信息:" -ForegroundColor Cyan
        Write-Host "   $remoteTags" -ForegroundColor Gray
    } else {
        Write-Host "❌ 版本 $LATEST_VERSION 不存在或无法访问" -ForegroundColor Red
    }
} catch {
    Write-Host "⚠️  Git 未安装或配置错误" -ForegroundColor Yellow
    Write-Host "   错误: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   请确保已安装 Git 并配置到环境变量" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "💡 测试建议" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "1. 如果能看到版本号，说明 API 调用成功 ✓" -ForegroundColor White
Write-Host "2. 如果版本号可访问，说明可以正常克隆 ✓" -ForegroundColor White
Write-Host "3. 在 GitHub Actions 中运行时，逻辑完全相同 ✓" -ForegroundColor White
Write-Host ""
Write-Host "✅ 测试完成！" -ForegroundColor Green
Write-Host ""
Write-Host "最终使用版本: $LATEST_VERSION" -ForegroundColor Yellow
Write-Host ""
