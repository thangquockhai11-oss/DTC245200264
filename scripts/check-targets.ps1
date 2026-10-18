# =======================================================
# Script kiểm tra trạng thái Prometheus Targets (Target Health)
# Tương ứng với trang Status > Target health trên Web UI
# =======================================================

$prometheusUrl = "http://localhost:9090/api/v1/targets"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  KIỂM TRA PROMETHEUS TARGET HEALTH (ĐỀ 9 E-COMMERCE)     " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod -Uri $prometheusUrl -Method Get -TimeoutSec 5
    if ($response.status -eq "success") {
        $activeTargets = $response.data.activeTargets
        Write-Host "`nTìm thấy $($activeTargets.Count) targets đang được Prometheus giám sát:`n" -ForegroundColor Green

        $targetList = @()
        foreach ($t in $activeTargets) {
            $healthColor = if ($t.health -eq "up") { "Green" } else { "Red" }
            $statusText = if ($t.health -eq "up") { "UP (1/1) [OK]" } else { "DOWN [ERROR]" }
            
            $targetList += [PSCustomObject]@{
                "Job"         = $t.labels.job
                "Endpoint"    = $t.scrapeUrl
                "State"       = $statusText
                "LastScrape"  = $t.lastScrapeDuration
                "LastError"   = if ($t.lastError) { $t.lastError } else { "None" }
            }
        }

        $targetList | Format-Table -AutoSize

        $downTargets = $activeTargets | Where-Object { $_.health -ne "up" }
        if ($downTargets.Count -eq 0) {
            Write-Host "✅ TẤT CẢ $($activeTargets.Count) TARGETS ĐỀU ĐẠT TRẠNG THÁI UP (1/1)!" -ForegroundColor Green
            Write-Host "Bạn có thể mở trình duyệt: http://localhost:9090/targets để chụp ảnh minh chứng.`n" -ForegroundColor Cyan
        } else {
            Write-Host "⚠️ Có $($downTargets.Count) target chưa đạt trạng thái UP. Vui lòng kiểm tra container tương ứng:`n" -ForegroundColor Red
            foreach ($d in $downTargets) {
                Write-Host " - $($d.labels.job): $($d.lastError)" -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "❌ Phản hồi từ Prometheus không thành công: $($response.status)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Không thể kết nối tới Prometheus tại $prometheusUrl" -ForegroundColor Red
    Write-Host "Hãy đảm bảo container Prometheus đang chạy: docker compose up -d" -ForegroundColor Yellow
    Write-Host "Chi tiết lỗi: $_" -ForegroundColor DarkGray
}
