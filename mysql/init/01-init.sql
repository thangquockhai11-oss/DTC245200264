-- =======================================================
-- Database Initialization Script for ElectroShop (Đề 9)
-- Database: ecommerce_db (UTF-8 / utf8mb4)
-- =======================================================

SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

CREATE DATABASE IF NOT EXISTS ecommerce_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ecommerce_db;

-- 1. Table: categories
CREATE TABLE IF NOT EXISTS categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Table: products
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT DEFAULT NULL,
    category VARCHAR(100) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(12, 2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    image_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_category (category),
    INDEX idx_price (price)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Table: orders
CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(150) NOT NULL,
    customer_email VARCHAR(150),
    customer_phone VARCHAR(30) NOT NULL,
    shipping_address TEXT NOT NULL,
    total_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    status ENUM('PENDING', 'PAID', 'SHIPPED', 'CANCELLED') NOT NULL DEFAULT 'PAID',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_created_at (created_at),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Table: order_items
CREATE TABLE IF NOT EXISTS order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    price DECIMAL(12, 2) NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    subtotal DECIMAL(12, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    INDEX idx_order_id (order_id),
    INDEX idx_product_id (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =======================================================
-- Seed Initial Sample Data (Tiếng Việt Chuẩn UTF-8)
-- =======================================================

INSERT INTO categories (id, name, description) VALUES
(1, 'Laptop', 'Máy tính xách tay cao cấp cho lập trình và đồ họa'),
(2, 'Smartphone', 'Điện thoại thông minh flagship đời mới'),
(3, 'Phụ kiện', 'Bàn phím cơ, chuột không dây và tai nghe chống ồn'),
(4, 'Màn hình', 'Màn hình đồ họa chuẩn màu 4K và 2K')
ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description);

INSERT INTO products (id, category_id, category, name, description, price, stock, image_url) VALUES
(1, 1, 'Laptop', 'MacBook Pro 14" M3 Pro (18GB / 512GB SSD)', 'Hiệu năng đồ họa đỉnh cao với chip Apple M3 Pro, màn hình Liquid Retina XDR 120Hz siêu sáng.', 49990000, 15, 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=500'),
(2, 1, 'Laptop', 'Dell XPS 15 9530 Core i7-13700H (32GB / 1TB)', 'Thiết kế nhôm nguyên khối sang trọng, màn hình OLED 3.5K sắc nét, card rời RTX 4060.', 42500000, 8, 'https://images.unsplash.com/photo-1593642632823-8f785ba67e45?w=500'),
(3, 2, 'Smartphone', 'iPhone 15 Pro Max 256GB Titan Tự Nhiên', 'Khung viền titan siêu nhẹ, vi xử lý A17 Pro cực mạnh, camera tiềm vọng zoom quang học 5x.', 29490000, 25, 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=500'),
(4, 2, 'Smartphone', 'Samsung Galaxy S24 Ultra 5G 512GB', 'Tích hợp bút S-Pen, vi xử lý Snapdragon 8 Gen 3 for Galaxy và bộ tính năng Galaxy AI thông minh.', 28990000, 20, 'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=500'),
(5, 3, 'Phụ kiện', 'Bàn phím cơ Keychron Q1 Pro Wireless RGB', 'Khung nhôm CNC full custom, kết nối Bluetooth 5.1 đa thiết bị, switch Keychron K Pro siêu êm.', 4190000, 30, 'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=500'),
(6, 3, 'Phụ kiện', 'Tai nghe chống ồn Sony WH-1000XM5', 'Chống ồn chủ động đỉnh cao ngành âm thanh, thời lượng pin 30 giờ, đàm thoại AI trong trẻo.', 7490000, 18, 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500'),
(7, 3, 'Phụ kiện', 'Chuột Logitech MX Master 3S Graphite', 'Cảm biến 8K DPI mượt mà trên mọi bề mặt, con lăn MagSpeed siêu tốc, bấm êm Quiet Clicks.', 2290000, 45, 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=500'),
(8, 4, 'Màn hình', 'Màn hình Dell UltraSharp 27" 4K U2723QE', 'Công nghệ tấm nền IPS Black độ tương phản 2000:1, chuẩn màu 98% DCI-P3, cổng kết nối Type-C 90W.', 13890000, 12, 'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=500')
ON DUPLICATE KEY UPDATE category=VALUES(category), name=VALUES(name), description=VALUES(description), price=VALUES(price), stock=VALUES(stock);

-- Seed 1 sample initial order
INSERT INTO orders (id, customer_name, customer_email, customer_phone, shipping_address, total_amount, status)
VALUES (1, 'Trần Minh Khang', 'khang.tran@gmail.com', '0988776655', 'Khu Công Nghệ Cao, TP. Thủ Đức, TP.HCM', 7490000, 'PAID')
ON DUPLICATE KEY UPDATE customer_name=VALUES(customer_name);

INSERT INTO order_items (id, order_id, product_id, product_name, price, quantity, subtotal)
VALUES (1, 1, 6, 'Tai nghe chống ồn Sony WH-1000XM5', 7490000, 1, 7490000)
ON DUPLICATE KEY UPDATE product_name=VALUES(product_name);

-- =======================================================
-- Security Hardening: Least Privilege Grants for Services
-- Principle of Least Privilege: shop_user chỉ được quyền DML
-- KHÔNG có quyền DDL (CREATE, DROP, ALTER) hoặc ADMIN
-- =======================================================

-- App user: chỉ quyền đọc/ghi dữ liệu, không sửa cấu trúc
GRANT SELECT, INSERT, UPDATE, DELETE ON ecommerce_db.* TO 'shop_user'@'%';
GRANT SHOW DATABASES ON *.* TO 'shop_user'@'%';

CREATE USER IF NOT EXISTS 'exporter'@'%' IDENTIFIED BY 'ExporterPass123!' WITH MAX_USER_CONNECTIONS 5;
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'%';

FLUSH PRIVILEGES;
