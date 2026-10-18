# =======================================================
# Script tạo lưu lượng giả lập (Traffic Simulation) cho ElectroShop
# Kích hoạt metrics: HTTP Request Rate, Orders Total, Revenue Total,
# Latency Percentiles và Nginx / MySQL Metrics
# =======================================================

param (
    [int]$Iterations = 15,
    [string]$BaseUrl = "http://localhost"
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  GIẢ LẬP LƯU LƯỢNG WEB & GIAO DỊCH E-COMMERCE (ĐỀ 9)     " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Mục tiêu: $BaseUrl | Số lượt lặp: $Iterations`n" -ForegroundColor Gray

$names = @("Nguyễn Văn An", "Trần Thị Bích", "Lê Hoàng Long", "Phạm Minh Đức", "Võ Quỳnh Nga")
$phones = @("0901234567", "0912345678", "0987654321", "0933445566", "0977889900")
$cities = @("Hà Nội", "TP. Hồ Chí Minh", "Đà Nẵng", "Cần Thơ", "Hải Phòng")

for ($i = 1; $i -le $Iterations; $i++) {
    Write-Host "[$i/$Iterations] Gửi request kiểm tra hệ thống..." -ForegroundColor DarkCyan

    # 1. GET Trang chủ
    try {
        $resHome = Invoke-WebRequest -Uri "$BaseUrl/" -Method Get -UseBasicParsing -TimeoutSec 3
        Write-Host "  -> GET / [Status: $($resHome.StatusCode)]" -ForegroundColor Gray
    } catch {
        Write-Host "  -> GET / Thất bại: $($_.Exception.Message)" -ForegroundColor DarkGray
    }

    # 2. GET Danh sách sản phẩm API
    try {
        $resProd = Invoke-WebRequest -Uri "$BaseUrl/api/products" -Method Get -UseBasicParsing -TimeoutSec 3
        Write-Host "  -> GET /api/products [Status: $($resProd.StatusCode)]" -ForegroundColor Gray
    } catch {
        Write-Host "  -> GET /api/products Thất bại: $($_.Exception.Message)" -ForegroundColor DarkGray
    }

    # 3. GET Health check
    try {
        $resHealth = Invoke-WebRequest -Uri "$BaseUrl/health" -Method Get -UseBasicParsing -TimeoutSec 3
        Write-Host "  -> GET /health [Status: $($resHealth.StatusCode)]" -ForegroundColor Gray
    } catch {}

    # 4. Giả lập đặt hàng Checkout ngẫu nhiên
    if ($i % 2 -eq 0) {
        $randName = $names | Get-Random
        $randPhone = $phones | Get-Random
        $randCity = $cities | Get-Random
        $randProdId = Get-Random -Minimum 1 -Maximum 9
        $randQty = Get-Random -Minimum 1 -Maximum 4

        $orderPayload = @{
            customer_name    = $randName
            customer_email   = "khachhang$i@example.com"
            customer_phone   = $randPhone
            shipping_address = "Số $i, Đường Công Nghệ, $randCity"
            items            = @(
                @{
                    product_id = $randProdId
                    quantity   = $randQty
                }
            )
        } | ConvertTo-Json

        try {
            $resOrder = Invoke-RestMethod -Uri "$BaseUrl/checkout" -Method Post -Body $orderPayload -ContentType "application/json" -TimeoutSec 5
            if ($resOrder.success) {
                Write-Host "  🎉 [CHECKOUT THÀNH CÔNG] Đơn hàng #$($resOrder.order_id) - Tổng: $($resOrder.total_amount.ToString('N0')) VND" -ForegroundColor Green
            }
        } catch {
            Write-Host "  -> POST /checkout Thất bại: $($_.Exception.Message)" -ForegroundColor DarkYellow
        }
    }

    # 5. Giả lập request 404 để test error metrics & Loki log
    if ($i % 5 -eq 0) {
        try {
            Invoke-WebRequest -Uri "$BaseUrl/api/nonexistent-route-$i" -Method Get -UseBasicParsing -TimeoutSec 2 | Out-Null
        } catch {
            Write-Host "  -> GET /api/nonexistent-route-$i [Tạo 404 cho metrics test]" -ForegroundColor DarkYellow
        }
    }

    Start-Sleep -Milliseconds 400
}

Write-Host "`n✅ ĐÃ HOÀN TẤT GIẢ LẬP LƯU LƯỢNG!" -ForegroundColor Green
Write-Host "Truy cập Grafana: http://localhost:3000 để xem đồ thị nhảy số trực quan!" -ForegroundColor Cyan
