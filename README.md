# 🛒 ĐỒ ÁN ĐỀ 9: HỆ THỐNG WEBSITE THƯƠNG MẠI ĐIỆN TỬ VỚI DOCKER COMPOSE

> **Học phần**: Triển khai và Quản trị Hệ thống Phần mềm &nbsp;|&nbsp; **MSSV**: DTC245200264 &nbsp;|&nbsp; **GitHub**: [thangquockhai11-oss/DTC245200264](https://github.com/thangquockhai11-oss/DTC245200264)

> **Hệ thống vi dịch vụ container hóa toàn diện**: Node.js (Express) + MySQL 8.0 + phpMyAdmin + Nginx Reverse Proxy (SSL/TLS) + Prometheus + Grafana + cAdvisor + Exporters + Loki + Promtail.

---

## 📑 MỤC LỤC
1. [Giới Thiệu Tổng Quan](#1-giới-thiệu-tổng-quan)
2. [Sơ Đồ Kiến Trúc Hệ Thống](#2-sơ-đồ-kiến-trúc-hệ-thống)
3. [Cấu Trúc Thư Mục Chuẩn Hóa](#3-cấu-trúc-thư-mục-chuẩn-hóa)
4. [Yêu Cầu Môi Trường](#4-yêu-cầu-môi-trường)
5. [Hướng Dẫn Khởi Chạy Nhanh (1 Lệnh)](#5-hướng-dẫn-khởi-chạy-nhanh-1-lệnh)
6. [Danh Sách Cổng & Tài Khoản Mặc Định](#6-danh-sách-cổng--tài-khoản-mặc-định)
7. [Hệ Thống Giám Sát & Dashboard Grafana](#7-hệ-thống-giám-sát--dashboard-grafana)
8. [Hệ Thống Gom Log Tập Trung & Truy Vấn LogQL](#8-hệ-thống-gom-log-tập-trung--truy-vấn-logql)
9. [Bảo Mật & Hardening Hệ Thống](#9-bảo-mật--hardening-hệ-thống)
10. [Lịch Sử Commit Git Chuẩn Hóa](#10-lịch-sử-commit-git-chuẩn-hóa)

---

## 1. Giới Thiệu Tổng Quan

Dự án được xây dựng theo yêu cầu chuẩn hóa **Đề 9: Website Thương mại điện tử (E-commerce)** với nền tảng **Docker Compose**. Hệ thống giải quyết trọn vẹn bài toán vận hành dịch vụ web hiện đại theo mô hình DevOps/SRE:
* **Ứng dụng bán hàng (E-Commerce Storefront)**: Tra cứu sản phẩm công nghệ, lọc danh mục, giỏ hàng, đặt hàng (`POST /checkout`), theo dõi trạng thái đơn hàng.
* **Cơ sở dữ liệu quan hệ (RDBMS)**: MySQL 8.0 lưu trữ quan hệ danh mục, sản phẩm, đơn hàng, chi tiết đơn hàng với cơ chế transaction ACID.
* **Cổng điều phối & Bảo mật (Reverse Proxy)**: Nginx hỗ trợ SSL/TLS 1.3 tự ký đa tên miền (SAN), chuyển hướng HTTP sang HTTPS, bộ Security Headers chuẩn OWASP.
* **Giám sát hiệu năng (Metrics Monitoring)**: Prometheus thu thập chỉ số từ máy chủ (Node Exporter), container (cAdvisor), database (MySQLd Exporter), và ứng dụng web (Prom-client). Trực quan hóa qua Grafana.
* **Quản lý log tập trung (Centralized Logging)**: Promtail thu thập log Nginx (JSON access log) và log Node.js, đẩy về Grafana Loki, cho phép phân tích nâng cao qua LogQL.
* **Hardening bảo mật**: Chạy non-root user, cô lập mạng Database, giới hạn tài nguyên CPU/RAM, cô lập biến môi trường `.env`.

---

## 2. Sơ Đồ Kiến Trúc Hệ Thống

```mermaid
flowchart TB
    subgraph Client ["🌐 Client / Người Dùng & Quản Trị"]
        Browser["Trình duyệt (Browser)<br/>shop.local | pma.local"]
        Admin["Quản trị viên<br/>localhost:3000 (Grafana)"]
    end

    subgraph Host ["💻 Máy Chủ Docker Host"]
        subgraph FrontendNet ["🌐 Network: frontend-net (Public Web Zone)"]
            Nginx["🛡️ Nginx Reverse Proxy<br/>Ports: 80, 443 (SSL/TLS)<br/>Security Headers"]
            Web["📦 Web App (Node.js/Express)<br/>Non-root: user node<br/>Port: 3000"]
            PMA["🗄️ phpMyAdmin<br/>Internal Port: 80"]
            Grafana["📊 Grafana Visualization<br/>Port: 3000"]
            cAdvisor["📈 cAdvisor<br/>Port: 8080"]
            NodeExp["🖥️ Node Exporter<br/>Port: 9100"]
            Promtail["🚚 Promtail Log Shipper"]
            Loki["📝 Loki Log Engine<br/>Internal Port: 3100"]
        end

        subgraph BackendNet ["🔒 Network: backend-net (Isolated Data Zone)"]
            DB[("💾 MySQL 8.0 Database<br/>Port: 3306 (NO HOST PORT)<br/>User: shop_user (Least Privilege)")]
            MySQLExp["📊 MySQLd Exporter<br/>Internal Port: 9104"]
        end

        Prometheus["📉 Prometheus Server<br/>Scrapes: Web, Exporters<br/>Retention: 15d"]
    end

    Browser -->|HTTPS :443| Nginx
    Browser -->|HTTP :80| Nginx
    Nginx -.->|Redirect 301| Nginx
    Nginx -->|shop.local| Web
    Nginx -->|pma.local| PMA

    Web -->|SQL Queries (Pool)| DB
    PMA -->|DB Admin| DB
    MySQLExp -->|Metrics User: exporter| DB

    Prometheus -->|Scrape /metrics| Web
    Prometheus -->|Scrape :9100| NodeExp
    Prometheus -->|Scrape :8080| cAdvisor
    Prometheus -->|Scrape :9104| MySQLExp

    Promtail -->|Tail /var/log/nginx| Nginx
    Promtail -->|Tail /var/log/app| Web
    Promtail -->|Push Logs :3100| Loki

    Admin -->|Dashboard & Explore| Grafana
    Grafana -->|Datasource: PromQL| Prometheus
    Grafana -->|Datasource: LogQL| Loki
```

---

## 3. Cấu Trúc Thư Mục Chuẩn Hóa

```text
├── .env                                # File biến môi trường bảo mật (không commit Git)
├── .env.example                        # File mẫu biến môi trường (an toàn commit)
├── .gitignore                          # Cấu hình loại trừ file nhạy cảm và node_modules
├── docker-compose.yml                  # Khởi chạy 11 container vi dịch vụ
├── README.md                           # Tài liệu hướng dẫn dự án chi tiết
├── BAO_CAO_DO_AN.md                    # Đề cương & nội dung báo cáo tổng hợp (10+ trang)
├── scripts/
│   ├── generate-ssl.ps1                # Script PowerShell tạo SSL SAN tự ký
│   ├── generate-ssl.sh                 # Script Bash tạo SSL SAN tự ký
│   └── setup-hosts.ps1                 # Script cấu hình file hosts Windows tự động
├── web/
│   ├── Dockerfile                      # Build image Node.js (chạy user node non-root)
│   ├── package.json                    # Khai báo thư viện (Express, MySQL2, prom-client)
│   ├── server.js                       # Backend REST API, MySQL Pool, Metrics, Logging
│   ├── logs/                           # Thư mục chứa log ứng dụng (Promtail theo dõi)
│   │   └── .gitkeep
│   └── public/                         # Frontend E-Commerce hiện đại
│       ├── index.html                  # Giao diện cửa hàng, giỏ hàng, modal thanh toán
│       ├── css/
│       │   └── style.css               # Design system hiện đại, responsive, hiệu ứng đẹp
│       └── js/
│           └── app.js                  # Xử lý tương tác, giỏ hàng, gọi API /checkout
├── mysql/
│   └── init/
│       └── 01-init.sql                 # Khởi tạo bảng, nạp 8 sản phẩm mẫu & phân quyền
├── nginx/
│   ├── nginx.conf                      # Reverse proxy, SSL termination, Security Headers
│   └── ssl/                            # Chứa chứng chỉ server.crt và server.key
│       └── .gitkeep
├── monitoring/
│   ├── prometheus/
│   │   └── prometheus.yml              # Cấu hình scrape jobs (4 targets)
│   └── grafana/
│       └── provisioning/
│           └── datasources/
│               └── datasources.yml     # Tự động nạp Prometheus & Loki làm datasource
└── logging/
    ├── loki/
    │   └── loki-config.yml             # Cấu hình lưu trữ log Loki với TSDB schema
    └── promtail/
        └── promtail-config.yml         # Thu thập và parse log Nginx (JSON) & Web App
```

---

## 4. Yêu Cầu Môi Trường

* **Hệ điều hành**: Windows 10/11 (khuyến nghị chạy kèm WSL2/Docker Desktop), macOS, hoặc Ubuntu Linux 20.04+.
* **Docker Engine**: Phiên bản 20.10+ (đã kiểm thử tương thích với Docker 29.x).
* **Docker Compose**: Phiên bản v2.x trở lên (sử dụng lệnh `docker compose`).
* **OpenSSL** hoặc **Git for Windows** (đã tích hợp sẵn openssl).

---

## 5. Hướng Dẫn Khởi Chạy Nhanh (1 Lệnh)

### Bước 1: Sao chép cấu hình biến môi trường
```powershell
# Trên Windows PowerShell
Copy-Item .env.example .env

# Hoặc trên Linux/macOS
cp .env.example .env
```

### Bước 2: Tạo chứng chỉ SSL tự ký
```powershell
# Chạy script PowerShell tự động phát hiện OpenSSL:
powershell -ExecutionPolicy Bypass -File .\scripts\generate-ssl.ps1

# Hoặc trên Linux/Git Bash:
bash ./scripts/generate-ssl.sh
```

### Bước 3: Cấu hình tên miền ảo trong file `hosts` (1 lần duy nhất)
Thêm 2 dòng sau vào file hosts (`C:\Windows\System32\drivers\etc\hosts` trên Windows hoặc `/etc/hosts` trên Linux/Mac):
```text
127.0.0.1 shop.local
127.0.0.1 pma.local
```
*(Trên Windows, bạn có thể chạy file tiện ích `powershell -ExecutionPolicy Bypass -File .\scripts\setup-hosts.ps1` bằng quyền Run as Administrator).*

### Bước 4: Khởi chạy toàn bộ hệ thống bằng 1 lệnh duy nhất
```bash
docker compose up -d --build
```

Kiểm tra trạng thái các container:
```bash
docker compose ps
```

---

## 6. Danh Sách Cổng & Tài Khoản Mặc Định

| Dịch Vụ | Tên Miền / URL Truy Cập | Cổng Expose Host | Cổng Nội Bộ Container | Tài Khoản / Mật Khẩu | Ghi Chú Bảo Mật |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **E-Commerce Web (qua Nginx SSL)** | `https://shop.local` | 443 (qua Nginx) | 3000 | *(không cần đăng nhập)* | HTTPS, Security Headers đầy đủ |
| **E-Commerce Web (trực tiếp)** | `http://localhost:5000` | **5000** | 3000 | *(không cần đăng nhập)* | Truy cập thẳng, bypass Nginx |
| **HTTP → HTTPS Redirect** | `http://shop.local` | 80 (qua Nginx) | 80 | - | Redirect 301 tự động sang HTTPS |
| **phpMyAdmin (qua Nginx SSL)** | `https://pma.local` | 443 (qua Nginx) | 80 | User: `shop_user`<br/>Pass: `ShopUserPass123!` | HTTPS qua Reverse Proxy |
| **phpMyAdmin (trực tiếp)** | `http://localhost:8081` | **8081** | 80 | User: `shop_user`<br/>Pass: `ShopUserPass123!` | Truy cập thẳng không qua Nginx |
| **Grafana Dashboard** | `http://localhost:3000` | 3000 | 3000 | User: `admin`<br/>Pass: `GrafanaAdminSecure2026!` | Prometheus + Loki tự động nạp |
| **Prometheus** | `http://127.0.0.1:9090` | 9090 (localhost only) | 9090 | *(không có)* | Chỉ bind `127.0.0.1` |
| **MySQL Database** | *(nội bộ container)* | **ĐÃ ĐÓNG** | 3306 | Root: `RootSecretPassword2026!`<br/>App: `shop_user` / `ShopUserPass123!` | Cô lập hoàn toàn trong `backend-net` |
| **Loki Log Engine** | *(nội bộ container)* | **ĐÃ ĐÓNG** | 3100 | - | Truy vấn qua Grafana → Explore → LogQL |
| **Promtail Collector** | *(nội bộ container)* | **ĐÃ ĐÓNG** | 9080 | - | Tự động thu thập log Nginx + App |
| **cAdvisor** | *(nội bộ container)* | **ĐÃ ĐÓNG** | 8080 | - | Đẩy container metrics về Prometheus |
| **Node Exporter** | *(nội bộ container)* | **ĐÃ ĐÓNG** | 9100 | - | Đẩy host system metrics về Prometheus |
| **MySQLd Exporter** | *(nội bộ container)* | **ĐÃ ĐÓNG** | 9104 | User: `exporter`<br/>Pass: `ExporterPass123!` | Đẩy DB metrics về Prometheus |

---

## 7. Hệ Thống Giám Sát & Dashboard Grafana

Prometheus được cấu hình tự động thu thập (scrape) 4 job theo chu kỳ 10 giây:
1. `ecommerce-web`: Thu thập chỉ số HTTP requests, latency, số đơn hàng tạo ra (`ecommerce_orders_total`), doanh thu (`ecommerce_revenue_total`).
2. `cadvisor`: Thu thập mức tiêu thụ CPU, RAM, Network I/O của toàn bộ 11 container.
3. `mysqld-exporter`: Thu thập số kết nối MySQL, câu lệnh queries/sec, InnoDB buffer pool, locks.
4. `node-exporter`: Thu thập tải CPU máy chủ, RAM, phân vùng ổ đĩa và băng thông mạng.

### 📌 Danh Sách Mã ID Dashboard Chuẩn Trên Grafana.com Để Import:
Đăng nhập Grafana (`http://localhost:3000`), vào **Dashboards** ➔ **New** ➔ **Import** ➔ Nhập ID:
* **Node Exporter Full**: `1860` (Theo dõi toàn diện tài nguyên phần cứng máy chủ).
* **Docker Container & cAdvisor**: `14282` hoặc `893` (Theo dõi CPU %, RAM, Network từng container).
* **MySQL Overview**: `7362` hoặc `11323` (Theo dõi hiệu năng database MySQL).
* **Node.js Application Dashboard**: `11159` (Theo dõi Event Loop, GC, Heap Memory của Express app).

---

## 8. Hệ Thống Gom Log Tập Trung & Truy Vấn LogQL

Promtail đọc liên tục log thời gian thực từ:
* `/var/log/nginx/access.log` (định dạng JSON chuyên dụng)
* `/var/log/nginx/error.log`
* `/var/log/app/access.log` và `/var/log/app/error.log`

### 🔍 4 Câu Truy Vấn LogQL Demo Chuẩn (Truy cập Grafana Explore -> Chọn Loki):

#### 1. Lọc tất cả log của Nginx access log:
```logql
{job="nginx"}
```
*(Hiển thị toàn bộ dòng log truy cập được Nginx ghi nhận)*

#### 2. Lọc các request trả về mã lỗi HTTP 4xx hoặc 5xx:
```logql
{job="nginx"} | json | status >= 400
```
*(Bóc tách trường JSON `status` và lọc các request thất bại hoặc truy cập sai URL)*

#### 3. Đếm số lượng request theo thời gian (rate/count_over_time):
```logql
sum(rate({job="nginx"}[1m]))
```
*(Vẽ đồ thị biểu diễn tần suất lưu lượng request trên mỗi giây trong cửa sổ trượt 1 phút)*

#### 4. Lọc log chứa từ khóa 'POST /checkout' hoặc 'error':
```logql
{job=~"nginx|ecommerce-web"} |~ "(?i)(POST /checkout|error)"
```
*(Tìm kiếm không phân biệt hoa thường các sự kiện giao dịch thanh toán hoặc phát sinh lỗi máy chủ)*

---

## 9. Bảo Mật & Hardening Hệ Thống

| STT | Biện Pháp Hardening | Vị Trí Triển Khai Trong Dự Án | Mục Đích & Hiệu Quả Bảo Mật |
| :---: | :--- | :--- | :--- |
| **1** | **Chạy Non-Root Container** | `web/Dockerfile` (`USER node`)<br/>`docker-compose.yml` (`user: nobody`, `user: 10001`) | Tránh nguy cơ Container Breakout leo thang đặc quyền root trên máy chủ. |
| **2** | **Giới Hạn Tài Nguyên (Resource Limits)** | `docker-compose.yml` (`deploy.resources.limits`) | Giới hạn tối đa CPU và RAM từng service, ngăn ngừa tấn công DoS/ReDoS làm cạn kiệt tài nguyên host. |
| **3** | **Cô Lập Mạng Phân Tầng (Network Segmentation)** | `docker-compose.yml` (`frontend-net`, `backend-net`) | Đưa Database và Exporter vào `backend-net`. Database không kết nối internet, chặn hoàn toàn truy cập trực tiếp. |
| **4** | **Đóng Cổng Host Nguy Hiểm (Port Hardening)** | `docker-compose.yml` | Chỉ mở cổng 80, 443 của Nginx ra Host. Đóng hoàn toàn cổng 3306 (MySQL), 3100 (Loki), 8080, 9100. |
| **5** | **Tách Biệt Bí Mật (.env & .gitignore)** | `.env`, `.env.example`, `.gitignore` | Không lưu mật khẩu database trong mã nguồn Git; dễ dàng cấu hình linh hoạt theo từng môi trường. |
| **6** | **Phân Quyền Cơ Sở Dữ Liệu Tối Thiểu (Least Privilege)** | `mysql/init/01-init.sql` | Ứng dụng web dùng tài khoản `shop_user` chỉ có quyền `SELECT, INSERT, UPDATE, DELETE`, cấm quyền DDL/ADMIN. |
| **7** | **Mã Hóa SSL/TLS & Bộ Security Headers** | `nginx/nginx.conf`, `scripts/generate-ssl.ps1` | Mã hóa kênh truyền HTTPS 443, chặn tấn công Clickjacking (`X-Frame-Options`), XSS (`CSP`, `X-XSS-Protection`), MIME sniffing. |

---

## 10. Lịch Sử Commit Git Chuẩn Hóa

Dự án được cam kết phiên bản theo tiến trình 3 bước chuẩn mực:

* **Commit 1**:
  ```bash
  git commit -m "feat(core): initialize e-commerce web, mysql database and hardened nginx reverse proxy (commit 1)"
  ```
* **Commit 2**:
  ```bash
  git commit -m "feat(monitoring): integrate prometheus, grafana, cadvisor and exporters (commit 2)"
  ```
* **Commit 3**:
  ```bash
  git commit -m "feat(logging): integrate centralized logging with loki, promtail and logql queries (commit 3)"
  ```
* **Commit 4 (Hoàn thiện tài liệu)**:
  ```bash
  git commit -m "docs(report): complete system hardening, documentation and 10-page project report outline"
  ```
