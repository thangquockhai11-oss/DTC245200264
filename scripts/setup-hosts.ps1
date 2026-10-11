# =======================================================
# Script cấu hình file hosts trên Windows
# Yêu cầu: Chạy PowerShell với quyền Administrator
# =======================================================

$hostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"
$domains = @("127.0.0.1 shop.local", "127.0.0.1 pma.local")

Write-Host ">>> Đang kiểm tra cấu hình hosts tại: $hostsPath" -ForegroundColor Cyan

$content = Get-Content $hostsPath -Raw

foreach ($entry in $domains) {
    $domainName = ($entry -split " ")[1]
    if ($content -match $domainName) {
        Write-Host " [OK] Domain '$domainName' đã tồn tại trong file hosts." -ForegroundColor Green
    } else {
        Add-Content -Path $hostsPath -Value "`n$entry"
        Write-Host " [+] Đã thêm '$entry' vào file hosts." -ForegroundColor Yellow
    }
}

Write-Host "`n>>> Hoàn tất! Bạn có thể truy cập:" -ForegroundColor Cyan
Write-Host "    - Web Store:  https://shop.local" -ForegroundColor White
Write-Host "    - phpMyAdmin: https://pma.local" -ForegroundColor White
