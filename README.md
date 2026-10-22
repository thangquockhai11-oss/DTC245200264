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
        Browser["Trình duyệt (Browser)<br/>localhost:5000 (Web App)<br/>localhost:8081 (phpMyAdmin)"]
        Admin["Quản trị viên / Giám sát<br/>localhost:3000 (Grafana)<br/>localhost:8080 (cAdvisor)"]
    end

    subgraph Host ["💻 Máy Chủ Docker Host"]
        subgraph FrontendNet ["🌐 Network: frontend-net (Public Web Zone)"]
            Nginx["🛡️ Nginx Reverse Proxy<br/>Ports: 80, 443 (SSL/TLS)<br/>Security Headers"]
            Web["📦 Web App (Node.js/Express)<br/>Non-root: user node<br/>Port Host: 5000 (Container: 3000)"]
            PMA["🗄️ phpMyAdmin<br/>Port Host: 8081 (Container: 80)"]
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

## 5. Hướng Dẫn Khởi Chạy Nhanh

### Cách 1: Khởi chạy và truy cập trực tiếp qua Localhost (Khuyên dùng - Đơn giản nhất)

Không cần tạo chứng chỉ SSL, không cần sửa file `hosts`, chỉ cần 2 lệnh là hệ thống hoạt động ngay:

```powershell
# Bước 1: Sao chép cấu hình biến môi trường
Copy-Item .env.example .env

# Bước 2: Khởi chạy toàn bộ hệ thống
docker compose up -d --build
```

Kiểm tra trạng thái các container:
```powershell
docker compose ps
```
Sau đó mở trình duyệt và truy cập ngay qua **`http://localhost:5000`**!

---

### Cách 2: Tùy chọn nâng cao qua Nginx Reverse Proxy (SSL tự ký & Domain ảo)

Nếu bạn muốn kiểm tra tính năng SSL/TLS và Reverse Proxy:
1. **Tạo SSL tự ký:**
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\scripts\generate-ssl.ps1
   ```
2. **Cấu hình file `hosts`:**
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\scripts\setup-hosts.ps1
   ```
   *(Hoặc thêm thủ công vào file `hosts`: `127.0.0.1 shop.local` và `127.0.0.1 pma.local`)*

---

## 6. Danh Sách Cổng & URL Truy Cập Bằng Localhost

Hệ thống đã mở sẵn các cổng trực tiếp, bạn có thể truy cập ngay trên trình duyệt hoặc qua lệnh `curl.exe`:

### 🌐 Bảng truy cập trực tiếp bằng `localhost`:

| Dịch Vụ | URL Truy Cập Trực Tiếp | Cổng Host | Tài Khoản / Mật Khẩu | Mô Tả & Chức Năng |
| :--- | :--- | :---: | :--- | :--- |
| 🛒 **Website Bán Hàng (Web App)** | **`http://localhost:5000`** | **`5000`** | *(không cần)* | Giao diện mua sắm, giỏ hàng, đặt hàng API |
| 🗄️ **phpMyAdmin (Quản lý CSDL)** | **`http://localhost:8081`** | **`8081`** | User: `shop_user`<br/>Pass: `ShopUserPass123!` | Quản trị MySQL, xem bảng, dữ liệu đơn hàng |
| 📊 **Grafana Dashboard** | **`http://localhost:3000`** | **`3000`** | User: `admin`<br/>Pass: `GrafanaAdminSecure2026!` | 7 Dashboard giám sát tự động nạp sẵn |
| 📈 **cAdvisor (Container Metrics)** | **`http://localhost:8080`** | **`8080`** | *(không cần)* | Giám sát CPU/RAM/Network từng container |
| 🔍 **Prometheus UI** | **`http://localhost:9090`** | **`9090`** | *(không cần)* | Tra cứu metrics, Target health (`/targets`) |
| 🖥️ **Node Exporter** | **`http://localhost:9100/metrics`**| **`9100`** | *(không cần)* | Thống kê tài nguyên máy chủ OS |
| 🐬 **MySQLd Exporter** | **`http://localhost:9104/metrics`**| **`9104`** | User: `exporter`<br/>Pass: `ExporterPass123!` | Chỉ số hiệu năng cơ sở dữ liệu MySQL |
| 🌐 **Nginx Exporter** | **`http://localhost:9113/metrics`**| **`9113`** | *(không cần)* | Chỉ số lưu lượng và kết nối Nginx |
| 💾 **MySQL Database** | *(kết nối nội bộ container)* | **ĐÃ ĐÓNG** | Root: `RootSecretPassword2026!`<br/>App: `shop_user` / `ShopUserPass123!` | Cổng 3306 cô lập trong `backend-net` |
| 📝 **Loki Log Engine** | *(nội bộ container)* | **ĐÃ ĐÓNG** | - | Truy vấn log qua Grafana (Explore -> Loki) |

> [!TIP]
> **Các lệnh kiểm tra nhanh trạng thái qua PowerShell:**
> ```powershell
> curl.exe -I http://localhost:5000       # Website bán hàng (200 OK)
> curl.exe -I http://localhost:8081       # phpMyAdmin (200 OK)
> curl.exe -I http://localhost:3000       # Grafana (302 Found / 200 OK)
> curl.exe -I -L http://localhost:8080    # cAdvisor (200 OK kèm cờ -L redirect)
> curl.exe -I http://localhost:9090       # Prometheus (200 OK)
> ```

### 🔒 Tùy chọn truy cập qua Nginx Reverse Proxy (Domain ảo & SSL):
* **Web Bán Hàng (HTTPS)**: `https://shop.local` (Port 443)
* **phpMyAdmin (HTTPS)**: `https://pma.local` (Port 443)
* **Tự động chuyển hướng**: `http://shop.local` (Port 80 → Redirect 301 sang HTTPS)

---

## 7. Hệ Thống Giám Sát & Dashboard Grafana

Prometheus được cấu hình tự động thu thập (scrape) **7 targets** theo chu kỳ 10 giây (khớp hoàn toàn với yêu cầu bài thi và trang **Status > Target health**):

| Target Job | Endpoint Giám Sát | Trạng Thái | Vai Trò & Dữ Liệu Thu Thập |
| :--- | :--- | :---: | :--- |
| **`cadvisor`** | `http://cadvisor:8080/metrics` | **1/1 UP** | CPU, RAM, Network I/O, Filesystem của tất cả containers |
| **`prometheus`** | `http://localhost:9090/metrics` | **1/1 UP** | Giám sát nội bộ Prometheus (TSDB, scrape duration, bộ nhớ) |
| **`backend`** | `http://backend:3000/metrics` | **1/1 UP** | HTTP Requests, Latency (P50/P95/P99), Doanh thu & Đơn hàng |
| **`loki`** | `http://loki:3100/metrics` | **1/1 UP** | Tốc độ nạp log (bytes/s, lines/s), dung lượng chunk & index |
| **`mysql`** | `http://mysqld_exporter:9104/metrics` | **1/1 UP** | Active connections, queries/sec (SELECT/INSERT), Buffer Pool |
| **`nginx`** | `http://nginx_exporter:9113/metrics` | **1/1 UP** | Active connections, reading/writing/waiting, request throughput |
| **`node-exporter`** | `http://node-exporter:9100/metrics` | **1/1 UP** | Tài nguyên phần cứng máy chủ chủ quản (CPU, RAM, Disk) |

### 📊 Hệ Thống 7 Dashboard Grafana Đã Được Tự Động Nạp (Auto-Provisioned)
Khi mở Grafana (`http://localhost:3000`), toàn bộ 7 Dashboard chuyên nghiệp đã nằm sẵn trong thư mục **"ElectroShop Monitoring"**:

1. **`01. ElectroShop - Tổng Quan Hệ Thống & Target Health (Đề 9)`**:
   - Bảng trạng thái sức khỏe từng Target (UP/DOWN giống hệt Prometheus).
   - Chỉ số kinh doanh: Tổng đơn hàng, Doanh thu (VND), Tốc độ HTTP Req/s, P95 Latency.
   - Tổng quan nhanh Nginx, MySQL, CPU và RAM container.
2. **`02. Nginx Reverse Proxy & Lưu Lượng Web (Đề 9)`**:
   - Trạng thái Nginx Up/Down, Active Connections, Reading/Writing/Waiting.
   - Biểu đồ tốc độ xử lý request (req/s), Handled vs Accepted connections.
3. **`03. Node.js Web Application & API Metrics (Đề 9)`**:
   - Uptime, HTTP Request rate theo từng route (`/api/products`, `/checkout`, `/health`).
   - Phân vị độ trễ (P50, P90, P95, P99), Tỷ lệ lỗi status codes.
   - Node.js Heap Memory (Used vs Total), Event Loop Lag, Active Handles.
4. **`04. MySQL Database Performance (Đề 9)`**:
   - Active Connections vs Max Connections, Threads Running, Uptime.
   - Throughput các lệnh SQL (SELECT, INSERT, UPDATE, DELETE) trên giây.
   - Slow Queries, InnoDB Buffer Pool pages (Data vs Free), Băng thông Network I/O.
5. **`05. cAdvisor Docker Containers & Resource Limits (Đề 9)`**:
   - Số container hoạt động, Tổng CPU và RAM hệ thống.
   - Mức tiêu thụ CPU % và RAM Working Set chi tiết của từng container riêng biệt.
   - Lưu lượng mạng Rx/Tx của từng container.
6. **`06. Loki Centralized Logs & LogQL Analytics (Đề 9)`**:
   - Tốc độ nạp log (Bytes/s, Lines/s), Tổng số log lines.
   - Bảng Live Stream Log thời gian thực từ Nginx và Node.js Express.
   - Lọc và đếm log lỗi HTTP 4xx, 5xx và exception ứng dụng.
7. **`07. DevOps Summary (Containers, MySQL & Nginx)`**:
   - Biểu đồ mức sử dụng Container CPU theo thời gian thực.
   - Biểu đồ mức sử dụng Container RAM Working Set.
   - Thẻ hiển thị trạng thái kết nối và Uptime của MySQL Database.
   - Thẻ hiển thị trạng thái hoạt động và lưu lượng Nginx Reverse Proxy.


### 🛠️ Các Script Tiện Ích Hỗ Trợ Đánh Giá:
- **Kiểm tra nhanh Target Health**:
  ```powershell
  powershell -ExecutionPolicy Bypass -File .\scripts\check-targets.ps1
  ```
- **Tạo lưu lượng giả lập (để đồ thị Grafana nhảy số sinh động)**:
  ```powershell
  powershell -ExecutionPolicy Bypass -File .\scripts\simulate-traffic.ps1
  ```

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
