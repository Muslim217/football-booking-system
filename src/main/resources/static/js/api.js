const API_BASE = '/api';

// ===== Auth helpers =====
function getToken() {
    return localStorage.getItem('jwt_token');
}

function getUser() {
    const data = localStorage.getItem('user');
    return data ? JSON.parse(data) : null;
}

function saveAuth(data) {
    localStorage.setItem('jwt_token', data.token);
    localStorage.setItem('user', JSON.stringify({ username: data.username, role: data.role }));
}

function logout() {
    localStorage.removeItem('jwt_token');
    localStorage.removeItem('user');
    window.location.href = '/login.html';
}

function isLoggedIn() {
    return !!getToken();
}

function isAdmin() {
    const user = getUser();
    return user && user.role === 'ADMIN';
}

function isOwner() {
    const user = getUser();
    return user && user.role === 'OWNER';
}

// ===== Fetch wrapper =====
async function apiFetch(url, options = {}) {
    const token = getToken();
    const headers = { 'Content-Type': 'application/json', ...options.headers };
    if (token) {
        headers['Authorization'] = 'Bearer ' + token;
    }

    const response = await fetch(API_BASE + url, { ...options, headers });

    if (response.status === 401) {
        logout();
        return null;
    }

    return response;
}

// ===== Update navbar based on auth state =====
function updateNavbar() {
    const navAuth = document.getElementById('nav-auth');
    if (!navAuth) return;

    if (isLoggedIn()) {
        const user = getUser();
        let extraLinks = '';
        if (isOwner()) {
            extraLinks = '<li class="nav-item"><a class="nav-link" href="/owner.html">Мои поля</a></li>';
        }
        if (isAdmin()) {
            extraLinks = '<li class="nav-item"><a class="nav-link" href="/admin.html">Админ-панель</a></li>';
        }
        const bookingsLink = (user.role === 'USER' || user.role === 'ADMIN')
            ? '<li class="nav-item"><a class="nav-link" href="/bookings.html">Мои бронирования</a></li>'
            : '';

        const roleBadge = user.role === 'OWNER' ? 'Владелец' : (user.role === 'ADMIN' ? 'Админ' : 'Клиент');

        navAuth.innerHTML = `
            ${extraLinks}
            ${bookingsLink}
            <li class="nav-item">
                <span class="nav-link text-light">${user.username} <small class="badge bg-secondary">${roleBadge}</small></span>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="#" onclick="logout()">Выйти</a>
            </li>
        `;
    } else {
        navAuth.innerHTML = `
            <li class="nav-item"><a class="nav-link" href="/login.html">Войти</a></li>
            <li class="nav-item"><a class="nav-link" href="/register.html">Регистрация</a></li>
        `;
    }
}

// Format datetime for display
function formatDateTime(dt) {
    if (!dt) return '—';
    const d = new Date(dt);
    return d.toLocaleString('ru-RU', {
        day: '2-digit', month: '2-digit', year: 'numeric',
        hour: '2-digit', minute: '2-digit'
    });
}

// Format price
function formatPrice(price) {
    return Number(price).toLocaleString('ru-RU') + ' ₽';
}

// Status badge
function statusBadge(status) {
    const map = {
        'CONFIRMED': '<span class="badge bg-success">Подтверждено</span>',
        'PENDING': '<span class="badge bg-warning text-dark">Ожидание</span>',
        'CANCELLED': '<span class="badge bg-danger">Отменено</span>'
    };
    return map[status] || status;
}

// Field type label
function fieldTypeLabel(type) {
    return type === 'INDOOR' ? 'Крытое' : 'Открытое';
}

document.addEventListener('DOMContentLoaded', updateNavbar);
