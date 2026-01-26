# 简单的版本检测测试
Write-Host "Testing OpenWrt Version Fetch..." -ForegroundColor Cyan
$response = Invoke-RestMethod -Uri "https://api.github.com/repos/openwrt/openwrt/tags"
$latest = ($response | Where-Object { $_.name -match "^v\d+\.\d+\.\d+$" })[0].name
Write-Host "Latest Version: $latest" -ForegroundColor Green
Write-Host ""
Write-Host "Recent versions:" -ForegroundColor Yellow
$response | Where-Object { $_.name -match "^v\d+\.\d+\.\d+$" } | Select-Object -First 10 | ForEach-Object { Write-Host " - $($_.name)" }
