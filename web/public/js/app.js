// ElectroShop E-Commerce Client Application
let allProducts = [];
let cart = JSON.parse(localStorage.getItem('electroshop_cart')) || [];
let activeCategory = 'ALL';

// Format currency to VND
function formatVND(amount) {
  return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(amount);
}

// Toast notification
function showToast(message, type = 'success') {
  const container = document.getElementById('toastContainer');
  const toast = document.createElement('div');
  toast.className = `toast ${type}`;
  toast.innerHTML = `
    <span>${type === 'success' ? '✅' : '⚠️'}</span>
    <div>${message}</div>
  `;
  container.appendChild(toast);
  setTimeout(() => {
    toast.style.opacity = '0';
    setTimeout(() => toast.remove(), 300);
  }, 4000);
}

// Fetch products from API
async function loadProducts() {
  const grid = document.getElementById('productGrid');
  try {
    const res = await fetch('/api/products');
    const data = await res.json();
    if (data.success) {
      allProducts = data.data;
      renderProducts();
    } else {
      grid.innerHTML = `<div class="loading-spinner">Không thể tải dữ liệu: ${data.error}</div>`;
    }
  } catch (err) {
    grid.innerHTML = `<div class="loading-spinner">Lỗi kết nối API máy chủ: ${err.message}</div>`;
  }
}

// Render products
function renderProducts() {
  const grid = document.getElementById('productGrid');
  const searchVal = document.getElementById('searchInput').value.trim().toLowerCase();

  const filtered = allProducts.filter(p => {
    const matchCat = activeCategory === 'ALL' || p.category === activeCategory;
    const matchSearch = p.name.toLowerCase().includes(searchVal) || p.description.toLowerCase().includes(searchVal);
    return matchCat && matchSearch;
  });

  if (filtered.length === 0) {
    grid.innerHTML = '<div class="loading-spinner">Không tìm thấy sản phẩm nào phù hợp.</div>';
    return;
  }

  grid.innerHTML = filtered.map(p => `
    <div class="product-card" data-id="${p.id}">
      <div class="product-image-wrap">
        <img class="product-image" src="${p.image_url || 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=500'}" alt="${p.name}" loading="lazy">
        <span class="product-category-tag">${p.category || 'Công nghệ'}</span>
      </div>
      <div class="product-card-body">
        <h4 class="product-name">${p.name}</h4>
        <p class="product-desc">${p.description}</p>
        <div class="stock-tag ${p.stock < 5 ? 'low' : ''}">
          ${p.stock > 0 ? `Tồn kho: ${p.stock} sản phẩm` : 'Hết hàng'}
        </div>
        <div class="product-card-footer">
          <div class="product-price-box">
            <span class="product-price-label">Giá niêm yết</span>
            <span class="product-price">${formatVND(p.price)}</span>
          </div>
          <button class="btn-add-cart" onclick="addToCart(${p.id})" ${p.stock <= 0 ? 'disabled' : ''}>
            🛒 Thêm
          </button>
        </div>
      </div>
    </div>
  `).join('');
}

// Cart operations
function saveCart() {
  localStorage.setItem('electroshop_cart', JSON.stringify(cart));
  updateCartUI();
}

function addToCart(productId) {
  const product = allProducts.find(p => p.id === productId);
  if (!product) return;

  const existing = cart.find(item => item.product_id === productId);
  if (existing) {
    if (existing.quantity >= product.stock) {
      showToast(`Số lượng trong giỏ đã đạt mức tối đa trong kho (${product.stock})`, 'error');
      return;
    }
    existing.quantity += 1;
  } else {
    cart.push({
      product_id: product.id,
      name: product.name,
      price: Number(product.price),
      image_url: product.image_url,
      quantity: 1,
      stock: product.stock
    });
  }

  saveCart();
  showToast(`Đã thêm "${product.name}" vào giỏ hàng!`);
}

function updateCartQty(productId, delta) {
  const item = cart.find(i => i.product_id === productId);
  if (!item) return;

  item.quantity += delta;
  if (item.quantity <= 0) {
    cart = cart.filter(i => i.product_id !== productId);
  }
  saveCart();
}

function removeFromCart(productId) {
  cart = cart.filter(i => i.product_id !== productId);
  saveCart();
}

function updateCartUI() {
  const countEl = document.getElementById('cartCount');
  const container = document.getElementById('cartItemsContainer');
  const totalEl = document.getElementById('cartTotalPrice');
  const checkoutBtn = document.getElementById('btnOpenCheckout');

  const totalCount = cart.reduce((sum, i) => sum + i.quantity, 0);
  const totalPrice = cart.reduce((sum, i) => sum + (i.price * i.quantity), 0);

  countEl.textContent = totalCount;
  totalEl.textContent = formatVND(totalPrice);

  if (cart.length === 0) {
    container.innerHTML = '<div style="text-align: center; color: #94a3b8; padding: 2rem;">Giỏ hàng của bạn đang trống.</div>';
    checkoutBtn.disabled = true;
    return;
  }

  checkoutBtn.disabled = false;
  container.innerHTML = cart.map(item => `
    <div class="cart-item">
      <img class="cart-item-img" src="${item.image_url}" alt="${item.name}">
      <div class="cart-item-info">
        <div class="cart-item-name">${item.name}</div>
        <div class="cart-item-price">${formatVND(item.price)}</div>
      </div>
      <div class="cart-item-actions">
        <button class="btn-qty" onclick="updateCartQty(${item.product_id}, -1)">-</button>
        <span style="font-weight: 700; min-width: 20px; text-align: center;">${item.quantity}</span>
        <button class="btn-qty" onclick="updateCartQty(${item.product_id}, 1)">+</button>
        <button class="btn-remove-item" onclick="removeFromCart(${item.product_id})" title="Xóa">&times;</button>
      </div>
    </div>
  `).join('');
}

// Health check status
async function checkHealth() {
  const statusEl = document.getElementById('systemStatus');
  try {
    const res = await fetch('/health');
    const data = await res.json();
    if (data.status === 'UP') {
      statusEl.className = 'system-status online';
      statusEl.querySelector('.status-label').textContent = 'Hệ thống & DB Sẵn sàng';
    } else {
      statusEl.className = 'system-status';
      statusEl.querySelector('.status-label').textContent = 'DB Chưa kết nối';
    }
  } catch (err) {
    statusEl.className = 'system-status';
    statusEl.querySelector('.status-label').textContent = 'API Mất kết nối';
  }
}

// Modal handling
const cartModal = document.getElementById('cartModal');
const checkoutModal = document.getElementById('checkoutModal');
const ordersModal = document.getElementById('ordersModal');

document.getElementById('btnOpenCart').addEventListener('click', () => {
  cartModal.classList.add('active');
});

document.getElementById('btnCloseCart').addEventListener('click', () => {
  cartModal.classList.remove('active');
});

document.getElementById('btnOpenCheckout').addEventListener('click', () => {
  if (cart.length === 0) return;
  cartModal.classList.remove('active');

  const totalCount = cart.reduce((sum, i) => sum + i.quantity, 0);
  const totalPrice = cart.reduce((sum, i) => sum + (i.price * i.quantity), 0);

  document.getElementById('summaryItemCount').textContent = totalCount;
  document.getElementById('summaryTotalAmount').textContent = formatVND(totalPrice);
  checkoutModal.classList.add('active');
});

document.getElementById('btnCloseCheckout').addEventListener('click', () => {
  checkoutModal.classList.remove('active');
});

document.getElementById('btnCancelCheckout').addEventListener('click', () => {
  checkoutModal.classList.remove('active');
});

// Checkout submit (Calls POST /checkout as required)
document.getElementById('checkoutForm').addEventListener('submit', async (e) => {
  e.preventDefault();
  const submitBtn = document.getElementById('btnSubmitOrder');
  submitBtn.disabled = true;
  submitBtn.textContent = 'Đang xử lý đơn hàng...';

  const formData = new FormData(e.target);
  const payload = {
    customer_name: formData.get('customer_name'),
    customer_email: formData.get('customer_email'),
    customer_phone: formData.get('customer_phone'),
    shipping_address: formData.get('shipping_address'),
    items: cart.map(i => ({ product_id: i.product_id, quantity: i.quantity }))
  };

  try {
    const res = await fetch('/checkout', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });

    const data = await res.json();
    if (res.ok && data.success) {
      showToast(`🎉 Đặt hàng thành công! Mã đơn: #${data.order_id}`, 'success');
      cart = [];
      saveCart();
      checkoutModal.classList.remove('active');
      loadProducts(); // Reload stock
    } else {
      showToast(`Lỗi đặt hàng: ${data.error || 'Thao tác không thành công'}`, 'error');
    }
  } catch (err) {
    showToast(`Lỗi mạng: ${err.message}`, 'error');
  } finally {
    submitBtn.disabled = false;
    submitBtn.textContent = 'Xác Nhận Đặt Hàng (POST /checkout)';
  }
});

// View orders
document.getElementById('btnViewOrders').addEventListener('click', async () => {
  ordersModal.classList.add('active');
  const container = document.getElementById('ordersListContainer');
  container.innerHTML = '<div class="loading-spinner">Đang tải danh sách đơn hàng...</div>';

  try {
    const res = await fetch('/api/orders');
    const data = await res.json();
    if (data.success && data.data.length > 0) {
      container.innerHTML = `
        <table class="orders-table">
          <thead>
            <tr>
              <th>Mã Đơn</th>
              <th>Khách Hàng</th>
              <th>Điện Thoại</th>
              <th>Tổng Tiền</th>
              <th>Trạng Thái</th>
              <th>Thời Gian</th>
            </tr>
          </thead>
          <tbody>
            ${data.data.map(o => `
              <tr>
                <td><strong>#${o.id}</strong></td>
                <td>${o.customer_name}</td>
                <td>${o.customer_phone || '-'}</td>
                <td><strong>${formatVND(o.total_amount)}</strong></td>
                <td><span class="order-status-badge">${o.status}</span></td>
                <td>${new Date(o.created_at).toLocaleString('vi-VN')}</td>
              </tr>
            `).join('')}
          </tbody>
        </table>
      `;
    } else {
      container.innerHTML = '<div style="text-align: center; color: #94a3b8; padding: 2rem;">Chưa có đơn hàng nào trong hệ thống. Hãy thực hiện đặt hàng thử!</div>';
    }
  } catch (err) {
    container.innerHTML = `<div class="loading-spinner">Lỗi khi tải đơn hàng: ${err.message}</div>`;
  }
});

document.getElementById('btnCloseOrders').addEventListener('click', () => {
  ordersModal.classList.remove('active');
});

// Category filtering
document.querySelectorAll('.filter-btn').forEach(btn => {
  btn.addEventListener('click', () => {
    document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    activeCategory = btn.getAttribute('data-category');
    renderProducts();
  });
});

// Live Search
document.getElementById('searchInput').addEventListener('input', () => {
  renderProducts();
});

// Initialization
document.addEventListener('DOMContentLoaded', () => {
  loadProducts();
  updateCartUI();
  checkHealth();
  setInterval(checkHealth, 10000);
});
