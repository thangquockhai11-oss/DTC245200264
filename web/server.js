const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
const morgan = require('morgan');
const fs = require('fs');
const path = require('path');
const client = require('prom-client');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Log directories setup
const logsDir = path.join(__dirname, 'logs');
if (!fs.existsSync(logsDir)) {
  fs.mkdirSync(logsDir, { recursive: true });
}
const accessLogStream = fs.createWriteStream(path.join(logsDir, 'access.log'), { flags: 'a' });
const errorLogStream = fs.createWriteStream(path.join(logsDir, 'error.log'), { flags: 'a' });

function writeErrorLog(message) {
  const timestamp = new Date().toISOString();
  const entry = `[${timestamp}] [ERROR] ${message}\n`;
  console.error(entry.trim());
  errorLogStream.write(entry);
}

function writeAppLog(message) {
  const timestamp = new Date().toISOString();
  const entry = `[${timestamp}] [INFO] ${message}\n`;
  console.log(entry.trim());
  accessLogStream.write(entry);
}

// Prometheus Metrics Setup
const register = new client.Registry();
client.collectDefaultMetrics({ register, prefix: 'node_' });

const httpRequestsTotal = new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests received',
  labelNames: ['method', 'route', 'status_code'],
  registers: [register]
});

const httpRequestDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5],
  registers: [register]
});

const ordersTotal = new client.Counter({
  name: 'ecommerce_orders_total',
  help: 'Total number of e-commerce orders placed',
  registers: [register]
});

const revenueTotal = new client.Counter({
  name: 'ecommerce_revenue_total',
  help: 'Total revenue generated in VND',
  registers: [register]
});

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Morgan combined logging to stdout and file
app.use(morgan('combined', { stream: accessLogStream }));
app.use(morgan('dev'));

// Metrics collection middleware
app.use((req, res, next) => {
  const start = process.hrtime();
  res.on('finish', () => {
    const duration = process.hrtime(start);
    const durationInSeconds = duration[0] + duration[1] / 1e9;
    const route = req.route ? req.route.path : req.path;
    httpRequestsTotal.inc({ method: req.method, route, status_code: res.statusCode });
    httpRequestDuration.observe({ method: req.method, route, status_code: res.statusCode }, durationInSeconds);
  });
  next();
});

// MySQL Connection Pool Configuration
const dbConfig = {
  host: process.env.DB_HOST || 'db',
  user: process.env.DB_USER || 'shop_user',
  password: process.env.DB_PASSWORD || 'ShopUserPass123!',
  database: process.env.DB_NAME || 'ecommerce_db',
  port: parseInt(process.env.DB_PORT || '3306', 10),
  charset: 'utf8mb4',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
};

let pool = null;

async function getPool() {
  if (!pool) {
    pool = mysql.createPool(dbConfig);
  }
  return pool;
}

// Check database connection on startup with retries
async function testDbConnection(retries = 15, delay = 3000) {
  for (let i = 0; i < retries; i++) {
    try {
      const p = await getPool();
      const [rows] = await p.query('SELECT 1 as test');
      writeAppLog('Database connected successfully!');
      return true;
    } catch (err) {
      writeErrorLog(`Database connection attempt ${i + 1}/${retries} failed: ${err.message}`);
      if (i < retries - 1) {
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
  }
  writeErrorLog('Could not connect to database after maximum retries.');
  return false;
}

// Static files
app.use(express.static(path.join(__dirname, 'public')));

// Prometheus Metrics Endpoint
app.get('/metrics', async (req, res) => {
  try {
    res.set('Content-Type', register.contentType);
    res.end(await register.metrics());
  } catch (err) {
    res.status(500).end(err);
  }
});

// Health check endpoint
app.get('/health', async (req, res) => {
  try {
    const p = await getPool();
    await p.query('SELECT 1');
    res.json({
      status: 'UP',
      database: 'CONNECTED',
      uptime: process.uptime(),
      timestamp: new Date().toISOString()
    });
  } catch (err) {
    res.status(503).json({
      status: 'DOWN',
      database: 'DISCONNECTED',
      error: err.message,
      uptime: process.uptime()
    });
  }
});

// API: Get all products
app.get('/api/products', async (req, res) => {
  try {
    const p = await getPool();
    const [products] = await p.query('SELECT * FROM products ORDER BY id ASC');
    res.json({ success: true, count: products.length, data: products });
  } catch (err) {
    writeErrorLog(`GET /api/products failed: ${err.message}`);
    res.status(500).json({ success: false, error: 'Database query failed' });
  }
});

// API: Get product by ID
app.get('/api/products/:id', async (req, res) => {
  try {
    const p = await getPool();
    const [rows] = await p.query('SELECT * FROM products WHERE id = ?', [req.params.id]);
    if (rows.length === 0) {
      return res.status(404).json({ success: false, error: 'Product not found' });
    }
    res.json({ success: true, data: rows[0] });
  } catch (err) {
    writeErrorLog(`GET /api/products/${req.params.id} failed: ${err.message}`);
    res.status(500).json({ success: false, error: 'Internal server error' });
  }
});

// Shared Checkout Handler (handles both /checkout and /api/orders)
async function handleCheckout(req, res) {
  const { customer_name, customer_email, customer_phone, shipping_address, items } = req.body;

  if (!customer_name || !items || !Array.isArray(items) || items.length === 0) {
    writeErrorLog('POST /checkout rejected: Invalid payload or empty items');
    return res.status(400).json({
      success: false,
      error: 'Vui lòng cung cấp đầy đủ họ tên khách hàng và danh sách sản phẩm.'
    });
  }

  let connection;
  try {
    const p = await getPool();
    connection = await p.getConnection();
    await connection.beginTransaction();

    let totalAmount = 0;
    const validatedItems = [];

    for (const item of items) {
      const [productRows] = await connection.query(
        'SELECT id, name, price, stock FROM products WHERE id = ? FOR UPDATE',
        [item.product_id]
      );

      if (productRows.length === 0) {
        throw new Error(`Sản phẩm mã #${item.product_id} không tồn tại.`);
      }

      const product = productRows[0];
      const qty = parseInt(item.quantity, 10) || 1;

      if (product.stock < qty) {
        throw new Error(`Sản phẩm "${product.name}" chỉ còn ${product.stock} trong kho, không đủ đáp ứng.`);
      }

      const itemTotal = Number(product.price) * qty;
      totalAmount += itemTotal;

      validatedItems.push({
        product_id: product.id,
        product_name: product.name,
        price: product.price,
        quantity: qty,
        subtotal: itemTotal
      });
    }

    // Insert order
    const [orderResult] = await connection.query(
      `INSERT INTO orders (customer_name, customer_email, customer_phone, shipping_address, total_amount, status)
       VALUES (?, ?, ?, ?, ?, 'PAID')`,
      [customer_name, customer_email || '', customer_phone || '', shipping_address || '', totalAmount]
    );

    const orderId = orderResult.insertId;

    // Insert order items and update stock
    for (const item of validatedItems) {
      await connection.query(
        `INSERT INTO order_items (order_id, product_id, product_name, price, quantity, subtotal)
         VALUES (?, ?, ?, ?, ?, ?)`,
        [orderId, item.product_id, item.product_name, item.price, item.quantity, item.subtotal]
      );

      await connection.query(
        'UPDATE products SET stock = stock - ? WHERE id = ?',
        [item.quantity, item.product_id]
      );
    }

    await connection.commit();

    // Increment metrics
    ordersTotal.inc();
    revenueTotal.inc(totalAmount);

    writeAppLog(`POST /checkout SUCCESS: Order #${orderId} created for ${customer_name}. Total: ${totalAmount} VND`);

    res.status(201).json({
      success: true,
      message: 'Đặt hàng thành công!',
      order_id: orderId,
      total_amount: totalAmount,
      items: validatedItems
    });
  } catch (err) {
    if (connection) await connection.rollback();
    writeErrorLog(`POST /checkout FAILED: ${err.message}`);
    res.status(400).json({ success: false, error: err.message });
  } finally {
    if (connection) connection.release();
  }
}

// Both /checkout and /api/orders route to checkout handler
app.post('/checkout', handleCheckout);
app.post('/api/orders', handleCheckout);

// API: Get recent orders
app.get('/api/orders', async (req, res) => {
  try {
    const p = await getPool();
    const [orders] = await p.query(
      'SELECT * FROM orders ORDER BY created_at DESC LIMIT 20'
    );
    res.json({ success: true, count: orders.length, data: orders });
  } catch (err) {
    writeErrorLog(`GET /api/orders failed: ${err.message}`);
    res.status(500).json({ success: false, error: 'Database query failed' });
  }
});

// 404 handler
app.use((req, res) => {
  writeErrorLog(`HTTP 404 Not Found: ${req.method} ${req.originalUrl}`);
  res.status(404).json({ success: false, error: 'Endpoint không tồn tại' });
});

// Global error handler
app.use((err, req, res, next) => {
  writeErrorLog(`HTTP 500 Server Error: ${err.message}\n${err.stack}`);
  res.status(500).json({ success: false, error: 'Lỗi máy chủ nội bộ' });
});

// Start Server
app.listen(PORT, '0.0.0.0', () => {
  writeAppLog(`E-Commerce Web Service is running on port ${PORT}`);
  testDbConnection();
});
