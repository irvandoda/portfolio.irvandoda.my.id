# 🎨 Portfolio Library - Irvandoda

<div align="center">

![Portfolio Library](https://img.shields.io/badge/Portfolio-Library-purple?style=for-the-badge)
![Projects](https://img.shields.io/badge/Projects-100%2B-blue?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Active-success?style=for-the-badge)

**Kumpulan 100+ Landing Page Projects yang telah dibuat dengan desain modern dan responsif**

[🌐 Live Website](https://portfolio.irvandoda.my.id) • [📧 Email](mailto:irvando.d.a@gmail.com) • [💬 WhatsApp](https://wa.me/6285747476308)

</div>

---

## 📋 Tentang Project

Portfolio Library adalah koleksi lengkap **100+ landing page projects** yang mencakup berbagai kategori bisnis dan industri. Setiap landing page dirancang menggunakan teknologi modern seperti **HTML5**, **Tailwind CSS**, dan **React** dengan build tool **Vite** untuk memberikan pengalaman pengguna yang optimal.

## Progress & Checkpoints

### 2026-03-11
- GitHub repository connected and latest code pulled
- Dockerfile updated for React + Vite build (using dist/ folder)
- Production build completed successfully
- Docker container rebuilt and deployed on port 3024
- Container running and verified (HTTP 200 OK)
- Website accessible at https://portfolio.irvandoda.my.id
- Fixed LP folder access: Added LP/ directory copy to Dockerfile
- All 100+ landing pages now accessible (e.g., /LP/kedaikopi.html)

### Previous Updates
- **Scan & Cleanup**: File script `.py` dan dokumen `.md` yang tidak terpakai telah dibersihkan untuk optimalisasi dan kerapian repositori
- **SSL Certificate Fixed**: Konfigurasi Nginx telah diperbarui, memastikan sertifikat SSL termuat dengan baik dan memperbaiki error `net::ERR_CERT_COMMON_NAME_INVALID` saat website diakses

---

## Bug Fix Log

### 2026-03-11
**Bug**: 404 Not Found saat akses https://portfolio.irvandoda.my.id/LP/kedaikopi.html dan semua landing pages di folder LP/

**Cause**: Dockerfile hanya copy folder `dist/` tanpa include folder `LP/` yang berisi 100+ landing pages

**Fix**: Update Dockerfile untuk copy folder `LP/` ke container, rebuild dan redeploy. Semua landing pages sekarang accessible

---

## 🏗️ Arsitektur & Teknologi

- **Frontend**: React 18, Vite, Tailwind CSS 3.4
- **Asset / Landing Pages**: 100+ static HTML landing pages di dalam direktori `/LP/`
- **Hosting / Proxy**: Nginx Web Server dengan Let's Encrypt SSL

## 📁 Struktur Project

```text
portfolio.irvandoda.my.id/
├── dist/            # Production build untuk UI React utama
├── src/             # Source code komponen React
├── LP/              # Direktori berisi 100+ landing page HTML files
└── index.html       # Entry point Vite dev server
```

## 🚀 Deployment

### Server Configuration
- **Domain**: portfolio.irvandoda.my.id
- **Container Port**: 3024
- **SSL**: Let's Encrypt (Auto-renewal via Certbot)
- **Reverse Proxy**: Nginx on host

### Deploy Steps
```bash
# Build production
npm run build

# Deploy container
docker compose down
docker compose build
docker compose up -d

# Verify
docker ps | grep portfolio
curl -I http://localhost:3024
```

---

## 🚀 Instalasi & Development

```bash
# Clone the repository
git clone https://github.com/irvandoda/portfolio.git
cd portfolio

# Install dependencies  
npm install

# Run dev server
npm run dev

# Build for production
npm run build
```

---

<div align="center">
Made with ❤️ by Irvando Demas Arifiandani
</div>
