# =====================================================================
# Script PowerShell: Tao chung chi SSL tu ky (Self-Signed SSL SAN)
# Ho tro domain: shop.local, pma.local, localhost, 127.0.0.1
# =====================================================================

$sslDir = Join-Path $PSScriptRoot "..\nginx\ssl"
if (-not (Test-Path $sslDir)) {
    New-Item -ItemType Directory -Path $sslDir -Force | Out-Null
}

$certFile = Join-Path $sslDir "server.crt"
$keyFile  = Join-Path $sslDir "server.key"
$cnfFile  = Join-Path $sslDir "openssl.cnf"

Write-Host ">>> Dang tao chung chi SSL cho shop.local va pma.local..." -ForegroundColor Cyan

# Tim OpenSSL binary (uu tien PATH hoac Git bin)
$opensslBin = "openssl"
if (-not (Get-Command "openssl" -ErrorAction SilentlyContinue)) {
    $gitOpenSsl = "C:\Program Files\Git\usr\bin\openssl.exe"
    if (Test-Path $gitOpenSsl) {
        $opensslBin = $gitOpenSsl
    } else {
        Write-Host "Khong tim thay openssl! Vui long cai dat Git hoac them OpenSSL vao PATH." -ForegroundColor Red
        exit 1
    }
}

# Tao file cau hinh OpenSSL SAN
$cnfContent = @"
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
x509_extensions = v3_req

[dn]
C = VN
ST = HoChiMinh
L = HoChiMinh
O = ElectroShop
OU = IT
CN = shop.local

[v3_req]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = shop.local
DNS.2 = pma.local
DNS.3 = localhost
IP.1 = 127.0.0.1
"@

Set-Content -Path $cnfFile -Value $cnfContent -Encoding utf8

# Chay OpenSSL tao Private Key va Certificate
& $opensslBin req -x509 -nodes -days 365 -newkey rsa:2048 `
    -keyout $keyFile `
    -out $certFile `
    -config $cnfFile

if (Test-Path $certFile) {
    Write-Host ">>> Tao SSL thanh cong tai: $sslDir" -ForegroundColor Green
    Write-Host "    - Private Key: $keyFile"
    Write-Host "    - Certificate: $certFile"
    Remove-Item $cnfFile -Force
} else {
    Write-Host ">>> Tao SSL that bai!" -ForegroundColor Red
    exit 1
}
