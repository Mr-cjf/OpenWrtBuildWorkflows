# OpenWrt 版本检测模拟测试 (Windows PowerShell 版本)

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "OpenWrt 版本检测模拟测试" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 模拟环境变量
$REPO_URL = "https://github.com/openwrt/openwrt.git"
$REPO_BRANCH = "v24.10.0"

Write-Host "📋 测试配置:" -ForegroundColor Yellow
Write-Host "  仓库URL: $REPO_URL"
Write-Host "  默认版本: $REPO_BRANCH"
Write-Host ""

# 获取 OpenWrt 仓库的所有可用分支和标签
Write-Host "🔍 正在获取 OpenWrt 仓库的可用版本..." -ForegroundColor Green

# 先获取所有标签
Write-Host "  正在从 GitHub API 获取所有标签..." -ForegroundColor Gray
try {
    $response = Invoke-RestMethod -Uri "https://api.github.com/repos/openwrt/openwrt/tags" -ErrorAction Stop
    $ALL_TAGS = $response | Where-Object { $_.name -match '^v\d+\.\d+\.\d+$' } | 
                ForEach-Object { $_.name } | 
                Sort-Object -Descending
    
    Write-Host "  找到 $($ALL_TAGS.Count) 个候选版本" -ForegroundColor Gray
    Write-Host ""
}
catch {
    Write-Host "  ❌ 获取标签失败: $_" -ForegroundColor Red
    Write-Host ""
    $ALL_TAGS = @()
}

# 验证标签是否真的存在于远程仓库
$LATEST_VERSION = ""
$VALID_TAGS = 0
$CHECKED_TAGS = 0

Write-Host "🔎 开始验证标签..." -ForegroundColor Green
Write-Host ""

foreach ($tag in $ALL_TAGS) {
    $CHECKED_TAGS++
    Write-Host "  [$CHECKED_TAGS] 检查标签: $tag" -ForegroundColor Gray
    
    try {
        $null = git ls-remote --exit-code --tags $REPO_URL "refs/tags/$tag" 2>&1
        if ($LASTEXITCODE -eq 0) {
            $LATEST_VERSION = $tag
            $VALID_TAGS++
            Write-Host "      ✅ 找到有效标签: $LATEST_VERSION" -ForegroundColor Green
            Write-Host ""
            break
        }
        else {
            Write-Host "      ❌ 标签不存在或无效" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "      ❌ 检查失败: $_" -ForegroundColor Red
    }
    
    # 只检查前10个标签,避免测试时间过长
    if ($CHECKED_TAGS -ge 10) {
        Write-Host "  已检查前10个标签,停止验证..." -ForegroundColor Yellow
        Write-Host ""
        break
    }
}

# 如果获取失败，使用默认版本
if ([string]::IsNullOrWhiteSpace($LATEST_VERSION)) {
    $LATEST_VERSION = $REPO_BRANCH
    Write-Host "⚠️  无法获��最新版本，使用默认版本: $LATEST_VERSION" -ForegroundColor Yellow
    Write-Host "❌ 测试失败: 没有找到有效的版本标签" -ForegroundColor Red
}
else {
    Write-Host "✅ 检测到最新版本: $LATEST_VERSION" -ForegroundColor Green
    Write-Host "✅ 测试成功: 找到 $VALID_TAGS 个有效标签" -ForegroundColor Green
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "测试结果汇总" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  检查的标签数: $CHECKED_TAGS"
Write-Host "  有效的标签数: $VALID_TAGS"
Write-Host "  最终使用的版本: $LATEST_VERSION"
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 尝试克隆验证
Write-Host "🧪 验证版本是否可以克隆..." -ForegroundColor Green
Write-Host "  尝试克隆 $LATEST_VERSION ..." -ForegroundColor Gray

$tempDir = "$env:TEMP\test-openwrt-clone"
try {
    # 删除临时目录(如果存在)
    if (Test-Path $tempDir) {
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    # 执行克隆
    $output = git clone --depth 1 --branch $LATEST_VERSION --single-branch $REPO_URL $tempDir 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ 克隆成功!" -ForegroundColor Green
        
        # 清理临时目录
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        
        Write-Host "  ✅ 最终验证通过" -ForegroundColor Green
    }
    else {
        Write-Host "  ❌ 克隆失败!" -ForegroundColor Red
        Write-Host "  ❌ 最终验证失败" -ForegroundColor Red
        Write-Host "  错误信息: $output" -ForegroundColor Gray
    }
}
catch {
    Write-Host "  ❌ 克隆过程中出现异常: $_" -ForegroundColor Red
    Write-Host "  ❌ 最终验证失败" -ForegroundColor Red
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "测试完成" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan