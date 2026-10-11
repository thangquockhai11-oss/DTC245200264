#!/usr/bin/env bash
# =====================================================================
# Script Bash: Tao chung chi SSL tu ky (Self-Signed SSL SAN)
# Ho tro domain: shop.local, pma.local, localhost, 127.0.0.1
# =====================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SSL_DIR="${SCRIPT_DIR}/../nginx/ssl"
mkdir -p "${SSL_DIR}"

CNF_FILE="${SSL_DIR}/openssl.cnf"
KEY_FILE="${SSL_DIR}/server.key"
CERT_FILE="${SSL_DIR}/server.crt"

echo ">>> Tao file cau hinh OpenSSL SAN..."
cat > "${CNF_FILE}" << 'EOF'
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
EOF

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "${KEY_FILE}" \
    -out "${CERT_FILE}" \
    -config "${CNF_FILE}"

rm -f "${CNF_FILE}"
echo ">>> Tao SSL thanh cong: ${CERT_FILE} & ${KEY_FILE}"
