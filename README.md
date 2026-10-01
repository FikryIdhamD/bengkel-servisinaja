# PitStop by Servisin Aja — Multi-Vehicle Booking Mobile App

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![State Management](https://img.shields.io/badge/State_Management-Riverpod-blue)](https://riverpod.dev)
[![Backend](https://img.shields.io/badge/Backend-Supabase-3ECF8E?logo=supabase)](https://supabase.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Aplikasi mobile berbasis Flutter yang dikembangkan sebagai solusi untuk **Technical & UI/UX Assessment** posisi **Mobile Developer & UI/UX Designer** di **PT Karya Putra Wardjito (Servisin Aja)**.

Aplikasi ini mengatasi tantangan utama (*Product Design Challenge*) pada aplikasi purna jual servis motor konvensional (seperti MotorkuX yang umumnya hanya mengizinkan 1 motor per transaksi) dengan menghadirkan solusi inovatif **Multi-Vehicle Booking in One Flow**.

---

## 🎯 Solusi 4 Tantangan Utama (Core UI/UX Challenge)

1. **Multi-Vehicle Selection & Management**  
   Pengguna dapat memilih lebih dari satu kendaraan (misal: Motor A dan Motor B) sekaligus dalam satu keranjang pemesanan. Dilengkapi fitur penambahan unit motor baru secara instan (*modal sheet*) tanpa perlu meninggalkan alur pemesanan.
2. **Keluhan & Servis Spesifik per Unit**  
   Konfigurasi kebutuhan terpisah per kendaraan menggunakan *Sticky Unit Switcher Tab*. Pengguna dapat memilih jenis paket servis, opsi suku cadang/pelumas, dan menuliskan catatan keluhan/kerusakan yang berbeda untuk tiap unit motor secara independen tanpa menimbulkan *form fatigue*.
3. **Jadwal & Form Booking Terpadu**  
   Penentuan 1 lokasi cabang bengkel resmi Servisin Aja dan 1 slot waktu kedatangan terpadu yang berlaku untuk seluruh unit, dilengkapi penomoran antrean pit servis otomatis berurutan (misal: Unit 1 Pit #01, Unit 2 Pit #02) serta kalkulasi akumulatif total durasi dan estimasi biaya.
4. **Tiket Konfirmasi & Status Pelacakan Real-Time**  
   Tiket digital terpadu dengan Kode Booking unik (`#PSA-YYYYMMDD-XXX`), QR Code check-in, dan pelacakan progres pengerjaan bertingkat (*4-stage stepper*) per unit motor yang sinkron secara reaktif menggunakan **Supabase Realtime**.

---

## ⚠️ Panduan Khusus Penguji / Evaluator (PENTING)

Bagi tim penilai dan penguji teknis yang menguji fungsionalitas aplikasi, mohon perhatikan beberapa hal berikut:

### 1. Auto-Generate 2 Kendaraan Default saat Pendaftaran (Register)
* Saat Anda membuat akun baru melalui menu **Daftar / Registrasi**, sistem secara otomatis meng-generate **2 unit motor default** ke dalam garasi akun Anda:
  * **Honda Vario 160** (Plat: `B 1234 ABC`, Tahun: 2023)
  * **Yamaha NMAX 155** (Plat: `B 5678 XYZ`, Tahun: 2022)
* **Tujuan:** Memudahkan evaluator untuk **langsung menguji alur Multi-Vehicle Booking** tanpa harus menginput motor secara manual terlebih dahulu.  
* *Catatan:* Anda tetap dapat menambahkan kendaraan baru sendiri kapan saja melalui tombol **"+ Tambah Kendaraan Baru"** di Garasi maupun di tengah alur booking.

### 2. Tombol Dev Simulator (Simulasi Status Mekanik Real-Time)
* Pada halaman detail tiket & pelacakan servis (`/tracking/:id`), terdapat **Floating Action Button bertuliskan "Develop / Dev"** di pojok kanan bawah layar.
* **Fungsi:** Membuka *Dev Simulation Bottom Sheet* yang memungkinkan penguji memilih kendaraan dan memperbarui status pengerjaannya secara langsung di database Supabase:
  1. `Menunggu Antrean` *(Oranye)*
  2. `Sedang Dikerjakan` *(Biru)*
  3. `Pengecekan Akhir` *(Ungu)*
  4. `Selesai` *(Hijau)*
* **Tujuan:** Memvalidasi bahwa animasi dan stepper pelacakan per unit di aplikasi benar-benar **terbarui secara reaktif dan seketika (Real-Time)** via koneksi WebSocket Supabase tanpa perlu me-refresh halaman atau membuka portal backend admin bengkel.

### 3. Pemetaan Data Dinamis vs Data Dummy Statis
Untuk transparansi arsitektur sistem, berikut pembagian data pada aplikasi:

| Fitur / Modul | Status Data | Sumber & Keterangan |
| :--- | :--- | :--- |
| **Autentikasi & Akun** | **Dinamis** | Supabase Auth (Sign In, Sign Up, Session Cache). |
| **Garasi Kendaraan** | **Dinamis** | PostgreSQL Supabase (`vehicles`). CRUD tersimpan per pengguna. |
| **Transaksi Booking & Item** | **Dinamis** | PostgreSQL Supabase (`bookings`, `booking_vehicle_items`, `booking_item_parts`). |
| **Pelacakan Real-Time & Dev Tool** | **Dinamis** | Supabase Realtime Stream & pembaruan status unit via Dev Tool. |
| **Katalog Servis & Suku Cadang** | **Master In-Memory** | Disimpan terstruktur pada model Dart agar katalog selalu tersedia cepat & andal. |
| **Daftar Cabang Bengkel** | **Seed Data** | Data bengkel resmi Servisin Aja Jabodetabek (`dummy_workshops.dart`) dengan rating bintang dan ulasan. |
| **Banner Promosi & Edukasi** | **Statis Dummy** | Carousel banner promo di Beranda (`promo_carousel.dart`). |
| **Notifikasi Sistem** | **Statis Dummy** | Mock pemberitahuan servis dan promo (`dummy_notifications.dart`). |
| **Halaman Informasi Sekunder** | **Statis Dummy** | Pusat Bantuan, Kebijakan Privasi, dan Tentang Aplikasi pada menu Profil. |

---

## 📱 Struktur Navigasi & Ragam Layar (Bonus Points)

Aplikasi dibangun dengan arsitektur navigasi persisten **Bottom Navigation Bar & Center Docked FAB**:

```
[ SHELL NAVIGATION ]
├── 🏠 Beranda (/home)
│   ├── User Header & Status Verifikasi Akun
│   ├── Carousel Banner Promosi & Edukasi
│   ├── Seksi Garasi Ringkas (Quick Fleet)
│   ├── Seksi Bengkel Terdekat & Rating Ulasan
│   └── Notifikasi Masuk (/notifications)
├── 🛵 Garasi (/garage)
│   ├── Daftar Semua Kendaraan
│   ├── Modal Tambah Kendaraan Instan
│   └── Detail Kendaraan (/vehicle/:id) & Riwayat Servis
├── ➕ Center FAB Quick Booking (/vehicle-selection)
├── 🎟️ Tiket (/tickets)
│   ├── Tab Tiket Aktif & Riwayat Selesai
│   └── Akses Langsung ke Pelacakan Servis
└── 👤 Profil (/profile)
    ├── Informasi Identitas Pengguna
    ├── Status Verifikasi Nomor HP (+62 OTP)
    ├── Pusat Bantuan (/profile/help)
    ├── Kebijakan Privasi (/profile/privacy)
    └── Tentang Servisin Aja (/profile/about)

[ ALUR TRANSAKSI MULTI-VEHICLE BOOKING ]
1. Seleksi Multi-Kendaraan (/vehicle-selection)
2. Konfigurasi Servis, Suku Cadang & Keluhan per Unit (/service-configuration)
3. Jadwal Kedatangan, Cabang Bengkel & Antrean Pit (/schedule)
4. Ringkasan Biaya & Checkout (/summary-checkout)
5. Tiket Digital & Pelacakan Status Real-Time (/tracking/:id)
   └── Dev Simulation Bottom Sheet (Realtime State Switcher)
```

---

## 🛠️ Panduan Instalasi & Menjalankan Proyek Secara Lokal

### Prasyarat Sistem
- **Flutter SDK:** Versi `3.24.x` atau lebih baru
- **Dart SDK:** Versi `3.5.x` atau lebih baru
- **Android Studio / VS Code** dengan plugin Flutter & Dart
- **Java Development Kit (JDK):** Versi 17

### Langkah-Langkah Menjalankan

1. **Clone repositori:**
   ```bash
   git clone https://github.com/fikryidham/pitstop_servisinaja_app.git
   cd pitstop_servisinaja_app
   ```

2. **Konfigurasi Environment Variables (`.env`):**  
   Salin file template `.env.example` menjadi `.env`:
   ```bash
   cp .env.example .env
   ```
   *Catatan: File `.env` bawaan proyek sudah terisi kredensial anonim Supabase sandbox untuk keperluan evaluasi.*

3. **Unduh seluruh dependensi:**
   ```bash
   flutter pub get
   ```

4. **Jalankan pengujian unit & widget:**
   ```bash
   flutter test
   ```

5. **Jalankan aplikasi pada Emulator atau Device fisik:**
   ```bash
   flutter run
   ```

6. **Membangun installer APK Rilis (Siap Pasang):**
   ```bash
   flutter build apk --release
   ```
   *File output APK berada di:* `build/app/outputs/flutter-apk/app-release.apk`

---

## 📂 Arsitektur Kode Sumber (Clean Architecture)

Proyek mengadopsi arsitektur berbasis fitur (*Feature-First Clean Architecture*) untuk kemudahan pemeliharaan dan skalabilitas:

```
lib/
├── core/
│   ├── constants/       # Tokens warna (#FF6600), tipografi, aset, daftar negara
│   ├── data/            # Dummy seed data (workshops, notifications)
│   ├── models/          # Model data domain inti (Workshop, dsb.)
│   ├── network/         # Inisialisasi Supabase Client & environment loader
│   ├── routes/          # Konfigurasi deklaratif GoRouter & ShellRoute
│   ├── theme/           # Konfigurasi Material 3 Light Theme
│   └── widgets/         # Komponen UI umum (Button, TextField, Card, Switcher, dsb.)
├── features/
│   ├── auth/            # Splash, Login (Dual-Tab OTP & Password), Register
│   ├── garage/          # Manajemen armada, tambah motor, detail kendaraan
│   ├── booking/         # Alur 4 langkah pemesanan multi-kendaraan & checkout
│   ├── tracking/        # Tiket digital, pelacakan bertingkat, Dev Simulator
│   ├── home/            # Dashboard, promo carousel, main layout
│   └── profile/         # Profil pengguna, verifikasi telepon, halaman sekunder
└── main.dart            # Entry point aplikasi
```

---

## 🎨 Dokumen Desain & Penugasan

Dokumentasi lengkap perancangan arsitektur dan UI/UX tersimpan di direktori `assessment_docs/`:
- **`assessment_docs/PRD.md`:** *Product Requirement Document* mencakup latar belakang, batasan MVP, spesifikasi fungsional 4 pilar, skema database PostgreSQL, dan kriteria penerimaan.
- **`assessment_docs/Design.md`:** Panduan *Design System*, token warna resmi Servisin Aja, skala tipografi, sistem elevasi, pustaka komponen, serta spesifikasi detail tiap layar.

---

## 📋 Tautan Pengumpulan Penugasan

- **Figma File:** [Tautan Desain Figma (Anyone with the link can view)] *(Sesuai tautan publik yang dikumpulkan)*
- **GitHub Repository:** [https://github.com/fikryidham/pitstop_servisinaja_app](https://github.com/fikryidham/pitstop_servisinaja_app)
- **Installer APK Siap Pasang:** Disertakan melalui Google Drive / GitHub Releases.
- **Log AI / Riwayat Chat:** Disertakan sesuai kebijakan integritas pengerjaan penugasan.
