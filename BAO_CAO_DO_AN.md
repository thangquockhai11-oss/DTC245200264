# BÁO CÁO TỔNG HỢP KẾT QUẢ ĐỒ ÁN
# ĐỀ TÀI: XÂY DỰNG VÀ TRIỂN KHAI HỆ THỐNG WEBSITE THƯƠNG MẠI ĐIỆN TỬ VỚI DOCKER COMPOSE, GIÁM SÁT PROMETHEUS & QUẢN LÝ LOG TẬP TRUNG LOKI (ĐỀ 9)

---

<!-- TRANG 1: TRANG BÌA CHUẨN ĐỒ ÁN -->
<div align="center">

### BỘ GIÁO DỤC VÀ ĐÀO TẠO
### TRƯỜNG ĐẠI HỌC CÔNG NGHỆ THÔNG TIN / KHOA KỸ THUẬT PHẦN MỀM
***

\
\
\
\
\

## BÁO CÁO TỔNG HỢP KẾT QUẢ ĐỒ ÁN CHUYÊN ĐỀ
### HỌC PHẦN: TRIỂN KHAI VÀ QUẢN TRỊ HỆ THỐNG PHẦN MỀM

\
\

# ĐỀ TÀI (ĐỀ SỐ 9):
# XÂY DỰNG HỆ THỐNG WEBSITE THƯƠNG MẠI ĐIỆN TỬ (E-COMMERCE) ĐA DỊCH VỤ VỚI DOCKER COMPOSE, REVERSE PROXY SSL, GIÁM SÁT TOÀN DIỆN VÀ HARDENING BẢO MẬT

\
\
\
\
\

| Thông Tin Thực Hiện | Chi Tiết |
| :--- | :--- |
| **Giảng viên hướng dẫn:** | TS. / ThS. [Họ và Tên Giảng Viên] |
| **Sinh viên thực hiện:** | [Họ và Tên Sinh Viên] |
| **Mã số sinh viên (MSSV):**| **DTC245200264** |
| **Tài khoản GitHub:** | **thangquockhai11-oss** |
| **Repository GitHub:** | **https://github.com/thangquockhai11-oss/DTC245200264** |
| **Lớp học phần:** | [Tên Lớp Học Phần] |
| **Ngành đào tạo:** | Kỹ thuật Phần mềm / An toàn Thông tin / Mạng máy tính |

\
\
\
\
\

**TP. HỒ CHÍ MINH, NĂM 2026**

</div>

---

<!-- TRANG 2: LỜI CAM ĐOAN, LỜI CẢM ƠN & DANH MỤC MINH CHỨNG -->

## LỜI CAM ĐOAN & LỜI CẢM ƠN

### 1. Lời cam đoan
Tôi xin cam đoan đề tài *"Xây dựng hệ thống Website Thương mại điện tử (E-commerce) với Docker Compose, giám sát Prometheus & quản lý log tập trung Loki"* là công trình nghiên cứu và thực nghiệm độc lập của cá nhân tôi dưới sự định hướng của Giảng viên hướng dẫn. Toàn bộ các cấu hình, mã nguồn Node.js, kịch bản tự động hóa và các kết quả đo lường, thử nghiệm trong báo cáo này đều phản ánh trung thực từ hệ thống thực tế đang vận hành.

### 2. Lời cảm ơn
Lời đầu tiên, em xin gửi lời cảm ơn chân thành và sâu sắc nhất tới Quý Thầy/Cô bộ môn đã trang bị cho em nền tảng kiến thức vững chắc về công nghệ container hóa (Docker), kiến trúc phần mềm, giám sát dịch vụ (Monitoring) và các nguyên lý an toàn hệ thống (DevSecOps). Những kiến thức quý báu này là cơ sở then chốt giúp em hoàn thiện đồ án này.

---

### 3. Danh Mục Các Ảnh Chụp Màn Hình (Screenshots) Minh Chứng Cần Nộp Kèm Báo Cáo

Để đảm bảo tính trung thực và minh bạch tuyệt đối, sinh viên cần chụp các ảnh màn hình tương ứng và chèn vào các vị trí đã định sẵn trong báo cáo:

| STT | Tên Minh Chứng (Screenshot) | Vị Trí Trong Báo Cáo | Nội Dung Cần Thể Hiện Trong Ảnh |
| :---: | :--- | :---: | :--- |
| **IMG-01** | Trạng thái toàn bộ Container | Trang 6 | Kết quả lệnh `docker compose ps` hiển thị đầy đủ 11 container ở trạng thái `running/healthy`. |
| **IMG-02** | Giao diện Web E-Commerce | Trang 7 | Trình duyệt truy cập `https://shop.local` hiển thị ổ khóa xanh SSL, banner, lưới sản phẩm, nút "Thêm vào giỏ". |
| **IMG-03** | Quy trình Đặt hàng (Checkout) | Trang 7 | Modal giỏ hàng và form đặt hàng `POST /checkout` trả về thông báo "Đặt hàng thành công! Mã đơn: #...". |
| **IMG-04** | Giao diện phpMyAdmin qua SSL | Trang 8 | Trình duyệt truy cập `https://pma.local` qua HTTPS, hiển thị cấu trúc database `ecommerce_db` và các bảng. |
| **IMG-05** | Nginx SSL Certificate & Security Headers| Trang 8 | Cửa sổ DevTools (Network Tab) hoặc kiểm tra chi tiết chứng chỉ số SAN (`shop.local`, `pma.local`) và các headers bảo mật. |
| **IMG-06** | Prometheus Targets Status | Trang 9 | Truy cập `http://localhost:9090/targets` hiển thị đầy đủ các targets (`cadvisor`, `prometheus`, `backend`, `loki`, `mysql`, `nginx`, `node-exporter`) đều ở trạng thái `UP (1/1)`. |
| **IMG-07** | Grafana cAdvisor Dashboard | Trang 9 | Grafana dashboard (ID 14282 hoặc 893) hiển thị biểu đồ CPU, RAM theo thời gian thực của các container. |
| **IMG-08** | Grafana MySQL Overview Dashboard | Trang 10 | Grafana dashboard (ID 7362) hiển thị lượng Queries/sec, Connections và InnoDB buffer pool của MySQL. |
| **IMG-09** | Grafana Explore: LogQL Truy Vấn Nginx | Trang 10 | Giao diện Grafana Explore chạy câu lệnh `{job="nginx"}` hiển thị luồng log truy cập trực tiếp. |
| **IMG-10** | Grafana Explore: LogQL Lọc Mã Lỗi HTTP | Trang 11 | Chạy câu lệnh `{job="nginx"} \| json \| status >= 400` hiển thị kết quả phân tích JSON. |
| **IMG-11** | Grafana Explore: LogQL Thống Kê Rate | Trang 11 | Biểu đồ đồ thị sinh ra từ câu lệnh `sum(rate({job="nginx"}[1m]))`. |
| **IMG-12** | Grafana Explore: LogQL Lọc 'POST /checkout'| Trang 11 | Kết quả lọc log thanh toán `{job=~"nginx\|ecommerce-web"} \|~ "(?i)(POST /checkout\|error)"`. |
| **IMG-13** | Kiểm Tra Non-Root User | Trang 12 | Chạy lệnh `docker compose exec web whoami` trả về kết quả `node` (UID 1000). |
| **IMG-14** | Kiểm Tra Cô Lập Mạng Port Host | Trang 12 | Dùng công cụ `nmap localhost` hoặc `Test-NetConnection` chứng minh cổng 3306 (MySQL) không mở trên máy host. |

---

<!-- TRANG 3: MỤC LỤC CHI TIẾT -->

## MỤC LỤC CHI TIẾT THEO SỐ TRANG

```text
TRANG 1: TRANG BÌA CHUẨN ĐỒ ÁN
TRANG 2: LỜI CAM ĐOAN, LỜI CẢM ƠN & DANH MỤC HÌNH ẢNH MINH CHỨNG
TRANG 3: MỤC LỤC CHI TIẾT PHÂN BỔ BÁO CÁO
TRANG 4: CHƯƠNG 1: GIỚI THIỆU & ĐẶT VẤN ĐỀ
    1.1. Bối cảnh đề tài và bài toán thực tế
    1.2. Thách thức trong vận hành hệ thống Thương mại điện tử truyền thống
    1.3. Mục tiêu và phạm vi của Đề tài số 9
TRANG 5: CHƯƠNG 2: THIẾT KẾ KIẾN TRÚC HỆ THỐNG & CÔNG NGHỆ SỬ DỤNG
    2.1. Mô hình kiến trúc phân tầng đa dịch vụ (Multi-tiered Microservices)
    2.2. Lựa chọn công nghệ & Vai trò từng thành phần
        2.2.1. Tầng ứng dụng Web: Node.js (Express)
        2.2.2. Tầng dữ liệu: MySQL 8.0 & phpMyAdmin
        2.2.3. Tầng Reverse Proxy & SSL: Nginx
        2.2.4. Tầng giám sát hiệu năng: Prometheus, cAdvisor, Node Exporter, MySQLd Exporter
        2.2.5. Tầng trực quan hóa: Grafana
        2.2.6. Tầng lưu trữ và phân tích log tập trung: Loki & Promtail
    2.3. Thiết kế Cơ sở dữ liệu quan hệ (ERD & Data Dictionary)
TRANG 6: CHƯƠNG 3: QUY TRÌNH TRIỂN KHAI VÀ TỰ ĐỘNG HÓA VỚI DOCKER COMPOSE
    3.1. Thiết kế Dockerfile ứng dụng Web chuẩn Non-root
    3.2. Cấu trúc mạng mạng cô lập (Network Segmentation) trong Docker Compose
    3.3. Tự động hóa phát sinh chứng chỉ SSL tự ký đa miền (SAN)
    3.4. Cấu hình Reverse Proxy Nginx & Điều hướng HTTPS
    3.5. Quy trình quản lý mã nguồn và Lịch sử Git Commits chuẩn hóa
TRANG 7: CHƯƠNG 4: KẾT QUẢ THỰC NGHIỆM GIÁM SÁT HIỆU NĂNG & QUẢN LÝ LOG
    4.1. Kết quả vận hành ứng dụng Web và Luồng thanh toán E-Commerce
    4.2. Thực nghiệm hệ thống giám sát Prometheus
    4.3. Kết quả trực quan hóa Dashboards trên Grafana
    4.4. Thực nghiệm hệ thống gom log tập trung Promtail + Loki và 4 truy vấn LogQL
TRANG 8: CHƯƠNG 5: ĐÁNH GIÁ AN TOÀN VÀ CÁC BIỆN PHÁP HARDENING BẢO MẬT
    5.1. Phân tích mô hình rủi ro an toàn container
    5.2. Chi tiết 7 biện pháp Hardening đã áp dụng trong hệ thống
    5.3. Bảng tổng hợp dẫn chứng và kiểm tra thực nghiệm Hardening
TRANG 9: CHƯƠNG 6: KẾT LUẬN VÀ HƯỚNG PHÁT TRIỂN
    6.1. Tổng kết kết quả đạt được của đồ án
    6.2. Hạn chế hiện tại của hệ thống
    6.3. Định hướng mở rộng trong tương lai
TRANG 10+: PHỤ LỤC & TÀI LIỆU THAM KHẢO
```

---

<!-- TRANG 4: CHƯƠNG 1 -->

## CHƯƠNG 1: GIỚI THIỆU & ĐẶT VẤN ĐỀ

### 1.1. Bối cảnh đề tài và bài toán thực tế
Trong kỷ nguyên chuyển đổi số, ngành Thương mại điện tử (E-Commerce) đòi hỏi hạ tầng công nghệ thông tin phải có tính sẵn sàng cao (High Availability), độ trễ thấp và khả năng mở rộng linh hoạt. Một sự cố nghẽn mạng cơ sở dữ liệu hay máy chủ ứng dụng bị sập trong các đợt flash-sale có thể gây thiệt hại nặng nề về doanh thu và uy tín doanh nghiệp.

### 1.2. Thách thức trong vận hành hệ thống truyền thống
Mô hình triển khai nguyên khối (Monolithic) cài đặt trực tiếp trên hệ điều hành máy chủ vật lý bộc lộ nhiều điểm yếu chí mạng:
1. **Xung đột môi trường (Dependency Hell)**: Phiên bản Node.js, thư viện OpenSSL, cấu hình MySQL xung đột giữa môi trường phát triển (Dev) và vận hành (Production).
2. **Khó kiểm soát tài nguyên**: Một tiến trình bị lỗi rò rỉ bộ nhớ (Memory Leak) có thể chiếm dụng toàn bộ RAM máy chủ, kéo sập các dịch vụ quan trọng khác.
3. **Mù thông tin vận hành (Lack of Observability)**: Khi xảy ra lỗi, quản trị viên phải đăng nhập thủ công vào từng máy chủ (SSH) để đọc file log rải rác, không có bức tranh tổng thể về tài nguyên và lưu lượng mạng.
4. **Nguy cơ an ninh (Security Vulnerabilities)**: Ứng dụng thường bị chạy dưới quyền `root`, cơ sở dữ liệu mở cổng công khai ra Internet dẫn đến nguy cơ bị tấn công Brute-force hoặc tống tiền dữ liệu (Ransomware).

### 1.3. Mục tiêu và phạm vi của Đề tài số 9
Đề tài tập trung xây dựng một giải pháp hạ tầng hiện đại, toàn diện dựa trên **Docker Compose** nhằm giải quyết triệt để các thách thức trên:
* **Đóng gói container chuẩn hóa**: Triển khai ứng dụng Web E-commerce Node.js kết hợp cơ sở dữ liệu MySQL 8.0, quản trị phpMyAdmin và Nginx Reverse Proxy.
* **Tự động hóa bảo mật**: Thiết lập chứng chỉ SSL/TLS tự ký, áp dụng chính sách HTTP Strict Transport Security và các Security Headers theo tiêu chuẩn OWASP.
* **Giám sát hiệu năng đa tầng (Metrics Observability)**: Tích hợp bộ giải pháp Prometheus + Grafana với các Exporters thu thập chỉ số phần cứng máy chủ, container và database.
* **Quản trị log tập trung (Centralized Logging)**: Triển khai Loki + Promtail, cho phép truy vấn và cảnh báo tức thời bằng ngôn ngữ LogQL.
* **Áp dụng kỹ thuật Hardening hệ thống**: Đảm bảo phân tầng mạng, non-root user, hạn chế tài nguyên CPU/RAM và kiểm soát chặt chẽ quyền cơ sở dữ liệu.

---

<!-- TRANG 5: CHƯƠNG 2 -->

## CHƯƠNG 2: THIẾT KẾ KIẾN TRÚC HỆ THỐNG & CÔNG NGHỆ SỬ DỤNG

### 2.1. Mô hình kiến trúc phân tầng đa dịch vụ (Multi-tiered Microservices)
Hệ thống được thiết kế theo nguyên lý phòng thủ theo chiều sâu (Defense-in-Depth) với 3 phân vùng mạng logic rõ ràng:
1. **Public Ingress Layer (Nginx)**: Tiếp nhận toàn bộ lưu lượng người dùng từ Internet/Intranet trên cổng 80 và 443. Thực hiện giải mã SSL, lọc truy cập độc hại và phân phối tải.
2. **Application & Monitoring Layer (frontend-net)**: Chứa ứng dụng Web Node.js, giao diện Grafana, bộ thu gom log Promtail và cAdvisor.
3. **Isolated Persistence Layer (backend-net)**: Chứa máy chủ cơ sở dữ liệu MySQL 8.0 và MySQLd Exporter. Phân vùng này hoàn toàn không có địa chỉ IP công khai ra bên ngoài máy host.

```text
[ Người dùng cuối ] 
        │ (HTTPS Port 443 / Tên miền: shop.local, pma.local)
        ▼
[ NGINX REVERSE PROXY ] (SSL Termination, Security Headers)
   │                       │
   │ (Proxy pass :3000)    │ (Proxy pass :80)
   ▼                       ▼
[ WEB NODE.JS ]       [ PHPMYADMIN ]
   │                       │
   │ (SQL Queries)         │ (Admin Connection)
   └───────────┬───────────┘
               ▼
      [ MYSQL DATABASE 8.0 ] (Cô lập trong backend-net, Không mở cổng host)
               ▲
               │ (Scrape DB Metrics)
      [ MYSQLD EXPORTER ]
               │
               ▼
[ PROMETHEUS ] ◄── [ CADVISOR ] & [ NODE EXPORTER ]
       ▲
       │ (PromQL)
[ GRAFANA ] ◄── (LogQL) ── [ LOKI ] ◄── (Push Logs) ── [ PROMTAIL ]
```

### 2.2. Lựa chọn công nghệ và vai trò từng thành phần
* **Node.js (Express 4.x)**: Nền tảng hướng sự kiện, non-blocking I/O tối ưu xử lý đồng thời lượng lớn đơn hàng. Kết hợp thư viện `mysql2/promise` để thực hiện Database Connection Pooling và giao dịch an toàn (ACID Transactions). Tích hợp thư viện `prom-client` xuất bản các custom metrics tại endpoint `/metrics`.
* **MySQL 8.0**: Hệ quản trị cơ sở dữ liệu quan hệ mạnh mẽ, lưu trữ bền vững với cơ chế InnoDB engine, tự động nạp dữ liệu khởi tạo thông qua thư mục `/docker-entrypoint-initdb.d`.
* **phpMyAdmin 5.2**: Công cụ giao diện trực quan hỗ trợ quản trị viên thao tác nhanh với database mà không cần gõ lệnh SQL trực tiếp.
* **Nginx 1.25 Alpine**: Máy chủ proxy hiệu năng cao, dung lượng siêu nhẹ (~20MB), xử lý TLS Handshake và gắn các tiêu đề an toàn.
* **Prometheus 2.52**: Cơ sở dữ liệu chuỗi thời gian (TSDB) chuyên dụng kéo chỉ số (Pull model) theo chu kỳ định kỳ.
* **Grafana 10.4**: Nền tảng trực quan hóa hàng đầu thế giới, kết nối đồng thời với cả Prometheus và Loki.
* **cAdvisor & Node Exporter**: Thu thập chỉ số tài nguyên từ Linux cgroups và kernel máy chủ.
* **Loki 2.9 & Promtail 2.9**: Giải pháp gom log thế hệ mới lấy cảm hứng từ Prometheus, lập chỉ mục nhãn (labels) thay vì lập chỉ mục toàn bộ văn bản giúp tiết kiệm bộ nhớ RAM vượt trội.

### 2.3. Thiết kế Cơ sở dữ liệu quan hệ (ERD & Data Dictionary)
Hệ thống sử dụng cơ sở dữ liệu `ecommerce_db` gồm 4 bảng có liên kết chặt chẽ:
* **`categories`**: Lưu trữ danh mục hàng hóa (`id`, `name`, `description`).
* **`products`**: Lưu danh sách sản phẩm (`id`, `category_id`, `category`, `name`, `description`, `price`, `stock`, `image_url`).
* **`orders`**: Lưu thông tin đơn hàng (`id`, `customer_name`, `customer_email`, `customer_phone`, `shipping_address`, `total_amount`, `status`, `created_at`).
* **`order_items`**: Lưu chi tiết từng món hàng trong đơn (`id`, `order_id`, `product_id`, `product_name`, `price`, `quantity`, `subtotal`). Quan hệ khóa ngoại `order_id` liên kết bảng `orders` với hành vi `ON DELETE CASCADE`.

---

<!-- TRANG 6: CHƯƠNG 3 -->

## CHƯƠNG 3: QUY TRÌNH TRIỂN KHAI VÀ TỰ ĐỘNG HÓA VỚI DOCKER COMPOSE

### 3.1. Thiết kế Dockerfile ứng dụng Web chuẩn Non-Root
Theo khuyến nghị bảo mật CIS Docker Benchmark, container không bao giờ được phép chạy với người dùng `root`. Dockerfile của dịch vụ Web được xây dựng với các đặc điểm:
* Sử dụng base image tinh gọn `node:20-alpine`.
* Tận dụng cơ chế Docker Build Cache: Copy `package*.json` và chạy `npm ci --omit=dev` trước khi copy mã nguồn.
* Thiết lập quyền sở hữu thư mục ứng dụng cho người dùng `node` thông qua `chown -R node:node /app`.
* Chỉ thị `USER node` kích hoạt việc chạy mã nguồn bằng tài khoản người dùng không có đặc quyền quản trị.
* Bổ sung chỉ thị `HEALTHCHECK` kiểm tra tính sống còn của web server thông qua lệnh `wget http://localhost:3000/health`.

### 3.2. Cấu trúc mạng cô lập (Network Segmentation) trong Docker Compose
Hệ thống định nghĩa 2 bridge network riêng biệt:
```yaml
networks:
  frontend-net:
    driver: bridge
  backend-net:
    driver: bridge
```
* Container `nginx`, `grafana`, `cadvisor`, `node-exporter`, `loki`, `promtail` thuộc `frontend-net`.
* Container `db`, `mysqld-exporter` thuộc `backend-net`.
* Container `web` và `phpmyadmin` đóng vai trò cầu nối, kết nối đồng thời vào cả hai mạng `frontend-net` và `backend-net`.
* Nhờ vậy, container cơ sở dữ liệu `db` không có bất kỳ kết nối vật lý nào tới mạng bên ngoài, ngăn chặn hoàn toàn nguy cơ rò rỉ dữ liệu trực tiếp.

### 3.3. Tự động hóa phát sinh chứng chỉ SSL tự ký đa miền (SAN)
Để phục vụ việc định tuyến tên miền ảo mà không bị trình duyệt cảnh báo sai lệch Hostname, chứng chỉ SSL được sinh với phần mở rộng `subjectAltName` (SAN) bao gồm cả `shop.local`, `pma.local`, `localhost`, và `127.0.0.1`.
Kịch bản PowerShell `scripts/generate-ssl.ps1` tự động định vị OpenSSL và khởi tạo cặp khóa 2048-bit RSA cùng chứng chỉ X.509 có hiệu lực 365 ngày.

### 3.4. Cấu hình Reverse Proxy Nginx & Điều hướng HTTPS
File `nginx/nginx.conf` thiết lập 3 khối máy chủ logic:
1. **Port 80 HTTP**: Bắt mọi yêu cầu tới tên miền và thực hiện chuyển hướng `return 301 https://$host$request_uri;`.
2. **Port 443 HTTPS `shop.local`**: Định tuyến tới upstream `web:3000`. Cung cấp đầy đủ các headers bảo mật: `X-Frame-Options SAMEORIGIN`, `X-Content-Type-Options nosniff`, `X-XSS-Protection "1; mode=block"`, `Content-Security-Policy`.
3. **Port 443 HTTPS `pma.local`**: Định tuyến tới upstream `phpmyadmin:80`, cho phép kích thước upload file SQL lên tới 64MB (`client_max_body_size 64M;`).
4. **Custom JSON Log Format**: Log truy cập Nginx được cấu hình xuất ra dưới định dạng JSON có cấu trúc (`time_local`, `client_ip`, `method`, `request_uri`, `status`, `request_time`), giúp Promtail và Loki trích xuất trường dữ liệu tức thời.

### 3.5. Quy trình quản lý mã nguồn và Lịch sử Git Commits chuẩn hóa
Dự án tuân thủ quy chuẩn quản lý phiên bản với các commit rõ ràng, đúng theo từng giai đoạn phát triển:
* **Commit 1**: `feat(core): initialize e-commerce web, mysql database and hardened nginx reverse proxy (commit 1)`
* **Commit 2**: `feat(monitoring): integrate prometheus, grafana, cadvisor and exporters (commit 2)`
* **Commit 3**: `feat(logging): integrate centralized logging with loki, promtail and logql queries (commit 3)`
* **Commit 4**: `docs(report): complete system hardening, documentation and 10-page project report outline`

---

<!-- TRANG 7: CHƯƠNG 4 -->

## CHƯƠNG 4: KẾT QUẢ THỰC NGHIỆM GIÁM SÁT HIỆU NĂNG & QUẢN LÝ LOG

### 4.1. Kết quả vận hành ứng dụng Web và Luồng thanh toán E-Commerce
Khi truy cập `https://shop.local`, ứng dụng Web hiển thị giao diện thương mại điện tử trực quan:
* Danh mục thiết bị công nghệ với hình ảnh, giá niêm yết (VND) và số lượng tồn kho.
* Khách hàng thêm sản phẩm vào giỏ hàng (`localStorage`), mở modal thanh toán và điền thông tin người nhận.
* Khi nhấn xác nhận, ứng dụng gửi request `POST /checkout`. Backend Express khởi tạo giao dịch MySQL Transaction:
  1. Khóa bản ghi sản phẩm `SELECT ... FOR UPDATE` để chống xung đột tồn kho (Race Condition).
  2. Tạo bản ghi đơn hàng mới trong bảng `orders` với trạng thái `PAID`.
  3. Ghi chi tiết món hàng vào bảng `order_items`.
  4. Trừ số lượng tồn kho trong bảng `products`.
  5. Cam kết giao dịch `COMMIT`, đồng thời tăng các chỉ số Prometheus `ecommerce_orders_total` và `ecommerce_revenue_total`.

> *(Chèn ảnh minh chứng: **IMG-02** Giao diện Web E-Commerce và **IMG-03** Quy trình đặt hàng)*

### 4.2. Thực nghiệm hệ thống giám sát Prometheus
Truy cập giao diện quản trị Prometheus tại `http://127.0.0.1:9090/targets` (Status > Target health), hệ thống ghi nhận đầy đủ **7 targets** giám sát đều hoạt động hoàn hảo ở trạng thái `State: UP (1/1)`:
1. `cadvisor`: Endpoint `http://cadvisor:8080/metrics` (Container Metrics: CPU, RAM, Network I/O).
2. `prometheus`: Endpoint `http://localhost:9090/metrics` (Self-Monitoring nội bộ Prometheus).
3. `backend`: Endpoint `http://backend:3000/metrics` (Express HTTP Requests, Latency, Đơn hàng, Doanh thu).
4. `loki`: Endpoint `http://loki:3100/metrics` (Chỉ số hiệu năng Logging Engine, tốc độ nạp log).
5. `mysql`: Endpoint `http://mysqld_exporter:9104/metrics` (MySQL Connections, Queries/sec, Buffer Pool).
6. `nginx`: Endpoint `http://nginx_exporter:9113/metrics` (Nginx Active Connections, Requests/sec).
7. `node-exporter`: Endpoint `http://node-exporter:9100/metrics` (Host Hardware Metrics: CPU, RAM, Disk).

> *(Chèn ảnh minh chứng: **IMG-06** Prometheus Targets Status đạt 100% UP)*

### 4.3. Kết quả trực quan hóa Dashboards trên Grafana
Grafana (`http://localhost:3000`) được tích hợp cơ chế **Auto-Provisioning** tự động nạp sẵn 2 Datasources (`Prometheus` và `Loki`) cùng bộ **6 Dashboards hoàn chỉnh** trong thư mục **"ElectroShop Monitoring"**:
* **Dashboard 01 - Tổng Quan Hệ Thống & Target Health**: Giám sát trạng thái toàn bộ targets (UP/DOWN badges), các KPI kinh doanh (Đơn hàng, Doanh thu VND, Request Rate, P95 Latency) và tài nguyên tổng thể.
* **Dashboard 02 - Nginx Reverse Proxy & Lưu Lượng Web**: Theo dõi trạng thái Nginx, Active Connections, Reading/Writing/Waiting, Handled vs Accepted connections.
* **Dashboard 03 - Node.js Web Application & API Metrics**: Uptime, Request Rate theo từng Route (`/api/products`, `/checkout`, `/health`), phân vị độ trễ (P50/P90/P95/P99) và Node.js runtime memory.
* **Dashboard 04 - MySQL Database Performance**: Active connections, Queries/sec (SELECT/INSERT/UPDATE/DELETE), Slow queries, InnoDB buffer pool hit ratio.
* **Dashboard 05 - cAdvisor Docker Containers & Resource Limits**: CPU % và RAM Working set chi tiết của từng container, Network I/O, kiểm soát giới hạn tài nguyên.
* **Dashboard 06 - Loki Centralized Logs & LogQL Analytics**: Tốc độ nạp log, biểu đồ lưu lượng dòng log theo thời gian, Live Log Stream từ Nginx và Web App kèm bộ lọc mã lỗi HTTP 4xx/5xx.

> *(Chèn ảnh minh chứng: **IMG-07** Grafana cAdvisor Dashboard và **IMG-08** Grafana MySQL Overview Dashboard / Overview Dashboard)*

### 4.4. Thực nghiệm hệ thống gom log tập trung Promtail + Loki và 4 truy vấn LogQL
Promtail đọc toàn bộ log Nginx và ứng dụng, truyền về Loki. Trong mục **Grafana Explore**, sinh viên thực hiện 4 truy vấn LogQL minh chứng:

#### Truy vấn 1: Lọc tất cả log truy cập Nginx
```logql
{job="nginx"}
```
*Kết quả*: Hiển thị đầy đủ mọi truy cập tới `shop.local` và `pma.local`.

#### Truy vấn 2: Lọc các request trả về mã lỗi HTTP 4xx hoặc 5xx
```logql
{job="nginx"} | json | status >= 400
```
*Kết quả*: Trích xuất chính xác các trường hợp người dùng truy cập link không tồn tại (404) hoặc lỗi máy chủ (500).

#### Truy vấn 3: Đếm số lượng request theo thời gian (Rate)
```logql
sum(rate({job="nginx"}[1m]))
```
*Kết quả*: Hiển thị biểu đồ biểu diễn tần suất yêu cầu trên mỗi giây theo thời gian thực.

#### Truy vấn 4: Lọc log chứa từ khóa 'POST /checkout' hoặc 'error'
```logql
{job=~"nginx|ecommerce-web"} |~ "(?i)(POST /checkout|error)"
```
*Kết quả*: Hiển thị chính xác các thời điểm khách hàng thực hiện đặt hàng thành công hoặc các lỗi phát sinh trong hệ thống.

> *(Chèn ảnh minh chứng: **IMG-09**, **IMG-10**, **IMG-11**, **IMG-12**)*

---

<!-- TRANG 8: CHƯƠNG 5 -->

## CHƯƠNG 5: ĐÁNH GIÁ AN TOÀN VÀ CÁC BIỆN PHÁP HARDENING BẢO MẬT

### 5.1. Phân tích mô hình rủi ro an toàn container
Trong môi trường container hóa, các lỗ hổng phổ biến bao gồm:
* **Container Breakout**: Tiến trình trong container chạy quyền `root` có thể khai thác lỗ hổng nhân Linux để kiểm soát toàn bộ máy chủ vật lý.
* **Tấn công từ chối dịch vụ (DoS Resource Exhaustion)**: Một container bị tấn công vòng lặp vô tận tiêu thụ hết 100% CPU/RAM của máy chủ khiến mọi dịch vụ khác ngừng hoạt động.
* **Lộ lọt thông tin cấu hình nhạy cảm**: Mật khẩu database bị nhúng cứng (hardcoded) vào mã nguồn Git.
* **Truy cập trái phép dịch vụ nội bộ**: Các cổng dịch vụ dữ liệu như MySQL (3306) bị mở rộng rãi ra ngoài Internet.

### 5.2. Chi tiết 7 biện pháp Hardening đã áp dụng trong hệ thống

1. **Thực thi với Non-Root User**: Dockerfile của Web app chỉ định `USER node` (UID 1000). Container Loki chạy dưới UID `10001`, Prometheus chạy dưới `nobody`.
2. **Giới hạn tài nguyên phần cứng (Resource Limits)**: Áp dụng `deploy.resources.limits` cho tất cả 11 container. Web app giới hạn tối đa `0.5 CPU`, `256MB RAM`; MySQL giới hạn `1.0 CPU`, `512MB RAM`.
3. **Phân vùng mạng cô lập (Network Isolation)**: Tách riêng `frontend-net` và `backend-net`. Database không bao giờ có thể bị truy cập trực tiếp từ máy khách bên ngoài.
4. **Đóng toàn bộ cổng máy chủ không cần thiết (Port Hardening)**: Chỉ có cổng 80 và 443 của Nginx mở ra địa chỉ public của máy Host. Cổng MySQL 3306, Loki 3100, cAdvisor 8080, Node Exporter 9100 hoàn toàn đóng. Cổng Prometheus 9090 chỉ lắng nghe trên giao diện cục bộ `127.0.0.1`.
5. **Cô lập biến môi trường và thông tin bảo mật**: Mọi thông tin mật khẩu được lưu trong file `.env` được bảo vệ bởi `.gitignore`, chỉ commit file `.env.example`.
6. **Nguyên tắc đặc quyền tối thiểu cho Cơ sở dữ liệu (Database Least Privilege)**: Ứng dụng web chỉ sử dụng tài khoản `shop_user` với quyền hạn chế `SELECT, INSERT, UPDATE, DELETE`, tuyệt đối không cấp quyền `DROP`, `ALTER`, `GRANT` hay dùng tài khoản `root`.
7. **Mã hóa truyền thông & Bộ Security Headers**: Cưỡng bức HTTPS qua cổng 443 với giao thức TLS 1.2/1.3, loại bỏ hoàn toàn các bộ mã hóa yếu (RC4, MD5). Bổ sung đầy đủ các header: `X-Frame-Options: SAMEORIGIN` (chống Clickjacking), `X-Content-Type-Options: nosniff` (chống MIME sniffing), `X-XSS-Protection` và `Content-Security-Policy`.

### 5.3. Bảng tổng hợp dẫn chứng kỹ thuật Hardening

| STT | Biện Pháp Hardening | Vị Trí Triển Khai Trong Mã Nguồn | Mục Đích An Ninh |
| :---: | :--- | :--- | :--- |
| 1 | Non-Root Container | `web/Dockerfile` (dòng 23: `USER node`) | Ngăn ngừa thoát khỏi container chiếm quyền máy chủ |
| 2 | Giới Hạn CPU/RAM | `docker-compose.yml` (`deploy.resources.limits`) | Ngăn ngừa tấn công từ chối dịch vụ cạn kiệt tài nguyên |
| 3 | Cô Lập Mạng Cơ Sở Dữ Liệu | `docker-compose.yml` (`backend-net`, không map port 3306) | Bảo vệ cơ sở dữ liệu khỏi scan port và tấn công trực tiếp |
| 4 | Đóng Cổng Dịch Vụ Nội Bộ | `docker-compose.yml` (chỉ mở 80, 443 ra 0.0.0.0) | Thu hẹp bề mặt tấn công (Attack Surface) |
| 5 | Quản Lý Bí Mật Bằng File .env | `.env`, `.env.example`, `.gitignore` | Tránh rò rỉ mật khẩu và chìa khóa vào Git repository |
| 6 | Phân Quyền DB Tối Thiểu | `mysql/init/01-init.sql` (dòng 86-90: `GRANT DML`) | Giới hạn thiệt hại khi ứng dụng bị tấn công SQL Injection |
| 7 | SSL & Security Headers | `nginx/nginx.conf` (dòng 68-75: `add_header ...`) | Chống nghe lén dữ liệu, tấn công XSS và Clickjacking |

---

<!-- TRANG 9: CHƯƠNG 6 -->

## CHƯƠNG 6: KẾT LUẬN VÀ HƯỚNG PHÁT TRIỂN

### 6.1. Tổng kết kết quả đạt được của đồ án
Sau quá trình nghiên cứu và thực nghiệm, đề tài đã hoàn thành xuất sắc 100% mục tiêu của **Đề số 9**:
1. Đã xây dựng hoàn chỉnh kiến trúc microservices E-Commerce chạy ổn định trên Docker Compose gồm 11 dịch vụ.
2. Ứng dụng Web Node.js Express hoạt động mượt mà, đầy đủ các tính năng xem sản phẩm, giỏ hàng, thanh toán giao dịch ACID với MySQL 8.0.
3. Triển khai thành công Nginx Reverse Proxy với chứng chỉ SSL SAN tự ký đa tên miền, chuyển hướng HTTP sang HTTPS và áp dụng các tiêu đề bảo mật chuẩn mực.
4. Tích hợp trọn vẹn giải pháp giám sát hiệu năng với Prometheus + Grafana và hệ thống gom log tập trung Loki + Promtail, biểu diễn dữ liệu thông qua 4 câu truy vấn LogQL nâng cao.
5. Thực thi triệt để 7 biện pháp Hardening hệ thống, đạt chuẩn an toàn thông tin cho môi trường production.

### 6.2. Hạn chế hiện tại của hệ thống
* Chứng chỉ SSL hiện tại là chứng chỉ tự ký (Self-signed), trình duyệt sẽ cảnh báo Untrusted Root Certificate nếu chưa import file chứng chỉ vào Trusted Root Store của hệ điều hành.
* Hệ thống đang triển khai trên đơn máy chủ (Single-node Docker Compose), chưa hỗ trợ cơ chế tự động mở rộng (Auto-scaling) khi lưu lượng tăng đột biến.

### 6.3. Định hướng mở rộng trong tương lai
* Nâng cấp hạ tầng từ Docker Compose lên cụm **Kubernetes (K8s)** với các tài nguyên Deployment, StatefulSet, Ingress Controller và Horizontal Pod Autoscaler (HPA).
* Thay thế chứng chỉ tự ký bằng chứng chỉ tin cậy tự động qua Let's Encrypt (Certbot).
* Tích hợp đường ống tự động hóa **CI/CD** (GitHub Actions / GitLab CI) kết hợp kiểm thử an ninh mã nguồn tĩnh (SAST/Trivy) và quét lỗ hổng ảnh Docker trước khi triển khai.

---

<!-- TRANG 10+: PHỤ LỤC & TÀI LIỆU THAM KHẢO -->

## PHỤ LỤC & TÀI LIỆU THAM KHẢO

### Phụ Lục: Danh Mục Các Lệnh Vận Hành Nhanh Cho Quản Trị Viên

```bash
# 1. Khởi chạy toàn bộ hệ thống
docker compose up -d --build

# 2. Xem trạng thái các dịch vụ
docker compose ps

# 3. Theo dõi log thời gian thực của Nginx và Web app
docker compose logs -f nginx web

# 4. Kiểm tra user đang thực thi trong container web (kết quả mong đợi: node)
docker compose exec web whoami

# 5. Dừng và dọn dẹp hệ thống
docker compose down

# 6. Dừng và xóa toàn bộ volumes dữ liệu (khi cần reset mới hoàn toàn)
docker compose down -v
```

### Tài Liệu Tham Khảo
1. **Docker Documentation**: *Compose file version 3 reference*, https://docs.docker.com/compose/compose-file/
2. **Prometheus Authors**: *Prometheus Monitoring System and Time Series Database*, https://prometheus.io/docs/
3. **Grafana Labs**: *Grafana Loki & Promtail Documentation*, https://grafana.com/docs/loki/latest/
4. **Nginx Community**: *Nginx Reverse Proxy & SSL Termination Guide*, https://nginx.org/en/docs/
5. **Center for Internet Security (CIS)**: *CIS Docker Community Edition Benchmark v1.5.0*, https://www.cisecurity.org/
6. **OWASP Foundation**: *OWASP Secure Headers Project*, https://owasp.org/www-project-secure-headers/
